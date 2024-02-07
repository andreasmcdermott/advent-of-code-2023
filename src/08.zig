const std = @import("std");
const h = @import("./helpers.zig");

const print = std.debug.print;

pub fn run() !void {
    var alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer alloc.deinit();

    try part1(alloc.allocator());
    try part2(alloc.allocator());
}

const Node = struct {
    id: []const u8 = undefined,
    left: []const u8 = undefined,
    right: []const u8 = undefined,
};

const JumpNode = struct {
    id: []const u8 = undefined,
    jumpTo: std.ArrayList([]const u8) = undefined,
    distanceToZ: u32 = undefined,
};

fn part1(allocator: std.mem.Allocator) !void {
    var map = std.StringHashMap(Node).init(allocator);
    defer map.deinit();

    var it = try h.iterate_file_by_line(allocator, "08");

    var instructions: []const u8 = it.next() orelse "";

    while (it.next()) |line| {
        if (line.len == 0) continue;

        var nodeIt = std.mem.splitAny(u8, line, " =(,)");

        var node = Node{};
        var i: u8 = 0;

        while (nodeIt.next()) |str| {
            if (str.len == 0) continue;
            if (i == 0) {
                node.id = str;
                i += 1;
            } else if (i == 1) {
                node.left = str;
                i += 1;
            } else {
                node.right = str;
            }
        }

        try map.put(node.id, node);
    }

    var node = map.get("AAA") orelse unreachable;
    var i: u32 = 0;

    while (!std.mem.eql(u8, "ZZZ", node.id)) {
        var instruction = instructions[i % instructions.len];

        if (instruction == 'L') {
            node = map.get(node.left) orelse unreachable;
        } else {
            node = map.get(node.right) orelse unreachable;
        }

        i += 1;
    }

    print("{}\n", .{i});
}

fn part2(allocator: std.mem.Allocator) !void {
    var map = std.StringHashMap(Node).init(allocator);
    defer map.deinit();

    var it = try h.iterate_file_by_line(allocator, "08");

    var instructions: []const u8 = it.next() orelse "";

    var nodes = std.ArrayList([]const u8).init(allocator);

    while (it.next()) |line| {
        if (line.len == 0) continue;

        var nodeIt = std.mem.splitAny(u8, line, " =(,)");

        var node = Node{};
        var i: u8 = 0;

        while (nodeIt.next()) |str| {
            if (str.len == 0) continue;
            if (i == 0) {
                node.id = str;
                if (str[str.len - 1] == 'A') {
                    try nodes.append(str);
                }
                i += 1;
            } else if (i == 1) {
                node.left = str;
                i += 1;
            } else {
                node.right = str;
            }
        }

        try map.put(node.id, node);
    }

    var stepsPerNode = std.ArrayList(u64).init(allocator);
    for (nodes.items) |node| {
        var steps = countSteps(node, map, instructions);
        try stepsPerNode.append(steps);
    }

    var answer: u64 = 1;

    for (stepsPerNode.items) |steps| {
        answer = leastCommonMultiple(answer, steps);
    }

    print("{d}\n", .{answer});
}

fn countSteps(nodeId: []const u8, map: std.StringHashMap(Node), instructions: []const u8) u64 {
    var i: u64 = 0;
    var node = map.get(nodeId) orelse unreachable;

    while (node.id[node.id.len - 1] != 'Z') {
        var instruction = instructions[i % instructions.len];

        if (instruction == 'L') {
            node = map.get(node.left) orelse unreachable;
        } else {
            node = map.get(node.right) orelse unreachable;
        }

        i += 1;
    }

    return i;
}

fn leastCommonMultiple(this: u64, other: u64) u64 {
    return (this * other) / greatestCommonDivisor(this, other);
}

fn greatestCommonDivisor(this: u64, other: u64) u64 {
    var remainder = this % other;
    if (remainder == 0) return other;
    return greatestCommonDivisor(other, remainder);
}

fn isDone(nodes: std.ArrayList([]const u8)) bool {
    for (nodes.items) |node| {
        if (node[node.len - 1] != 'Z') {
            return false;
        }
    }

    return true;
}
