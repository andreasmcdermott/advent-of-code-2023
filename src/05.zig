const std = @import("std");
const h = @import("./helpers.zig");

const print = std.debug.print;

pub fn run() !void {
    var alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer alloc.deinit();

    try part1(alloc.allocator());
    try part2(alloc.allocator());
}

const MapType = enum { none, seed, soil, fertilizer, water, light, temperature, humidity, location };
const Mapping = struct { src0: u64, dest0: u64, len: u64 };
const Map = struct { from: MapType = .none, to: MapType = .none, mappings: std.ArrayList(Mapping) = undefined };

fn part1(allocator: std.mem.Allocator) !void {
    var val: u64 = 0;

    var it = try h.iterate_file_by_line(allocator, "05");

    var seeds = std.ArrayList(u64).init(allocator);
    defer seeds.deinit();

    var maps = std.AutoHashMap(MapType, Map).init(allocator);
    parseSeeds(&seeds, &it);

    while (true) {
        if (parseMap(allocator, &it)) |map| {
            try maps.put(map.from, map);
        } else {
            break;
        }
    }

    for (seeds.items) |seed| {
        var loc = getLocation(seed, maps);
        if (val == 0 or loc < val) {
            val = loc;
        }
    }

    print("{}\n", .{val});
}

const SeedRange = struct { start: u64, len: u64 };

fn part2(allocator: std.mem.Allocator) !void {
    var val: u64 = 0;

    var it = try h.iterate_file_by_line(allocator, "05");

    var seedRanges = std.ArrayList(SeedRange).init(allocator);
    defer seedRanges.deinit();

    var maps = std.AutoHashMap(MapType, Map).init(allocator);
    parseSeeds2(&seedRanges, &it);

    while (true) {
        if (parseMap(allocator, &it)) |map| {
            try maps.put(map.from, map);
        } else {
            break;
        }
    }

    var mapType: MapType = .seed;

    while (mapType != .location and seedRanges.items.len > 0) {
        var map = maps.get(mapType) orelse unreachable;
        mapRanges(&seedRanges, map);
        mapType = map.to;
        // break;
    }

    for (seedRanges.items) |range| {
        if (val == 0 or range.start < val) {
            val = range.start;
        }
    }

    print("{}\n", .{val});
}

fn getLocation(seed: u64, maps: std.AutoHashMap(MapType, Map)) u64 {
    var next_value: u64 = seed;

    var from: MapType = .seed;

    while (from != .location) {
        var map = maps.get(from) orelse break;

        for (map.mappings.items) |mapping| {
            if (next_value < mapping.src0 or next_value > mapping.src0 + mapping.len - 1) continue;
            next_value = mapping.dest0 + (next_value - mapping.src0);
            break;
        }
        from = map.to;
    }

    return next_value;
}

fn parseSeeds(seeds: *std.ArrayList(u64), it: *std.mem.SplitIterator(u8, .any)) void {
    while (it.next()) |line| {
        if (line.len == 0) {
            break;
        }

        var seed_it = std.mem.splitAny(u8, line[7..], " ");

        while (seed_it.next()) |seed| {
            if (h.to_u64(seed)) |num| {
                seeds.append(num) catch unreachable;
            }
        }
    }
}

fn parseSeeds2(seeds: *std.ArrayList(SeedRange), it: *std.mem.SplitIterator(u8, .any)) void {
    while (it.next()) |line| {
        if (line.len == 0) {
            break;
        }

        var seed_it = std.mem.splitAny(u8, line[7..], " ");

        while (seed_it.next()) |first| {
            var second = seed_it.next() orelse break;

            if (h.to_u64(first)) |start| {
                if (h.to_u64(second)) |len| {
                    seeds.append(SeedRange{ .start = start, .len = len }) catch unreachable;
                }
            }
        }
    }
}

fn mapRanges(seedRanges: *std.ArrayList(SeedRange), map: Map) void {
    var currentRanges = seedRanges.clone() catch unreachable;

    seedRanges.clearAndFree();

    while (currentRanges.items.len > 0) {
        var range: SeedRange = currentRanges.pop();
        var foundAny = false;

        for (map.mappings.items) |mapping| {
            if ((range.start + range.len - 1 < mapping.src0) or (range.start > mapping.src0 + mapping.len - 1)) {
                continue;
            } else if (range.start >= mapping.src0 and range.start + range.len <= mapping.src0 + mapping.len) {
                seedRanges.append(SeedRange{ .start = mapping.dest0 + (range.start - mapping.src0), .len = range.len }) catch unreachable;
                foundAny = true;
                break;
            } else if (range.start < mapping.src0 and range.start + range.len - 1 <= mapping.src0 + mapping.len - 1) {
                var split = mapping.src0 - range.start;
                currentRanges.append(SeedRange{ .start = range.start, .len = split }) catch unreachable;
                seedRanges.append(SeedRange{ .start = mapping.dest0, .len = range.len - split }) catch unreachable;
                foundAny = true;
            } else if (range.start >= mapping.src0 and range.start + range.len - 1 > mapping.src0 + mapping.len - 1) {
                var split = mapping.src0 + mapping.len - range.start;
                seedRanges.append(SeedRange{ .start = mapping.dest0 + (mapping.src0 + mapping.len - split), .len = split }) catch unreachable;
                currentRanges.append(SeedRange{ .start = range.start + split, .len = range.len - split }) catch unreachable;
                foundAny = true;
            } else if (range.start < mapping.src0 and range.start + range.len - 1 > mapping.src0 + mapping.len - 1) {
                var split1 = mapping.src0 - range.start;
                var split2 = (range.start + range.len) - (mapping.src0 + mapping.len);
                currentRanges.append(SeedRange{ .start = range.start, .len = split1 }) catch unreachable;
                seedRanges.append(SeedRange{ .start = mapping.dest0, .len = mapping.len }) catch unreachable;
                currentRanges.append(SeedRange{ .start = mapping.src0 + mapping.len, .len = split2 }) catch unreachable;
                foundAny = true;
            }
        }

        if (!foundAny) {
            seedRanges.append(range) catch unreachable;
        }
    }
}

fn parseMap(allocator: std.mem.Allocator, it: *std.mem.SplitIterator(u8, .any)) ?Map {
    var map = Map{ .mappings = std.ArrayList(Mapping).init(allocator) };

    while (it.next()) |line| {
        if (line.len == 0) {
            break;
        }

        if (std.mem.endsWith(u8, line, "map:")) {
            var type_it = std.mem.splitAny(u8, line, "- ");
            while (type_it.next()) |val| {
                if (std.mem.eql(u8, val, "map:") or std.mem.eql(u8, val, "to")) continue;

                if (map.from == .none) {
                    map.from = parseMapTypeEnum(val);
                } else {
                    map.to = parseMapTypeEnum(val);
                }
            }
        } else {
            var num_it = std.mem.splitAny(u8, line, " ");
            var dest0 = num_it.next() orelse "";
            var src0 = num_it.next() orelse "";
            var len = num_it.next() orelse "";

            var num_dest0 = h.to_u64(dest0) orelse 0;
            var num_src0 = h.to_u64(src0) orelse 0;
            var num_len = h.to_u64(len) orelse 0;

            map.mappings.append(Mapping{ .src0 = num_src0, .dest0 = num_dest0, .len = num_len }) catch unreachable;
        }
    }

    if (map.from == .none or map.to == .none) return null;

    return map;
}

fn parseMapTypeEnum(val: []const u8) MapType {
    if (std.mem.eql(u8, val, "seed")) return .seed;
    if (std.mem.eql(u8, val, "soil")) return .soil;
    if (std.mem.eql(u8, val, "fertilizer")) return .fertilizer;
    if (std.mem.eql(u8, val, "water")) return .water;
    if (std.mem.eql(u8, val, "light")) return .light;
    if (std.mem.eql(u8, val, "temperature")) return .temperature;
    if (std.mem.eql(u8, val, "humidity")) return .humidity;
    if (std.mem.eql(u8, val, "location")) return .location;

    return .none;
}
