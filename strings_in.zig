const std = @import("std");
const c = @cImport({
    @cInclude("stdio.h");
});

pub fn main() !void {
    var buf: [32]u8 = undefined;

    c.read(0, &buf, 32);

    std.debug.print("{s}\n", .{buf});    
}
