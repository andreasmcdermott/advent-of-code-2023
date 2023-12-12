const std = @import("std");
const h = @import("./helpers.zig");

const print = std.debug.print;

pub fn run() !void {
    var alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer alloc.deinit();

    // try part1(alloc.allocator());
    try part2(alloc.allocator());
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

const Race2 = struct { time: u64 = 0, minDistance: u64 = 0 };

fn part2(allocator: std.mem.Allocator) !void {
    var val: u64 = 0;

    var it = try h.iterate_file_by_line(allocator, "06");

    var race: Race2 = Race2{};

    while (it.next()) |line| {
        var output = try allocator.dupe(u8, line);
        var i: usize = 0;

        for (line[0..]) |c| {
            if (c >= '0' and c <= '9') {
                output[i] = c;
                i += 1;
            }
        }

        var num = h.to_u64(output[0..i]) orelse 0;

        if (race.time == 0) {
            race.time = num;
        } else {
            race.minDistance = num;
            break;
        }
    }

    var ms: u64 = 0;

    var min: u64 = 0;
    var max: u64 = 0;

    while (ms <= race.time and (min == 0 or max == 0)) {
        var dist: u64 = ms * (race.time - ms);
        if (dist > race.minDistance) {
            min = ms;
        }

        dist = (race.time - ms) * ms;
        if (dist > race.minDistance) {
            max = race.time - ms;
        }

        ms += 1;
    }

    val = max - min + 1;

    print("{}\n", .{val});
}
