// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Vec3 = basis.math.Vec3;

pub const DisplacementEffectID = u32;

pub const DisplacementEffectRendererPtr = struct {
    const Self = @This();
    pub const Null = initNull();
    cppPtr: basis.CppPtr,

    pub fn initNull() Self {
        return Self{ .cppPtr = 0 };
    }

    pub fn createShockwaveEffect(self: *const Self, position: Vec3, radius: f32, duration: f32) DisplacementEffectID {
        const pos = position.toInterop();
        return basis.bindings.api.DisplacementEffectRenderer_createShockwaveEffect(self.cppPtr, &pos, radius, duration);
    }

    pub fn createForceFieldEffect(self: *const Self, position: Vec3, radius: f32, animationSpeed: f32) DisplacementEffectID {
        const pos = position.toInterop();
        return basis.bindings.api.DisplacementEffectRenderer_createForceFieldEffect(self.cppPtr, &pos, radius, animationSpeed);
    }

    pub fn createGravityCraneEffect(self: *const Self, position: Vec3, radius: f32, animationSpeed: f32) DisplacementEffectID {
        const pos = position.toInterop();
        return basis.bindings.api.DisplacementEffectRenderer_createGravityCraneEffect(self.cppPtr, &pos, radius, animationSpeed);
    }

    pub fn setEffectCutoffDistance(self: *const Self, id: DisplacementEffectID, cutoffDistance: f32) void {
        basis.bindings.api.DisplacementEffectRenderer_setEffectCutoffDistance(self.cppPtr, id, cutoffDistance);
    }

    pub fn setEffectPosition(self: *const Self, id: DisplacementEffectID, position: Vec3) void {
        const pos = position.toInterop();
        basis.bindings.api.DisplacementEffectRenderer_setEffectPosition(self.cppPtr, id, &pos);
    }

    pub fn setEffectStrength(self: *const Self, id: DisplacementEffectID, strength: f32) void {
        basis.bindings.api.DisplacementEffectRenderer_setEffectStrength(self.cppPtr, id, strength);
    }

    pub fn stopEffect(self: *const Self, id: DisplacementEffectID) void {
        basis.bindings.api.DisplacementEffectRenderer_stopEffect(self.cppPtr, id);
    }

    pub fn killEffect(self: *const Self, id: DisplacementEffectID) void {
        basis.bindings.api.DisplacementEffectRenderer_killEffect(self.cppPtr, id);
    }

    pub fn killAllEffects(self: *const Self) void {
        basis.bindings.api.DisplacementEffectRenderer_killAllEffects(self.cppPtr);
    }
};
