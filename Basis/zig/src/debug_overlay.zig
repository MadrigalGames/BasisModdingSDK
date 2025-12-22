// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
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
// Public interface
//----------------------------------------------------

pub fn init(allocator: Allocator) void {
    state = State.init(allocator);
}

pub fn deinit() void {
    if (state) |*s| {
        s.deinit();
    }
}

pub fn isVisible() bool {
    const visible = basis.bindings.api.DebugOverlay_isVisible();
    return (visible == 1);
}

pub fn registerImGuiMenuBarCallback(cb: ImGuiCallback) ImGuiCallbackID {
    if (state) |*s| {
        if (s.imGuiMenuBarCallbacks.count() == 0) {
            basis.bindings.api.DebugOverlay_setImGuiMenuBarCallbackEnabled(
                basis.library_api.getZigLibCppPtr(),
                1,
            );
        }

        const id = s.nextImGuiMenuBarCallbackID;
        s.imGuiMenuBarCallbacks.put(id, cb) catch unreachable;
        s.nextImGuiMenuBarCallbackID += 1;
        return id;
    }

    return -1;
}

pub fn unregisterImGuiMenuBarCallback(id: ImGuiCallbackID) void {
    if (state) |*s| {
        _ = s.imGuiMenuBarCallbacks.swapRemove(id);

        if (s.imGuiMenuBarCallbacks.count() == 0) {
            basis.bindings.api.DebugOverlay_setImGuiMenuBarCallbackEnabled(
                basis.library_api.getZigLibCppPtr(),
                0,
            );
        }
    }
}

pub fn registerImGuiCallback(cb: ImGuiCallback) ImGuiCallbackID {
    if (state) |*s| {
        if (s.imGuiCallbacks.count() == 0) {
            basis.bindings.api.DebugOverlay_setImGuiCallbackEnabled(
                basis.library_api.getZigLibCppPtr(),
                1,
            );
        }

        const id = s.nextImGuiCallbackID;
        s.imGuiCallbacks.put(id, cb) catch unreachable;
        s.nextImGuiCallbackID += 1;
        return id;
    }

    return -1;
}

pub fn unregisterImGuiCallback(id: ImGuiCallbackID) void {
    if (state) |*s| {
        _ = s.imGuiCallbacks.swapRemove(id);

        if (s.imGuiCallbacks.count() == 0) {
            basis.bindings.api.DebugOverlay_setImGuiCallbackEnabled(
                basis.library_api.getZigLibCppPtr(),
                0,
            );
        }
    }
}

pub fn debugTrace(comptime fmt: []const u8, args: anytype) void {
    if (state) |*s| {
        const data = std.fmt.allocPrint(s.allocator, fmt, args) catch unreachable;
        defer s.allocator.free(data);

        basis.bindings.api.DebugOverlay_debugTrace(&data[0], @as(u32, @intCast(data.len)));
    }
}

pub fn debugWarning(comptime fmt: []const u8, args: anytype) void {
    if (state) |*s| {
        const data = std.fmt.allocPrint(s.allocator, fmt, args) catch unreachable;
        defer s.allocator.free(data);

        basis.bindings.api.DebugOverlay_debugWarning(&data[0], @as(u32, @intCast(data.len)));
    }
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
    if (state) |*s| {
        var it = s.imGuiMenuBarCallbacks.iterator();

        while (it.next()) |entry| {
            entry.value_ptr.call();
        }
    }
}

pub fn _runImGuiCallbacks() void {
    if (state) |*s| {
        var it = s.imGuiCallbacks.iterator();

        while (it.next()) |entry| {
            entry.value_ptr.call();
        }
    }
}

//----------------------------------------------------
// Implementation
//----------------------------------------------------

var state: ?State = null;

const State = struct {
    const Self = @This();

    allocator: Allocator,

    imGuiMenuBarCallbacks: std.AutoArrayHashMap(ImGuiCallbackID, ImGuiCallback),
    nextImGuiMenuBarCallbackID: ImGuiCallbackID,

    imGuiCallbacks: std.AutoArrayHashMap(ImGuiCallbackID, ImGuiCallback),
    nextImGuiCallbackID: ImGuiCallbackID,

    pub fn init(allocator: Allocator) Self {
        return Self{
            .allocator = allocator,
            .imGuiMenuBarCallbacks = std.AutoArrayHashMap(ImGuiCallbackID, ImGuiCallback).init(allocator),
            .nextImGuiMenuBarCallbackID = 0,
            .imGuiCallbacks = std.AutoArrayHashMap(ImGuiCallbackID, ImGuiCallback).init(allocator),
            .nextImGuiCallbackID = 0,
        };
    }

    pub fn deinit(self: *Self) void {
        self.imGuiMenuBarCallbacks.deinit();
        self.imGuiCallbacks.deinit();
    }
};
