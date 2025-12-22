// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const builtin = @import("builtin");
const basis = @import("../basis.zig");

// Currently these just assert with a hardcoded false value.
// TODO: We should have a proper fatal error message box.

pub fn fatalError(src: std.builtin.SourceLocation) void {
    basis.assert(src, false);
}

pub fn fatalErrorWithName(src: std.builtin.SourceLocation, err: anyerror) void {
    basis.assertd(src, false, @errorName(err));
}

pub fn fatalErrorWithMessage(src: std.builtin.SourceLocation, message: []const u8) void {
    basis.assertd(src, false, message);
}

pub fn fatalErrorWithFormat(src: std.builtin.SourceLocation, comptime fmt: []const u8, args: anytype) void {
    basis.assertf(src, false, fmt, args);
}
