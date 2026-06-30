// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Vec3 = basis.math.Vec3;

const PhysicsActorPtr = basis.physics.PhysicsActorPtr;
const PhysicsActorType = basis.physics.PhysicsActorType;
const VehicleControllerPtr = basis.physics.vehicle_controller.VehicleControllerPtr;
const PhysicsJointPtr = basis.physics.PhysicsJointPtr;
const PhysicsShapePtr = basis.physics.PhysicsShapePtr;
const PhysicsMaterialPtr = basis.physics.PhysicsMaterialPtr;

const GameObjectPtr = basis.game_object.GameObjectPtr;

//----------------------------------------------------

pub const PhysicsScenePtr = struct {
    const Self = @This();
    pub const Null = initNull();
    cppPtr: basis.CppPtr,

    pub fn initNull() Self {
        return Self{
            .cppPtr = 0,
        };
    }

    pub fn isNull(self: *const Self) bool {
        return (self.cppPtr == 0);
    }

    pub fn addActor(self: *const Self, actor: PhysicsActorPtr) void {
        basis.bindings.api.PhysicsScene_addActor(self.cppPtr, actor.cppPtr);
    }

    pub fn removeActor(self: *const Self, actor: PhysicsActorPtr) void {
        basis.bindings.api.PhysicsScene_removeActor(self.cppPtr, actor.cppPtr);
    }

    pub fn addJoint(self: *const Self, joint: PhysicsJointPtr) void {
        basis.bindings.api.PhysicsScene_addJoint(self.cppPtr, joint.cppPtr, @intFromEnum(joint.jointType));
    }

    pub fn removeJoint(self: *const Self, joint: PhysicsJointPtr) void {
        basis.bindings.api.PhysicsScene_removeJoint(self.cppPtr, joint.cppPtr, @intFromEnum(joint.jointType));
    }

    pub fn addVehicleController(self: *const Self, controller: VehicleControllerPtr) void {
        basis.bindings.api.PhysicsScene_addVehicleController(self.cppPtr, controller.cppPtr);
    }

    pub fn removeVehicleController(self: *const Self, controller: VehicleControllerPtr) void {
        basis.bindings.api.PhysicsScene_removeVehicleController(self.cppPtr, controller.cppPtr);
    }

    pub fn applyRadialForce(self: *const Self, center: Vec3, radius: f32, strength: f32, falloff: basis.physics.Easing, accelerationChange: bool) void {
        const c = center.toInterop();
        const fo: u32 = @intFromEnum(falloff);
        basis.bindings.api.PhysicsScene_applyRadialForce(self.cppPtr, &c, radius, strength, fo, accelerationChange);
    }

    pub fn applyRadialImpulse(self: *const Self, center: Vec3, radius: f32, strength: f32, falloff: basis.physics.Easing, velocityChange: bool) void {
        const c = center.toInterop();
        const fo: u32 = @intFromEnum(falloff);
        basis.bindings.api.PhysicsScene_applyRadialImpulse(self.cppPtr, &c, radius, strength, fo, velocityChange);
    }

    pub fn sphereSweep(self: *const Self, sphereRadius: f32, origin: Vec3, direction: Vec3, maxDistance: f32, result: *RayCastResult) bool {
        const interopOrigin = Vec3.toInterop(origin);
        const interopDirection = Vec3.toInterop(direction);

        var interopResult = basis.bindings.PhysicsInteropRayCastResult{
            .hitPoint = Vec3.toInterop(Vec3.Zero),
            .hitPointNormal = Vec3.toInterop(Vec3.Zero),
            .distance = 0.0,
            .hitGameObjectCppPtr = 0,
            .hitPhysicsActorCppPtr = 0,
            .hitPhysicsActorType = 0,
        };

        const wasHit = basis.bindings.api.PhysicsScene_sphereSweep(self.cppPtr, sphereRadius, &interopOrigin, &interopDirection, maxDistance, &interopResult);

        if (wasHit == 1) {
            result.* = RayCastResult.fromInterop(interopResult);
        }

        return wasHit == 1;
    }

    pub fn sphereSweepEx(self: *const Self, sphereRadius: f32, origin: Vec3, direction: Vec3, maxDistance: f32, results: []RayCastResult, blockingActorTypes: u32) u32 {
        const interopOrigin = Vec3.toInterop(origin);
        const interopDirection = Vec3.toInterop(direction);

        const RESULT_BUFFER_SIZE = 32;
        var interopResults: [RESULT_BUFFER_SIZE]basis.bindings.PhysicsInteropRayCastResult = undefined;
        const resultCount: u32 = @min(@as(u32, @intCast(results.len)), RESULT_BUFFER_SIZE);

        const hitCount = basis.bindings.api.PhysicsScene_sphereSweepEx(self.cppPtr, sphereRadius, &interopOrigin, &interopDirection, maxDistance, &interopResults[0], resultCount, blockingActorTypes);

        if (hitCount > 0) {
            var i: u32 = 0;
            while (i < hitCount) : (i += 1) {
                results[i] = RayCastResult.fromInterop(interopResults[i]);
            }
        }

        return hitCount;
    }

    pub fn getSphereOverlapping(self: *const Self, center: Vec3, radius: f32) u32 {
        // TODO: Add actor list parameters.

        const c = center.toInterop();
        return basis.bindings.api.PhysicsScene_getSphereOverlapping(self.cppPtr, &c, radius);
    }

    pub fn castRay(self: *const Self, origin: Vec3, direction: Vec3, maxDistance: f32, result: *RayCastResult) bool {
        const interopOrigin = Vec3.toInterop(origin);
        const interopDirection = Vec3.toInterop(direction);

        var interopResult = basis.bindings.PhysicsInteropRayCastResult{
            .hitPoint = Vec3.toInterop(Vec3.Zero),
            .hitPointNormal = Vec3.toInterop(Vec3.Zero),
            .distance = 0.0,
            .hitGameObjectCppPtr = 0,
            .hitPhysicsActorCppPtr = 0,
            .hitPhysicsActorType = 0,
        };

        const wasHit = basis.bindings.api.PhysicsScene_castRay(self.cppPtr, &interopOrigin, &interopDirection, maxDistance, &interopResult);

        if (wasHit == 1) {
            result.* = RayCastResult.fromInterop(interopResult);
        }

        return wasHit == 1;
    }

    pub fn castRayEx(self: *const Self, origin: Vec3, direction: Vec3, maxDistance: f32, result: *RayCastResult, blockingActorTypes: u32) bool {
        const interopOrigin = Vec3.toInterop(origin);
        const interopDirection = Vec3.toInterop(direction);

        var interopResult = basis.bindings.PhysicsInteropRayCastResult{
            .hitPoint = Vec3.toInterop(Vec3.Zero),
            .hitPointNormal = Vec3.toInterop(Vec3.Zero),
            .distance = 0.0,
            .hitGameObjectCppPtr = 0,
            .hitPhysicsActorCppPtr = 0,
            .hitPhysicsActorType = 0,
        };

        const wasHit = basis.bindings.api.PhysicsScene_castRayEx(self.cppPtr, &interopOrigin, &interopDirection, maxDistance, &interopResult, blockingActorTypes);

        if (wasHit == 1) {
            result.* = RayCastResult.fromInterop(interopResult);
        }

        return wasHit == 1;
    }

    pub fn castRayWithCallback(self: *const Self, origin: Vec3, direction: Vec3, maxDistance: f32, result: *RayCastResult, blockingActorTypes: u32, callback: *const RayCastCallback) bool {
        const interopOrigin = Vec3.toInterop(origin);
        const interopDirection = Vec3.toInterop(direction);

        var interopResult = basis.bindings.PhysicsInteropRayCastResult{
            .hitPoint = Vec3.toInterop(Vec3.Zero),
            .hitPointNormal = Vec3.toInterop(Vec3.Zero),
            .distance = 0.0,
            .hitGameObjectCppPtr = 0,
            .hitPhysicsActorCppPtr = 0,
            .hitPhysicsActorType = 0,
        };

        const callbackPtr = @intFromPtr(callback);
        const needsPostFilter = (callback.shouldReportHitPostFilter != null);

        const wasHit = basis.bindings.api.PhysicsScene_castRayWithCallback(
            self.cppPtr,
            &interopOrigin,
            &interopDirection,
            maxDistance,
            &interopResult,
            blockingActorTypes,
            callbackPtr,
            needsPostFilter,
            RayCast_shouldReportHit_wrapper,
            RayCast_shouldReportHitPostFilter_wrapper,
        );

        if (wasHit == 1) {
            result.* = RayCastResult.fromInterop(interopResult);
        }

        return wasHit == 1;
    }
};

//----------------------------------------------------

pub const RayCastResult = struct {
    hitPoint: Vec3,
    hitPointNormal: Vec3,
    distance: f32,
    hitGameObjectCppPtr: basis.CppPtr,
    physicsActorCppPtr: basis.CppPtr,
    physicsActorType: basis.physics.PhysicsActorType,

    pub fn initZero() RayCastResult {
        return RayCastResult{
            .hitPoint = Vec3.Zero,
            .hitPointNormal = Vec3.Zero,
            .distance = 0.0,
            .hitGameObjectCppPtr = 0,
            .physicsActorCppPtr = 0,
            .physicsActorType = PhysicsActorType.RigidBodyDynamic,
        };
    }

    pub fn getPhysicsActor(self: RayCastResult) PhysicsActorPtr {
        return PhysicsActorPtr{
            .cppPtr = self.physicsActorCppPtr,
            .actorType = self.physicsActorType,
        };
    }

    pub fn getGameObject(self: RayCastResult) GameObjectPtr {
        return GameObjectPtr{
            .cppPtr = self.hitGameObjectCppPtr,
        };
    }

    pub fn toInterop(self: RayCastResult) basis.bindings.PhysicsInteropRayCastResult {
        return basis.bindings.PhysicsInteropRayCastResult{
            .hitPoint = self.hitPoint.toInterop(),
            .hitPointNormal = self.hitPointNormal.toInterop(),
            .distance = self.distance,
            .hitGameObjectCppPtr = self.hitGameObjectCppPtr,
            .hitPhysicsActorCppPtr = self.physicsActorCppPtr,
            .hitPhysicsActorType = @intFromEnum(self.physicsActorType),
        };
    }

    pub fn fromInterop(interop: basis.bindings.PhysicsInteropRayCastResult) RayCastResult {
        return RayCastResult{
            .hitPoint = Vec3.fromInterop(interop.hitPoint),
            .hitPointNormal = Vec3.fromInterop(interop.hitPointNormal),
            .distance = interop.distance,
            .hitGameObjectCppPtr = interop.hitGameObjectCppPtr,
            .physicsActorCppPtr = interop.hitPhysicsActorCppPtr,
            .physicsActorType = @as(PhysicsActorType, @enumFromInt(interop.hitPhysicsActorType)),
        };
    }
};

//----------------------------------------------------

pub const RayCastCallback = struct {
    pub const ShouldReportHitDelegate = basis.delegate.RetDelegate1(basis.physics.PhysicsActorPtr, bool);
    pub const ShouldReportHitPostFilterDelegate = basis.delegate.RetDelegate3(basis.physics.PhysicsActorPtr, basis.math.Vec3, basis.math.Vec3, bool);

    // Should the raycast report a hit for the given actor?
    shouldReportHit: ShouldReportHitDelegate = .{},

    // Post-filter raycast callback. Should the raycast report a hit for the given actor?
    // You can set this fn ptr to null if you don't need the hit position or normal. Not requiring a post filter is better for performance.
    shouldReportHitPostFilter: ?ShouldReportHitPostFilterDelegate = null,
};

/// A raycast callback which ignores the given actor. The return value
/// of get() should be passed to castRayWithCallback() when using.
pub const IgnoreActorRaycastCallback = struct {
    const Self = @This();
    //----------------------------------------------------

    actor: PhysicsActorPtr,

    /// Don't access directly, but via get().
    _cb: RayCastCallback,

    //----------------------------------------------------

    pub fn init(actor: PhysicsActorPtr) Self {
        return Self{
            .actor = actor,
            ._cb = .{},
        };
    }

    pub fn get(self: *Self) *RayCastCallback {
        // We bind the delegate here, instead of in init() since the self ptr is likely stable here.
        self._cb.shouldReportHit = .initMethod(
            self,
            Self,
            shouldReportHit,
        );
        return &self._cb;
    }

    //----------------------------------------------------

    fn shouldReportHit(self: *const Self, actor: basis.physics.PhysicsActorPtr) bool {
        return self.actor.cppPtr != actor.cppPtr;
    }
};

/// A raycast callback which ignores actors associated with the given game object.
/// The return value of get() should be passed to castRayWithCallback() when using.
pub const IgnoreGameObjectRaycastCallback = struct {
    const Self = @This();
    //----------------------------------------------------

    gameObject: basis.game_object.GameObjectPtr,

    /// Don't access directly, but via get().
    _cb: RayCastCallback,

    //----------------------------------------------------

    pub fn init(gameObject: basis.game_object.GameObjectPtr) Self {
        return Self{
            .gameObject = gameObject,
            ._cb = .{},
        };
    }

    pub fn get(self: *Self) *RayCastCallback {
        // We bind the delegate here, instead of in init() since the self ptr is likely stable here.
        self._cb.shouldReportHit = .initMethod(
            self,
            Self,
            shouldReportHit,
        );
        return &self._cb;
    }

    //----------------------------------------------------

    fn shouldReportHit(self: *const Self, actor: basis.physics.PhysicsActorPtr) bool {
        const go = actor.getAssociatedGameObject();
        return self.gameObject.cppPtr != go.cppPtr;
    }
};

//----------------------------------------------------

// Internal callbacks:

fn RayCast_shouldReportHit_wrapper(callbackPtr: basis.IntPtr, actorCppPtr: basis.CppPtr, actorTypeInt: u32) callconv(.c) i32 {
    var cb = @as(*RayCastCallback, @ptrFromInt(callbackPtr));
    const actor = basis.physics.PhysicsActorPtr{ .cppPtr = actorCppPtr, .actorType = @as(basis.physics.PhysicsActorType, @enumFromInt(actorTypeInt)) };

    const ret = cb.shouldReportHit.call(actor) catch |err| {
        basis.assertf(@src(), false, "Error calling raycast shouldReportHit(): {s}", .{@errorName(err)});
        return 0;
    };

    return if (ret) 1 else 0;
}

fn RayCast_shouldReportHitPostFilter_wrapper(callbackPtr: basis.IntPtr, actorCppPtr: basis.CppPtr, actorTypeInt: u32, pos: *const basis.bindings.InteropVec3, norm: *const basis.bindings.InteropVec3) callconv(.c) i32 {
    const cb = @as(*RayCastCallback, @ptrFromInt(callbackPtr));
    const actor = basis.physics.PhysicsActorPtr{ .cppPtr = actorCppPtr, .actorType = @as(basis.physics.PhysicsActorType, @enumFromInt(actorTypeInt)) };
    const position = basis.math.Vec3.fromInterop(pos.*);
    const normal = basis.math.Vec3.fromInterop(norm.*);

    if (cb.shouldReportHitPostFilter) |cbActual| {
        const ret = cbActual.call(actor, position, normal) catch |err| {
            basis.assertf(@src(), false, "Error calling raycast shouldReportHitPostFilter(): {s}", .{@errorName(err)});
            return 0;
        };

        return if (ret) 1 else 0;
    }

    return 0;
}

//----------------------------------------------------

// Collision callbacks:

pub const CollisionPoint = struct {
    position: Vec3 = .Zero,
    normal: Vec3 = .Zero,
    impulse: Vec3 = .Zero,
    force: f32 = 0.0,
    material0: PhysicsMaterialPtr = .Null,
    material1: PhysicsMaterialPtr = .Null,
};

pub const CollisionData = struct {
    pub const MaxCollisionPointCount = 8;

    shape0: PhysicsShapePtr = .Null,
    shape1: PhysicsShapePtr = .Null,

    // The actors the two shapes belong to. Either may be .Null (e.g. a removed actor).
    actor0: PhysicsActorPtr = .Null,
    actor1: PhysicsActorPtr = .Null,

    collisionPoints: basis.BoundedArray(CollisionPoint, MaxCollisionPointCount) = .{},
};

pub const CollisionCallback = basis.delegate.VoidDelegate1(*const CollisionData);

pub const CollisionCallbackID = u32;

//----------------------------------------------------

const CollisionCallbackState = struct {
    id: CollisionCallbackID,
    sceneIntPtr: basis.CppPtr,
    cb: CollisionCallback,
};

pub const GlobalData = struct {
    mutex: std.Io.Mutex = .init,
    callbackStates: basis.ArrayList(CollisionCallbackState) = undefined,
    sceneToCallbackCountMap: basis.HashMap(basis.CppPtr, u32) = undefined,
    idAccumulator: CollisionCallbackID = 0,
    initialized: bool = false,
};

inline fn getG() *GlobalData {
    return &basis.g.physics_scene;
}

//----------------------------------------------------

pub fn init() void {
    const g = getG();

    g.callbackStates = .init(basis.g.allocator);
    g.sceneToCallbackCountMap = .init(basis.g.allocator);
    g.initialized = true;
}

pub fn deinit() void {
    const g = getG();

    g.callbackStates.deinit();
    g.sceneToCallbackCountMap.deinit();
    g.initialized = false;
}

pub fn registerCollisionCallback(scene: PhysicsScenePtr, cb: CollisionCallback) CollisionCallbackID {
    const g = getG();

    g.mutex.lock(basis.g.io) catch @panic("Mutex Canceled");
    defer g.mutex.unlock(basis.g.io);

    basis.assertd(
        @src(),
        g.initialized,
        "Collision callback states not initialized. Call physics_scene.init() first.",
    );

    g.idAccumulator += 1;

    g.callbackStates.append(CollisionCallbackState{
        .id = g.idAccumulator,
        .sceneIntPtr = scene.cppPtr,
        .cb = cb,
    }) catch @panic("OOM");

    var needsToEnableCallbacks = true;
    var result = g.sceneToCallbackCountMap.getOrPut(scene.cppPtr) catch @panic("OOM");

    if (result.found_existing) {
        needsToEnableCallbacks = result.value_ptr.* == 0;
        result.value_ptr.* += 1;
    } else {
        result.value_ptr.* = 1;
    }

    //basis.printf("registerCollisionCallback() - ID: {}, needsToEnableCallbacks: {}\n", .{ g.idAccumulator, needsToEnableCallbacks });

    if (needsToEnableCallbacks) {
        basis.bindings.api.PhysicsScene_setCollisionCallbacksEnabled(scene.cppPtr, 1);
    }

    return g.idAccumulator;
}

pub fn unregisterCollisionCallback(id: CollisionCallbackID) void {
    const g = getG();

    g.mutex.lock(basis.g.io) catch @panic("Mutex Canceled");
    defer g.mutex.unlock(basis.g.io);

    basis.assertd(
        @src(),
        g.initialized,
        "Collision callback states not initialized. Call physics_scene.init() first.",
    );

    var sceneIntPtr: basis.CppPtr = 0;

    for (g.callbackStates.items, 0..) |state, i| {
        if (state.id == id) {
            sceneIntPtr = state.sceneIntPtr;
            _ = g.callbackStates.orderedRemove(i);
            break;
        }
    }

    if (sceneIntPtr != 0) {
        if (g.sceneToCallbackCountMap.getPtr(sceneIntPtr)) |countPtr| {
            basis.assert(@src(), countPtr.* > 0);
            countPtr.* -= 1;

            //basis.printf("unregisterCollisionCallback() - ID: {}, needsToDisableCallbacks: {}\n", .{ id, countPtr.* == 0 });

            if (countPtr.* == 0) {
                basis.bindings.api.PhysicsScene_setCollisionCallbacksEnabled(sceneIntPtr, 0);
            }
        }
    }
}

pub fn _onCollisionCallback(sceneIntPtr: basis.CppPtr, collisionData: *const CollisionData) void {
    const g = getG();

    g.mutex.lock(basis.g.io) catch @panic("Mutex Canceled");
    defer g.mutex.unlock(basis.g.io);

    for (g.callbackStates.items) |state| {
        if (state.sceneIntPtr == sceneIntPtr) {
            state.cb.call(collisionData);
        }
    }
}
