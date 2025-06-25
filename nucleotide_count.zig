const std = @import("std");
const print = std.debug.print;
const testing = std.testing;

const ADNError = error{
	InvalidCharacter,
};
 
pub fn main() !void {
	const chain: []const u8 = "AAAACCCCGGGGTTTT";
	const resultat = try count_nucleotides(chain);
	
	print("{any} de cada\n", .{resultat});
        
        _ = try count_nucleotids_hm(chain);
        
        
}

fn count_nucleotides(comptime chain: []const u8) error{InvalidCharacter}![4]u32 {
	print("Entra {s}\n", .{chain});
	var counter = [4]u32{0,0,0,0};
	var bit_chain: [chain.len]u2 = undefined;
	
	// convertim els strings en dos bits, ja que hi ha 4 grafies i 2^2 = 4 ergo u2
	for (0..,chain) |i, nuc| {
		switch (nuc) {
			'A' => bit_chain[i] = 0b00,
			'C' => bit_chain[i] = 0b01,
			'T' => bit_chain[i] = 0b10,
			'G' => bit_chain[i] = 0b11,
			else => return error.InvalidCharacter,
		}
	}
	
	for (bit_chain) |bnuc| {
		counter[bnuc] += 1;
	}	
	return counter;
}

fn count_nucleotids_hm(chain: []const u8) (error{InvalidCharacter} || error{OutOfMemory})!std.AutoHashMap(u8, u32) {
    print("Entra {s}\n", .{chain});
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    
    const allocator = arena.allocator();

    var counter = std.AutoHashMap(u8, u32).init(allocator);
    defer counter.deinit();

    try counter.put('A', 0);
    try counter.put('T', 0);
    try counter.put('G', 0);
    try counter.put('C', 0);

    // convertim els strings en dos bits, ja que hi ha 4 grafies i 2^2 = 4 ergo u2
    for (chain) |nuc| {
         if (counter.getPtr(nuc)) |value_ptr| {
            value_ptr.* += 1;
        } else {
            return error.InvalidCharacter;
        }        
    }
    var iter = counter.iterator();
    while (iter.next()) |entry| {
        std.debug.print("  {c} => {d},\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }

    return counter;

}
test "valid characters" {
	try testing.expectEqual([4]u32{4,4,4,4}, count_nucleotides("AAAACCCCTTTTGGGG"));
}
