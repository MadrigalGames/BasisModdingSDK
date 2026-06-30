// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

pub const physics_engine = @import("physics/physics_engine.zig");
pub const physics_actor = @import("physics/physics_actor.zig");
pub const physics_scene = @import("physics/physics_scene.zig");
pub const physics_shape = @import("physics/physics_shape.zig");
pub const physics_material = @import("physics/physics_material.zig");
pub const physics_transform = @import("physics/physics_transform.zig");
pub const physics_joint = @import("physics/physics_joint.zig");
pub const physics_trigger = @import("physics/physics_trigger.zig");
pub const character_controller = @import("physics/character_controller.zig");
pub const vehicle_controller = @import("physics/vehicle_controller.zig");
pub const vehicles = @import("physics/vehicles.zig");
pub const physics_trimesh = @import("physics/physics_trimesh.zig");

pub const PhysicsEnginePtr = physics_engine.PhysicsEnginePtr;
pub const PhysicsActorPtr = physics_actor.PhysicsActorPtr;
pub const PhysicsActorType = physics_actor.PhysicsActorType;
pub const PhysicsScenePtr = physics_scene.PhysicsScenePtr;
pub const RayCastResult = physics_scene.RayCastResult;
pub const RayCastCallback = physics_scene.RayCastCallback;
pub const PhysicsShapePtr = physics_shape.PhysicsShapePtr;
pub const PhysicsMaterialPtr = physics_material.PhysicsMaterialPtr;
pub const PhysicsTransform = physics_transform.PhysicsTransform;
pub const PhysicsJointPtr = physics_joint.PhysicsJointPtr;
pub const TriggerEnterCallback = physics_trigger.TriggerEnterCallback;
pub const TriggerExitCallback = physics_trigger.TriggerExitCallback;
pub const TriggerGameObjectFilter = physics_trigger.TriggerGameObjectFilter;
pub const CharacterControllerPtr = character_controller.CharacterControllerPtr;
pub const VehicleControllerPtr = vehicle_controller.VehicleControllerPtr;
pub const CollisionData = physics_scene.CollisionData;
pub const PhysicsTriMeshPtr = physics_trimesh.PhysicsTriMeshPtr;

// Note! Keep in sync with the C++ side.
pub const Easing = enum(u32) {
    None = 0,
    Linear,
    SmoothStep,
    EaseOutQuart,
};
