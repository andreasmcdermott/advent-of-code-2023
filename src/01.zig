const std = @import("std");
const h = @import("./helpers.zig");

const print = std.debug.print;

pub fn run() !void {
    var alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer alloc.deinit();

    try part1(alloc.allocator());
    try part2(alloc.allocator());
}

fn part1(allocator: std.mem.Allocator) !void {
    var val: i32 = 0;

    var it = try h.iterate_file_by_line(allocator, "01");

    while (it.next()) |line| {
        val += try find_number_by_char(line);
    }

    print("{}\n", .{val});
}

fn part2(allocator: std.mem.Allocator) !void {
    var val: i32 = 0;

    var it = try h.iterate_file_by_line(allocator, "01");

    while (it.next()) |line| {
        val += try find_number_by_char_or_word(line);
    }

    print("{}\n", .{val});
}

const EMPTY = ' ';

fn find_number_by_char(line: []const u8) !i32 {
    if (line.len == 0) {
        return 0;
    }

    var i: u64 = 0;

    var num = [2]u8{ EMPTY, EMPTY };

    while (i < line.len and (num[0] == EMPTY or num[1] == EMPTY)) {
        if (num[0] == EMPTY) {
            if (is_digit(line[i])) {
                num[0] = line[i];
            }
        }

        if (num[1] == EMPTY) {
            var r = line.len - i - 1;

            if (is_digit(line[r])) {
                num[1] = line[r];
            }
        }

        i += 1;
    }

    return try std.fmt.parseInt(i32, &num, 10);
}

fn find_number_by_char_or_word(line: []const u8) !i32 {
    if (line.len == 0) {
        return 0;
    }

    var i: u64 = 0;

    var num = [2]u8{ EMPTY, EMPTY };

    while (i < line.len and (num[0] == EMPTY or num[1] == EMPTY)) {
        if (num[0] == EMPTY) {
            if (is_digit(line[i])) {
                num[0] = line[i];
            }

            var val = maybe_get_word(line, i);
            if (val != EMPTY) {
                num[0] = val;
            }
        }

        if (num[1] == EMPTY) {
            var j = line.len - i - 1;

            if (is_digit(line[j])) {
                num[1] = line[j];
            }

            var val = maybe_get_word(line, j);
            if (val != EMPTY) {
                num[1] = val;
            }
        }

        i += 1;
    }

    return try std.fmt.parseInt(i32, &num, 10);
}

const WORDS = [_][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };
const WORD_VALUES = [_]u8{ '1', '2', '3', '4', '5', '6', '7', '8', '9' };

fn maybe_get_word(str: []const u8, i: u64) u8 {
    for (WORDS, 0..) |word, index| {
        if (std.mem.startsWith(u8, str[i..], word)) {
            return WORD_VALUES[index];
        }
    }
    return EMPTY;
}

fn is_digit(c: u8) bool {
    return (c >= '0' and c <= '9');
}
