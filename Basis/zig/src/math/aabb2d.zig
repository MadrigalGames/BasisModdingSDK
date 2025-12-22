// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Vec2 = basis.math.Vec2;

pub const AABB2D = struct {
    const Self = @This();

    pub const UnitBounds = init(0.0, 0.0, 1.0, 1.0);

    min: Vec2,
    max: Vec2,
    hasPoints: bool,

    pub fn init(minX: f32, minY: f32, maxX: f32, maxY: f32) AABB2D {
        return Self{
            .min = Vec2.init(minX, minY),
            .max = Vec2.init(maxX, maxY),
            .hasPoints = true,
        };
    }

    pub fn initFromVec2(min: Vec2, max: Vec2) AABB2D {
        return Self{
            .min = min,
            .max = max,
            .hasPoints = true,
        };
    }

    pub fn initEmpty() AABB2D {
        return Self{
            .min = Vec2.init(basis.math.LargestNumber, basis.math.LargestNumber),
            .max = Vec2.init(-basis.math.LargestNumber, -basis.math.LargestNumber),
            .hasPoints = false,
        };
    }

    pub fn clear(self: *Self) void {
        self.min = Vec2.init(basis.math.LargestNumber, basis.math.LargestNumber);
        self.max = Vec2.init(-basis.math.LargestNumber, -basis.math.LargestNumber);
        self.hasPoints = false;
    }

    pub fn addPoint(self: *Self, point: Vec2) void {
        if (point.x > self.max.x) self.max.x = point.x;
        if (point.x < self.min.x) self.min.x = point.x;
        if (point.y > self.max.y) self.max.y = point.y;
        if (point.y < self.min.y) self.min.y = point.y;

        self.hasPoints = true;
    }

    pub fn addPointXY(self: *Self, x: f32, y: f32) void {
        self.addPoint(basis.math.Vec2.init(x, y));
    }

    pub fn addAABB(self: *Self, aabb: AABB2D) void {
        self.addPoint(aabb.min);
        self.addPoint(aabb.max);
    }

    pub fn getXSize(self: *const Self) f32 {
        return self.max.x - self.min.x;
    }

    pub fn getYSize(self: *const Self) f32 {
        return self.max.y - self.min.y;
    }

    pub fn getSize(self: *const Self) Vec2 {
        return self.max.sub(self.min);
    }

    //----------------------------------------------------

    pub fn deserialize(self: *Self, stream: *basis.BinaryReadStream) void {
        self.clear();

        var min: Vec2 = Vec2.Zero;
        var max: Vec2 = Vec2.Zero;

        min.deserialize(stream);
        max.deserialize(stream);

        self.addPoint(min);
        self.addPoint(max);
    }

    pub fn serialize(self: Self, stream: *basis.BinaryWriteStream) void {
        self.min.serialize(stream);
        self.max.serialize(stream);
    }
};
