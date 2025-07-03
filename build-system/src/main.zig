const std = @import("std");

pub fn main() !void {
    var buffer: [1024]u8 = undefined; 
    var stdout_writer = std.fs.File.stdout().writer(&buffer);
    const stdout = &stdout_writer.interface;

    try stdout.print("Hello, World!\n", .{});

    try stdout.flush();
}

