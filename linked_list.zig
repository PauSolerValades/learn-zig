const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    // mira't el document dels allocators per l'explicació d'això
    // jo aquí he pensat: com que quan fas una llista el que vols son molts nodes
    // però exactament no saps quants, fas un arena allocator i va que xuta
    
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const ll = LinkedList(u16);
    var list = ll{}; //haig de cridar l'struct per a inicialitzar-la
                     
    const node1 = try allocator.create(ll.Node);
    node1.* = .{ .data = 100 }; // això és la sintaxi de crear una struct.
    const node2 = try allocator.create(ll.Node);
    node2.* = .{ .data = 102 }; // això és la sintaxi de crear una struct.
    

    list.push(node1);

    _ = list.pop();
    list.printList();
}

fn LinkedList(comptime T: type) type {
    return struct {
        
        pub const Node = struct {
            data: T,
            next: ?*Node = null, // si quelcom pot ser null, s'ha d'explicitar amb ? 
        };

        first: ?*Node = null,
        len: usize = 0,
        
        // contradictoriament, no s'ha de retornar cap error aquí
        // l'únic error que tindria sentit seria "OutOfMemory" i literalment
        // no passa, ja que el node es fa amb l'allocator fora de la llista
        pub fn push(self: *@This(), node: *Node) void {
            var iter: *(?*Node) = &self.first; //això és el primer node, o directament null
            
            // en zig, accedir a un struct el dereferencia directament, és adir
            // node.next === node.*.next
            // però, quan el punter pot ser null (?) això no pot passar, ja que 
            // zig espera que sàpigues que el node no és nul, i que especifiquis què ha
            // de passar sinó, ergo while (iter.next != null) és molt elegant, és il·legal en 
            while (iter.*) |n| { //n és iter sabent que no és null, ergo, un node segur (n)
                iter = &n.*.next;
            }
            // quan sabem que next és null, el primer node és realment null
            iter.* = node; 
            self.len += 1;
        }

        pub fn pop(self: *@This()) ?*Node {
            var current: *(?*Node) = &self.first; //això és el primer node, o directament null
            var previous: *(?*Node) = &self.first; 
            
            while (current.*) |n| { // la derreferència és important, ja que el que pot ser null és el node, no el punter.
                previous = current;
                current = &n.*.next;
            }

            if (previous.*) |prev| {
                prev.*.next = null;
                self.len -= 1;
                return current.*;
            } else {
                return null;
            }
        }

        pub fn printList(self: *@This()) void {
            var iter: ?*Node = self.first;

            for (0..self.len) |i| {
                print("Node {d} -> data {d}\n", .{i, iter.?.*.data});
                iter = iter.?.*.next; // saps segur que no és null perque tens la lenght, ergo ? i mai paniquejarà 
            }
        }
    };
    
}
