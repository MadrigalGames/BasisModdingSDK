// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Vec3 = basis.math.Vec3;
const Mat43 = basis.math.Mat43;

pub const Vec4 = struct {
    x: f32,
    y: f32,
    z: f32,
    w: f32,

    pub const Zero = init(0.0, 0.0, 0.0, 0.0);
    pub const One = init(1.0, 1.0, 1.0, 1.0);
    pub const UnitX = init(1.0, 0.0, 0.0, 0.0);
    pub const UnitY = init(0.0, 1.0, 0.0, 0.0);
    pub const UnitZ = init(0.0, 0.0, 1.0, 0.0);
    pub const UnitW = init(0.0, 0.0, 0.0, 1.0);

    pub fn init(x: f32, y: f32, z: f32, w: f32) Vec4 {
        return Vec4{
            .x = x,
            .y = y,
            .z = z,
            .w = w,
        };
    }

    pub fn initFromVec3(vec3: Vec3, w: f32) Vec4 {
        return Vec4{
            .x = vec3.x,
            .y = vec3.y,
            .z = vec3.z,
            .w = w,
        };
    }

    pub fn initFromSlice(slice: []const f32) Vec4 {
        return Vec4{
            .x = slice[0],
            .y = slice[1],
            .z = slice[2],
            .w = slice[3],
        };
    }

    pub fn initFromJsonArray(array: std.json.Array) Vec4 {
        const x: f32 = switch (array.items[0]) {
            .integer => |val| @as(f32, @floatFromInt(val)),
            .float => |val| @as(f32, @floatCast(val)),
            else => @panic("Unsupported type"),
        };

        const y: f32 = switch (array.items[1]) {
            .integer => |val| @as(f32, @floatFromInt(val)),
            .float => |val| @as(f32, @floatCast(val)),
            else => @panic("Unsupported type"),
        };

        const z: f32 = switch (array.items[2]) {
            .integer => |val| @as(f32, @floatFromInt(val)),
            .float => |val| @as(f32, @floatCast(val)),
            else => @panic("Unsupported type"),
        };

        const w: f32 = switch (array.items[3]) {
            .integer => |val| @as(f32, @floatFromInt(val)),
            .float => |val| @as(f32, @floatCast(val)),
            else => @panic("Unsupported type"),
        };

        return Vec4.init(x, y, z, w);
    }

    pub fn setXYZW(self: *Vec4, x: f32, y: f32, z: f32, w: f32) void {
        self.x = x;
        self.y = y;
        self.z = z;
        self.w = w;
    }

    /// When the w component of the vector is 1 this transforms points. When it is 0 it transforms directions.
    pub fn transform(self: Vec4, matrix: Mat43) Vec4 {
        const x = matrix._11 * self.x + matrix._21 * self.y + matrix._31 * self.z + matrix._41 * self.w;
        const y = matrix._12 * self.x + matrix._22 * self.y + matrix._32 * self.z + matrix._42 * self.w;
        const z = matrix._13 * self.x + matrix._23 * self.y + matrix._33 * self.z + matrix._43 * self.w;
        const w = self.w;
        return Vec4.init(x, y, z, w);
    }

    pub fn toVec3(self: Vec4) Vec3 {
        return Vec3{
            .x = self.x,
            .y = self.y,
            .z = self.z,
        };
    }

    pub fn negate(self: *Vec4) void {
        self.x *= -1.0;
        self.y *= -1.0;
        self.z *= -1.0;
        self.w *= -1.0;
    }

    pub fn negated(self: Vec4) Vec4 {
        var n = self;
        n.negate();
        return n;
    }

    //----------------------------------------------------

    pub fn deserialize(self: *Vec4, stream: *basis.BinaryReadStream) void {
        self.x = stream.getFloat();
        self.y = stream.getFloat();
        self.z = stream.getFloat();
        self.w = stream.getFloat();
    }

    pub fn serialize(self: Vec4, stream: *basis.BinaryWriteStream) void {
        stream.putFloat(self.x);
        stream.putFloat(self.y);
        stream.putFloat(self.z);
        stream.putFloat(self.w);
    }

    //----------------------------------------------------

    pub fn toInterop(self: Vec4) basis.bindings.InteropVec4 {
        return basis.bindings.InteropVec4{
            .x = self.x,
            .y = self.y,
            .z = self.z,
            .w = self.w,
        };
    }

    pub fn fromInterop(interop: basis.bindings.InteropVec4) Vec4 {
        return Vec4{
            .x = interop.x,
            .y = interop.y,
            .z = interop.z,
            .w = interop.w,
        };
    }
};
