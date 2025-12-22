// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

pub const Vec2Int = struct {
    x: i32,
    y: i32,

    pub const Zero = init(0, 0);
    pub const One = init(1, 1);
    pub const UnitX = init(1, 0);
    pub const UnitY = init(0, 1);

    pub fn init(x: i32, y: i32) Vec2Int {
        return Vec2Int{
            .x = x,
            .y = y,
        };
    }

    pub fn initFromSlice(slice: []const i32) Vec2Int {
        return Vec2Int{
            .x = slice[0],
            .y = slice[1],
        };
    }

    pub fn setXY(self: *Vec2Int, x: i32, y: i32) void {
        self.x = x;
        self.y = y;
    }

    pub fn add(self: Vec2Int, other: Vec2Int) Vec2Int {
        return Vec2Int{
            .x = self.x + other.x,
            .y = self.y + other.y,
        };
    }

    pub fn sub(self: Vec2Int, other: Vec2Int) Vec2Int {
        return Vec2Int{
            .x = self.x - other.x,
            .y = self.y - other.y,
        };
    }

    pub fn multiplyInt(self: Vec2Int, i: i32) Vec2Int {
        return Vec2Int{
            .x = self.x * i,
            .y = self.y * i,
        };
    }
};
