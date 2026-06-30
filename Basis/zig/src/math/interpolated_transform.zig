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
const TransformInterpolator = basis.math.TransformInterpolator;
const SceneNodePtr = basis.math.SceneNodePtr;

// A helper struct to make working with interpolated transforms easier.
// Use set() or set the position and orientation directly to update the transform.
// Every tick, call tick() to make sure the interpolator is updated at the correct time.
// Use getInterpolatedTransform() or applyToSceneNode() every update to apply the
// interpolated transform to a mesh or some other visual object that needs interpolation.
pub const InterpolatedTransform = struct {
    const Self = @This();

    //----------------------------------------------------

    position: Vec3 = .Zero,
    orientation: Quaternion = .Identity,
    interpolator: TransformInterpolator = .{},

    //----------------------------------------------------

    pub fn set(self: *Self, position: Vec3, orientation: Quaternion) void {
        self.position = position;
        self.orientation = orientation;
    }

    pub fn tick(self: *Self) void {
        self.interpolator.pushTransform(self.position, self.orientation);
    }

    pub fn getInterpolatedTransform(
        self: *const Self,
        interpolationFactor: f32,
        position: *Vec3,
        orientation: *Quaternion,
    ) void {
        self.interpolator.getInterpolatedTransform(interpolationFactor, position, orientation);
    }

    pub fn applyToSceneNode(
        self: *const Self,
        interpolationFactor: f32,
        sceneNode: SceneNodePtr,
    ) void {
        var p = Vec3.Zero;
        var o = Quaternion.Identity;

        self.interpolator.getInterpolatedTransform(interpolationFactor, &p, &o);

        sceneNode.setPosition(p);
        sceneNode.setOrientation(o);
    }

    pub fn applyToSceneNodeInSpace(
        self: *const Self,
        interpolationFactor: f32,
        sceneNode: SceneNodePtr,
        space: basis.math.CoordinateSpace,
        immediateUpdate: bool,
    ) void {
        var p = Vec3.Zero;
        var o = Quaternion.Identity;

        self.interpolator.getInterpolatedTransform(interpolationFactor, &p, &o);

        sceneNode.setPositionInSpace(p, space, immediateUpdate);
        sceneNode.setOrientationInSpace(o, space, immediateUpdate);
    }
};
