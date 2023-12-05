const std = @import("std");

pub fn print(str: []const u8) void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    stdout.print("{s}\n", .{str}) catch std.debug.print("Error printing", .{});
    bw.flush() catch std.debug.print("Error flushing", .{});
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
