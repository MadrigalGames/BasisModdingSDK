// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const goofy = @import("goofy.zig");

pub fn registerSkin(skinName: []const u8) void {
    const interopName = basis.string.toInteropString(skinName);
    goofy.bindings.api.GoofySkins_registerSkin(&interopName);
}

pub fn setButtonRenderCallback(skinName: []const u8, cb: goofy.bindings.InteropButtonRenderCallback) void {
    const interopName = basis.string.toInteropString(skinName);
    goofy.bindings.api.GoofySkins_setButtonRenderCallback(&interopName, cb);
}

pub fn setSpinBoxRenderCallback(skinName: []const u8, cb: goofy.bindings.InteropSpinBoxRenderCallback) void {
    const interopName = basis.string.toInteropString(skinName);
    goofy.bindings.api.GoofySkins_setSpinBoxRenderCallback(&interopName, cb);
}
