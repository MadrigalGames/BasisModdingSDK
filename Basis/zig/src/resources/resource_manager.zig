// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const MeshResourcePtr = basis.resources.MeshResourcePtr;
const MaterialResourcePtr = basis.resources.MaterialResourcePtr;
const JsonResourcePtr = basis.resources.JsonResourcePtr;

pub const ResourceCallback = basis.delegate.VoidDelegate0();

pub const LooseFileMapping = struct {
    sourceFilePath: []const u8,
    resourcePath: []const u8,
    resourceType: basis.typeinfo.ResourceTypeID,
};

//----------------------------------------------------

pub fn acquireResource(comptime T: type, resourcePath: []const u8) ?T {
    const path = basis.string.toInteropString(resourcePath);

    const cppPtr = basis.bindings.api.ResourceManager_acquireResource(
        gResourceManagerCppPtr,
        &path,
        @intFromEnum(basis.typeinfo.getResourceTypeID(T)),
    );

    if (cppPtr == 0) {
        return null;
    }

    return T{
        .cppPtr = cppPtr,
    };
}

pub fn acquireResourceOrError(comptime T: type, resourcePath: []const u8) T {
    const res = acquireResource(T, resourcePath);
    if (res == null) {
        basis.fatalErrorWithFormat(@src(), "Could not find resource \"{s}\".", .{resourcePath});
    }
    return res.?;
}

pub fn getResourcesWithFileExtension(
    list: *basis.ArrayList(basis.String),
    fileExtension: []const u8,
    appendToList: bool,
) void {
    lock();
    defer unlock();

    if (!appendToList) {
        for (list.items) |*item| {
            item.deinit();
        }
        list.clearRetainingCapacity();
    }

    var resourceCount: u32 = 0;

    const fileExt = basis.string.toInteropString(fileExtension);

    // Get the list of resource paths and copy to temp buffers on the C++ side.
    const interopStrings = basis.bindings.api.ResourceManager_beginGetResourcesWithFileExtension(
        gResourceManagerCppPtr,
        &fileExt,
        &resourceCount,
    );

    // Copy from the temp buffers into the array list.
    var i: u32 = 0;
    while (i < resourceCount) : (i += 1) {
        const str = basis.string.init(gAllocator, interopStrings[i].ptr[0..interopStrings[i].len]);
        //basis.printf("Resource: {s}\n", .{str.str()});
        list.append(str) catch unreachable;
    }

    // Free the temp buffers on the C++ side.
    basis.bindings.api.ResourceManager_endGetResourcesWithFileExtension();
}

pub fn registerResourceReloadedCallback(resource: anytype, callback: ResourceCallback) void {
    lock();
    defer unlock();

    const id = gCallbackIDAccumulator;
    gCallbackIDAccumulator += 1;

    const data = ResourceCallbackData{
        .id = id,
        .callback = callback,
        .resourceCppPtr = resource.cppPtr,
    };

    gRegisteredResourceCallbacks.append(data) catch unreachable;

    basis.bindings.api.ResourceManager_registerResourceReloadedCallback(
        data.resourceCppPtr,
        data.id,
    );
}

pub fn unregisterResourceReloadedCallback(resource: anytype, callback: ResourceCallback) void {
    lock();
    defer unlock();

    for (gRegisteredResourceCallbacks.items, 0..) |element, i| {
        if (callback.eql(element.callback) and resource.cppPtr == element.resourceCppPtr) {
            const data = gRegisteredResourceCallbacks.swapRemove(i);

            basis.bindings.api.ResourceManager_unregisterResourceReloadedCallback(
                data.resourceCppPtr,
                data.id,
            );

            return;
        }
    }
}

pub fn addLooseFileResourcePack(
    resourcePackName: []const u8,
    fileMappings: []const LooseFileMapping,
) void {
    lock();
    defer unlock();

    var interopMappings = basis.ArrayList(basis.bindings.InteropLooseFileMapping).init(gAllocator);
    defer interopMappings.deinit();

    for (fileMappings) |mapping| {
        const interopMapping = basis.bindings.InteropLooseFileMapping{
            .sourceFilePath = basis.string.toInteropString(mapping.sourceFilePath),
            .resourcePath = basis.string.toInteropString(mapping.resourcePath),
            .resourceType = @intFromEnum(mapping.resourceType),
        };

        interopMappings.append(interopMapping) catch unreachable;
    }

    const interopName = basis.string.toInteropString(resourcePackName);
    const count: u32 = @as(u32, @intCast(fileMappings.len));

    basis.bindings.api.ResourceManager_addLooseFileResourcePack(
        gResourceManagerCppPtr,
        &interopName,
        &interopMappings.items[0],
        count,
    );
}

//----------------------------------------------------
// Resource manager boilerplate. Don't call directly.

pub fn init(allocator: std.mem.Allocator) void {
    gAllocator = allocator;

    gResourceManagerCppPtr = basis.bindings.api.ResourceManager_init();

    gRegisteredResourceCallbacks = gAllocator.create(CallbackMap) catch unreachable;
    gRegisteredResourceCallbacks.* = CallbackMap.init(gAllocator);
}

pub fn deinit() void {
    gRegisteredResourceCallbacks.deinit();
    gAllocator.destroy(gRegisteredResourceCallbacks);

    basis.bindings.api.ResourceManager_deinit();
}

pub fn _resourceWasReloaded(resourceCppPtr: basis.CppPtr, callbackID: u32) void {
    lock();
    defer unlock();

    _ = resourceCppPtr;

    for (gRegisteredResourceCallbacks.items) |element| {
        if (element.id == callbackID) {
            element.callback.call();
            return;
        }
    }
}

//----------------------------------------------------
// Private functions:

fn lock() void {
    basis.bindings.api.ResourceManager_lock(gResourceManagerCppPtr);
}

fn unlock() void {
    basis.bindings.api.ResourceManager_unlock(gResourceManagerCppPtr);
}

//----------------------------------------------------

// Private data:

const CallbackMap = basis.ArrayList(ResourceCallbackData);

const ResourceCallbackData = struct {
    id: u32,
    callback: ResourceCallback,
    resourceCppPtr: basis.CppPtr,
};

var gAllocator: std.mem.Allocator = undefined;
var gResourceManagerCppPtr: basis.CppPtr = 0;
var gCallbackIDAccumulator: u32 = 0;
var gRegisteredResourceCallbacks: *CallbackMap = undefined;
