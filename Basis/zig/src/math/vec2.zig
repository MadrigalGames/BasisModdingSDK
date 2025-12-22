// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

pub const Vec2 = struct {
    x: f32,
    y: f32,

    pub const Zero = init(0.0, 0.0);
    pub const One = init(1.0, 1.0);
    pub const UnitX = init(1.0, 0.0);
    pub const UnitY = init(0.0, 1.0);

    pub fn init(x: f32, y: f32) Vec2 {
        return Vec2{
            .x = x,
            .y = y,
        };
    }

    pub fn initFromSlice(slice: []const f32) Vec2 {
        return Vec2{
            .x = slice[0],
            .y = slice[1],
        };
    }

    pub fn initFromJsonArray(array: std.json.Array) Vec2 {
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

        return Vec2.init(x, y);
    }

    pub fn setXY(self: *Vec2, x: f32, y: f32) void {
        self.x = x;
        self.y = y;
    }

    pub fn dot(self: Vec2, other: Vec2) f32 {
        return self.x * other.x + self.y * other.y;
    }

    pub fn perpDot(self: Vec2, other: Vec2) f32 {
        return self.y * other.x - self.x * other.y;
    }

    pub fn add(self: Vec2, other: Vec2) Vec2 {
        return Vec2{
            .x = self.x + other.x,
            .y = self.y + other.y,
        };
    }

    pub fn sub(self: Vec2, other: Vec2) Vec2 {
        return Vec2{
            .x = self.x - other.x,
            .y = self.y - other.y,
        };
    }

    pub fn multiplyFloat(self: Vec2, f: f32) Vec2 {
        return Vec2{
            .x = self.x * f,
            .y = self.y * f,
        };
    }

    pub fn length(self: Vec2) f32 {
        return std.math.sqrt(self.x * self.x + self.y * self.y);
    }

    pub fn squaredLength(self: Vec2) f32 {
        return self.x * self.x + self.y * self.y;
    }

    pub fn normalize(self: *Vec2) void {
        const len = self.length();

        basis.assertd(@src(), len > 0.0, "Zero Vec2 length in normalize().");

        const oneOverLen = 1.0 / len;
        self.x *= oneOverLen;
        self.y *= oneOverLen;
    }

    pub fn normalizeAndReturnPrevLength(self: *Vec2) f32 {
        const len = self.length();

        basis.assertd(@src(), len > 0.0, "Zero Vec2 length in normalizeAndReturnPrevLength().");

        const oneOverLen = 1.0 / len;
        self.x *= oneOverLen;
        self.y *= oneOverLen;

        return len;
    }

    pub fn normalized(self: Vec2) Vec2 {
        var n = self;
        n.normalize();
        return n;
    }

    pub fn lerp(p: f32, v0: Vec2, v1: Vec2) Vec2 {
        return Vec2{
            .x = basis.math.lerp(p, v0.x, v1.x),
            .y = basis.math.lerp(p, v0.y, v1.y),
        };
    }

    pub fn smoothStep(p: f32, v0: Vec2, v1: Vec2) Vec2 {
        return Vec2{
            .x = basis.math.smoothStep(p, v0.x, v1.x),
            .y = basis.math.smoothStep(p, v0.y, v1.y),
        };
    }

    //----------------------------------------------------

    pub fn deserialize(self: *Vec2, stream: *basis.BinaryReadStream) void {
        self.x = stream.getFloat();
        self.y = stream.getFloat();
    }

    pub fn serialize(self: Vec2, stream: *basis.BinaryWriteStream) void {
        stream.putFloat(self.x);
        stream.putFloat(self.y);
    }

    //----------------------------------------------------

    pub fn toInterop(self: Vec2) basis.bindings.InteropVec2 {
        return basis.bindings.InteropVec2{
            .x = self.x,
            .y = self.y,
        };
    }

    pub fn fromInterop(interop: basis.bindings.InteropVec2) Vec2 {
        return Vec2{
            .x = interop.x,
            .y = interop.y,
        };
    }
};
