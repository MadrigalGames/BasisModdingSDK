// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
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

pub fn init(allocator: std.mem.Allocator) void {
    gAllocator = allocator;
    gDescriptionMap = VehicleDescriptionMap.init(allocator);
}

pub fn deinit() void {
    var it = gDescriptionMap.iterator();
    while (it.next()) |entry| {
        var desc: *VehicleDescription = entry.value_ptr.*;
        desc.deinit();
        gAllocator.destroy(desc);
    }

    gDescriptionMap.deinit();
}

pub fn preloadVehicleDescription(path: []const u8, controllerType: VehicleControllerType) bool {
    gMutex.lock();
    defer gMutex.unlock();

    const pathHash = basis.string.makeStringHash(path);

    if (!gDescriptionMap.contains(pathHash)) {
        var descPtr = gAllocator.create(VehicleDescription) catch unreachable;

        const jsonResource: ?JsonResourcePtr = basis.resources.resource_manager.acquireResource(JsonResourcePtr, path);

        if (jsonResource) |json| {
            descPtr.* = VehicleDescription.init(gAllocator, json, controllerType);
            descPtr.postInit();

            gDescriptionMap.put(pathHash, descPtr) catch unreachable;

            json.release();
        } else {
            return false;
        }
    }

    return true;
}

pub fn getVehicleDescription(path: []const u8, controllerType: VehicleControllerType) *VehicleDescription {
    gMutex.lock();
    defer gMutex.unlock();

    if (preloadVehicleDescription(path, controllerType)) {
        const pathHash = basis.string.makeStringHash(path);
        return gDescriptionMap.get(pathHash).?;
    }

    basis.fatalErrorWithFormat(@src(), "Could not load vehicle description with path \"{s}\".", .{path});
    return undefined;
}

//----------------------------------------------------

// Private data:

const VehicleDescriptionMap = basis.HashMap(basis.string.StringHash, *VehicleDescription);

var gAllocator: std.mem.Allocator = undefined;
var gDescriptionMap: VehicleDescriptionMap = undefined;
var gMutex = std.Thread.Mutex.Recursive.init;
