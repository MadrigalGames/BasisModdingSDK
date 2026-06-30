// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
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

// The bulk audio operations below are protected by a lock on the C++ side,
// which means they are safe to call from the server thread even though the
// server runs on a different thread than the one that loads Timbre projects.
// This thread-safety guarantee applies ONLY to the bulk audio operations;
// nothing else in this file is safe to call off the main thread.

// Obviously this only works when the server is running in the same process as
// a client that has actually loaded Timbre project data. On a hypothetical
// dedicated server with no Timbre instance, these calls have nothing to query.

pub fn getBulkAudioAssetDuration(path: []const u8) f32 {
    const interopPath = basis.string.toInteropString(path);
    return timbre.bindings.api.TimbreSoundManager_getBulkAudioAssetDuration(&interopPath);
}

pub fn getBulkAudioAssetDurationByHash(pathHash: u32) f32 {
    return timbre.bindings.api.TimbreSoundManager_getBulkAudioAssetDurationByHash(pathHash);
}

pub fn getBulkAudioAssetID(path: []const u8) u32 {
    const interopPath = basis.string.toInteropString(path);
    return timbre.bindings.api.TimbreSoundManager_getBulkAudioAssetID(&interopPath);
}

pub const BulkAudioAssetData = struct {
    duration: f32,
    assetID: u32,
};

pub fn getBulkAudioAssetData(path: []const u8) ?BulkAudioAssetData {
    const interopPath = basis.string.toInteropString(path);
    var duration: f32 = -1.0;
    var assetID: u32 = 0xFFFFFFFF;
    const found = timbre.bindings.api.TimbreSoundManager_getBulkAudioAssetData(&interopPath, &duration, &assetID);
    if (found == 0) return null;
    return .{ .duration = duration, .assetID = assetID };
}
