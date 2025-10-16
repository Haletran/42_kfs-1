const v = @import("variables.zig");
const std = @import("std");
const utils = @import("utils.zig");

const VGA_WIDTH = v.VGA_WIDTH;
const VGA_HEIGHT = v.VGA_HEIGHT;
const vga_color = v.vga_color;
const keymaps_not_shifted = v.keymaps_not_shifted;
const keymaps_shifted = v.keymaps_shifted;
const SHIFT_PRESSED = v.SHIFT_PRESSED;
const SHIFT_RELEASED = v.SHIFT_RELEASED;
const DELETE_KEY = v.DELETE_KEY;
const PAGE_DOWN = 0x51;
const PAGE_UP = 0x49;
const CTRL_PRESSED = 0x1D;
const CTRL_RELEASED = 0x9D;
const L_KEY = 0x26;
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

// dummy scroll since it doesn't keep track of old character so really really dumb but allow for infinite text row
fn scroll_down(page_key: bool) void {
    if ((v.terminal_row >= VGA_HEIGHT) or page_key == true) {
        for (0..(VGA_HEIGHT - 1)) |y| {
            for (0..VGA_WIDTH) |x| {
                const from_index: usize = (y + 1) * VGA_WIDTH + x;
                const to_index: usize = y * VGA_WIDTH + x;
                v.buffer[to_index] = v.buffer[from_index];
            }
        }
        // clear the last line
        const last_line_start: usize = (VGA_HEIGHT - 1) * VGA_WIDTH;
        for (0..VGA_WIDTH) |x| {
            v.buffer[last_line_start + x] = utils.vga_entry(' ', v.terminal_color);
        }
        v.terminal_row = VGA_HEIGHT - 1;
    }
}

fn scroll_up(page_key: bool) void {
    if (page_key == true) {
        utils.put_string("GO UP MAN\n");
    }
}

fn delete_character(base_position: usize) void {
    // delete last character
    if (v.character_position > 0) {
        v.character_position -= 1;
        utils.putchar(' ', base_position + v.character_position);
        utils.moveCursor(@intCast(v.character_position), @intCast(v.terminal_row));
    }
    // delete the last character of the previous line if there position pos,0 so goback to the last line to delete
    else if (v.character_position == 0 and v.terminal_row >= 1) {
        v.terminal_row -= 1;
        v.character_position = VGA_WIDTH - 1;
        const new_base_position: usize = v.terminal_row * VGA_WIDTH;
        utils.putchar(' ', new_base_position + v.character_position);
        utils.moveCursor(@intCast(v.character_position), @intCast(v.terminal_row));
    }
}

fn add_character(base_position: usize, scancode: u8) void {
    const c: u8 = utils.getKey(scancode);
    if (c != 0) {
        utils.putchar(c, v.character_position + base_position);
        if (c != '\n') {
            v.character_position += 1;
        }
        if (v.character_position >= VGA_WIDTH) {
            v.terminal_row += 1;
            v.character_position = 0;
        }
        utils.moveCursor(@intCast(v.character_position), @intCast(v.terminal_row));
    }
}

fn render_input() void {
    const scancode: u8 = utils.scankey();
    const base_position: usize = v.terminal_row * VGA_WIDTH;

    switch (scancode) {
        SHIFT_PRESSED => v.shift = true,
        SHIFT_RELEASED => v.shift = false,
        CTRL_PRESSED => v.ctrl = true,
        CTRL_RELEASED => v.ctrl = false,
        PAGE_DOWN => scroll_down(true),
        PAGE_UP => scroll_up(true),
        L_KEY => {
            if (v.ctrl) {
                init_term();
                v.terminal_row = 0;
                v.character_position = 0;
                utils.moveCursor(0, 0);
            } else {
                add_character(base_position, L_KEY);
            }
        },
        else => {
            if (scancode < keymaps_not_shifted.len or scancode < keymaps_shifted.len) {
                if (scancode == DELETE_KEY) {
                    delete_character(base_position);
                } else {
                    add_character(base_position, scancode);
                }
            }
        },
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
    while (true) {
        render_input();
        scroll_down(false);
    }
}
