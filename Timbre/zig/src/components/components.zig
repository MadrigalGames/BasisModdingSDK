// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

pub const TimbreEventComponent = @import("TimbreEventComponent.zig").TimbreEventComponent;
pub const TimbreEventScriptComponent = @import("TimbreEventScriptComponent.zig").TimbreEventScriptComponent;

pub const list = .{
    TimbreEventComponent,
    TimbreEventScriptComponent,
};
