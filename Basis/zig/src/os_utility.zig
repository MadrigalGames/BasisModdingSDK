// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

pub fn writeStringToClipboard(str: []const u8) bool {
    const interopStr = basis.string.toInteropString(str);
    return if (basis.bindings.api.OSUtility_writeStringToClipboard(&interopStr) == 1) true else false;
}
