const std = @import("std");
const h = @import("./helpers.zig");

const print = std.debug.print;

pub fn run() !void {
    var alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer alloc.deinit();

    try part1(alloc.allocator());
    // try part2(alloc.allocator());
}

fn part1(allocator: std.mem.Allocator) !void {
    var val: i32 = 0;

    var it = try h.iterate_file_by_line(allocator, "00");

    while (it.next()) |line| {
        print("line: {s}\n", .{line});
    }

    print("{}\n", .{val});
}

fn part2(allocator: std.mem.Allocator) !void {
    var val: i32 = 0;

    var it = try h.iterate_file_by_line(allocator, "00");

    while (it.next()) |line| {
        print("line: {s}\n", .{line});
    }

    print("{}\n", .{val});
}
