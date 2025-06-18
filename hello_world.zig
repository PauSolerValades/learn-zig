const std = @import("std");
// o per quelcom més tradicional pots donar-li l'àlias de print
const print = std.debug.print;

// aquesta és la manera marrana d'imprimir a lo debut. sinó sempre pots crear un "output" i 
// i escriure-hi l'scring formatat.

// perdefecte totes les funcions són privades! (la hostia):
pub fn main() void {
    std.debug.print("Hello, World!\n", .{});
    print("Hello World des de l'altre print\n", .{});

}

// la millor cosa del print és que, al contrari que printf, els valors 
// del print són comptime, i per tant, si tu fessis en C
// printf("%s", 2+2); -> es veuria malament
// en canvi en zig
// print("%s", .{2+2}) -> comptime error


