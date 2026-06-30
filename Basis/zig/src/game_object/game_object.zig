// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const MeshInstancePtr = basis.renderer.mesh_instance.MeshInstancePtr;

const Vec3 = basis.math.Vec3;
const Quaternion = basis.math.Quaternion;

pub const GameObjectPtr = struct {
    const Self = @This();
    pub const Null = initNull();

    cppPtr: basis.CppPtr,

    pub fn initNull() Self {
        return Self{ .cppPtr = 0 };
    }

    pub fn isNull(self: *const Self) bool {
        return (self.cppPtr == 0);
    }

    pub fn getName(self: *const Self) []const u8 {
        var str: basis.bindings.InteropString = undefined;
        basis.bindings.api.GameObject_getName(self.cppPtr, &str);
        return str.ptr[0..str.len];
    }

    pub fn getType(self: *const Self) []const u8 {
        var str: basis.bindings.InteropString = undefined;
        basis.bindings.api.GameObject_getType(self.cppPtr, &str);
        return str.ptr[0..str.len];
    }

    pub fn getComponentByName(self: *const Self, comptime T: type, shortName: []const u8) ?*T {
        const interopName = basis.string.toInteropString(shortName);
        const componentIntPtr = basis.bindings.api.GameObject_getComponentPtrByShortName(self.cppPtr, &interopName);

        if (componentIntPtr == 0) {
            return null;
        }

        return @as(*T, @ptrFromInt(componentIntPtr));
    }

    pub fn getComponent(self: *const Self, comptime T: type) ?*T {
        const typeName = basis.components.getComponentTypeName(T);
        const interopName = basis.string.toInteropString(typeName);
        const componentIntPtr = basis.bindings.api.GameObject_getComponentPtrByTypeName(self.cppPtr, &interopName);

        if (componentIntPtr == 0) {
            return null;
        }

        return @as(*T, @ptrFromInt(componentIntPtr));
    }

    pub fn addGameObjectMeshInstanceMapping(self: *const Self, meshInstance: MeshInstancePtr) void {
        basis.bindings.api.GameObject_addGameObjectMeshInstanceMapping(self.cppPtr, meshInstance.cppPtr);
    }

    pub fn removeGameObjectMeshInstanceMapping(self: *const Self, meshInstance: MeshInstancePtr) void {
        basis.bindings.api.GameObject_removeGameObjectMeshInstanceMapping(self.cppPtr, meshInstance.cppPtr);
    }

    pub fn getNameHash(self: *const Self) basis.string.StringHash {
        return basis.bindings.api.GameObject_getNameHash(self.cppPtr);
    }

    pub fn getWorldTransform(self: *const Self, position: *Vec3, orientation: *Quaternion) bool {
        var interopPos: basis.bindings.InteropVec3 = undefined;
        var interopOri: basis.bindings.InteropQuaternion = undefined;

        const result = basis.bindings.api.GameObject_getWorldTransform(self.cppPtr, &interopPos, &interopOri);

        if (result == 0) return false;

        position.* = Vec3.fromInterop(interopPos);
        orientation.* = Quaternion.fromInterop(interopOri);

        return true;
    }

    pub fn setWorldTransform(self: *const Self, position: Vec3, orientation: Quaternion, teleport: bool) bool {
        const interopPos = position.toInterop();
        const interopOri = orientation.toInterop();

        const result = basis.bindings.api.GameObject_setWorldTransform(self.cppPtr, &interopPos, &interopOri, teleport);

        return (result == 1);
    }

    pub fn getWorldPosition(self: *const Self) Vec3 {
        var pos = Vec3.Zero;
        var ori = Quaternion.Identity;
        _ = self.getWorldTransform(&pos, &ori);
        return pos;
    }

    pub fn getMeshComponentData(self: *const Self, shortName: []const u8) ?basis.components.MeshComponentData {
        var sceneNodeCppPtr: basis.CppPtr = 0;
        var meshCppPtr: basis.CppPtr = 0;
        var meshInstanceCppPtr: basis.CppPtr = 0;

        const interopName = basis.string.toInteropString(shortName);

        if (basis.bindings.api.GameObject_getMeshComponentData(
            self.cppPtr,
            &interopName,
            &sceneNodeCppPtr,
            &meshCppPtr,
            &meshInstanceCppPtr,
        ) == 0) {
            return null;
        }

        return basis.components.MeshComponentData{
            .sceneNode = basis.math.SceneNodePtr.initFromCppPtr(sceneNodeCppPtr),
            .mesh = basis.renderer.MeshPtr{ .cppPtr = meshCppPtr },
            .meshInstance = basis.renderer.MeshInstancePtr{ .cppPtr = meshInstanceCppPtr },
        };
    }

    pub fn getAndAssertMeshComponentData(self: *const Self, shortName: []const u8) basis.components.MeshComponentData {
        const data = self.getMeshComponentData(shortName);
        basis.assertf(@src(), data != null, "Could not find mesh component data \"{s}\".", .{shortName});

        // The mesh component might be created but not fully initialized at this point. Assert that it is.
        basis.assertf(
            @src(),
            !data.?.meshInstance.isNull(),
            "Mesh component \"{s}\" hasn't created its mesh instance yet.",
            .{shortName},
        );

        return data.?;
    }

    pub fn getPhysicsActor(self: *const Self) basis.physics.PhysicsActorPtr {
        var actorCppPtr: basis.CppPtr = 0;
        var actorTypeInt: u32 = 0;

        const res = basis.bindings.api.GameObject_getPhysicsActor(self.cppPtr, &actorCppPtr, &actorTypeInt);

        if (res == 0) {
            return basis.physics.PhysicsActorPtr{
                .cppPtr = 0,
                .actorType = .RigidBodyDynamic, // Have to assign something...
            };
        }

        return basis.physics.PhysicsActorPtr{ .cppPtr = actorCppPtr, .actorType = @as(basis.physics.PhysicsActorType, @enumFromInt(actorTypeInt)) };
    }

    pub fn getGameTag(self: *const Self) u32 {
        return basis.bindings.api.GameObject_getGameTag(self.cppPtr);
    }

    pub fn setGameTag(self: *const Self, tag: u32) void {
        basis.bindings.api.GameObject_setGameTag(self.cppPtr, tag);
    }

    pub fn getRenderSceneNode(self: *Self) basis.math.SceneNodePtr {
        const cppPtr = basis.bindings.api.GameObject_getRenderSceneNode(self.cppPtr);
        return basis.math.SceneNodePtr{
            .cppPtr = cppPtr,
            .ownsMemory = false,
        };
    }

    /// Fills outIDs with the obstacle IDs of every NavMeshObstacleComponent on this
    /// object for the given nav mesh. Returns the IDs written.
    pub fn getNavMeshObstacleIDs(
        self: *const Self,
        navMeshID: basis.navmesh_runtime.NavMeshID,
        outIDs: []basis.navmesh_runtime.NavMeshObstacleID,
    ) []basis.navmesh_runtime.NavMeshObstacleID {
        const count = basis.bindings.api.GameObject_getNavMeshObstacleIDs(
            self.cppPtr,
            @intFromEnum(navMeshID),
            outIDs.ptr,
            @intCast(outIDs.len),
        );
        return outIDs[0..count];
    }
};
