const v = @import("variables.zig");
const std = v.std;
const utils = @import("utils.zig");
const expectEqual = std.testing.expectEqual;

const VGA_WIDTH = v.VGA_WIDTH;
const vga_color = v.vga_color;

pub fn strlen(str: []const u8) usize {
    var len: usize = 0;

    while (len < str.len) {
        len += 1;
    }
    return len;
}

test "custom strlen" {
    try expectEqual(@as(usize, 5), strlen("hello"));
    try expectEqual(@as(usize, 0), strlen(""));
    try expectEqual(@as(usize, 11), strlen("hello-world"));
}

// merge bg and fg color (the bg need to be cast into u8 before doing the multiplication)
// 4bits + 4bits = 8bits -> 1 byte
pub inline fn vga_entry_color(bg: u4, fg: u4) u8 {
    return fg | (@as(u8, bg) * 16);
    //return fg | (@as(u8, bg) << 4);
}

test "merge_bg_fg" {
    try expectEqual(@as(u8, 22), vga_entry_color(@intFromEnum(vga_color.VGA_COLOR_BLUE), @intFromEnum(vga_color.VGA_COLOR_BROWN)));
    try expectEqual(@as(u8, 97), vga_entry_color(@intFromEnum(vga_color.VGA_COLOR_BROWN), @intFromEnum(vga_color.VGA_COLOR_BLUE)));
}

// merge the character and the color
// 8bits + 8bits = 16bits -> 2 bytes
pub inline fn vga_entry(c: u8, color: u8) u16 {
    return (@as(u16, c)) | (@as(u16, color) * 256);
}

test "merge_char_color" {
    try expectEqual(@as(u16, 0x4F41), vga_entry(@as(u8, 'A'), @as(u8, 79)));
    try expectEqual(@as(u16, 0x2041), vga_entry(@as(u8, 'A'), @as(u8, 32)));
}

pub fn putchar(c: u8, pos: usize) void {
    if (c == '\n') {
        v.terminal_row += 1;
        v.character_position = 0;
        return;
    }
    v.buffer[pos] = vga_entry(c, v.terminal_color);
}

pub fn put_string(str: []const u8) void {
    var pos: usize = 0;
    const len: usize = strlen(str);
    const base: usize = v.terminal_row * VGA_WIDTH;
    for (0..len) |i| {
        putchar(str[i], pos + base);
        pos += 1;
    }
}
