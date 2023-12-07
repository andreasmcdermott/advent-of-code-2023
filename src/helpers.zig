const std = @import("std");

pub fn to_u32(str: []const u8) ?u32 {
    return std.fmt.parseInt(u32, str, 10) catch null;
}

pub fn each_line(str: []const u8) std.mem.SplitIterator(u8, .any) {
    return std.mem.splitAny(u8, str, "\n");
}

pub fn read_file(allocator: std.mem.Allocator, comptime file_name: []const u8) ![]const u8 {
    var file = try std.fs.cwd().openFile("./inputs/" ++ file_name ++ ".txt", .{});
    defer file.close();

    const stat = try file.stat();

    var file_content = try file.reader().readAllAlloc(allocator, stat.size);

    return file_content;
}

pub fn iterate_file_by_line(allocator: std.mem.Allocator, comptime file_name: []const u8) !std.mem.SplitIterator(u8, .any) {
    var file_content = try read_file(allocator, file_name);
    return each_line(file_content);
}
