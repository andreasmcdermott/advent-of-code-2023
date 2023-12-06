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

    var it = try h.iterate_file_by_line(allocator, "02");

    while (it.next()) |line| {
        var game = parse_line(line);
        if (game.id > 0 and game.r <= 12 and game.g <= 13 and game.b <= 14) {
            val += game.id;
        }
    }

    print("{}\n", .{val});
}

fn part2(allocator: std.mem.Allocator) !void {
    var val: i32 = 0;

    var it = try h.iterate_file_by_line(allocator, "02");

    while (it.next()) |line| {
        var game = parse_line(line);
        if (game.id > 0) {
            val += game.r * game.g * game.b;
        }
    }

    print("{}\n", .{val});
}

const Game = struct {
    id: i32 = 0,
    r: i32 = 0,
    g: i32 = 0,
    b: i32 = 0,
};

fn parse_line(line: []const u8) Game {
    var game = Game{};

    if (std.mem.indexOf(u8, line, ":")) |index| {
        game.id = std.fmt.parseInt(u8, line[5..index], 10) catch 0;

        var it = std.mem.splitAny(u8, line[index + 2 ..], "; ,");

        var lastValue: i32 = 0;
        while (it.next()) |part| {
            if (part.len == 0) continue;

            if (std.mem.eql(u8, part, "blue")) {
                if (lastValue > game.b) game.b = lastValue;
            } else if (std.mem.eql(u8, part, "green")) {
                if (lastValue > game.g) game.g = lastValue;
            } else if (std.mem.eql(u8, part, "red")) {
                if (lastValue > game.r) game.r = lastValue;
            } else {
                lastValue = std.fmt.parseInt(u8, part, 10) catch 0;
            }
        }
    }

    return game;
}
