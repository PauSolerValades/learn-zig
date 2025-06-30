const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    const allocator = gpa.allocator();
    // això no és opcional, el gpa és molt específic amb el que fa 
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) @panic("ups");
    }

    const result: []const u8 = try raindrops(40, "", allocator);
    print("{s}\n", .{result});
    defer allocator.free(result);

    const result2 = raindrops_pure_comptime(40, "");
    print("{s}\n", .{result2});
}

fn raindrops(comptime n: i64, comptime base: []const u8, allocator: Allocator) ![]const u8 {
    var normal = base;

    const div_3 = @rem(n,3) == 0; 
    const div_5 = @rem(n,5) == 0;
    const div_7 = @rem(n,7) == 0;

    if (!(div_3 and div_5 and div_7)){
        return try std.fmt.allocPrint(allocator, "{d}", .{n}); 
    }

    if (div_3){
        normal = normal ++ "Pling";
    }

    if (div_5){
        normal = normal ++ "Plang";
    }

    if (div_7){
        normal = normal ++ "Plong";
    }

    return normal;
}

fn raindrops_pure_comptime(comptime n: i64, comptime base: []const u8) []const u8 {
    var result = base;

    const div_3 = @rem(n, 3) == 0;
    const div_5 = @rem(n, 5) == 0;
    const div_7 = @rem(n, 7) == 0;

    if (div_3){
        result = result ++ "Pling";
    }
    if (div_5){
        result = result ++ "Plang";
    }
    if (div_7) {
        result = result ++ "Plong";
    }


    if (result.len == 0) {
        // We can't use allocPrint, but we can use comptime formatting!
        return std.fmt.comptimePrint("{d}", .{n});
    } else {
        return result;
    }
}
