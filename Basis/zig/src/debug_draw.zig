// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

pub const DEFAULT_SPHERE_POINT_COUNT: i32 = 30;

pub const TextPivot = enum(i32) {
    UpLeft = 0,
    UpRight,
    UpCenter,
    DownLeft,
    DownRight,
    DownCenter,
    CenterLeft,
    CenterRight,
    Center,

    pub fn asInt(self: TextPivot) i32 {
        return @intFromEnum(self);
    }
};

pub fn drawLine2D(x1: i32, y1: i32, x2: i32, y2: i32, color: basis.Color) void {
    const ci = color.toInterop();
    basis.bindings.api.DebugDraw_drawLine2D(x1, y1, x2, y2, &ci, &ci);
}

pub fn drawLine2DMultiColor(x1: i32, y1: i32, x2: i32, y2: i32, color1: basis.Color, color2: basis.Color) void {
    const ci1 = color1.toInterop();
    const ci2 = color2.toInterop();
    basis.bindings.api.DebugDraw_drawLine2D(x1, y1, x2, y2, &ci1, &ci2);
}

pub fn drawLine3D(p1: basis.math.Vec3, p2: basis.math.Vec3, color: basis.Color) void {
    const pi1 = p1.toInterop();
    const pi2 = p2.toInterop();
    const ci = color.toInterop();
    basis.bindings.api.DebugDraw_drawLine3D(&pi1, &pi2, &ci, &ci);
}

pub fn drawLine3DMultiColor(p1: basis.math.Vec3, p2: basis.math.Vec3, color1: basis.Color, color2: basis.Color) void {
    const pi1 = p1.toInterop();
    const pi2 = p2.toInterop();
    const ci1 = color1.toInterop();
    const ci2 = color2.toInterop();
    basis.bindings.api.DebugDraw_drawLine3D(&pi1, &pi2, &ci1, &ci2);
}

pub fn drawAxisCross(point: basis.math.Vec3, scale: f32) void {
    const p = point.toInterop();
    basis.bindings.api.DebugDraw_drawAxisCross(&p, scale);
}

pub fn drawSphere(center: basis.math.Vec3, radius: f32, color: basis.Color) void {
    const c = center.toInterop();
    const co = color.toInterop();
    basis.bindings.api.DebugDraw_drawSphere(&c, radius, &co, DEFAULT_SPHERE_POINT_COUNT);
}

pub fn drawSphereWithPointCount(center: basis.math.Vec3, radius: f32, color: basis.Color, pointCount: i32) void {
    const c = center.toInterop();
    const co = color.toInterop();
    basis.bindings.api.DebugDraw_drawSphere(&c, radius, &co, pointCount);
}

pub fn drawTriangle3D(p1: basis.math.Vec3, p2: basis.math.Vec3, p3: basis.math.Vec3, color1: basis.Color, color2: basis.Color, color3: basis.Color) void {
    const pi1 = p1.toInterop();
    const pi2 = p2.toInterop();
    const pi3 = p3.toInterop();
    const ci1 = color1.toInterop();
    const ci2 = color2.toInterop();
    const ci3 = color3.toInterop();
    basis.bindings.api.DebugDraw_drawTriangle3D(&pi1, &pi2, &pi3, &ci1, &ci2, &ci3);
}

pub fn drawString(text: []const u8, worldPosition: basis.math.Vec3, color: basis.Color) void {
    const s = basis.string.toInteropString(text);
    const p = worldPosition.toInterop();
    const c = color.toInterop();
    basis.bindings.api.DebugDraw_drawString(&s, &p, &c);
}

pub fn drawStringXY(text: []const u8, x: i32, y: i32, color: basis.Color, pivot: TextPivot) void {
    const s = basis.string.toInteropString(text);
    const c = color.toInterop();

    basis.bindings.api.DebugDraw_drawStringXY(&s, x, y, &c, pivot.asInt());
}

pub fn drawMatrixAxes(mat: basis.math.Mat43, scale: f32, color: ?basis.Color) void {
    const pos = mat.getT();
    const x = mat.getX().multiplyFloat(scale);
    const y = mat.getY().multiplyFloat(scale);
    const z = mat.getZ().multiplyFloat(scale);

    if (color != null) {
        basis.debug_draw.drawLine3D(pos, pos.add(x), color.?);
        basis.debug_draw.drawLine3D(pos, pos.add(y), color.?);
        basis.debug_draw.drawLine3D(pos, pos.add(z), color.?);
    } else {
        basis.debug_draw.drawLine3D(pos, pos.add(x), basis.Color.Red);
        basis.debug_draw.drawLine3D(pos, pos.add(y), basis.Color.Green);
        basis.debug_draw.drawLine3D(pos, pos.add(z), basis.Color.Blue);
    }
}
