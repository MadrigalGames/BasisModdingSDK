// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Vec3 = basis.math.Vec3;

pub const TireID = u32;
pub const StaticTireTrackID = u32;

pub const TireTrackRendererPtr = struct {
    const Self = @This();
    cppPtr: basis.CppPtr,

    pub fn initNull() Self {
        return Self{ .cppPtr = 0 };
    }

    //----------------------------------------------------

    pub fn clear(self: *const Self) void {
        basis.bindings.api.TireTrackRenderer_clear(self.cppPtr);
    }

    //----------------------------------------------------

    // Dynamic tracks:

    pub fn registerTire(self: *const Self, width: f32, isRightSideTire: bool, tireType: u32) TireID {
        return basis.bindings.api.TireTrackRenderer_registerTire(self.cppPtr, width, isRightSideTire, tireType);
    }

    pub fn unregisterTire(self: *const Self, id: TireID) void {
        basis.bindings.api.TireTrackRenderer_unregisterTire(self.cppPtr, id);
    }

    pub fn beginTireTrack(self: *const Self, id: TireID) void {
        basis.bindings.api.TireTrackRenderer_beginTireTrack(self.cppPtr, id);
    }

    pub fn endTireTrack(self: *const Self, id: TireID) void {
        basis.bindings.api.TireTrackRenderer_endTireTrack(self.cppPtr, id);
    }

    pub fn updateTireTrack(self: *const Self, id: TireID, contactPosition: Vec3, movementDirection: Vec3, longitudinalSlip: f32, lateralSlip: f32, groundNormal: Vec3) void {
        const interopPos = Vec3.toInterop(contactPosition);
        const interopDir = Vec3.toInterop(movementDirection);
        const interopNormal = Vec3.toInterop(groundNormal);
        basis.bindings.api.TireTrackRenderer_updateTireTrack(self.cppPtr, id, &interopPos, &interopDir, longitudinalSlip, lateralSlip, &interopNormal);
    }

    //----------------------------------------------------

    // Static tracks:

    pub fn beginStaticTireTrack(self: *const Self, width: f32, isRightSideTire: bool, tireType: u32) StaticTireTrackID {
        return basis.bindings.api.TireTrackRenderer_beginStaticTireTrack(self.cppPtr, width, isRightSideTire, tireType);
    }

    pub fn addPointToStaticTireTrack(self: *const Self, id: StaticTireTrackID, contactPosition: Vec3, movementDirection: Vec3, longitudinalSlip: f32, lateralSlip: f32, groundNormal: Vec3, alpha: f32) void {
        const interopPos = Vec3.toInterop(contactPosition);
        const interopDir = Vec3.toInterop(movementDirection);
        const interopNormal = Vec3.toInterop(groundNormal);
        basis.bindings.api.TireTrackRenderer_addPointToStaticTireTrack(self.cppPtr, id, &interopPos, &interopDir, longitudinalSlip, lateralSlip, &interopNormal, alpha);
    }

    pub fn endStaticTireTrack(self: *const Self, id: StaticTireTrackID) void {
        basis.bindings.api.TireTrackRenderer_endStaticTireTrack(self.cppPtr, id);
    }

    pub fn removeStaticTireTrack(self: *const Self, id: StaticTireTrackID) void {
        basis.bindings.api.TireTrackRenderer_removeStaticTireTrack(self.cppPtr, id);
    }
};
