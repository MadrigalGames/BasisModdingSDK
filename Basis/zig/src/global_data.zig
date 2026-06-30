// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

pub const LibraryGlobalData = struct {
    // Global allocator and IO interface. Only use these for global-data purposes!
    // If it is possible to pass an allocator/io to a function, prefer that.
    allocator: std.mem.Allocator,
    io: std.Io,

    // When adding more global data here, if possible, try to name each field
    // according to the zig file where it is used.
    physics_trigger: basis.physics.physics_trigger.GlobalData = .{},
    physics_scene: basis.physics.physics_scene.GlobalData = .{},
    debug_overlay: basis.debug_overlay.GlobalData = .{},
    components: basis.components.GlobalData = .{},
    resource_manager: basis.resources.resource_manager.GlobalData = .{},
    free_camera_controller: basis.utils.free_camera_controller.GlobalData = .{},
    game_object_debug_popup: basis.utils.game_object_debug_popup.GlobalData = .{},
};

pub fn create(allocator: std.mem.Allocator, io: std.Io) void {
    basis.g = allocator.create(LibraryGlobalData) catch @panic("OOM");
    basis.g.* = LibraryGlobalData{ .allocator = allocator, .io = io };

    basis.physics.physics_trigger.init();
    basis.physics.physics_scene.init();
    basis.debug_overlay.init();
    basis.resources.resource_manager.init();
}

pub fn destroy() void {
    basis.resources.resource_manager.deinit();
    basis.debug_overlay.deinit();
    basis.physics.physics_scene.deinit();
    basis.physics.physics_trigger.deinit();

    basis.g.allocator.destroy(basis.g);
}
