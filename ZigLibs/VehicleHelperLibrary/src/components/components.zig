// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

pub const VehicleControllerComponent = @import("VehicleControllerComponent.zig").VehicleControllerComponent;
pub const VehicleWheelRendererComponent = @import("VehicleWheelRendererComponent.zig").VehicleWheelRendererComponent;
pub const AutoGearBoxComponent = @import("AutoGearBoxComponent.zig").AutoGearBoxComponent;

pub const list = .{
    VehicleControllerComponent,
    VehicleWheelRendererComponent,
    AutoGearBoxComponent,
};
