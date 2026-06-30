// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
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

pub fn create(comptime T: type, allocator: Allocator, io: std.Io) *T {
    basis.bindings.api.init(allocator);

    var controllerPtr: *T = allocator.create(T) catch |err| {
        basis.fatalErrorWithFormat(@src(), "Error creating the mod controller instance: {s}", .{@errorName(err)});
        return undefined;
    };

    const cppPtr = basis.bindings.api.ModController_createModController(
        basis.library_api.getZigLibCppPtr(),
        @intFromPtr(&controllerPtr.interface),
    );

    controllerPtr.* = T.init(ModControllerInterface.make(T, controllerPtr), allocator, io, cppPtr);
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
    io: std.Io,
    cppPtr: basis.CppPtr,

    pub fn init(allocator: Allocator, io: std.Io, cppPtr: basis.CppPtr) Self {
        return Self{
            .allocator = allocator,
            .io = io,
            .cppPtr = cppPtr,
        };
    }

    pub fn deinit(self: *Self) void {
        _ = self;
    }

    pub fn getAppMode(self: *const Self) basis.app.AppMode {
        return @as(basis.app.AppMode, @enumFromInt(basis.bindings.api.ModController_getAppMode(self.cppPtr)));
    }

    pub fn getClient(self: *const Self) ClientPtr {
        return ClientPtr{
            .cppPtr = basis.bindings.api.ModController_getClient(self.cppPtr),
            .allocator = self.allocator,
            .io = self.io,
        };
    }

    pub fn getServer(self: *const Self) ServerPtr {
        return ServerPtr{
            .cppPtr = basis.bindings.api.ModController_getServer(self.cppPtr),
            .allocator = self.allocator,
            .io = self.io,
        };
    }

    pub fn registerMessage(self: *const Self, message: anytype, category: anytype) void {
        basis.bindings.api.ModController_registerMessage(self.cppPtr, @intFromEnum(message), @intFromEnum(category));
    }
};
