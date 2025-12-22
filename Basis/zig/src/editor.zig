// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

pub const EditorError = error{
    ExportFailed,
};

pub fn printInfo(allocator: std.mem.Allocator, comptime fmt: []const u8, args: anytype) void {
    const data = std.fmt.allocPrint(allocator, fmt, args) catch unreachable;
    defer allocator.free(data);

    basis.bindings.api.Editor_printInfo(&data[0], @as(u32, @intCast(data.len)));
}

pub fn printWarning(allocator: std.mem.Allocator, comptime fmt: []const u8, args: anytype) void {
    const data = std.fmt.allocPrint(allocator, fmt, args) catch unreachable;
    defer allocator.free(data);

    basis.bindings.api.Editor_printWarning(&data[0], @as(u32, @intCast(data.len)));
}

pub fn printError(allocator: std.mem.Allocator, comptime fmt: []const u8, args: anytype) void {
    const data = std.fmt.allocPrint(allocator, fmt, args) catch unreachable;
    defer allocator.free(data);

    basis.bindings.api.Editor_printError(&data[0], @as(u32, @intCast(data.len)));
}

pub fn getEditorCamera() basis.renderer.CameraPtr {
    const cppPtr = basis.bindings.api.Editor_getEditorCamera();
    return basis.renderer.CameraPtr{ .cppPtr = cppPtr };
}
