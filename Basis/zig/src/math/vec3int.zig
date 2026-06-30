// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

pub const Vec3Int = struct {
    x: i32,
    y: i32,
    z: i32,

    pub const Zero = init(0, 0, 0);
    pub const One = init(1, 1, 1);
    pub const UnitX = init(1, 0, 0);
    pub const UnitY = init(0, 1, 0);
    pub const UnitZ = init(0, 0, 1);

    pub fn init(x: i32, y: i32, z: i32) Vec3Int {
        return Vec3Int{
            .x = x,
            .y = y,
            .z = z,
        };
    }

    pub fn initFromSlice(slice: []const i32) Vec3Int {
        return Vec3Int{
            .x = slice[0],
            .y = slice[1],
            .z = slice[2],
        };
    }

    pub fn setXY(self: *Vec3Int, x: i32, y: i32, z: i32) void {
        self.x = x;
        self.y = y;
        self.z = z;
    }

    pub fn add(self: Vec3Int, other: Vec3Int) Vec3Int {
        return Vec3Int{
            .x = self.x + other.x,
            .y = self.y + other.y,
            .z = self.z + other.z,
        };
    }

    pub fn sub(self: Vec3Int, other: Vec3Int) Vec3Int {
        return Vec3Int{
            .x = self.x - other.x,
            .y = self.y - other.y,
            .z = self.z - other.z,
        };
    }

    pub fn multiplyInt(self: Vec3Int, i: i32) Vec3Int {
        return Vec3Int{
            .x = self.x * i,
            .y = self.y * i,
            .z = self.z * i,
        };
    }
};
