// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const goofy = @import("goofy.zig");

pub const LibraryGlobalData = struct {
    // Global allocator and IO interface. Only use these for global-data purposes!
    // If it is possible to pass an allocator/io to a function, prefer that.
    allocator: std.mem.Allocator,
    io: std.Io,

    // When adding more global data here, if possible, try to name each field
    // according to the zig file where it is used.
    manager: goofy.manager.GlobalData = .{},
    canvas: goofy.canvas.GlobalData = .{},
    user_widget: goofy.user_widget.GlobalData = .{},
    view: goofy.view.GlobalData = .{},
};

pub fn create(allocator: std.mem.Allocator, io: std.Io) void {
    goofy.g = allocator.create(LibraryGlobalData) catch @panic("OOM");
    goofy.g.* = LibraryGlobalData{ .allocator = allocator, .io = io };

    goofy.canvas.init();
    goofy.user_widget.init();
    goofy.view.init();
}

pub fn destroy() void {
    goofy.view.deinit();
    goofy.user_widget.deinit();
    goofy.canvas.deinit();

    goofy.g.allocator.destroy(goofy.g);
}
