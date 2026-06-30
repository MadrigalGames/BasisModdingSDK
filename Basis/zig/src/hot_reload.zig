// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

// For now, we put the global data on the heap, so the only thing we need to
// store/restore is the pointer value.

pub fn storeState(stream: *basis.BinaryWriteStream) void {
    stream.putInt(basis.IntPtr, @intFromPtr(basis.g));
}

pub fn restoreState(stream: *basis.BinaryReadStream, allocator: std.mem.Allocator, io: std.Io) void {
    basis.g = @ptrFromInt(stream.getInt(basis.IntPtr));
    basis.g.allocator = allocator;
    basis.g.io = io;
}
