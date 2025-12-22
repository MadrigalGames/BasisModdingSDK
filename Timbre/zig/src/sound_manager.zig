// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const timbre = @import("timbre.zig");

pub fn getMasterGroupBus() timbre.GroupBusPtr {
    const cppPtr = timbre.bindings.api.TimbreSoundManager_getMasterGroupBus();
    return timbre.GroupBusPtr.initFromCppPtr(cppPtr);
}

pub fn getGroupBus(path: []const u8) timbre.GroupBusPtr {
    const interopPath = basis.string.toInteropString(path);
    const cppPtr = timbre.bindings.api.TimbreSoundManager_getGroupBus(&interopPath);
    return timbre.GroupBusPtr.initFromCppPtr(cppPtr);
}

pub fn getEventDesc(path: []const u8) timbre.EventDescriptionPtr {
    const interopPath = basis.string.toInteropString(path);
    const cppPtr = timbre.bindings.api.TimbreSoundManager_getEventDesc(&interopPath);
    return timbre.EventDescriptionPtr.initFromCppPtr(cppPtr);
}

pub fn playAndForget2D(eventDesc: timbre.EventDescriptionPtr, autoPause: bool) void {
    timbre.bindings.api.TimbreSoundManager_playAndForget2D(eventDesc.cppPtr, autoPause);
}

pub fn playAndForget3D(eventDesc: timbre.EventDescriptionPtr, position: basis.math.Vec3, autoPause: bool) void {
    const p = position.toInterop();
    timbre.bindings.api.TimbreSoundManager_playAndForget3D(eventDesc.cppPtr, &p, autoPause);
}

pub fn playByPathAndForget2D(path: []const u8, autoPause: bool) void {
    const interopPath = basis.string.toInteropString(path);
    timbre.bindings.api.TimbreSoundManager_playByPathAndForget2D(&interopPath, autoPause);
}

pub fn playByPathAndForget3D(path: []const u8, position: basis.math.Vec3, autoPause: bool) void {
    const interopPath = basis.string.toInteropString(path);
    const p = position.toInterop();
    timbre.bindings.api.TimbreSoundManager_playByPathAndForget3D(&interopPath, &p, autoPause);
}
