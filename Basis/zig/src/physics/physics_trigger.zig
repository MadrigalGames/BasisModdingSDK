// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Vec3 = basis.math.Vec3;

const PhysicsEnginePtr = basis.physics.PhysicsEnginePtr;
const PhysicsTransform = basis.physics.PhysicsTransform;
const PhysicsScenePtr = basis.physics.PhysicsScenePtr;
const PhysicsActorPtr = basis.physics.PhysicsActorPtr;

const GameObjectPtr = basis.game_object.GameObjectPtr;

//----------------------------------------------------

pub const TriggerEnterCallback = basis.delegate.VoidDelegate1(PhysicsActorPtr);
pub const TriggerExitCallback = basis.delegate.VoidDelegate2(PhysicsActorPtr, bool);

const TriggerCallbackState = struct {
    enterCB: ?TriggerEnterCallback = null,
    exitCB: ?TriggerExitCallback = null,
};

const CallbackStateMap = basis.HashMap(basis.CppPtr, TriggerCallbackState);

pub const GlobalData = struct {
    mutex: std.Io.Mutex = .init,
    callbackStates: CallbackStateMap = undefined,
    initialized: bool = false,
};

inline fn getG() *GlobalData {
    return &basis.g.physics_trigger;
}

//----------------------------------------------------

pub fn init() void {
    const g = getG();

    g.callbackStates = CallbackStateMap.init(basis.g.allocator);
    g.initialized = true;
}

pub fn deinit() void {
    const g = getG();

    g.callbackStates.deinit();
    g.initialized = false;
}

//----------------------------------------------------

pub fn registerEnterCallback(trigger: PhysicsActorPtr, cb: TriggerEnterCallback) void {
    const g = getG();

    g.mutex.lock(basis.g.io) catch @panic("Mutex Canceled");
    defer g.mutex.unlock(basis.g.io);

    basis.assertd(
        @src(),
        g.initialized,
        "Trigger callback states not initialized. Call physics_trigger.init() first.",
    );

    basis.assertd(@src(), trigger.actorType == .Trigger, "Cannot set callback. Not a trigger.");

    var result = g.callbackStates.getOrPut(trigger.cppPtr) catch @panic("OOM");

    if (result.found_existing) {
        basis.assert(@src(), result.value_ptr.enterCB == null);
    } else {
        result.value_ptr.* = TriggerCallbackState{};
    }

    result.value_ptr.enterCB = cb;
}

pub fn registerExitCallback(trigger: PhysicsActorPtr, cb: TriggerExitCallback) void {
    const g = getG();

    g.mutex.lock(basis.g.io) catch @panic("Mutex Canceled");
    defer g.mutex.unlock(basis.g.io);

    basis.assertd(
        @src(),
        g.initialized,
        "Trigger callback states not initialized. Call physics_trigger.init() first.",
    );

    basis.assertd(@src(), trigger.actorType == .Trigger, "Cannot set callback. Not a trigger.");

    var result = g.callbackStates.getOrPut(trigger.cppPtr) catch @panic("OOM");
    if (result.found_existing) {
        basis.assert(@src(), result.value_ptr.exitCB == null);
    } else {
        result.value_ptr.* = TriggerCallbackState{};
    }
    result.value_ptr.exitCB = cb;
}

pub fn unregisterCallbacks(trigger: PhysicsActorPtr) void {
    const g = getG();

    g.mutex.lock(basis.g.io) catch @panic("Mutex Canceled");
    defer g.mutex.unlock(basis.g.io);

    basis.assertd(
        @src(),
        g.initialized,
        "Trigger callback states not initialized. Call physics_trigger.init() first.",
    );

    _ = g.callbackStates.remove(trigger.cppPtr);
}

pub fn _onTriggerEnterEvent(triggerActorIntPtr: basis.CppPtr, otherActorIntPtr: basis.CppPtr, otherActorType: u32) void {
    const g = getG();

    g.mutex.lock(basis.g.io) catch @panic("Mutex Canceled");
    defer g.mutex.unlock(basis.g.io);

    const possibleEntry = g.callbackStates.get(triggerActorIntPtr);

    if (possibleEntry) |entry| {
        if (entry.enterCB) |cb| {
            const otherActor = PhysicsActorPtr{
                .cppPtr = otherActorIntPtr,
                .actorType = @enumFromInt(otherActorType),
            };

            cb.call(otherActor);
        }
    }
}

pub fn _onTriggerExitEvent(triggerActorIntPtr: basis.CppPtr, otherActorIntPtr: basis.CppPtr, otherActorType: u32, otherActorRemoved: bool) void {
    const g = getG();

    g.mutex.lock(basis.g.io) catch @panic("Mutex Canceled");
    defer g.mutex.unlock(basis.g.io);

    const possibleEntry = g.callbackStates.get(triggerActorIntPtr);

    if (possibleEntry) |entry| {
        if (entry.exitCB) |cb| {
            const otherActor = PhysicsActorPtr{
                .cppPtr = otherActorIntPtr,
                .actorType = @enumFromInt(otherActorType),
            };

            cb.call(otherActor, otherActorRemoved);
        }
    }
}

//----------------------------------------------------

// Helper struct which keeps track of enter/exiting game objects
// based on the actors fed to it.
pub const TriggerGameObjectFilter = struct {
    const Self = @This();

    gameObjectEnterCount: std.AutoArrayHashMap(basis.StringHash, u32) = undefined,

    //----------------------------------------------------

    pub fn init(
        allocator: std.mem.Allocator,
    ) Self {
        return Self{
            .gameObjectEnterCount = std.AutoArrayHashMap(basis.StringHash, u32).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.gameObjectEnterCount.deinit();
    }

    //----------------------------------------------------

    pub fn enter(self: *Self, actor: PhysicsActorPtr) ?GameObjectPtr {
        const obj = actor.getAssociatedGameObject();

        if (!obj.isNull()) {
            const nameHash = obj.getNameHash();

            if (self.gameObjectEnterCount.getEntry(nameHash)) |entry| {
                entry.value_ptr.* = entry.value_ptr.* + 1;
            } else {
                self.gameObjectEnterCount.put(nameHash, 1) catch |err| {
                    basis.fatalErrorWithName(@src(), err);
                };
                return obj;
            }
        }

        return null;
    }

    pub fn exit(self: *Self, actor: PhysicsActorPtr) ?GameObjectPtr {
        const obj = actor.getAssociatedGameObject();

        if (!obj.isNull()) {
            const nameHash = obj.getNameHash();

            const possibleEntry = self.gameObjectEnterCount.getEntry(nameHash);
            basis.assert(@src(), possibleEntry != null);
            const entry = possibleEntry.?;

            entry.value_ptr.* = entry.value_ptr.* - 1;
            //basis.printf("Sub - value_ptr: {}\n", .{entry.value_ptr.*});

            if (entry.value_ptr.* == 0) {
                _ = self.gameObjectEnterCount.swapRemove(nameHash);
                return obj;
            }
        }

        return null;
    }
};
