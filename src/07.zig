const std = @import("std");
const h = @import("./helpers.zig");

const print = std.debug.print;

pub fn run() !void {
    var alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer alloc.deinit();

    try part1(alloc.allocator());
    try part2(alloc.allocator());
}

const HandType = enum(u8) {
    HighCard = 0,
    OnePair = 1,
    TwoPairs = 2,
    ThreeOfAKind = 3,
    FullHouse = 4,
    FourOfAKind = 5,
    FiveOfAKind = 6,
};

const Hand = struct { cards: []u8, bid: u32, type: HandType };

fn part1(allocator: std.mem.Allocator) !void {
    var val: u64 = 0;

    var hands = std.ArrayList(Hand).init(allocator);
    defer hands.deinit();

    var it = try h.iterate_file_by_line(allocator, "07");

    while (it.next()) |line| {
        var newHand = parseHand(allocator, line);

        if (hands.items.len == 0) {
            try hands.append(newHand);
        } else {
            var added = false;

            for (hands.items, 0..) |hand, i| {
                if (added) break;

                if (@intFromEnum(newHand.type) > @intFromEnum(hand.type)) {
                    try hands.insert(i, newHand);
                    added = true;
                    break;
                } else if (newHand.type == hand.type) {
                    for (newHand.cards, 0..) |card, j| {
                        var result = compareCards(card, hand.cards[j]);
                        if (result < 0) {
                            try hands.insert(i, newHand);
                            added = true;
                            break;
                        } else if (result > 0) {
                            break;
                        }
                    }
                }
            }

            if (!added) try hands.append(newHand);
        }
    }

    for (hands.items, 0..) |hand, i| {
        val += hand.bid * (hands.items.len - i);
    }

    print("{}\n", .{val});
}

fn part2(allocator: std.mem.Allocator) !void {
    var val: u64 = 0;

    var hands = std.ArrayList(Hand).init(allocator);
    defer hands.deinit();

    var it = try h.iterate_file_by_line(allocator, "07");

    while (it.next()) |line| {
        var newHand = parseHand2(allocator, line);

        if (hands.items.len == 0) {
            try hands.append(newHand);
        } else {
            var added = false;

            for (hands.items, 0..) |hand, i| {
                if (added) break;

                if (@intFromEnum(newHand.type) > @intFromEnum(hand.type)) {
                    try hands.insert(i, newHand);
                    added = true;
                    break;
                } else if (newHand.type == hand.type) {
                    for (newHand.cards, 0..) |card, j| {
                        var result = compareCards2(card, hand.cards[j]);
                        if (result < 0) {
                            try hands.insert(i, newHand);
                            added = true;
                            break;
                        } else if (result > 0) {
                            break;
                        }
                    }
                }
            }

            if (!added) try hands.append(newHand);
        }
    }

    for (hands.items, 0..) |hand, i| {
        val += hand.bid * (hands.items.len - i);
    }

    print("{}\n", .{val});
}

fn compareCards(card: u8, otherCard: u8) i8 {
    const cards = " AKQJT98765432";
    var ic = std.mem.indexOfScalar(u8, cards, card) orelse 0;
    var ioc = std.mem.indexOfScalar(u8, cards, otherCard) orelse 0;

    if (ic < ioc) return -1;
    if (ic > ioc) return 1;

    return 0;
}

fn parseHand(allocator: std.mem.Allocator, line: []const u8) Hand {
    var cards: []u8 = std.mem.Allocator.dupe(allocator, u8, line[0..5]) catch unreachable;
    return Hand{ .cards = cards, .bid = h.to_u32(line[6..]) orelse 0, .type = getHandType(cards) };
}

fn getHandType(cards: []u8) HandType {
    var i: u3 = 0;
    const one: u5 = 1;

    var checked: u5 = 0;

    var first: u32 = 0;
    var second: u32 = 0;

    while (i < cards.len - 1) {
        if ((checked & one << i) != 0) {
            i += 1;
            continue;
        }

        checked = checked | one << i;

        var count: u3 = 1;
        var c = cards[i];

        var j: u3 = i + 1;

        while (j < cards.len) {
            if (cards[j] == c) {
                checked = checked | one << j;
                count += 1;
            }
            j += 1;
        }

        if (count > first) {
            second = first;
            first = count;
        } else if (count > second) {
            second = count;
        }

        i += 1;
    }

    if (first == 5) return .FiveOfAKind;
    if (first == 4) return .FourOfAKind;
    if (first == 3 and second == 2) return .FullHouse;
    if (first == 3) return .ThreeOfAKind;
    if (first == 2 and second == 2) return .TwoPairs;
    if (first == 2) return .OnePair;

    return .HighCard;
}

fn compareCards2(card: u8, otherCard: u8) i8 {
    const cards = " AKQT98765432J";
    var ic = std.mem.indexOfScalar(u8, cards, card) orelse 0;
    var ioc = std.mem.indexOfScalar(u8, cards, otherCard) orelse 0;

    if (ic < ioc) return -1;
    if (ic > ioc) return 1;

    return 0;
}

fn parseHand2(allocator: std.mem.Allocator, line: []const u8) Hand {
    var cards: []u8 = std.mem.Allocator.dupe(allocator, u8, line[0..5]) catch unreachable;
    return Hand{ .cards = cards, .bid = h.to_u32(line[6..]) orelse 0, .type = getHandType2(cards) };
}

fn getHandType2(cards: []u8) HandType {
    var i: u3 = 0;
    const one: u5 = 1;

    var checked: u5 = 0;
    var numJokers: u32 = 0;

    var first: u32 = 0;
    var second: u32 = 0;

    while (i < cards.len) {
        if ((checked & one << i) != 0) {
            i += 1;
            continue;
        }

        checked = checked | one << i;

        var count: u3 = 1;
        var c = cards[i];

        if (c == 'J') {
            numJokers += 1;
            i += 1;
            continue;
        }

        var j: u3 = i + 1;

        while (j < cards.len) {
            if (cards[j] == 'J') {
                j += 1;
                continue;
            }

            if (cards[j] == c) {
                checked = checked | one << j;
                count += 1;
            }
            j += 1;
        }

        if (count > first) {
            second = first;
            first = count;
        } else if (count > second) {
            second = count;
        }

        i += 1;
    }

    if ((first + numJokers) == 5) return .FiveOfAKind;
    if ((first + numJokers) == 4) return .FourOfAKind;
    if (((first + numJokers) == 3 and second == 2) or (first == 3 and (second + numJokers) == 2)) return .FullHouse;
    if ((first + numJokers) == 3) return .ThreeOfAKind;
    if ((first == (2 + numJokers) and second == 2) or (first == 2 and (second + numJokers) == 2)) return .TwoPairs;
    if ((first + numJokers) == 2) return .OnePair;

    return .HighCard;
}
