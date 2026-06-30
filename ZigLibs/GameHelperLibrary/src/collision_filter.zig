// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");

const Vec3 = basis.math.Vec3;

const PhysicsScenePtr = basis.physics.PhysicsScenePtr;
const PhysicsActorPtr = basis.physics.PhysicsActorPtr;
const GameObjectPtr = basis.game_object.GameObjectPtr;

const CollisionData = basis.physics.CollisionData;
const CollisionCallbackID = basis.physics.physics_scene.CollisionCallbackID;

//----------------------------------------------------

// ActorCollisionFilter

// Listens for collisions involving a single actor, coalesces them, and fires one callback
// for the highest-impact collision within a short settle window. After firing it stays
// quiet for a minimum time. The owner holds one as a member, ticks it every frame, and
// supplies the callback. The filter has no idea what the callback does. Impact is
// measured as impulse magnitude (kg*m/s).

pub const CollisionFilterEvent = struct {
    otherGameObject: GameObjectPtr = .Null,
    otherActor: PhysicsActorPtr = .Null,
    impact: f32 = 0.0,
    position: Vec3 = .Zero,
    normal: Vec3 = .Zero,
};

pub const CollisionFilterCallback = basis.delegate.VoidDelegate1(*const CollisionFilterEvent);

pub const ActorCollisionFilter = struct {
    const Self = @This();

    const State = enum {
        Idle,
        Collecting,
        Cooldown,
    };

    scene: PhysicsScenePtr = .Null,
    actor: PhysicsActorPtr = .Null,

    minImpact: f32 = 0.0,
    settleWindow: f32 = 0.0,
    minTimeBetweenEvents: f32 = 0.0,

    callback: CollisionFilterCallback = .{},

    collisionCallbackID: CollisionCallbackID = 0,

    state: State = .Idle,
    settleTimer: f32 = 0.0,
    cooldownTimer: f32 = 0.0,

    best: CollisionFilterEvent = .{},

    // [settleWindow] may be 0, which makes the filter fire on the next tick with the
    // highest-impact collision seen that frame. A larger value waits to catch the true
    // peak of an impact, which usually arrives a tick or two after first contact.
    pub fn init(
        self: *Self,
        scene: PhysicsScenePtr,
        actor: PhysicsActorPtr,
        minImpact: f32,
        settleWindow: f32,
        minTimeBetweenEvents: f32,
        callback: CollisionFilterCallback,
    ) void {
        self.* = Self{
            .scene = scene,
            .actor = actor,
            .minImpact = minImpact,
            .settleWindow = settleWindow,
            .minTimeBetweenEvents = minTimeBetweenEvents,
            .callback = callback,
        };

        self.collisionCallbackID = basis.physics.physics_scene.registerCollisionCallback(
            scene,
            .initMethod(self, Self, onCollision),
        );
    }

    pub fn deinit(self: *Self) void {
        basis.physics.physics_scene.unregisterCollisionCallback(self.collisionCallbackID);
        self.collisionCallbackID = 0;
    }

    pub fn tick(self: *Self, tickDeltaTime: f32) void {
        switch (self.state) {
            .Idle => {},
            .Collecting => {
                self.settleTimer -= tickDeltaTime;
                if (self.settleTimer <= 0.0) {
                    self.callback.call(&self.best);
                    self.cooldownTimer = self.minTimeBetweenEvents;
                    self.state = .Cooldown;
                }
            },
            .Cooldown => {
                self.cooldownTimer -= tickDeltaTime;
                if (self.cooldownTimer <= 0.0) {
                    self.state = .Idle;
                }
            },
        }
    }

    fn onCollision(self: *Self, collisionData: *const CollisionData) void {
        if (self.state == .Cooldown) {
            return;
        }

        // Find which side of the collision is the other actor, if our actor is involved.
        var otherActor: PhysicsActorPtr = .Null;
        if (collisionData.actor0.cppPtr == self.actor.cppPtr) {
            otherActor = collisionData.actor1;
        } else if (collisionData.actor1.cppPtr == self.actor.cppPtr) {
            otherActor = collisionData.actor0;
        } else {
            return;
        }

        // Pick the collision point with the highest impulse magnitude.
        var impact: f32 = 0.0;
        var position: Vec3 = .Zero;
        var normal: Vec3 = .Zero;
        for (collisionData.collisionPoints.slice()) |cp| {
            const pointImpact = cp.impulse.length();
            if (pointImpact > impact) {
                impact = pointImpact;
                position = cp.position;
                normal = cp.normal;
            }
        }

        if (impact < self.minImpact) {
            return;
        }

        // Keep the highest-impact collision seen during the current window.
        if (self.state == .Idle or impact > self.best.impact) {
            self.best = CollisionFilterEvent{
                .otherGameObject = otherActor.getAssociatedGameObject(),
                .otherActor = otherActor,
                .impact = impact,
                .position = position,
                .normal = normal,
            };
        }

        if (self.state == .Idle) {
            self.settleTimer = self.settleWindow;
            self.state = .Collecting;
        }
    }
};
