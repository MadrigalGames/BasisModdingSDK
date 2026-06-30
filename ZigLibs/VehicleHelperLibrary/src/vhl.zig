// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");

pub const global_data = @import("global_data.zig");
pub const hot_reload = @import("hot_reload.zig");
pub const vehicle_description = @import("vehicle_description.zig");
pub const vehicle_database = @import("vehicle_database.zig");
pub const vehicle_camera_controller = @import("vehicle_camera_controller.zig");
pub const vehicle_speed_controller = @import("vehicle_speed_controller.zig");
pub const auto_gear_box = @import("auto_gear_box.zig");
pub const components = @import("components/components.zig");
pub const pid_controller = @import("pid_controller.zig");

// The global data ptr.
pub var g: *global_data.LibraryGlobalData = undefined;

//----------------------------------------------------

pub const VehicleDescription = vehicle_description.VehicleDescription;
pub const VehicleCameraController = vehicle_camera_controller.VehicleCameraController;

//----------------------------------------------------

pub fn beforeHotReload() void {
    vehicle_database.beforeHotReload();
}

pub fn afterHotReload() void {
    vehicle_database.afterHotReload();
}

pub fn vehicleInputToVec4(inputData: basis.physics.vehicles.VehicleInputData) basis.math.Vec4 {
    return basis.math.Vec4{
        .x = inputData.acceleration,
        .y = inputData.brake,
        .z = inputData.steering,
        .w = inputData.handbrake,
    };
}

pub fn vec4ToVehicleInput(vec4: basis.math.Vec4) basis.physics.vehicles.VehicleInputData {
    return basis.physics.vehicles.VehicleInputData{
        .acceleration = vec4.x,
        .brake = vec4.y,
        .steering = vec4.z,
        .handbrake = vec4.w,
    };
}

pub fn forceAnalysis() void {
    const modules = .{
        vehicle_description,
        vehicle_database,
        vehicle_camera_controller,
        vehicle_speed_controller,
        pid_controller,

        // Must leave out because of the BoundedArray/Writer issue.
        //auto_gear_box,
        //components,
    };

    inline for (modules) |module| {
        std.testing.refAllDecls(module);
    }
}
