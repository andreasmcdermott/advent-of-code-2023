const std = @import("std");
const h = @import("./helpers.zig");

pub fn run() !void {
    try part1();
    try part2();
}

fn part1() !void {
    var val: i32 = 0;

    var alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer alloc.deinit();

    var it = try h.iterate_file_by_line(alloc.allocator(), "01_1");

    while (it.next()) |line| {
        val += try find_number_by_char(line);
    }

    std.debug.print("{}\n", .{val});
}

fn part2() !void {}

const EMPTY = ' ';

fn find_number_by_char(line: []const u8) !i32 {
    if (line.len == 0) {
        return 0;
    }

    var l: u64 = 0;
    var r: u64 = line.len - 1;

    var num = [2]u8{ EMPTY, EMPTY };

    while (l < line.len and r >= 0 and (num[0] == EMPTY or num[1] == EMPTY)) {
        if (num[0] == EMPTY) {
            if (is_digit(line[l])) {
                num[0] = (line[l]);
            } else {
                l += 1;
            }
        }

        if (num[1] == EMPTY) {
            if (is_digit(line[r])) {
                num[1] = (line[r]);
            } else if (r > 0) {
                r -= 1;
            }
        }
    }

    return try std.fmt.parseInt(i32, &num, 10);
}

fn is_digit(c: u8) bool {
    return (c >= '0' and c <= '9');
}
