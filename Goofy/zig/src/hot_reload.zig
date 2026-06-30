// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const goofy = @import("goofy.zig");

// For now, we put the global data on the heap, so the only thing we need to
// store/restore is the pointer value.

pub fn storeState(stream: *basis.BinaryWriteStream) void {
    stream.putInt(basis.IntPtr, @intFromPtr(goofy.g));
}

pub fn restoreState(stream: *basis.BinaryReadStream, allocator: std.mem.Allocator, io: std.Io) void {
    goofy.g = @ptrFromInt(stream.getInt(basis.IntPtr));
    goofy.g.allocator = allocator;
    goofy.g.io = io;
}
