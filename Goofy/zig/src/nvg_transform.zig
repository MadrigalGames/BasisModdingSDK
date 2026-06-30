// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");

// Zig versions of NanoVG transform functions. Functions are
// ported to Zig as needed. See nanovg.c for the implementations.

pub fn transformIdentity(t: []f32) void {
    t[0] = 1.0;
    t[1] = 0.0;
    t[2] = 0.0;
    t[3] = 1.0;
    t[4] = 0.0;
    t[5] = 0.0;
}

pub fn transformTranslate(t: []f32, tx: f32, ty: f32) void {
    t[0] = 1.0;
    t[1] = 0.0;
    t[2] = 0.0;
    t[3] = 1.0;
    t[4] = tx;
    t[5] = ty;
}

pub fn transformScale(t: []f32, sx: f32, sy: f32) void {
    t[0] = sx;
    t[1] = 0.0;
    t[2] = 0.0;
    t[3] = sy;
    t[4] = 0.0;
    t[5] = 0.0;
}

pub fn transformRotate(t: []f32, a: f32) void {
    const cs = @cos(a);
    const sn = @sin(a);
    t[0] = cs;
    t[1] = sn;
    t[2] = -sn;
    t[3] = cs;
    t[4] = 0.0;
    t[5] = 0.0;
}
