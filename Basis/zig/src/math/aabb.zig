// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Vec3 = basis.math.Vec3;

pub const AABB = struct {
    const Self = @This();
    pub const Empty = initEmpty();

    min: Vec3,
    max: Vec3,
    hasPoints: bool,

    pub fn init(min: Vec3, max: Vec3) Self {
        var self = initEmpty();
        self.addPoint(min);
        self.addPoint(max);
        return self;
    }

    pub fn initEmpty() AABB {
        return Self{
            .min = Vec3.init(basis.math.LargestNumber, basis.math.LargestNumber, basis.math.LargestNumber),
            .max = Vec3.init(-basis.math.LargestNumber, -basis.math.LargestNumber, -basis.math.LargestNumber),
            .hasPoints = false,
        };
    }

    pub fn clear(self: *Self) void {
        self.min = Vec3.init(basis.math.LargestNumber, basis.math.LargestNumber, basis.math.LargestNumber);
        self.max = Vec3.init(-basis.math.LargestNumber, -basis.math.LargestNumber, -basis.math.LargestNumber);
        self.hasPoints = false;
    }

    pub fn addPoint(self: *Self, point: Vec3) void {
        if (point.x > self.max.x) self.max.x = point.x;
        if (point.x < self.min.x) self.min.x = point.x;
        if (point.y > self.max.y) self.max.y = point.y;
        if (point.y < self.min.y) self.min.y = point.y;
        if (point.z > self.max.z) self.max.z = point.z;
        if (point.z < self.min.z) self.min.z = point.z;

        self.hasPoints = true;
    }

    pub fn addAABB(self: *Self, aabb: AABB) void {
        self.addPoint(aabb.min);
        self.addPoint(aabb.max);
    }

    pub fn getSize(self: *const Self) Vec3 {
        return self.max.sub(self.min);
    }

    pub fn getCenterAndExtents(self: Self, center: *Vec3, extents: *Vec3) void {
        center.* = self.min.add(self.max).multiplyFloat(0.5);
        extents.* = self.max.sub(self.min).multiplyFloat(0.5);
    }

    pub fn getCorner(self: Self, cornerIndex: usize) Vec3 {
        basis.assert(@src(), cornerIndex < 8);

        return switch (cornerIndex) {
            0 => self.min,
            1 => Vec3.init(self.max.x, self.min.y, self.min.z),
            2 => Vec3.init(self.min.x, self.min.y, self.max.z),
            3 => Vec3.init(self.max.x, self.min.y, self.max.z),
            4 => Vec3.init(self.min.x, self.max.y, self.min.z),
            5 => Vec3.init(self.max.x, self.max.y, self.min.z),
            6 => Vec3.init(self.min.x, self.max.y, self.max.z),
            else => self.max,
        };
    }

    pub fn scale(self: *Self, s: f32) void {
        if (!self.hasPoints) return;

        var center: Vec3 = Vec3.Zero;
        var extents: Vec3 = Vec3.Zero;

        self.getCenterAndExtents(&center, &extents);

        if (basis.math.vec3sAlmostEqual(extents, Vec3.Zero)) return;

        self.min = center.sub(extents.multiplyFloat(s));
        self.max = center.add(extents.multiplyFloat(s));
    }

    pub fn containsVec3(self: Self, point: Vec3) bool {
        return (point.x >= self.min.x) and (point.x <= self.max.x) and
            (point.y >= self.min.y) and (point.y <= self.max.y) and
            (point.z >= self.min.z) and (point.z <= self.max.z);
    }

    pub fn containsAABB(self: Self, aabb: AABB) bool {
        return self.containsVec3(aabb.max) and self.containsVec3(aabb.min);
    }

    pub fn intersectsRay(self: Self, rayOrigin: Vec3, rayDirection: Vec3) bool {
        return self.intersectsRayEx(rayOrigin, rayDirection, 0.0, basis.math.LargeNumber, null);
    }

    pub fn intersectsRayEx(self: Self, rayOrigin: Vec3, rayDirection: Vec3, nearClip: f32, farClip: f32, distance: ?*f32) bool {
        if (!self.hasPoints) return false;

        // Based on "An Efficient and Robust Ray-Box Intersection Algorithm"
        // Williams, Barrus, Morley and Shirley. University of Utah.
        // http://www.cs.utah.edu/~awilliam/box/box.pdf

        const inverseDir = Vec3.init(1.0 / rayDirection.x, 1.0 / rayDirection.y, 1.0 / rayDirection.z);
        const inverseDirSigns = [_]usize{ @intFromBool(inverseDir.x < 0), @intFromBool(inverseDir.y < 0), @intFromBool(inverseDir.z < 0) };
        const bounds = [_]Vec3{ self.min, self.max };

        var tmin = (bounds[inverseDirSigns[0]].x - rayOrigin.x) * inverseDir.x;
        var tmax = (bounds[1 - inverseDirSigns[0]].x - rayOrigin.x) * inverseDir.x;
        const tymin = (bounds[inverseDirSigns[1]].y - rayOrigin.y) * inverseDir.y;
        const tymax = (bounds[1 - inverseDirSigns[1]].y - rayOrigin.y) * inverseDir.y;

        if ((tmin > tymax) or (tymin > tmax))
            return false;

        if (tymin > tmin)
            tmin = tymin;

        if (tymax < tmax)
            tmax = tymax;

        const tzmin = (bounds[inverseDirSigns[2]].z - rayOrigin.z) * inverseDir.z;
        const tzmax = (bounds[1 - inverseDirSigns[2]].z - rayOrigin.z) * inverseDir.z;

        if ((tmin > tzmax) or (tzmin > tmax))
            return false;

        if (tzmin > tmin)
            tmin = tzmin;

        if (tzmax < tmax)
            tmax = tzmax;

        if ((tmin < farClip) and (tmax > nearClip)) {
            if (distance) |dist| {
                dist.* = @max(tmin, tymin);
                dist.* = @max(tzmin, dist.*);
            }
            return true;
        }

        return false;
    }

    pub fn debugDraw(self: Self) void {
        self.debugDrawWithColor(basis.Color.White);
    }

    pub fn debugDrawWithColor(self: Self, color: basis.Color) void {
        const minA = self.min;
        const minB = Vec3.init(self.min.x, self.max.y, self.min.z);
        const minC = Vec3.init(self.min.x, self.max.y, self.max.z);
        const minD = Vec3.init(self.min.x, self.min.y, self.max.z);

        const maxA = Vec3.init(self.max.x, self.min.y, self.min.z);
        const maxB = Vec3.init(self.max.x, self.max.y, self.min.z);
        const maxC = self.max;
        const maxD = Vec3.init(self.max.x, self.min.y, self.max.z);

        basis.debug_draw.drawLine3D(minA, minB, color);
        basis.debug_draw.drawLine3D(minB, minC, color);
        basis.debug_draw.drawLine3D(minC, minD, color);
        basis.debug_draw.drawLine3D(minD, minA, color);

        basis.debug_draw.drawLine3D(maxA, maxB, color);
        basis.debug_draw.drawLine3D(maxB, maxC, color);
        basis.debug_draw.drawLine3D(maxC, maxD, color);
        basis.debug_draw.drawLine3D(maxD, maxA, color);

        basis.debug_draw.drawLine3D(minA, maxA, color);
        basis.debug_draw.drawLine3D(minB, maxB, color);
        basis.debug_draw.drawLine3D(minC, maxC, color);
        basis.debug_draw.drawLine3D(minD, maxD, color);
    }

    pub fn debugDrawWithColorAndTransform(self: Self, color: basis.Color, transform: basis.math.Mat43) void {
        const minA = transform.transformPoint(self.min);
        const minB = transform.transformPoint(Vec3.init(self.min.x, self.max.y, self.min.z));
        const minC = transform.transformPoint(Vec3.init(self.min.x, self.max.y, self.max.z));
        const minD = transform.transformPoint(Vec3.init(self.min.x, self.min.y, self.max.z));

        const maxA = transform.transformPoint(Vec3.init(self.max.x, self.min.y, self.min.z));
        const maxB = transform.transformPoint(Vec3.init(self.max.x, self.max.y, self.min.z));
        const maxC = transform.transformPoint(self.max);
        const maxD = transform.transformPoint(Vec3.init(self.max.x, self.min.y, self.max.z));

        basis.debug_draw.drawLine3D(minA, minB, color);
        basis.debug_draw.drawLine3D(minB, minC, color);
        basis.debug_draw.drawLine3D(minC, minD, color);
        basis.debug_draw.drawLine3D(minD, minA, color);

        basis.debug_draw.drawLine3D(maxA, maxB, color);
        basis.debug_draw.drawLine3D(maxB, maxC, color);
        basis.debug_draw.drawLine3D(maxC, maxD, color);
        basis.debug_draw.drawLine3D(maxD, maxA, color);

        basis.debug_draw.drawLine3D(minA, maxA, color);
        basis.debug_draw.drawLine3D(minB, maxB, color);
        basis.debug_draw.drawLine3D(minC, maxC, color);
        basis.debug_draw.drawLine3D(minD, maxD, color);
    }

    //----------------------------------------------------

    pub fn deserialize(self: *Self, stream: *basis.BinaryReadStream) void {
        self.clear();

        var min: Vec3 = Vec3.Zero;
        var max: Vec3 = Vec3.Zero;

        min.deserialize(stream);
        max.deserialize(stream);

        self.addPoint(min);
        self.addPoint(max);
    }

    pub fn serialize(self: Self, stream: *basis.BinaryWriteStream) void {
        self.min.serialize(stream);
        self.max.serialize(stream);
    }

    //----------------------------------------------------
};
