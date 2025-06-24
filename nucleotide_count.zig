const std = @import("std");
const print = std.debug.print;
const testing = std.testing;

const ADNError = error{
	InvalidCharacter,
};
 
pub fn main() !void {
	const chain: []const u8 = "AAAACCCCGGGGTrTTT";
	const resultat = try count_nucleotides(chain);
	
	print("{any} de cada\n", .{resultat});
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

test "valid characters" {
	try testing.expectEqual([4]u32{4,4,4,4}, count_nucleotides("AAAACCCCTTTTGGGG"));
}
