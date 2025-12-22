// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

pub fn printOnHost(comptime fmt: []const u8, args: anytype) void {
    var buffer: [256]u8 = undefined;

    const str = std.fmt.bufPrint(
        &buffer,
        fmt,
        args,
    ) catch "(printOnHost() - BUFFER TOO SMALL, CANNOT PRINT MESSAGE)\n";

    const interop = basis.string.toInteropString(str);
    basis.bindings.api.Core_printOnHost(&interop);
}
