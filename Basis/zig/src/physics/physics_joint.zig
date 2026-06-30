// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const PhysicsTransform = basis.physics.PhysicsTransform;

// Note! Keep in sync with the C++ side.
pub const PhysicsJointType = enum(u32) {
    JointTypeFixed = 0,
    JointTypePrismatic, // aka slider
    JointTypeRevolute, // aka hinge
    JointTypeSpherical, // aka point-to-point
    JointTypeDistance,
    JointTypeDof6,
    JointTypeSphericalSpring,
};

// Note! Keep in sync with the C++ side.
pub const Dof6JointAxis = enum(u32) {
    AlongX = 0,
    AlongY,
    AlongZ,
    AroundX,
    AroundY,
    AroundZ,
};

// Note! Keep in sync with the C++ side.
pub const Dof6JointMotion = enum(u32) {
    Locked = 0,
    Limited,
    Free,
};

// Note! Keep in sync with the C++ side.
pub const Dof6JointDrive = enum(u32) {
    X = 0, // Drive along the X-axis
    Y, // Drive along the Y-axis
    Z, // Drive along the Z-axis
    Swing, // Rotational drive around the Y- and Z-axis
    Twist, // Rotational drive around the X-axis
    Slerp, // Drive of all three angular degrees along a SLERP-path (note: takes precedence over Swing/Twist)
};

pub const PhysicsJointPtr = struct {
    const Self = @This();
    pub const Null = initNull();
    cppPtr: basis.CppPtr,
    jointType: PhysicsJointType,

    pub fn initNull() PhysicsJointPtr {
        return PhysicsJointPtr{
            .cppPtr = 0,
            .jointType = PhysicsJointType.JointTypeFixed,
        };
    }

    pub fn isNull(self: *const Self) bool {
        return (self.cppPtr == 0);
    }

    pub fn enableProjection(self: *const Self, projectToActor0: bool, linearTolerance: f32, angularTolerance: f32) void {
        basis.bindings.api.PhysicsJoint_enableProjection(self.cppPtr, @intFromEnum(self.jointType), projectToActor0, linearTolerance, angularTolerance);
    }

    pub fn setBreakForce(self: *const Self, force: f32, torque: f32) void {
        basis.bindings.api.PhysicsJoint_setBreakForce(self.cppPtr, @intFromEnum(self.jointType), force, torque);
    }

    pub fn setDof6Motion(self: *const Self, axis: Dof6JointAxis, motion: Dof6JointMotion) void {
        basis.assertd(@src(), self.jointType == PhysicsJointType.JointTypeDof6, "Calling setDof6Motion() on a non-Dof6 joint.");
        basis.bindings.api.PhysicsJoint_setDof6Motion(self.cppPtr, @intFromEnum(axis), @intFromEnum(motion));
    }

    pub fn setDof6Drive(self: *const Self, drive: Dof6JointDrive, driveStiffness: f32, driveDamping: f32, driveForceLimit: f32, isAcceleration: bool) void {
        basis.assertd(@src(), self.jointType == PhysicsJointType.JointTypeDof6, "Calling setDof6Drive() on a non-Dof6 joint.");
        basis.bindings.api.PhysicsJoint_setDof6Drive(self.cppPtr, @intFromEnum(drive), driveStiffness, driveDamping, driveForceLimit, isAcceleration);
    }

    pub fn setDof6TwistLimit(self: *const Self, lower: f32, upper: f32) void {
        basis.assertd(@src(), self.jointType == PhysicsJointType.JointTypeDof6, "Calling setDof6TwistLimit() on a non-Dof6 joint.");
        basis.bindings.api.PhysicsJoint_setDof6TwistLimit(self.cppPtr, lower, upper);
    }

    pub fn setDriveGoalPose(self: *const Self, pose: PhysicsTransform) void {
        if (self.jointType != PhysicsJointType.JointTypeDof6) {
            return; // Only the Dof6 joint supports drives at the moment...
        }

        const interopPosition = pose.position.toInterop();
        const interopOrientation = pose.orientation.toInterop();
        basis.bindings.api.PhysicsJoint_setDriveGoalPose(self.cppPtr, @intFromEnum(self.jointType), &interopPosition, &interopOrientation);
    }

    pub fn getConstraintForce(self: *const Self, linear: ?*basis.math.Vec3, angular: ?*basis.math.Vec3) void {
        var interopLin = basis.bindings.InteropVec3{ .x = 0.0, .y = 0.0, .z = 0.0 };
        var interopAng = basis.bindings.InteropVec3{ .x = 0.0, .y = 0.0, .z = 0.0 };

        basis.bindings.api.PhysicsJoint_getConstraintForce(self.cppPtr, @intFromEnum(self.jointType), &interopLin, &interopAng);

        if (linear) |v| {
            v.* = basis.math.Vec3.fromInterop(interopLin);
        }

        if (angular) |v| {
            v.* = basis.math.Vec3.fromInterop(interopAng);
        }
    }

    pub fn setInvMassScale0(self: *const Self, invMassScale: f32) void {
        basis.bindings.api.PhysicsJoint_setInvMassScale0(self.cppPtr, @intFromEnum(self.jointType), invMassScale);
    }

    pub fn setInvInertiaScale0(self: *const Self, invInertiaScale: f32) void {
        basis.bindings.api.PhysicsJoint_setInvInertiaScale0(self.cppPtr, @intFromEnum(self.jointType), invInertiaScale);
    }

    pub fn setInvMassScale1(self: *const Self, invMassScale: f32) void {
        basis.bindings.api.PhysicsJoint_setInvMassScale1(self.cppPtr, @intFromEnum(self.jointType), invMassScale);
    }

    pub fn setInvInertiaScale1(self: *const Self, invInertiaScale: f32) void {
        basis.bindings.api.PhysicsJoint_setInvInertiaScale1(self.cppPtr, @intFromEnum(self.jointType), invInertiaScale);
    }

    pub fn getInvMassScale0(self: *const Self) f32 {
        return basis.bindings.api.PhysicsJoint_getInvMassScale0(self.cppPtr, @intFromEnum(self.jointType));
    }

    pub fn getInvInertiaScale0(self: *const Self) f32 {
        return basis.bindings.api.PhysicsJoint_getInvInertiaScale0(self.cppPtr, @intFromEnum(self.jointType));
    }

    pub fn getInvMassScale1(self: *const Self) f32 {
        return basis.bindings.api.PhysicsJoint_getInvMassScale1(self.cppPtr, @intFromEnum(self.jointType));
    }

    pub fn getInvInertiaScale1(self: *const Self) f32 {
        return basis.bindings.api.PhysicsJoint_getInvInertiaScale1(self.cppPtr, @intFromEnum(self.jointType));
    }

    pub fn addRef(self: *const Self) void {
        basis.bindings.api.PhysicsJoint_addRef(self.cppPtr, @intFromEnum(self.jointType));
    }

    pub fn release(self: *const Self) void {
        if (self.cppPtr != 0) {
            basis.bindings.api.PhysicsJoint_release(self.cppPtr, @intFromEnum(self.jointType));
        }
    }

    pub fn releaseAndZero(self: *Self) void {
        self.release();
        self.cppPtr = 0;
    }
};
