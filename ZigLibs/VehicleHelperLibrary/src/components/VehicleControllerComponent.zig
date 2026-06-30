// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");

const GameObjectComponent = basis.component_contexts.GameObjectComponent;

const VehicleControllerDescription = basis.physics.vehicle_controller.VehicleControllerDescription;
const VehicleControllerType = basis.physics.vehicle_controller.VehicleControllerType;
const VehicleControllerPtr = basis.physics.vehicle_controller.VehicleControllerPtr;

const PhysicsActorPtr = basis.physics.PhysicsActorPtr;

const Allocator = std.mem.Allocator;

pub const VehicleControllerComponent = struct {
    const Self = @This();

    pub const RegistrationName = "vhl.VehicleControllerComponent";

    context: GameObjectComponent,

    controller: VehicleControllerPtr = VehicleControllerPtr.Null,
    chassisRB: PhysicsActorPtr = PhysicsActorPtr.Null,

    //----------------------------------------------------

    pub fn init(context: GameObjectComponent) !Self {
        return Self{
            .context = context,
        };
    }

    //pub fn create(_: *Self) !void {}

    pub fn destroy(self: *Self) !void {
        self.destroyController();
    }

    //pub fn onObjectCreated(_: *Self) !void {}

    //----------------------------------------------------

    pub fn createController(
        self: *Self,
        controllerDesc: VehicleControllerDescription,
        controllerType: VehicleControllerType,
        chassisRigidBody: PhysicsActorPtr,
    ) void {
        var descCopy = controllerDesc;
        descCopy.chassisRigidBody = chassisRigidBody;

        self.chassisRB = chassisRigidBody;

        self.chassisRB.addRef();
        self.chassisRB.setMassData(descCopy.chassisMass, descCopy.chassisCenterOfMass);

        const physicsEngine = self.context.getPhysicsEngine();

        self.controller = physicsEngine.createVehicleController(descCopy, controllerType);

        if (controllerType != VehicleControllerType.TypeNoDrive) {
            self.controller.forceGearChange(basis.physics.vehicles.VehicleGear.Gear1);
        }

        self.context.getPrimaryPhysicsScene().addVehicleController(self.controller);
    }

    pub fn recreateController(self: *Self, controllerDesc: VehicleControllerDescription) void {
        basis.assert(@src(), !self.controller.isNull());
        basis.assert(@src(), !self.chassisRB.isNull());

        var descCopy = controllerDesc;
        descCopy.chassisRigidBody = self.chassisRB;

        self.chassisRB.setMassData(descCopy.chassisMass, descCopy.chassisCenterOfMass);

        self.controller.reinit(descCopy);
    }

    pub fn destroyController(self: *Self) void {
        if (!self.controller.isNull()) {
            self.context.getPrimaryPhysicsScene().removeVehicleController(self.controller);
            self.controller.releaseAndZero();
        }

        if (!self.chassisRB.isNull()) {
            self.chassisRB.releaseAndZero();
        }
    }
};
