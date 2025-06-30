const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const talloc = std.testing.allocator;

pub fn main() !void {
    if(std.os.argv.len < 2)  {
        print("Invàlid nombre d'arguments\n", .{});
        return;
    }
    
    // QUÈ PASSA AQUÍ?
    // []const u8 és un fat pointer: {inici, longitud} de l'string
    // std.os.argv[1] és un C, és a dir, un punter al primer element de l'stack
    // la funció std.mem.span recorre la funció fins a trobar el \0, i crea l'slice de zig
    const input: []const u8 = std.mem.span(std.os.argv[1]);
    print("{s}\n", .{input});

    const raw_input = std.os.argv[1];
    
    var len: usize = 0;
    while (raw_input[len] != 0) { // '\0' is the integer 0
        len += 1;
    }

    const manual_input: []const u8 =  raw_input[0..len];

    print("{s}\n", .{if(std.mem.eql(u8, manual_input, input)) "yes" else "no"});
    
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator); 
    defer arena.deinit();
    const allocator = arena.allocator();

    const is_valid: bool = try valid_parenthesis(allocator, input);

    print("La cadena {s} {s} és valida\n", .{input, if(is_valid) "sí" else "no"}); 

    const is_valid_al: bool = try valid_parenthesis_arraylist(allocator, input);

    print("La cadena {s} {s} és valida\n", .{input, if(is_valid_al) "sí" else "no"});
}

// Aquesta aproximació és una exelsa demostració de la idea de descoplar els allocators 
// de la lògica: aquí puc instanciar un arena allocator i usar-lo amb una array list, 
// de manera que tinc "the best of both worlds":
//  - la memòria la tinc reservada des del princip amb una arena i a mesura que en necessito més
//      no necessito una syscall (és a dir, ni un realloc de tota la llista ni un malloc a lo linked list)
//  - tinc accés als elements que fan que la llista funcioni, que per a fer-ho així usant una arena, podria
//      seria molt més codi que aquest que hi ha aqui.
fn valid_parenthesis_arraylist(allocator: std.mem.Allocator, chain: []const u8) !bool {
    var stack = std.ArrayList(u8).init(allocator);
    defer stack.deinit();

    for(chain) |c| {
        switch (c) {
            '(' => try stack.append(')'),
            '[' => try stack.append(']'),
            '{' => try stack.append('}'),

            ')', ']', '}' => {
                // stack.pop() buit és null, seria correcte desempacar.
                if (stack.pop()) |cp| {
                    if (cp != c) return false;
                } else { // si és null ja està desequilibrat.
                    return false;
                }
            },
            else => continue,
        }
    }
    //és horrible que necessiti items per només trobar la len.   
    return stack.items.len == 0;
}

fn valid_parenthesis(allocator: std.mem.Allocator, chain: []const u8) !bool {
    
    var elements: usize = 0;
    var order: []u8 = try allocator.alloc(u8, 1);
    defer {
        if (order.len > 0) {
            allocator.free(order);
        }    
    }
    var last: *u8 = undefined;

    for(chain) |c| {
        if(c == '(' or c == '[' or c == '{') {
            elements += 1;
            order = try allocator.realloc(order, elements);
            // l'equivalència en C aquí seria fer aritmètica de punters!
            // La cosa és que no fa falta, ja que order és una array directament
            // i per tant tens tota la lògica que et fa falta! 
            last = &order[elements - 1]; 
            if(c == '(') last.* = ')'
            else if (c == '[') last.* = ']'
            else if (c == '{') last.* = '}';
        } else if (c == ')' or c == ']' or c == '}') {
            if (elements == 0) {
                return false; 
            } 
            
            if (last.* != c){
                return false; 
            }
                        
            order = try allocator.realloc(order, elements-1);
            
            elements -= 1;
            //l'últim element fa que surti de l'array...
            if (elements > 0) {
                last = &order[elements - 1];
            }
        } else {
            continue;
        }
        // això és unsafe behaviour, ull amb printejar, ja que arriba un moment 
        // que tot se'n va a la puta ja que last apunta a 
        //print("last: {c}\n", .{last.*}); 
        print("order: {s}\n", .{order});
    }
    print("Elements {d}\n", .{elements});
    return elements == 0;
    
}

test "valid arraylist" {
    
    try expect(try valid_parenthesis_arraylist(talloc, "()"));
    try expect(try valid_parenthesis_arraylist(talloc, "()[]{}"));
    try expect(try valid_parenthesis_arraylist(talloc, "{[]}"));
    try expect(try valid_parenthesis_arraylist(talloc, "()({[]})"));
}


test "valid" {
    
    try expect(try valid_parenthesis(talloc, "()"));
    try expect(try valid_parenthesis(talloc, "()[]{}"));
    try expect(try valid_parenthesis(talloc, "{[]}"));
    try expect(try valid_parenthesis(talloc, "()({[]})"));
}

test "missing arraylist" {
    // These strings are invalid because they are missing a closing or opening parenthesis.
    try expect(!(try valid_parenthesis_arraylist(talloc, "(")));
    try expect(!(try valid_parenthesis_arraylist(talloc, "{")));
    try expect(!(try valid_parenthesis_arraylist(talloc, "[()")));
    try expect(!(try valid_parenthesis_arraylist(talloc, ")")));
    try expect(!(try valid_parenthesis_arraylist(talloc, "())")));
}


test "missing" {
    // These strings are invalid because they are missing a closing or opening parenthesis.
    try expect(!(try valid_parenthesis(talloc, "(")));
    try expect(!(try valid_parenthesis(talloc, "{")));
    try expect(!(try valid_parenthesis(talloc, "[()")));
    try expect(!(try valid_parenthesis(talloc, ")")));
    try expect(!(try valid_parenthesis(talloc, "())")));
}


test "unbalanced arraylist" {
    // These strings are invalid because the parentheses are not balanced or correctly ordered.
    try expect(!(try valid_parenthesis_arraylist(talloc, "(]")));
    try expect(!(try valid_parenthesis_arraylist(talloc, "([)]")));
    try expect(!(try valid_parenthesis_arraylist(talloc, ")(()")));
    try expect(!(try valid_parenthesis_arraylist(talloc, "({)}")));
}

test "unbalanced" {
    // These strings are invalid because the parentheses are not balanced or correctly ordered.
    try expect(!(try valid_parenthesis(talloc, "(]")));
    try expect(!(try valid_parenthesis(talloc, "([)]")));
    try expect(!(try valid_parenthesis(talloc, ")(()")));
    try expect(!(try valid_parenthesis(talloc, "({)}")));
}

test "edge cases" {
    // These tests cover edge cases like empty strings and strings with other characters.
    try expect(try valid_parenthesis(talloc, ""));
    try expect(try valid_parenthesis(talloc, "a(b[c]d)e"));
    try expect(!(try valid_parenthesis(talloc, "a(b[c)d]e")));
    const long_string = "((((((((((()))))))))))";
    try expect(try valid_parenthesis(talloc, long_string)); }
