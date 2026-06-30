// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const vhl = @import("vhl.zig");

const VehicleDescription = vhl.VehicleDescription;
const VehicleControllerType = basis.physics.vehicle_controller.VehicleControllerType;
const VehicleControllerDescription = basis.physics.vehicle_controller.VehicleControllerDescription;

const JsonResourcePtr = basis.resources.JsonResourcePtr;

//----------------------------------------------------

const VehicleDescriptionMap = basis.HashMap(basis.string.StringHash, *VehicleDescription);

pub const GlobalData = struct {
    descriptionMap: VehicleDescriptionMap = undefined,
    mutex: std.Io.Mutex = .init,
};

inline fn getG() *GlobalData {
    return &vhl.g.vehicle_database;
}

pub fn init() void {
    const g = getG();
    g.descriptionMap = .init(vhl.g.allocator);
}

pub fn deinit() void {
    const g = getG();

    var it = g.descriptionMap.iterator();
    while (it.next()) |entry| {
        var desc: *VehicleDescription = entry.value_ptr.*;
        desc.deinit();
        vhl.g.allocator.destroy(desc);
    }

    g.descriptionMap.deinit();
}

pub fn preloadVehicleDescription(path: []const u8, controllerType: VehicleControllerType) bool {
    const g = getG();

    g.mutex.lock(vhl.g.io) catch @panic("Mutex Canceled");
    defer g.mutex.unlock(vhl.g.io);

    return preloadVehicleDescriptionInternal(path, controllerType);
}

pub fn getVehicleDescription(path: []const u8, controllerType: VehicleControllerType) *VehicleDescription {
    const g = getG();

    g.mutex.lock(vhl.g.io) catch @panic("Mutex Canceled");
    defer g.mutex.unlock(vhl.g.io);

    return getVehicleDescriptionInternal(path, controllerType);
}

pub fn beforeHotReload() void {
    const g = getG();

    var it = g.descriptionMap.iterator();
    while (it.next()) |entry| {
        var desc: *VehicleDescription = entry.value_ptr.*;
        desc.beforeHotReload();
    }
}

pub fn afterHotReload() void {
    const g = getG();

    var it = g.descriptionMap.iterator();
    while (it.next()) |entry| {
        var desc: *VehicleDescription = entry.value_ptr.*;
        desc.afterHotReload();
    }
}

//----------------------------------------------------

fn preloadVehicleDescriptionInternal(path: []const u8, controllerType: VehicleControllerType) bool {
    const g = getG();
    const pathHash = basis.string.makeStringHash(path);

    if (!g.descriptionMap.contains(pathHash)) {
        var descPtr = vhl.g.allocator.create(VehicleDescription) catch unreachable;

        const jsonResource: ?JsonResourcePtr = basis.resources.resource_manager.acquireResource(JsonResourcePtr, path);

        if (jsonResource) |json| {
            descPtr.* = VehicleDescription.init(vhl.g.allocator, json, controllerType);
            descPtr.postInit();

            g.descriptionMap.put(pathHash, descPtr) catch unreachable;

            json.release();
        } else {
            return false;
        }
    }

    return true;
}

fn getVehicleDescriptionInternal(path: []const u8, controllerType: VehicleControllerType) *VehicleDescription {
    const g = getG();

    if (preloadVehicleDescriptionInternal(path, controllerType)) {
        const pathHash = basis.string.makeStringHash(path);
        return g.descriptionMap.get(pathHash).?;
    }

    basis.fatalErrorWithFormat(@src(), "Could not load vehicle description with path \"{s}\".", .{path});
    return undefined;
}
