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
    var val: u32 = 0;

    var winners = std.StringHashMap(u32).init(allocator);
    defer winners.deinit();

    var it = try h.iterate_file_by_line(allocator, "04");

    while (it.next()) |line| {
        if (std.mem.indexOfAny(u8, line, ":")) |colon_i| {
            if (std.mem.indexOfAny(u8, line, "|")) |pipe_i| {
                var winning_numbers = line[(colon_i + 1)..(pipe_i - 1)];

                var win_it = std.mem.splitAny(u8, winning_numbers, " ");

                while (win_it.next()) |win| {
                    if (h.to_u32(win)) |num| {
                        try winners.put(win, num);
                    }
                }

                var numbers = line[(pipe_i + 1)..];

                var num_it = std.mem.splitAny(u8, numbers, " ");

                var points: u32 = 0;

                while (num_it.next()) |num| {
                    if (winners.contains(num)) {
                        if (points == 0) {
                            points = 1;
                        } else {
                            points *= 2;
                        }
                    }
                }

                val += points;
            }
        }
        winners.clearAndFree();
    }

    print("{}\n", .{val});
}

const Card = struct {
    id: u32,
    winning_numbers: []const u8,
    numbers: []const u8,
};

fn part2(allocator: std.mem.Allocator) !void {
    var val: u32 = 0;

    var card_map = std.AutoHashMap(u32, u32).init(allocator);
    defer card_map.deinit();

    var remaining_cards = std.ArrayList(Card).init(allocator);
    defer remaining_cards.deinit();

    var it = try h.iterate_file_by_line(allocator, "04");

    while (it.next()) |line| {
        if (std.mem.indexOfAny(u8, line, ":")) |colon_i| {
            if (std.mem.indexOfAny(u8, line, "|")) |pipe_i| {
                if (std.mem.lastIndexOfAny(u8, line[0..colon_i], " ")) |space_i| {
                    var card_id = line[(space_i + 1)..colon_i];
                    var winning_numbers = line[(colon_i + 1)..(pipe_i - 1)];
                    var numbers = line[(pipe_i + 1)..];

                    if (h.to_u32(card_id)) |id| {
                        var c = Card{
                            .id = id,
                            .winning_numbers = winning_numbers,
                            .numbers = numbers,
                        };

                        try card_map.put(id, 0);
                        try remaining_cards.append(c);
                    }
                }
            }
        }
    }

    var winners = std.StringHashMap(u32).init(allocator);
    defer winners.deinit();

    while (remaining_cards.popOrNull()) |c| {
        var win_it = std.mem.splitAny(u8, c.winning_numbers, " ");

        while (win_it.next()) |win| {
            if (h.to_u32(win)) |num| {
                try winners.put(win, num);
            }
        }

        var num_it = std.mem.splitAny(u8, c.numbers, " ");

        var wins: u32 = 0;

        while (num_it.next()) |num| {
            if (winners.contains(num)) {
                wins += 1;
            }
        }

        var i: u32 = 1;
        var total: u32 = 1;

        while (i <= wins) {
            if (card_map.get(c.id + i)) |v| {
                total += v;
            }
            i += 1;
        }

        val += total;
        try card_map.put(c.id, total);
        winners.clearAndFree();
    }

    print("{}\n", .{val});
}
