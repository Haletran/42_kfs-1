const std = @import("std");

pub const VGA_WIDTH = 80;
pub const VGA_HEIGHT = 25;
pub const SHIFT_PRESSED: usize = 0x2a;
pub const SHIFT_RELEASED: usize = 0xAA;
pub const DELETE_KEY: usize = 0x0E;
pub var shift = false;
// RAM zone mapped to the screen
pub const VGA_MEMORY: usize = 0xb8000;
// buffer to modify the posistion to put the character to the screen ex : 0xB8004 2,0
// since each character is equal to 2 bytes (16bits) (byte 0 = ascii code - byte 1 = color 4bits bg and 4bits fg)
pub var buffer: [*]volatile u16 = @ptrFromInt(VGA_MEMORY);
pub var terminal_color: u8 = 0;
pub var terminal_row: usize = 0;
pub var terminal_column: usize = 0;
pub var character_position: usize = 0;
pub const ArrayList = std.ArrayList;
pub const test_allocator = std.testing.allocator;

// standard color palette from IBM computer
pub const vga_color = enum(u4) {
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

pub const keymaps_not_shifted = [_]u8{ 0, 0, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 0, 0, 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n', 0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`', 0, '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0, '*', 0, ' ', 0, 0, 0, 0, 0, 0 };
pub const keymaps_shifted = [_]u8{ 0, 0, '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', 0, 0, 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '{', '}', '\n', 0, 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ':', '"', '~', 0, '|', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '<', '>', '?', 0, '*', 0, ' ', 0, 0, 0, 0, 0, 0 };
