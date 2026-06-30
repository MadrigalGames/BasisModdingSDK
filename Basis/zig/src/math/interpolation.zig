// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Vec3 = basis.math.Vec3;
const Quaternion = basis.math.Quaternion;

pub const TransformInterpolator = struct {
    const Self = @This();

    const Transform = struct {
        p: Vec3,
        o: Quaternion,
    };

    hasTransforms: bool = false,
    current: Transform = .{ .p = .Zero, .o = .Identity },
    previous: Transform = .{ .p = .Zero, .o = .Identity },

    //----------------------------------------------------

    pub fn pushTransform(self: *Self, position: Vec3, orientation: Quaternion) void {
        if (!self.hasTransforms) {
            // The first time we push a transform we need to push the transform to both current and previous.
            self.current.p = position;
            self.current.o = orientation;
            self.hasTransforms = true;
        }

        // Store the previous transform.
        self.previous.p = self.current.p;
        self.previous.o = self.current.o;

        // Push the new transform.
        self.current.p = position;
        self.current.o = orientation;
    }

    pub fn getInterpolatedTransform(
        self: *const Self,
        interpolationFactor: f32,
        position: *Vec3,
        orientation: *Quaternion,
    ) void {
        if (self.hasTransforms) {
            position.* = Vec3.lerp(interpolationFactor, self.previous.p, self.current.p);
            orientation.* = Quaternion.slerp(interpolationFactor, self.previous.o, self.current.o);
        }
    }

    pub fn clear(self: *Self) void {
        self.hasTransforms = false;
    }
};

pub const VectorInterpolator = struct {
    const Self = @This();

    hasValues: bool = false,
    current: Vec3 = .Zero,
    previous: Vec3 = .Zero,

    //----------------------------------------------------

    pub fn pushVector(self: *Self, value: Vec3) void {
        if (!self.hasValues) {
            // The first time we push a value we need to push the value to both current and previous.
            self.current = value;
            self.hasValues = true;
        }

        // Store the previous value.
        self.previous = self.current;

        // Push the new value.
        self.current = value;
    }

    pub fn getInterpolatedVector(self: *const Self, interpolationFactor: f32) Vec3 {
        if (self.hasValues) {
            return Vec3.lerp(interpolationFactor, self.previous, self.current);
        }

        return Vec3.Zero;
    }

    pub fn clear(self: *Self) void {
        self.hasValues = false;
    }
};

pub const QuaternionInterpolator = struct {
    const Self = @This();

    hasValues: bool = false,
    current: Quaternion = .Identity,
    previous: Quaternion = .Identity,

    //----------------------------------------------------

    pub fn pushQuaternion(self: *Self, value: Quaternion) void {
        if (!self.hasValues) {
            // The first time we push a value we need to push the value to both current and previous.
            self.current = value;
            self.hasValues = true;
        }

        // Store the previous value.
        self.previous = self.current;

        // Push the new value.
        self.current = value;
    }

    pub fn getInterpolatedQuaternion(self: *const Self, interpolationFactor: f32) Quaternion {
        if (self.hasValues) {
            return Quaternion.slerp(interpolationFactor, self.previous, self.current);
        }

        return Quaternion.Identity;
    }

    pub fn clear(self: *Self) void {
        self.hasValues = false;
    }
};

pub const FloatInterpolator = struct {
    const Self = @This();

    hasValues: bool = false,
    current: f32 = 0.0,
    previous: f32 = 0.0,

    //----------------------------------------------------

    pub fn pushFloat(self: *Self, value: f32) void {
        if (!self.hasValues) {
            // The first time we push a value we need to push the value to both current and previous.
            self.current = value;
            self.hasValues = true;
        }

        // Store the previous value.
        self.previous = self.current;

        // Push the new value.
        self.current = value;
    }

    pub fn getInterpolatedFloat(self: *const Self, interpolationFactor: f32) f32 {
        if (self.hasValues) {
            return basis.math.lerp(interpolationFactor, self.previous, self.current);
        }

        return 0.0;
    }

    pub fn clear(self: *Self) void {
        self.hasValues = false;
    }
};
