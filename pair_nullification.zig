const std = @import("std");

pub fn main() !void {
    const date: ?i32 = 10;
    const number: ?i32 = 42;

    // First check, then unwrap
    if (date != null and number != null) {
        // ✅ Both are available
        const d = date.?;
        const n = number.?;
        std.debug.print("Both are available: date = {d}, number = {d}\n", .{ d, n });
    } else if (date == null and number == null) {
        // ✅ Both are null
        std.debug.print("Both are null\n", .{});
    } else if (date != null) {
        // ✅ Only date is available
        const d = date.?;
        std.debug.print("Only date is available: {d}\n", .{d});
    } else {
        // ✅ Only number is available
        const n = number.?;
        std.debug.print("Only number is available: {d}\n", .{n});
    }
}
