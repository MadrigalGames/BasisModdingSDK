// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const vhl = @import("vhl.zig");

pub const VehicleSpeedController = struct {
    const Self = @This();

    pidData: vhl.pid_controller.PIDData,

    targetSpeed: f32,

    //----------------------------------------------------

    pub fn init() Self {
        return Self{
            .pidData = vhl.pid_controller.PIDData{
                .p = 0.5,
                .i = 0.05,
                .d = 0.1,
                .minIntegral = -20.0,
                .maxIntegral = 20.0,
                .min = -1.0,
                .max = 1.0,
            },
            .targetSpeed = 0.0,
        };
    }

    pub fn reset(self: *Self) void {
        vhl.pid_controller.clear(&self.pidData);
    }

    pub fn update(
        self: *Self,
        deltaTime: f32,
        vehicleInputData: *basis.physics.vehicles.VehicleInputData,
        currentSpeedForward: f32,
    ) void {
        const currentError = self.targetSpeed - currentSpeedForward;

        const newValue = vhl.pid_controller.update(
            &self.pidData,
            currentError,
            deltaTime,
            true,
        );

        vehicleInputData.acceleration = std.math.clamp(newValue, 0.0, 1.0);
        vehicleInputData.brake = std.math.clamp(newValue, -1.0, 0.0) * -1.0;
    }
};
