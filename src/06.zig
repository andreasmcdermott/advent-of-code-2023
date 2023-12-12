const std = @import("std");
const h = @import("./helpers.zig");

const print = std.debug.print;

pub fn run() !void {
    var alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer alloc.deinit();

    try part1(alloc.allocator());
    // try part2(alloc.allocator());
}

const Race = struct { time: u32 = 0, minDistance: u32 = 0 };

fn part1(allocator: std.mem.Allocator) !void {
    var val: u32 = 0;

    var list = std.ArrayList(Race).init(allocator);
    defer list.deinit();

    var it = try h.iterate_file_by_line(allocator, "06");
    var row: u32 = 0;

    while (it.next()) |line| {
        var raceIt = std.mem.splitAny(u8, line, " \t");
        var i: u32 = 0;

        while (raceIt.next()) |str| {
            if (std.mem.eql(u8, str, "Time:") or std.mem.eql(u8, str, "Distance:")) continue;

            var num = h.to_u32(str) orelse 0;

            if (num == 0) continue;

            if (row == 0) {
                try list.append(Race{ .time = num });
            } else {
                list.items[i].minDistance = num;
            }

            i += 1;
        }

        row += 1;
    }

    for (list.items) |item| {
        var ms: u32 = 0;

        var min: u32 = 0;
        var max: u32 = 0;

        while (ms <= item.time and (min == 0 or max == 0)) {
            var dist = calcDist(ms, item.time - ms);
            if (dist > item.minDistance) {
                min = ms;
            }

            dist = calcDist(item.time - ms, ms);
            if (dist > item.minDistance) {
                max = item.time - ms;
            }

            ms += 1;
        }

        if (val == 0) {
            val = max - min + 1;
        } else {
            val *= max - min + 1;
        }
    }

    print("{}\n", .{val});
}

fn calcDist(velocity: u32, travelTime: u32) u32 {
    return velocity * travelTime;
}

fn part2(allocator: std.mem.Allocator) !void {
    var val: u32 = 0;

    var it = try h.iterate_file_by_line(allocator, "00");

    while (it.next()) |line| {
        print("{s}\n", .{line});
    }

    print("{}\n", .{val});
}
