// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");

pub const Logger = struct {
    const Self = @This();

    pub const EntryType = enum {
        Info,
        Warning,
        Error,
    };

    pub const LogFunc = basis.delegate.VoidDelegate2([]const u8, EntryType);

    //----------------------------------------------------

    allocator: ?std.mem.Allocator = null,
    logFunc: ?LogFunc = null,

    //----------------------------------------------------

    pub fn log(self: *Self, comptime fmt: []const u8, args: anytype) void {
        self.logWithType(.Info, fmt, args);
    }

    pub fn logWithType(self: *Self, entryType: EntryType, comptime fmt: []const u8, args: anytype) void {
        if (self.allocator) |alloc| {
            if (self.logFunc) |f| {
                const message = std.fmt.allocPrint(alloc, fmt, args) catch unreachable;
                defer alloc.free(message);
                f.call(message, entryType);
            }
        }
    }
};
