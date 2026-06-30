// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Vec4 = basis.math.Vec4;
const Mat43 = basis.math.Mat43;

pub const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,

    pub const Zero = init(0.0, 0.0, 0.0);
    pub const One = init(1.0, 1.0, 1.0);
    pub const UnitX = init(1.0, 0.0, 0.0);
    pub const UnitY = init(0.0, 1.0, 0.0);
    pub const UnitZ = init(0.0, 0.0, 1.0);

    pub fn init(x: f32, y: f32, z: f32) Vec3 {
        return Vec3{
            .x = x,
            .y = y,
            .z = z,
        };
    }

    pub fn initFromVec4(vec4: Vec4) Vec3 {
        return Vec3{
            .x = vec4.x,
            .y = vec4.y,
            .z = vec4.z,
        };
    }

    pub fn initFromSlice(slice: []const f32) Vec3 {
        return Vec3{
            .x = slice[0],
            .y = slice[1],
            .z = slice[2],
        };
    }

    pub fn initFromJsonArray(array: std.json.Array) Vec3 {
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

        return Vec3.init(x, y, z);
    }

    pub fn setXYZ(self: *Vec3, x: f32, y: f32, z: f32) void {
        self.x = x;
        self.y = y;
        self.z = z;
    }

    pub fn dot(self: Vec3, other: Vec3) f32 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }

    pub fn cross(self: Vec3, other: Vec3) Vec3 {
        return Vec3.init(
            self.y * other.z - self.z * other.y,
            self.z * other.x - self.x * other.z,
            self.x * other.y - self.y * other.x,
        );
    }

    pub fn add(self: Vec3, other: Vec3) Vec3 {
        return Vec3{
            .x = self.x + other.x,
            .y = self.y + other.y,
            .z = self.z + other.z,
        };
    }

    pub fn sub(self: Vec3, other: Vec3) Vec3 {
        return Vec3{
            .x = self.x - other.x,
            .y = self.y - other.y,
            .z = self.z - other.z,
        };
    }

    pub fn multiplyFloat(self: Vec3, f: f32) Vec3 {
        return Vec3{
            .x = self.x * f,
            .y = self.y * f,
            .z = self.z * f,
        };
    }

    pub fn mulComponentwise(self: Vec3, other: Vec3) Vec3 {
        return Vec3{
            .x = self.x * other.x,
            .y = self.y * other.y,
            .z = self.z * other.z,
        };
    }

    pub fn divComponentwise(self: Vec3, other: Vec3) Vec3 {
        return Vec3{
            .x = self.x / other.x,
            .y = self.y / other.y,
            .z = self.z / other.z,
        };
    }

    pub fn length(self: Vec3) f32 {
        return std.math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z);
    }

    pub fn squaredLength(self: Vec3) f32 {
        return self.x * self.x + self.y * self.y + self.z * self.z;
    }

    pub fn normalize(self: *Vec3) void {
        const len = self.length();

        basis.assertd(@src(), len > 0.0, "Zero Vec3 length in normalize().");

        const oneOverLen = 1.0 / len;
        self.x *= oneOverLen;
        self.y *= oneOverLen;
        self.z *= oneOverLen;
    }

    pub fn normalizeAndReturnPrevLength(self: *Vec3) f32 {
        const len = self.length();

        basis.assertd(@src(), len > 0.0, "Zero Vec3 length in normalizeAndReturnPrevLength().");

        const oneOverLen = 1.0 / len;
        self.x *= oneOverLen;
        self.y *= oneOverLen;
        self.z *= oneOverLen;

        return len;
    }

    pub fn normalized(self: Vec3) Vec3 {
        var n = self;
        n.normalize();
        return n;
    }

    pub fn negate(self: *Vec3) void {
        self.x *= -1.0;
        self.y *= -1.0;
        self.z *= -1.0;
    }

    pub fn negated(self: Vec3) Vec3 {
        var n = self;
        n.negate();
        return n;
    }

    pub fn lerp(p: f32, v0: Vec3, v1: Vec3) Vec3 {
        return Vec3{
            .x = basis.math.lerp(p, v0.x, v1.x),
            .y = basis.math.lerp(p, v0.y, v1.y),
            .z = basis.math.lerp(p, v0.z, v1.z),
        };
    }

    pub fn smoothStep(p: f32, v0: Vec3, v1: Vec3) Vec3 {
        return Vec3{
            .x = basis.math.smoothStep(p, v0.x, v1.x),
            .y = basis.math.smoothStep(p, v0.y, v1.y),
            .z = basis.math.smoothStep(p, v0.z, v1.z),
        };
    }

    /// Assumes the hypothetical w component v to be 1.0. ie. transforms points, not directions.
    pub fn transform(self: Vec3, matrix: Mat43) Vec3 {
        const x = matrix._11 * self.x + matrix._21 * self.y + matrix._31 * self.z + matrix._41;
        const y = matrix._12 * self.x + matrix._22 * self.y + matrix._32 * self.z + matrix._42;
        const z = matrix._13 * self.x + matrix._23 * self.y + matrix._33 * self.z + matrix._43;
        return Vec3.init(x, y, z);
    }

    //----------------------------------------------------

    pub fn deserialize(self: *Vec3, stream: *basis.BinaryReadStream) void {
        self.x = stream.getFloat();
        self.y = stream.getFloat();
        self.z = stream.getFloat();
    }

    pub fn serialize(self: Vec3, stream: *basis.BinaryWriteStream) void {
        stream.putFloat(self.x);
        stream.putFloat(self.y);
        stream.putFloat(self.z);
    }

    //----------------------------------------------------

    pub fn toInterop(self: Vec3) basis.bindings.InteropVec3 {
        return basis.bindings.InteropVec3{
            .x = self.x,
            .y = self.y,
            .z = self.z,
        };
    }

    pub fn fromInterop(interop: basis.bindings.InteropVec3) Vec3 {
        return Vec3{
            .x = interop.x,
            .y = interop.y,
            .z = interop.z,
        };
    }
};
