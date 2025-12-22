// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Vec3 = basis.math.Vec3;
const Quaternion = basis.math.Quaternion;

const PhysicsActorPtr = basis.physics.PhysicsActorPtr;
const PhysicsActorType = basis.physics.PhysicsActorType;
const PhysicsShapePtr = basis.physics.PhysicsShapePtr;
const PhysicsTransform = basis.physics.PhysicsTransform;
const PhysicsMaterialPtr = basis.physics.PhysicsMaterialPtr;
const PhysicsJointPtr = basis.physics.PhysicsJointPtr;
const PhysicsTriMeshPtr = basis.physics.PhysicsTriMeshPtr;

const VehicleControllerDescription = basis.physics.vehicle_controller.VehicleControllerDescription;
const VehicleControllerType = basis.physics.vehicle_controller.VehicleControllerType;
const VehicleControllerPtr = basis.physics.vehicle_controller.VehicleControllerPtr;

// Note! Keep in sync with the C++ side.
pub const BasePhysicsMaterialName = enum(u32) {
    Default = 0, // Must have integral value 0.
    DefaultGround = 1,
    Trigger = 2,
    Character = 3,
    VehicleChassis = 4,
    VehicleWheel = 5,
    GravelGround = 6,
    GrassGround = 7,
    CliffGround = 8,
    MudGround = 9,
    TarmacGround = 10,
    MetalGround = 11,
    IceGround = 12,
    SandGround = 13,
    SnowGround = 14,
    Ghost = 15,
    DefaultIgnoreInternalCollisions1 = 16,
    DefaultIgnoreInternalCollisions2 = 17,
    DrivableDynamicObject = 18,
    VehicleWheelSwept = 19,
};

pub const PhysicsEnginePtr = struct {
    const Self = @This();
    pub const Null = initNull();
    cppPtr: basis.CppPtr,

    pub fn initNull() PhysicsEnginePtr {
        return PhysicsEnginePtr{
            .cppPtr = 0,
        };
    }

    pub fn isNull(self: *const Self) bool {
        return (self.cppPtr == 0);
    }

    //----------------------------------------------------

    // Materials:

    pub fn getDefaultMaterial(self: *const Self) PhysicsMaterialPtr {
        return PhysicsMaterialPtr{
            .cppPtr = basis.bindings.api.PhysicsMaterial_getDefaultMaterial(self.cppPtr),
        };
    }

    pub fn getBaseMaterial(self: *const Self, materialName: BasePhysicsMaterialName) PhysicsMaterialPtr {
        return PhysicsMaterialPtr{
            .cppPtr = basis.bindings.api.PhysicsMaterial_getBaseMaterial(
                self.cppPtr,
                @intFromEnum(materialName),
            ),
        };
    }

    //----------------------------------------------------

    // Shapes:

    pub fn createBox(
        self: *const Self,
        width: f32,
        height: f32,
        depth: f32,
        material: PhysicsMaterialPtr,
        localTransform: PhysicsTransform,
        exclusive: bool,
    ) PhysicsShapePtr {
        const interopPosition = localTransform.position.toInterop();
        const interopOrientation = localTransform.orientation.toInterop();
        const cppPtr = basis.bindings.api.PhysicsShape_createBox(
            self.cppPtr,
            width,
            height,
            depth,
            material.cppPtr,
            &interopPosition,
            &interopOrientation,
            exclusive,
        );

        return PhysicsShapePtr{
            .cppPtr = cppPtr,
        };
    }

    pub fn createSphere(
        self: *const Self,
        radius: f32,
        material: PhysicsMaterialPtr,
        localTransform: PhysicsTransform,
        exclusive: bool,
    ) PhysicsShapePtr {
        const interopPosition = localTransform.position.toInterop();
        const interopOrientation = localTransform.orientation.toInterop();
        const cppPtr = basis.bindings.api.PhysicsShape_createSphere(
            self.cppPtr,
            radius,
            material.cppPtr,
            &interopPosition,
            &interopOrientation,
            exclusive,
        );

        return PhysicsShapePtr{
            .cppPtr = cppPtr,
        };
    }

    pub fn createCapsule(
        self: *const Self,
        radius: f32,
        height: f32,
        material: PhysicsMaterialPtr,
        localTransform: PhysicsTransform,
        exclusive: bool,
    ) PhysicsShapePtr {
        const interopPosition = localTransform.position.toInterop();
        const interopOrientation = localTransform.orientation.toInterop();
        const cppPtr = basis.bindings.api.PhysicsShape_createCapsule(
            self.cppPtr,
            radius,
            height,
            material.cppPtr,
            &interopPosition,
            &interopOrientation,
            exclusive,
        );

        return PhysicsShapePtr{
            .cppPtr = cppPtr,
        };
    }

    pub fn createCylinder(
        self: *const Self,
        radius: f32,
        height: f32,
        material: PhysicsMaterialPtr,
        localTransform: PhysicsTransform,
        exclusive: bool,
    ) PhysicsShapePtr {
        const interopPosition = localTransform.position.toInterop();
        const interopOrientation = localTransform.orientation.toInterop();
        const cppPtr = basis.bindings.api.PhysicsShape_createCylinder(
            self.cppPtr,
            radius,
            height,
            material.cppPtr,
            &interopPosition,
            &interopOrientation,
            exclusive,
        );

        return PhysicsShapePtr{
            .cppPtr = cppPtr,
        };
    }

    pub fn createCylinderX(
        self: *const Self,
        radius: f32,
        height: f32,
        material: PhysicsMaterialPtr,
        localTransform: PhysicsTransform,
        exclusive: bool,
    ) PhysicsShapePtr {
        const interopPosition = localTransform.position.toInterop();
        const interopOrientation = localTransform.orientation.toInterop();
        const cppPtr = basis.bindings.api.PhysicsShape_createCylinderX(
            self.cppPtr,
            radius,
            height,
            material.cppPtr,
            &interopPosition,
            &interopOrientation,
            exclusive,
        );

        return PhysicsShapePtr{
            .cppPtr = cppPtr,
        };
    }

    pub fn createCylinderZ(
        self: *const Self,
        radius: f32,
        height: f32,
        material: PhysicsMaterialPtr,
        localTransform: PhysicsTransform,
        exclusive: bool,
    ) PhysicsShapePtr {
        const interopPosition = localTransform.position.toInterop();
        const interopOrientation = localTransform.orientation.toInterop();
        const cppPtr = basis.bindings.api.PhysicsShape_createCylinderZ(
            self.cppPtr,
            radius,
            height,
            material.cppPtr,
            &interopPosition,
            &interopOrientation,
            exclusive,
        );

        return PhysicsShapePtr{
            .cppPtr = cppPtr,
        };
    }

    //----------------------------------------------------

    // Rigid bodies:

    pub fn createRigidBodyDynamic(
        self: *const Self,
        shapes: []const PhysicsShapePtr,
        mass: f32,
        CoM: Vec3,
        initialTransform: PhysicsTransform,
        kinematic: bool,
        useCCD: bool,
    ) PhysicsActorPtr {
        const interopCoM = CoM.toInterop();
        const interopPosition = initialTransform.position.toInterop();
        const interopOrientation = initialTransform.orientation.toInterop();

        var shapePtrs: [8]basis.CppPtr = undefined;
        const shapeCount: u32 = @as(u32, @intCast(shapes.len));

        for (shapes, 0..) |shape, i| {
            shapePtrs[i] = shape.cppPtr;
        }

        const cppPtr = basis.bindings.api.PhysicsActor_createRigidBodyDynamic(
            self.cppPtr,
            &shapePtrs,
            shapeCount,
            mass,
            &interopCoM,
            &interopPosition,
            &interopOrientation,
            kinematic,
            useCCD,
        );

        return PhysicsActorPtr{
            .cppPtr = cppPtr,
            .actorType = PhysicsActorType.RigidBodyDynamic,
        };
    }

    pub fn createRigidBodyStatic(
        self: *const Self,
        shapes: []const PhysicsShapePtr,
        initialTransform: PhysicsTransform,
    ) PhysicsActorPtr {
        const interopPosition = initialTransform.position.toInterop();
        const interopOrientation = initialTransform.orientation.toInterop();

        var shapePtrs: [8]basis.IntPtr = undefined;
        const shapeCount: u32 = @as(u32, @intCast(shapes.len));

        for (shapes, 0..) |shape, i| {
            shapePtrs[i] = shape.cppPtr;
        }

        const cppPtr = basis.bindings.api.PhysicsActor_createRigidBodyStatic(
            self.cppPtr,
            &shapePtrs,
            shapeCount,
            &interopPosition,
            &interopOrientation,
        );

        return PhysicsActorPtr{
            .cppPtr = cppPtr,
            .actorType = PhysicsActorType.RigidBodyStatic,
        };
    }

    //----------------------------------------------------

    // Triggers:

    pub fn createBoxTrigger(
        self: *const Self,
        width: f32,
        height: f32,
        depth: f32,
        initialTransform: PhysicsTransform,
        ignoreStaticObjects: bool,
        ignoreRemovedObjects: bool,
    ) PhysicsActorPtr {
        const interopPosition = initialTransform.position.toInterop();
        const interopOrientation = initialTransform.orientation.toInterop();

        const cppPtr = basis.bindings.api.PhysicsActor_createBoxTrigger(
            basis.library_api.getZigLibCppPtr(),
            self.cppPtr,
            width,
            height,
            depth,
            &interopPosition,
            &interopOrientation,
            ignoreStaticObjects,
            ignoreRemovedObjects,
        );

        return PhysicsActorPtr{
            .cppPtr = cppPtr,
            .actorType = PhysicsActorType.Trigger,
        };
    }

    pub fn createSphereTrigger(
        self: *const Self,
        radius: f32,
        initialTransform: PhysicsTransform,
        ignoreStaticObjects: bool,
        ignoreRemovedObjects: bool,
    ) PhysicsActorPtr {
        const interopPosition = initialTransform.position.toInterop();
        const interopOrientation = initialTransform.orientation.toInterop();

        const cppPtr = basis.bindings.api.PhysicsActor_createSphereTrigger(
            basis.library_api.getZigLibCppPtr(),
            self.cppPtr,
            radius,
            &interopPosition,
            &interopOrientation,
            ignoreStaticObjects,
            ignoreRemovedObjects,
        );

        return PhysicsActorPtr{
            .cppPtr = cppPtr,
            .actorType = PhysicsActorType.Trigger,
        };
    }

    //----------------------------------------------------

    // Vehicles:

    pub fn createVehicleController(
        self: *const Self,
        desc: VehicleControllerDescription,
        controllerType: VehicleControllerType,
    ) VehicleControllerPtr {
        const interopDesc = basis.bindings.InteropVehCtrlDesc.initFromDesc(desc);
        const interopType: i32 = @intFromEnum(controllerType);

        const cppPtr = basis.bindings.api.VehicleController_createVehicleController(
            self.cppPtr,
            &interopDesc,
            interopType,
        );

        return VehicleControllerPtr{
            .cppPtr = cppPtr,
            .controllerType = controllerType,
        };
    }

    //----------------------------------------------------

    // Joints:

    pub fn createFixedJoint(
        self: *const Self,
        actorA: PhysicsActorPtr,
        actorATransform: PhysicsTransform,
        actorB: PhysicsActorPtr,
        actorBTransform: PhysicsTransform,
    ) PhysicsJointPtr {
        const interopPositionA = actorATransform.position.toInterop();
        const interopOrientationA = actorATransform.orientation.toInterop();

        const interopPositionB = actorBTransform.position.toInterop();
        const interopOrientationB = actorBTransform.orientation.toInterop();

        const cppPtr = basis.bindings.api.PhysicsJoint_createFixedJoint(
            self.cppPtr,
            actorA.cppPtr,
            &interopPositionA,
            &interopOrientationA,
            actorB.cppPtr,
            &interopPositionB,
            &interopOrientationB,
        );

        return PhysicsJointPtr{
            .cppPtr = cppPtr,
            .jointType = basis.physics.physics_joint.PhysicsJointType.JointTypeFixed,
        };
    }

    pub fn createSphericalJoint(
        self: *const Self,
        actorA: PhysicsActorPtr,
        actorATransform: PhysicsTransform,
        actorB: PhysicsActorPtr,
        actorBTransform: PhysicsTransform,
    ) PhysicsJointPtr {
        const interopPositionA = actorATransform.position.toInterop();
        const interopOrientationA = actorATransform.orientation.toInterop();

        const interopPositionB = actorBTransform.position.toInterop();
        const interopOrientationB = actorBTransform.orientation.toInterop();

        const cppPtr = basis.bindings.api.PhysicsJoint_createSphericalJoint(
            self.cppPtr,
            actorA.cppPtr,
            &interopPositionA,
            &interopOrientationA,
            actorB.cppPtr,
            &interopPositionB,
            &interopOrientationB,
        );

        return PhysicsJointPtr{
            .cppPtr = cppPtr,
            .jointType = basis.physics.physics_joint.PhysicsJointType.JointTypeSpherical,
        };
    }

    pub fn createDistanceJoint(
        self: *const Self,
        actorA: PhysicsActorPtr,
        actorATransform: PhysicsTransform,
        actorB: PhysicsActorPtr,
        actorBTransform: PhysicsTransform,
    ) PhysicsJointPtr {
        const interopPositionA = actorATransform.position.toInterop();
        const interopOrientationA = actorATransform.orientation.toInterop();

        const interopPositionB = actorBTransform.position.toInterop();
        const interopOrientationB = actorBTransform.orientation.toInterop();

        const cppPtr = basis.bindings.api.PhysicsJoint_createDistanceJoint(
            self.cppPtr,
            actorA.cppPtr,
            &interopPositionA,
            &interopOrientationA,
            actorB.cppPtr,
            &interopPositionB,
            &interopOrientationB,
        );

        return PhysicsJointPtr{
            .cppPtr = cppPtr,
            .jointType = basis.physics.physics_joint.PhysicsJointType.JointTypeDistance,
        };
    }

    pub fn createDof6Joint(
        self: *const Self,
        actorA: PhysicsActorPtr,
        actorATransform: PhysicsTransform,
        actorB: PhysicsActorPtr,
        actorBTransform: PhysicsTransform,
    ) PhysicsJointPtr {
        const interopPositionA = actorATransform.position.toInterop();
        const interopOrientationA = actorATransform.orientation.toInterop();

        const interopPositionB = actorBTransform.position.toInterop();
        const interopOrientationB = actorBTransform.orientation.toInterop();

        const cppPtr = basis.bindings.api.PhysicsJoint_createDof6Joint(
            self.cppPtr,
            actorA.cppPtr,
            &interopPositionA,
            &interopOrientationA,
            actorB.cppPtr,
            &interopPositionB,
            &interopOrientationB,
        );

        return PhysicsJointPtr{
            .cppPtr = cppPtr,
            .jointType = basis.physics.physics_joint.PhysicsJointType.JointTypeDof6,
        };
    }

    pub fn createSphericalSpringJoint(
        self: *const Self,
        actorA: PhysicsActorPtr,
        actorATransform: PhysicsTransform,
        actorB: PhysicsActorPtr,
        actorBTransform: PhysicsTransform,
        stiffness: f32,
        damping: f32,
        forceLimit: f32,
    ) PhysicsJointPtr {
        const interopPositionA = actorATransform.position.toInterop();
        const interopOrientationA = actorATransform.orientation.toInterop();

        const interopPositionB = actorBTransform.position.toInterop();
        const interopOrientationB = actorBTransform.orientation.toInterop();

        const cppPtr = basis.bindings.api.PhysicsJoint_createSphericalSpringJoint(
            self.cppPtr,
            actorA.cppPtr,
            &interopPositionA,
            &interopOrientationA,
            actorB.cppPtr,
            &interopPositionB,
            &interopOrientationB,
            stiffness,
            damping,
            forceLimit,
        );

        return PhysicsJointPtr{
            .cppPtr = cppPtr,
            .jointType = basis.physics.physics_joint.PhysicsJointType.JointTypeSphericalSpring,
        };
    }

    //----------------------------------------------------

    // Misc:

    pub fn createTriMesh(
        self: *const Self,
        triMeshData: []const u8,
    ) PhysicsTriMeshPtr {
        const data = basis.string.toInteropString(triMeshData);
        const cppPtr = basis.bindings.api.PhysicsTriMesh_createTriMesh(self.cppPtr, &data);

        return PhysicsTriMeshPtr{
            .cppPtr = cppPtr,
        };
    }
};
