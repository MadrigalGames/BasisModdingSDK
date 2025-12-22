// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

pub const UpdateMode = enum(i32) {
    // In this mode the engine sets the streaming position to the position of the
    // main camera every update, as long as there is a main camera.
    MainCamera = 0,

    // In this mode the engine does not set the streaming position automatically
    // and it is up to the game to set it.
    Manual,
};

pub fn setStreamingPosition(pos: basis.math.Vec3) void {
    const p = pos.toInterop();
    basis.bindings.api.StreamingUtils_setStreamingPosition(&p);
}

pub fn getStreamingPosition() basis.math.Vec3 {
    var interop: basis.bindings.InteropVec3 = undefined;
    basis.bindings.api.StreamingUtils_getStreamingPosition(&interop);
    return basis.math.Vec3.fromInterop(interop);
}

pub fn setStreamingPositionUpdateMode(mode: UpdateMode) void {
    basis.bindings.api.StreamingUtils_setStreamingPositionUpdateMode(@intFromEnum(mode));
}

pub fn getStreamingPositionUpdateMode() UpdateMode {
    const i = basis.bindings.api.StreamingUtils_getStreamingPositionUpdateMode();
    return @as(UpdateMode, @enumFromInt(i));
}
