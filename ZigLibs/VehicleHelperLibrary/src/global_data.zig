// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const vhl = @import("vhl.zig");

pub const LibraryGlobalData = struct {
    // Global allocator and IO interface. Only use these for global-data purposes!
    // If it is possible to pass an allocator/io to a function, prefer that.
    allocator: std.mem.Allocator,
    io: std.Io,

    // When adding more global data here, if possible, try to name each field
    // according to the zig file where it is used.
    vehicle_database: vhl.vehicle_database.GlobalData = .{},
};

pub fn create(allocator: std.mem.Allocator, io: std.Io) void {
    vhl.g = allocator.create(LibraryGlobalData) catch @panic("OOM");
    vhl.g.* = LibraryGlobalData{ .allocator = allocator, .io = io };

    vhl.vehicle_database.init();
}

pub fn destroy() void {
    vhl.vehicle_database.deinit();

    vhl.g.allocator.destroy(vhl.g);
}
