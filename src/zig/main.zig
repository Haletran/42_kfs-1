const std = @import("std");
const expectEqual = std.testing.expectEqual;

const VGA_WIDTH = 80;
const VGA_HEIGHT = 25;
// RAM zone mapped to the screen, so
const VGA_MEMORY: usize = 0xb8000;
// buffer to modify the posistion to put the character to the screen ex : 0xB8004 2,0
// since each character is equal to 2 bytes (16bits) (byte 0 = ascii code - byte 1 = color 4bits bg and 4bits fg)
var buffer: [*]volatile u16 = @ptrFromInt(VGA_MEMORY);
var terminal_color: u8 = 0;
var terminal_row: usize = 0;
var terminal_column: usize = 0;
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;

// standard color palette from IBM computer
const vga_color = enum(u4) {
    VGA_COLOR_BLACK = 0,
    VGA_COLOR_BLUE = 1,
    VGA_COLOR_GREEN = 2,
    VGA_COLOR_CYAN = 3,
    VGA_COLOR_RED = 4,
    VGA_COLOR_MAGENTA = 5,
    VGA_COLOR_BROWN = 6,
    VGA_COLOR_LIGHT_GREY = 7,
    VGA_COLOR_DARK_GREY = 8,
    VGA_COLOR_LIGHT_BLUE = 9,
    VGA_COLOR_LIGHT_GREEN = 10,
    VGA_COLOR_LIGHT_CYAN = 11,
    VGA_COLOR_LIGHT_RED = 12,
    VGA_COLOR_LIGHT_MAGENTA = 13,
    VGA_COLOR_LIGHT_BROWN = 14,
    VGA_COLOR_WHITE = 15,
};

const keymap = [3]u8{ 'a', 'b', 'c' };

const keymaps = [_]u8{ 0, 0, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 0, 0, 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n', 0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`', 0, '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0, '*', 0, ' ', 0, 0, 0, 0, 0, 0 };

// custom strlen
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
inline fn vga_entry_color(bg: u4, fg: u4) u8 {
    return fg | (@as(u8, bg) * 16);
    //return fg | (@as(u8, bg) << 4);
}

test "merge_bg_fg" {
    try expectEqual(@as(u8, 22), vga_entry_color(@intFromEnum(vga_color.VGA_COLOR_BLUE), @intFromEnum(vga_color.VGA_COLOR_BROWN)));
    try expectEqual(@as(u8, 97), vga_entry_color(@intFromEnum(vga_color.VGA_COLOR_BROWN), @intFromEnum(vga_color.VGA_COLOR_BLUE)));
}

// merge the character and the color
// 8bits + 8bits = 16bits -> 2 bytes
inline fn vga_entry(c: u8, color: u8) u16 {
    return (@as(u16, c)) | (@as(u16, color) * 256);
}

test "merge_char_color" {
    try expectEqual(@as(u16, 0x4F41), vga_entry(@as(u8, 'A'), @as(u8, 79)));
    try expectEqual(@as(u16, 0x2041), vga_entry(@as(u8, 'A'), @as(u8, 32)));
}

// color the fullscreen in the chosen terminal color
fn init_term() void {
    terminal_color = vga_entry_color(@intFromEnum(vga_color.VGA_COLOR_LIGHT_MAGENTA), @intFromEnum(vga_color.VGA_COLOR_BLACK));
    for (0..VGA_HEIGHT) |y| {
        for (0..VGA_WIDTH) |x| {
            const index: usize = y * VGA_WIDTH + x;
            buffer[index] = vga_entry(' ', terminal_color);
        }
    }
}

// string (color and str)
// putstr -> putchar (one character by one)
// global terminal color
// how to set the position ?? The render is column and row
var character_position: usize = 0;

fn putchar(c: u8, pos: usize) void {
    buffer[pos] = vga_entry(c, terminal_color);
}

fn put_string(str: []const u8) void {
    var pos: usize = 0;
    const len: usize = strlen(str);
    const base: usize = terminal_row * VGA_WIDTH;
    for (0..len) |i| {
        putchar(str[i], pos + base);
        pos += 1;
    }
}

// dont understand anything
pub fn inb(port: u16) u8 {
    return asm volatile ("inb %dx, %al"
        : [value] "={al}" (-> u8),
        : [port] "{dx}" (port),
    );
}

// get the scancode of the pressed key and return it
fn scankey() u8 {
    while (true) {
        if ((inb(0x64) & 0x1) != 0)
            return (inb(0x60));
    }
}

fn render_input() void {
    const scancode: u8 = scankey();
    if (scancode < keymaps.len) {
        const base_position: usize = terminal_row * VGA_WIDTH;
        if (scancode == 0x0E) {
            if (character_position > 0) {
                character_position -= 1;
                putchar(' ', base_position + character_position);
            }
        } else if (scancode == 28) {
            terminal_row += 1;
            putchar(' ', base_position + character_position);
            character_position = 0;
        } else {
            const c: u8 = keymaps[scancode];
            if (c != 0) {
                putchar(c, character_position + base_position);
                character_position += 1;
            }
        }
    }
}

export fn kernel_main() void {
    init_term();
    put_string("-> Bienvenue dans ce super kernel :) <-");
    terminal_row += 1;
    while (true) {
        render_input();
    }
}
