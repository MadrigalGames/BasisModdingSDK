// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

pub const Callback = basis.delegate.VoidDelegate0();

var callback: ?Callback = null; // Meh. This isn't really hot-reload-proof...

pub fn isActive() bool {
    return if (basis.bindings.api.ScreenFade_isActive() == 1) true else false;
}

pub fn fade(from: basis.Color, to: basis.Color, duration: f32) void {
    const fromInterop = from.toInterop();
    const toInterop = to.toInterop();
    basis.bindings.api.ScreenFade_fade(&fromInterop, &toInterop, duration);
}

pub fn fadeWithCallback(from: basis.Color, to: basis.Color, duration: f32, cb: Callback) void {
    callback = cb;
    const fromInterop = from.toInterop();
    const toInterop = to.toInterop();
    basis.bindings.api.ScreenFade_fadeWithCallback(&fromInterop, &toInterop, duration, callbackWrapper);
}

pub fn setColor(color: basis.Color) void {
    const colorInterop = color.toInterop();
    basis.bindings.api.ScreenFade_setColor(&colorInterop);
}

pub fn clear() void {
    basis.bindings.api.ScreenFade_clear();
}

fn callbackWrapper() callconv(.c) void {
    if (callback) |cb| {
        cb.call();
    }
}
