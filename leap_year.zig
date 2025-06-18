const std = @import("std");
const print = std.debug.print; 

pub fn main() void {
    const y1: i16 = 2000;
    const resultat = is_leap(y1);
    print("{d}{s}és un any de traspàs", .{y1, if (resultat) " " else " no "});

}

fn is_leap(year: i16) bool {
    
    const div_4: bool = @mod(year, 4) == 0;
    const div_100: bool = @mod(year, 100) == 0;
    const div_400: bool = @mod(year, 400) == 0;

    return div_4 or (div_400 and div_100) or (div_4 and !div_100);
}

test is_leap {
    try std.testing.expect(is_leap(1998) == false);
    try std.testing.expect(is_leap(2000) == true);
    try std.testing.expect(is_leap(1900) == true);
    try std.testing.expect(is_leap(-2000) == true); 
}
