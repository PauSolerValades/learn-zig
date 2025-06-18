const std = @import("std");

// This code won't compile if `main` isn't `pub` (public)
pub fn main() void {
	const user = User{
		.power = 9001,
		.name = "Goku",
	};

	std.debug.print("{s}'s power is {d}\n", .{user.name, user.power});

	//const a = [5]i32{1, 2, 3, 4, 5};

    // we already saw this .{...} syntax with structs
    // it works with arrays too
    const b: [5]i32 = .{1, 2, 3, 4, 5};

    // use _ to let the compiler infer the length
    const c = [_]i32{1, 2, 3, 4, 5};

    std.debug.print("{d}", c == b);
}

pub const User = struct {
	power: u64,
	name: []const u8,
};
