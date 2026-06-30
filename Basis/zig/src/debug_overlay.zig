// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

const Allocator = std.mem.Allocator;

pub const ImGuiCallback = basis.delegate.VoidDelegate0();
pub const ImGuiCallbackID = i32;

//----------------------------------------------------
// State management
//----------------------------------------------------

pub const GlobalData = struct {
    const Self = @This();

    imGuiMenuBarCallbacks: std.AutoArrayHashMap(ImGuiCallbackID, ImGuiCallback) = undefined,
    nextImGuiMenuBarCallbackID: ImGuiCallbackID = 0,

    imGuiCallbacks: std.AutoArrayHashMap(ImGuiCallbackID, ImGuiCallback) = undefined,
    nextImGuiCallbackID: ImGuiCallbackID = 0,
};

pub fn init() void {
    basis.g.debug_overlay.imGuiMenuBarCallbacks = .init(basis.g.allocator);
    basis.g.debug_overlay.imGuiCallbacks = .init(basis.g.allocator);
}

pub fn deinit() void {
    basis.g.debug_overlay.imGuiMenuBarCallbacks.deinit();
    basis.g.debug_overlay.imGuiCallbacks.deinit();
}

//----------------------------------------------------
// Public interface
//----------------------------------------------------

pub fn isVisible() bool {
    const visible = basis.bindings.api.DebugOverlay_isVisible();
    return (visible == 1);
}

pub fn registerImGuiMenuBarCallback(cb: ImGuiCallback) ImGuiCallbackID {
    const g = &basis.g.debug_overlay;

    if (g.imGuiMenuBarCallbacks.count() == 0) {
        basis.bindings.api.DebugOverlay_setImGuiMenuBarCallbackEnabled(
            basis.library_api.getZigLibCppPtr(),
            1,
        );
    }

    const id = g.nextImGuiMenuBarCallbackID;
    g.imGuiMenuBarCallbacks.put(id, cb) catch unreachable;
    g.nextImGuiMenuBarCallbackID += 1;
    return id;
}

pub fn unregisterImGuiMenuBarCallback(id: ImGuiCallbackID) void {
    const g = &basis.g.debug_overlay;

    _ = g.imGuiMenuBarCallbacks.swapRemove(id);

    if (g.imGuiMenuBarCallbacks.count() == 0) {
        basis.bindings.api.DebugOverlay_setImGuiMenuBarCallbackEnabled(
            basis.library_api.getZigLibCppPtr(),
            0,
        );
    }
}

pub fn registerImGuiCallback(cb: ImGuiCallback) ImGuiCallbackID {
    const g = &basis.g.debug_overlay;

    if (g.imGuiCallbacks.count() == 0) {
        basis.bindings.api.DebugOverlay_setImGuiCallbackEnabled(
            basis.library_api.getZigLibCppPtr(),
            1,
        );
    }

    const id = g.nextImGuiCallbackID;
    g.imGuiCallbacks.put(id, cb) catch unreachable;
    g.nextImGuiCallbackID += 1;
    return id;
}

pub fn unregisterImGuiCallback(id: ImGuiCallbackID) void {
    const g = &basis.g.debug_overlay;

    _ = g.imGuiCallbacks.swapRemove(id);

    if (g.imGuiCallbacks.count() == 0) {
        basis.bindings.api.DebugOverlay_setImGuiCallbackEnabled(
            basis.library_api.getZigLibCppPtr(),
            0,
        );
    }
}

pub fn debugTrace(comptime fmt: []const u8, args: anytype) void {
    const data = std.fmt.allocPrint(basis.g.allocator, fmt, args) catch unreachable;
    defer basis.g.allocator.free(data);

    basis.bindings.api.DebugOverlay_debugTrace(&data[0], @as(u32, @intCast(data.len)));
}

pub fn debugWarning(comptime fmt: []const u8, args: anytype) void {
    const data = std.fmt.allocPrint(basis.g.allocator, fmt, args) catch unreachable;
    defer basis.g.allocator.free(data);

    basis.bindings.api.DebugOverlay_debugWarning(&data[0], @as(u32, @intCast(data.len)));
}

pub fn areDebugObjectWindowKeysPressed() bool {
    return if (basis.bindings.api.DebugOverlay_areDebugObjectWindowKeysPressed() == 1) true else false;
}

pub fn showDebugActionAtPosition(position: basis.math.Vec3, surfaceNormal: basis.math.Vec3) void {
    const interopP = position.toInterop();
    const interopN = surfaceNormal.toInterop();
    basis.bindings.api.DebugOverlay_showDebugActionAtPosition(&interopP, &interopN);
}

pub fn addDebugSpawnableObjectType(objectType: []const u8, distanceFromSurface: f32) void {
    const interopType = basis.string.toInteropString(objectType);
    basis.bindings.api.DebugOverlay_addDebugSpawnableObjectType(&interopType, distanceFromSurface);
}

//----------------------------------------------------
// Don't call these directly.
//----------------------------------------------------

pub fn _runImGuiMenuBarCallbacks() void {
    const g = &basis.g.debug_overlay;

    var it = g.imGuiMenuBarCallbacks.iterator();

    while (it.next()) |entry| {
        entry.value_ptr.call();
    }
}

pub fn _runImGuiCallbacks() void {
    const g = &basis.g.debug_overlay;

    var it = g.imGuiCallbacks.iterator();

    while (it.next()) |entry| {
        entry.value_ptr.call();
    }
}
