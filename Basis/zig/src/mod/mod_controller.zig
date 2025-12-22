// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Allocator = std.mem.Allocator;

const ModControllerInterface = basis.mod_controller_interface.ModControllerInterface;

const GameObjectCreationParametersPtr = basis.game_object.GameObjectCreationParametersPtr;

const ClientPtr = basis.host.ClientPtr;
const ServerPtr = basis.host.ServerPtr;

// Convenience functions for creating/destroying mod controllers:

pub fn create(comptime T: type, allocator: Allocator) *T {
    basis.bindings.api.init(allocator);

    var controllerPtr: *T = allocator.create(T) catch |err| {
        basis.fatalErrorWithFormat(@src(), "Error creating the mod controller instance: {s}", .{@errorName(err)});
        return undefined;
    };

    const cppPtr = basis.bindings.api.ModController_createModController(
        basis.library_api.getZigLibCppPtr(),
        @intFromPtr(&controllerPtr.interface),
    );

    controllerPtr.* = T.init(ModControllerInterface.make(T, controllerPtr), allocator, cppPtr);
    controllerPtr.postInit() catch |err| {
        basis.fatalErrorWithFormat(@src(), "Error in mod controller postInit(): {s}", .{@errorName(err)});
    };
    return controllerPtr;
}

pub fn destroy(controllerPtr: anytype) void {
    const allocator = controllerPtr.allocator;
    controllerPtr.deinit();
    allocator.destroy(controllerPtr);

    basis.bindings.api.deinit();
}

//----------------------------------------------------

pub const ModControllerContext = struct {
    const Self = @This();

    allocator: Allocator,
    cppPtr: basis.CppPtr,

    pub fn init(allocator: Allocator, cppPtr: basis.CppPtr) Self {
        basis.resources.resource_manager.init(allocator);

        basis.debug_overlay.init(allocator);

        return Self{
            .allocator = allocator,
            .cppPtr = cppPtr,
        };
    }

    pub fn deinit(self: *Self) void {
        _ = self;

        basis.debug_overlay.deinit();

        basis.resources.resource_manager.deinit();
    }

    pub fn getAppMode(self: *const Self) basis.app.AppMode {
        return @as(basis.app.AppMode, @enumFromInt(basis.bindings.api.ModController_getAppMode(self.cppPtr)));
    }

    pub fn getClient(self: *const Self) ClientPtr {
        return ClientPtr{
            .cppPtr = basis.bindings.api.ModController_getClient(self.cppPtr),
            .allocator = self.allocator,
        };
    }

    pub fn getServer(self: *const Self) ServerPtr {
        return ServerPtr{
            .cppPtr = basis.bindings.api.ModController_getServer(self.cppPtr),
            .allocator = self.allocator,
        };
    }

    pub fn registerMessage(self: *const Self, message: anytype, category: anytype) void {
        basis.bindings.api.ModController_registerMessage(self.cppPtr, @intFromEnum(message), @intFromEnum(category));
    }
};
