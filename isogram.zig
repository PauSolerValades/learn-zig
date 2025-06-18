// crea un programa que detecti si una paraula és un isograma
// Isograma: frase o paraula que no té cap lletra repetida.

// Strings en Zig són single item pointers to null terminated byte arrays. osigui, com en C :D
const std = @import("std");
const print = @import("std").debug.print;

pub fn main() void {

    const paraula = "isograms";
    const resultat: bool = is_isogram(paraula);
    print("{s}{s}és un isograma", .{paraula, if (resultat) " " else " no "});
}

// els strings són llistes de uft-8 per defecte
// tot i que a low level siguin null terminated byte arrays, 
// la implementació és en una slice (com tot llenguatge modern)
fn is_isogram(sentence: []const u8) bool {
    var seen = [_]bool{false} ** 26; // inicialitzia el valor de tota la llista a false

    for (sentence) |letter| {
        //compute the value in ascii 
        const i = letter - 'a';
        // és brutal, si no li dius res al print, ell infereix que és l'ascii associat als
        // caràcters. Si li dius que vols un caracter, ell ho printeja com un caracter 
        print("Lletra {c} amb ascii {}. Index de la llista: {d}\n", .{letter, letter, i});
         
        if (seen[i]) {
            return false;
        } 
        seen[i] = true;
         
    }

    return true;
}
