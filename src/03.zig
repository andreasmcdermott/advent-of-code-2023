const std = @import("std");
const h = @import("./helpers.zig");

const print = std.debug.print;

pub fn run() !void {
    var alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer alloc.deinit();

    try part1(alloc.allocator());
    // try part2(alloc.allocator());
}

const SymbolPos = struct {
    x: usize,
    y: usize,
};

const offsets = [_]i32{ -1, 0, 1 };

fn part1(allocator: std.mem.Allocator) !void {
    var result: u32 = 0;

    // Position of all symbols we find:
    var symbols = std.ArrayList(SymbolPos).init(allocator);
    defer symbols.deinit();

    // Mapping between part id and value. Once a value is used, its id is removed from this map (to avoid double counting).
    var partValues = std.AutoHashMap(u32, u32).init(allocator);
    defer partValues.deinit();

    // Mapping between part position and id.
    // The ID is used so that we can insert the same value in multiple positions, without double counting it.
    var partPositions = std.StringHashMap(u32).init(allocator);
    defer partPositions.deinit();

    var next_id: u32 = 0;
    var y: usize = 0;

    var it = try h.iterate_file_by_line(allocator, "00");

    while (it.next()) |line| {
        var x: usize = 0;
        while (x < line.len) {
            var c = line[x];

            if (c == '.') {
                x += 1;
            } else if (is_digit(c)) {
                var x0: usize = x;
                x += 1;

                while (x < line.len) { // Move forward until we find a non-digit char.
                    if (!is_digit(line[x])) break;

                    x += 1;
                }

                var value_as_str = line[x0..x];
                var v = std.fmt.parseInt(u32, value_as_str, 10) catch 0;

                if (v > 0) {
                    try partValues.put(next_id, v); // Insert the value using a new ID.
                    for (value_as_str, 0..) |_, x_offset| { // Loop through each char of the value and insert the ID in each position.
                        var key = std.fmt.allocPrint(allocator, "{},{}", .{ y, x0 + x_offset }) catch "";

                        if (key.len > 0 and v > 0) {
                            try partPositions.put(key, next_id);
                        }
                    }

                    next_id += 1;
                }
            } else {
                try symbols.append(SymbolPos{ .x = x, .y = y });
                x += 1;
            }
        }
        y += 1;
    }

    // Loop through all symbols and look for adjacent parts.
    for (symbols.items) |symbol| {
        for (offsets) |xx| {
            for (offsets) |yy| {
                var sx: i32 = @as(i32, @intCast(symbol.x));
                var sy: i32 = @as(i32, @intCast(symbol.y));

                if (xx == 0 and yy == 0) continue;
                if ((sx + xx < 0) or (sy + yy < 0)) continue;

                var key = std.fmt.allocPrint(allocator, "{},{}", .{ sy + yy, sx + xx }) catch "";

                if (partPositions.get(key)) |id| {
                    if (partValues.get(id)) |val| {
                        if (partValues.remove(id)) {}
                        result += val;
                    }
                }
            }
        }
    }

    print("{}\n", .{result});
}

fn part2(allocator: std.mem.Allocator) !void {
    var val: i32 = 0;

    var it = try h.iterate_file_by_line(allocator, "00");

    while (it.next()) |line| {
        print("line: {s}\n", .{line});
    }

    print("{}\n", .{val});
}

fn is_digit(c: u8) bool {
    return (c >= '0' and c <= '9');
}
