// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const vhl = @import("../vhl.zig");

const GameObjectComponent = basis.component_contexts.GameObjectComponent;

const Message = basis.messaging.Message;
const MessageParametersPtr = basis.messaging.MessageParametersPtr;

const VehicleInputData = basis.physics.vehicles.VehicleInputData;
const VehicleControllerPtr = basis.physics.vehicle_controller.VehicleControllerPtr;
const ResourceCallback = basis.resources.resource_manager.ResourceCallback;

const AutoGearBox = vhl.auto_gear_box.AutoGearBox;
const AutoGearBoxParams = vhl.auto_gear_box.AutoGearBoxParams;

const RawDataFilePtr = basis.resources.RawDataFilePtr;

pub const AutoGearBoxComponent = struct {
    const Self = @This();
    pub const RegistrationName = "vhl.AutoGearBoxComponent";
    pub const UpdateOrder = 50;

    context: GameObjectComponent,
    parameterResource: ?RawDataFilePtr,
    controller: VehicleControllerPtr,
    autoGearBox: AutoGearBox,
    isSetup: bool,

    //----------------------------------------------------

    pub fn init(context: GameObjectComponent) !Self {
        return Self{
            .context = context,
            .parameterResource = null,
            .controller = undefined,
            .autoGearBox = undefined,
            .isSetup = false,
        };
    }

    //----------------------------------------------------

    pub fn destroy(self: *Self) !void {
        if (self.parameterResource) |*res| {
            basis.resources.resource_manager.unregisterResourceReloadedCallback(
                res,
                .initMethod(self, Self, onParametersUpdated),
            );
            res.release();
            self.parameterResource = null;
        }
    }

    pub fn initAutoGearBox(
        self: *Self,
        parameterResourcePath: []const u8,
        vehicleController: VehicleControllerPtr,
    ) void {
        if (self.parameterResource) |*res| {
            basis.resources.resource_manager.unregisterResourceReloadedCallback(
                res,
                .initMethod(self, Self, onParametersUpdated),
            );
            res.release();
            self.parameterResource = null;
        }

        self.controller = vehicleController;

        self.parameterResource = basis.resources.resource_manager.acquireResource(RawDataFilePtr, parameterResourcePath);
        basis.assert(@src(), self.parameterResource != null);
        basis.resources.resource_manager.registerResourceReloadedCallback(
            self.parameterResource.?,
            .initMethod(self, Self, onParametersUpdated),
        );

        self.initParameters();

        self.isSetup = true;
    }

    pub fn updateAutoGearBox(
        self: *Self,
        deltaTime: f32,
        inputAcceleration: f32,
        inputBrake: f32,
        inputHandBrake: f32,
        vehicleInputData: *VehicleInputData,
    ) void {
        basis.assert(@src(), self.isSetup);
        self.autoGearBox.update(deltaTime, inputAcceleration, inputBrake, inputHandBrake, vehicleInputData);
    }

    pub fn resetAutoGearBox(self: *Self) void {
        self.autoGearBox.reset();
    }

    pub fn beforeHotReload(self: *Self) !void {
        if (self.parameterResource) |*res| {
            basis.resources.resource_manager.unregisterResourceReloadedCallback(
                res,
                .initMethod(self, Self, onParametersUpdated),
            );
        }
    }

    pub fn afterHotReload(self: *Self) !void {
        if (self.parameterResource) |res| {
            basis.resources.resource_manager.registerResourceReloadedCallback(
                res,
                .initMethod(self, Self, onParametersUpdated),
            );
        }
    }

    //----------------------------------------------------

    fn initParameters(self: *Self) void {
        basis.assert(@src(), self.parameterResource != null);

        var stream = basis.BinaryReadStream.init(self.parameterResource.?.getRawData(), true);
        var params: AutoGearBoxParams = AutoGearBoxParams{};
        params.deserialize(&stream);

        self.autoGearBox = AutoGearBox.init(self.controller, params);
    }

    fn onParametersUpdated(self: *Self) void {
        self.initParameters();
    }
};
