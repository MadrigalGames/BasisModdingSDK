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
const AABB = basis.math.AABB;
const Mat43 = basis.math.Mat43;

const PhysicsShapePtr = basis.physics.PhysicsShapePtr;
const PhysicsTransform = basis.physics.PhysicsTransform;

const GameObjectPtr = basis.game_object.GameObjectPtr;

//----------------------------------------------------

pub const PhysicsActorType = enum(u32) {
    RigidBodyDynamic = (1 << 0),
    RigidBodyStatic = (1 << 1),
    Trigger = (1 << 2),
    HeightField = (1 << 3),
    CharacterController = (1 << 4),

    pub fn asUint(self: PhysicsActorType) u32 {
        return @intFromEnum(self);
    }
};

//----------------------------------------------------

pub const TriggerBufferedEventType = enum(u32) {
    ObjectEntered = 0,
    ObjectExited,
};

pub const TriggerBufferedEvent = struct {
    eventType: TriggerBufferedEventType,
    otherActor: PhysicsActorPtr,
    otherActorRemoved: bool,
};

//----------------------------------------------------

pub const PhysicsActorPtr = struct {
    const Self = @This();
    pub const Null = initNull();
    cppPtr: basis.CppPtr,
    actorType: PhysicsActorType,

    pub fn initNull() Self {
        return Self{
            .cppPtr = 0,
            .actorType = PhysicsActorType.RigidBodyDynamic,
        };
    }

    pub fn isNull(self: *const Self) bool {
        return (self.cppPtr == 0);
    }

    pub fn setWorldTransform(self: *const Self, transform: PhysicsTransform) void {
        const interopPosition = transform.position.toInterop();
        const interopOrientation = transform.orientation.toInterop();
        basis.bindings.api.PhysicsActor_setWorldTransform(self.cppPtr, &interopPosition, &interopOrientation);
    }

    pub fn getWorldTransform(self: *const Self) PhysicsTransform {
        var interopPosition: basis.bindings.InteropVec3 = undefined;
        var interopOrientation: basis.bindings.InteropQuaternion = undefined;
        basis.bindings.api.PhysicsActor_getWorldTransform(self.cppPtr, &interopPosition, &interopOrientation);

        return PhysicsTransform.init(Vec3.fromInterop(interopPosition), Quaternion.fromInterop(interopOrientation));
    }

    pub fn getWorldMatrix(self: *const Self) Mat43 {
        const t = self.getWorldTransform();
        return Mat43.fromOrientationPosition(t.orientation, t.position);
    }

    pub fn setKinematicTarget(self: *const Self, transform: PhysicsTransform) void {
        basis.assert(@src(), self.actorType == PhysicsActorType.RigidBodyDynamic);
        const interopPosition = transform.position.toInterop();
        const interopOrientation = transform.orientation.toInterop();
        basis.bindings.api.PhysicsActor_setKinematicTarget(self.cppPtr, &interopPosition, &interopOrientation);
    }

    pub fn setMassData(self: *const Self, mass: f32, centerOfMass: basis.math.Vec3) void {
        basis.assert(@src(), self.actorType == PhysicsActorType.RigidBodyDynamic);
        const interopCoM = centerOfMass.toInterop();
        basis.bindings.api.PhysicsActor_setMassData(self.cppPtr, mass, &interopCoM);
    }

    pub fn setContactReportThreshold(self: *const Self, threshold: f32) void {
        basis.assert(@src(), self.actorType == PhysicsActorType.RigidBodyDynamic);
        basis.bindings.api.PhysicsActor_setContactReportThreshold(self.cppPtr, threshold);
    }

    pub fn getWorldBounds(self: *const Self) AABB {
        var interopMin: basis.bindings.InteropVec3 = undefined;
        var interopMax: basis.bindings.InteropVec3 = undefined;
        basis.bindings.api.PhysicsActor_getWorldBounds(self.cppPtr, &interopMin, &interopMax);
        return AABB{
            .min = Vec3.fromInterop(interopMin),
            .max = Vec3.fromInterop(interopMax),
            .hasPoints = true,
        };
    }

    pub fn associateWithGameObject(self: *const Self, gameObject: GameObjectPtr) void {
        basis.bindings.api.PhysicsActor_associateWithGameObject(self.cppPtr, gameObject.cppPtr);
    }

    pub fn getAssociatedGameObject(self: *const Self) GameObjectPtr {
        const gameObjectCppPtr = basis.bindings.api.PhysicsActor_getAssociatedGameObject(self.cppPtr);
        return GameObjectPtr{ .cppPtr = gameObjectCppPtr };
    }

    pub fn isSleeping(self: *const Self) bool {
        basis.assert(@src(), self.actorType == PhysicsActorType.RigidBodyDynamic);
        const sleeping = basis.bindings.api.PhysicsActor_isSleeping(self.cppPtr);
        return (sleeping == 1);
    }

    pub fn wakeUp(self: *const Self) void {
        basis.assert(@src(), self.actorType == PhysicsActorType.RigidBodyDynamic);
        basis.bindings.api.PhysicsActor_wakeUp(self.cppPtr);
    }

    pub fn putToSleep(self: *const Self) void {
        basis.assert(@src(), self.actorType == PhysicsActorType.RigidBodyDynamic);
        basis.bindings.api.PhysicsActor_putToSleep(self.cppPtr);
    }

    pub fn setLinearVelocity(self: *const Self, linVel: Vec3) void {
        basis.assert(@src(), self.actorType == PhysicsActorType.RigidBodyDynamic);
        const interopLinVel = linVel.toInterop();
        basis.bindings.api.PhysicsActor_setLinearVelocity(self.cppPtr, &interopLinVel);
    }

    pub fn getLinearVelocity(self: *const Self) Vec3 {
        basis.assert(@src(), self.actorType == PhysicsActorType.RigidBodyDynamic);
        var interopLinVel: basis.bindings.InteropVec3 = undefined;
        basis.bindings.api.PhysicsActor_getLinearVelocity(self.cppPtr, &interopLinVel);
        return Vec3.fromInterop(interopLinVel);
    }

    pub fn setAngularVelocity(self: *const Self, angVel: Vec3) void {
        basis.assert(@src(), self.actorType == PhysicsActorType.RigidBodyDynamic);
        const interopAngVel = angVel.toInterop();
        basis.bindings.api.PhysicsActor_setAngularVelocity(self.cppPtr, &interopAngVel);
    }

    pub fn getAngularVelocity(self: *const Self) Vec3 {
        basis.assert(@src(), self.actorType == PhysicsActorType.RigidBodyDynamic);
        var interopAngVel: basis.bindings.InteropVec3 = undefined;
        basis.bindings.api.PhysicsActor_getAngularVelocity(self.cppPtr, &interopAngVel);
        return Vec3.fromInterop(interopAngVel);
    }

    // The force and position are given in world coordinates.
    pub fn addForce(self: *const Self, force: Vec3, position: Vec3, wakeUpActor: bool) void {
        basis.assert(@src(), self.actorType == PhysicsActorType.RigidBodyDynamic);
        const interopForce = force.toInterop();
        const interopPosition = position.toInterop();
        basis.bindings.api.PhysicsActor_addForce(self.cppPtr, &interopForce, &interopPosition, wakeUpActor);
    }

    // The impulse and position are given in world coordinates.
    pub fn addImpulse(self: *const Self, impulse: Vec3, position: Vec3, wakeUpActor: bool) void {
        basis.assert(@src(), self.actorType == PhysicsActorType.RigidBodyDynamic);
        const interopImpulse = impulse.toInterop();
        const interopPosition = position.toInterop();
        basis.bindings.api.PhysicsActor_addImpulse(self.cppPtr, &interopImpulse, &interopPosition, wakeUpActor);
    }

    pub fn setSolverIterationCounts(self: *const Self, minPositionIters: u32, minVelocityIters: u32) void {
        basis.assert(@src(), self.actorType == PhysicsActorType.RigidBodyDynamic);
        basis.bindings.api.PhysicsActor_setSolverIterationCounts(self.cppPtr, minPositionIters, minVelocityIters);
    }

    pub fn setAngularDamping(self: *const Self, damping: f32) void {
        basis.assert(@src(), self.actorType == PhysicsActorType.RigidBodyDynamic);
        basis.bindings.api.PhysicsActor_setAngularDamping(self.cppPtr, damping);
    }

    pub fn setMaxAngularVelocity(self: *const Self, maxAngVel: f32) void {
        basis.assert(@src(), self.actorType == PhysicsActorType.RigidBodyDynamic);
        basis.bindings.api.PhysicsActor_setMaxAngularVelocity(self.cppPtr, maxAngVel);
    }

    pub fn addRef(self: *const Self) void {
        basis.bindings.api.PhysicsActor_addRef(self.cppPtr);
    }

    pub fn release(self: *const Self) void {
        if (self.cppPtr != 0) {
            basis.bindings.api.PhysicsActor_release(self.cppPtr);
        }
    }

    pub fn releaseAndZero(self: *Self) void {
        self.release();
        self.cppPtr = 0;
    }
};
