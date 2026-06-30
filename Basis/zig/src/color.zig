// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,

    pub const Black: Color = initRGBA(0, 0, 0, 255);
    pub const White: Color = initRGBA(255, 255, 255, 255);
    pub const Red: Color = initRGBA(255, 0, 0, 255);
    pub const Green: Color = initRGBA(0, 255, 0, 255);
    pub const Blue: Color = initRGBA(0, 0, 255, 255);
    pub const Yellow: Color = initRGBA(255, 255, 0, 255);
    pub const Orange: Color = initRGBA(255, 165, 0, 255);
    pub const Gold: Color = initRGBA(204, 164, 61, 255);
    pub const Transparent: Color = initRGBA(0, 0, 0, 0);

    pub fn init(r: u8, g: u8, b: u8) Color {
        return Color{
            .r = r,
            .g = g,
            .b = b,
            .a = 255,
        };
    }

    pub fn initRGBA(r: u8, g: u8, b: u8, a: u8) Color {
        return Color{
            .r = r,
            .g = g,
            .b = b,
            .a = a,
        };
    }

    //----------------------------------------------------

    pub fn deserialize(self: *Color, stream: *basis.BinaryReadStream) void {
        self.r = stream.getInt(u8);
        self.g = stream.getInt(u8);
        self.b = stream.getInt(u8);
        self.a = stream.getInt(u8);
    }

    pub fn serialize(self: Color, stream: *basis.BinaryWriteStream) void {
        stream.putInt(u8, self.r);
        stream.putInt(u8, self.g);
        stream.putInt(u8, self.b);
        stream.putInt(u8, self.a);
    }

    //----------------------------------------------------

    pub fn toInterop(self: Color) basis.bindings.InteropColor {
        return basis.bindings.InteropColor{
            .r = self.r,
            .g = self.g,
            .b = self.b,
            .a = self.a,
        };
    }

    pub fn fromInterop(interop: basis.bindings.InteropColor) Color {
        return Color{
            .r = interop.r,
            .g = interop.g,
            .b = interop.b,
            .a = interop.a,
        };
    }

    pub fn toVec4(self: Color) basis.math.Vec4 {
        return basis.math.Vec4{
            .x = @as(f32, @floatFromInt(self.r)) / 255.0,
            .y = @as(f32, @floatFromInt(self.g)) / 255.0,
            .z = @as(f32, @floatFromInt(self.b)) / 255.0,
            .w = @as(f32, @floatFromInt(self.a)) / 255.0,
        };
    }

    pub fn toFloatArray(self: Color, f: []f32) void {
        f[0] = @as(f32, @floatFromInt(self.r)) / 255.0;
        f[1] = @as(f32, @floatFromInt(self.g)) / 255.0;
        f[2] = @as(f32, @floatFromInt(self.b)) / 255.0;
        f[3] = @as(f32, @floatFromInt(self.a)) / 255.0;
    }

    pub fn toLinearVec4(self: Color) basis.math.Vec4 {
        const vr = @as(f32, @floatFromInt(self.r)) / 255.0;
        const vg = @as(f32, @floatFromInt(self.g)) / 255.0;
        const vb = @as(f32, @floatFromInt(self.b)) / 255.0;

        return basis.math.Vec4{
            .x = vr * (vr * (vr * 0.305306011 + 0.682171111) + 0.012522878),
            .y = vg * (vg * (vg * 0.305306011 + 0.682171111) + 0.012522878),
            .z = vb * (vb * (vb * 0.305306011 + 0.682171111) + 0.012522878),
            .w = @as(f32, @floatFromInt(self.a)) / 255.0,
        };
    }
};
