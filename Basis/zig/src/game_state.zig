// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

pub const Vec3 = basis.math.Vec3;
pub const Quaternion = basis.math.Quaternion;

const Allocator = std.mem.Allocator;

const GameObjectPtr = basis.game_object.GameObjectPtr;

const GameObjectCreationParametersPtr = basis.game_object.GameObjectCreationParametersPtr;

pub const GameStatePtr = struct {
    const Self = @This();
    pub const Null = initNull();
    allocator: Allocator,
    cppPtr: basis.CppPtr,

    pub fn initNull() Self {
        return Self{
            .allocator = undefined,
            .cppPtr = 0,
        };
    }

    pub fn isNull(self: *const Self) bool {
        return self.cppPtr == 0;
    }

    pub fn getGameObject(self: *const Self, objectName: []const u8) ?GameObjectPtr {
        const nameHash = basis.string.makeStringHash(objectName);
        return self.getGameObjectByNameHash(nameHash);
    }

    pub fn getGameObjectByNameHash(self: *const Self, objectNameHash: basis.StringHash) ?GameObjectPtr {
        const objectCppPtr = basis.bindings.api.GameState_getGameObject(self.cppPtr, objectNameHash);

        if (objectCppPtr == 0) {
            return null;
        }

        return GameObjectPtr{
            .cppPtr = objectCppPtr,
        };
    }

    pub fn getGameObjectFromRenderable(self: *const Self, renderable: basis.renderer.RenderablePtr) ?GameObjectPtr {
        const objectCppPtr = basis.bindings.api.GameState_getGameObjectFromRenderable(self.cppPtr, renderable.cppPtr);

        if (objectCppPtr == 0) {
            return null;
        }

        return GameObjectPtr{
            .cppPtr = objectCppPtr,
        };
    }

    pub fn createGameObject(
        self: *const Self,
        objectName: []const u8,
        objectType: []const u8,
    ) void {
        const interopName = basis.string.toInteropString(objectName);
        const interopType = basis.string.toInteropString(objectType);
        const propagate = true;

        basis.bindings.api.GameState_createGameObject(self.cppPtr, &interopName, &interopType, propagate);
    }

    pub fn createGameObjectWithStartTransform(
        self: *const Self,
        objectName: []const u8,
        objectType: []const u8,
        position: Vec3,
        orientation: Quaternion,
    ) void {
        const interopName = basis.string.toInteropString(objectName);
        const interopType = basis.string.toInteropString(objectType);
        const pos = position.toInterop();
        const ori = orientation.toInterop();
        const propagate = true;

        basis.bindings.api.GameState_createGameObjectWithStartTransform(self.cppPtr, &interopName, &interopType, &pos, &ori, propagate);
    }

    pub fn createGameObjectWithSpawnPointIndex(
        self: *const Self,
        objectName: []const u8,
        objectType: []const u8,
        spawnPointIndex: u32,
    ) void {
        const interopName = basis.string.toInteropString(objectName);
        const interopType = basis.string.toInteropString(objectType);
        const propagate = true;

        basis.bindings.api.GameState_createGameObjectWithSpawnPointIndex(self.cppPtr, &interopName, &interopType, spawnPointIndex, propagate);
    }

    pub fn createGameObjectWithSpawnPointName(
        self: *const Self,
        objectName: []const u8,
        objectType: []const u8,
        spawnPointName: []const u8,
    ) void {
        const interopName = basis.string.toInteropString(objectName);
        const interopType = basis.string.toInteropString(objectType);
        const interopSpawnPointName = basis.string.toInteropString(spawnPointName);
        const propagate = true;

        basis.bindings.api.GameState_createGameObjectWithSpawnPointName(self.cppPtr, &interopName, &interopType, &interopSpawnPointName, propagate);
    }

    pub fn createGameObjectWithParameters(
        self: *const Self,
        params: GameObjectCreationParametersPtr,
    ) void {
        const propagate = true;
        basis.bindings.api.GameState_createGameObjectWithParameters(self.cppPtr, params.cppPtr, propagate);
    }

    pub fn destroyGameObject(self: *const Self, nameHash: basis.StringHash) void {
        const propagate = true;
        const destroyImmediately = false;
        basis.bindings.api.GameState_destroyGameObject(self.cppPtr, nameHash, propagate, destroyImmediately);
    }

    pub fn hasGameObject(self: *const Self, objectName: []const u8) bool {
        const nameHash = basis.string.makeStringHash(objectName);
        return basis.bindings.api.GameState_hasGameObject(self.cppPtr, nameHash);
    }

    pub fn setAvatarObject(self: *const Self, objectNameHash: basis.StringHash, hostID: i32) void {
        basis.bindings.api.GameState_setAvatarObject(self.cppPtr, objectNameHash, hostID);
    }

    pub fn clearAvatarObject(self: *const Self, hostID: i32) void {
        basis.bindings.api.GameState_clearAvatarObject(self.cppPtr, hostID);
    }

    pub fn getAvatarObjectByHostID(self: *const Self, hostID: i32) basis.StringHash {
        return basis.bindings.api.GameState_getAvatarObjectByHostID(self.cppPtr, hostID);
    }

    pub fn getHostIDByAvatarObject(self: *const Self, avatarNameHash: basis.StringHash) i32 {
        return basis.bindings.api.GameState_getHostIDByAvatarObject(self.cppPtr, avatarNameHash);
    }

    pub fn broadcastScriptMessage(self: *const Self, sender: GameObjectPtr, message: []const u8) void {
        const interopMessage = basis.string.toInteropString(message);
        basis.bindings.api.GameState_broadcastScriptMessage(self.cppPtr, sender.cppPtr, &interopMessage);
    }

    // We probably want this too, but how do we pass the receiver? Maybe as a string of the name?
    // We don't want to make the sender have a GameObjectPtr to the sender at hand. That would be
    // silly. Maybe by the time you read this we have a GameObjectRef-like type in Zig?
    // pub fn sendScriptMessageToGameObject(self: *const Self, sender: GameObjectPtr, receiver: []const u8, message: []const u8) void {
    //     _ = message;
    //     _ = receiver;
    //     _ = sender;
    //     _ = self;
    // }

    pub fn generateGameObjectName(self: *const Self, prefix: []const u8, randomPartLength: i32) []const u8 {
        const interopPrefix = basis.string.toInteropString(prefix);

        var interopResult: basis.bindings.InteropString = undefined;
        basis.bindings.api.GameState_generateGameObjectName(self.cppPtr, &interopPrefix, randomPartLength, &interopResult);
        return interopResult.ptr[0..interopResult.len];
    }
};
