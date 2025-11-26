const v = @import("variables.zig");
const std = @import("std");
const utils = @import("utils.zig");

const VGA_WIDTH = v.VGA_WIDTH;
const VGA_HEIGHT = v.VGA_HEIGHT;
const vga_color = v.vga_color;
const keymaps_not_shifted = v.keymaps_not_shifted;
const keymaps_shifted = v.keymaps_shifted;
const allocator = std.testing.allocator;

// color the fullscreen in the chosen terminal color
fn init_term() void {
    // here to change the terminal bg and fg color
    v.terminal_color = utils.vga_entry_color(@intFromEnum(vga_color.VGA_COLOR_BLACK), @intFromEnum(vga_color.VGA_COLOR_WHITE));
    for (0..VGA_HEIGHT) |y| {
        for (0..VGA_WIDTH) |x| {
            const index: usize = y * VGA_WIDTH + x;
            v.buffer[index] = utils.vga_entry(' ', v.terminal_color);
        }
    }
}

fn welcome_screen() void {
    utils.put_string(" _   ___ _______ \n");
    utils.put_string("| | |   |       |\n");
    utils.put_string("| |_|   |____   |\n");
    utils.put_string("|       |____|  |\n");
    utils.put_string("|___    | ______|\n");
    utils.put_string("    |   | |_____ \n");
    utils.put_string("    |___|_______|\n");
    utils.put_string("-> Bienvenue dans ce super kernel en zig :) <-\n\n");
}

export fn kernel_main() void {
    init_term();
    welcome_screen();
}
