const std = @import("std");

pub fn main() !void {
    const input = "your_input_here";

    std.debug.print("{d}\n", .{find(input, 4)});
    std.debug.print("{d}\n", .{find(input, 14)});
}

pub fn isUnique(string: []const u8) bool {
    var tracker:u32 = 0;
    const one = @truncate(u32, 1);
    for (string[(0)..string.len]) |char| {
        const shift = @truncate(u5, char - 97);
        if (tracker & one << shift > 0) {
            return false;
        }

        tracker |= one << shift;
    }
    return true;
}

fn range(len: usize) []const void {
    return @as([*]void, undefined)[0..len];
}

pub fn find(string: []const u8, length: u32) u32 {
    for (range(string.len - length + 1)) |_, i| {
        if (isUnique(string[i..i+length])) {
            return @truncate(u32, i + length); 
        } 
    }

    return 0;
}