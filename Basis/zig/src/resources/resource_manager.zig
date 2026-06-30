// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
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
        basis.g.resource_manager.resourceManagerCppPtr,
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
        basis.g.resource_manager.resourceManagerCppPtr,
        &fileExt,
        &resourceCount,
    );

    // Copy from the temp buffers into the array list.
    var i: u32 = 0;
    while (i < resourceCount) : (i += 1) {
        const str = basis.string.init(list.allocator, interopStrings[i].ptr[0..interopStrings[i].len]);
        //basis.printf("Resource: {s}\n", .{str.str()});
        list.append(str) catch @panic("OOM");
    }

    // Free the temp buffers on the C++ side.
    basis.bindings.api.ResourceManager_endGetResourcesWithFileExtension();
}

pub fn registerResourceReloadedCallback(resource: anytype, callback: ResourceCallback) void {
    lock();
    defer unlock();

    const id = basis.g.resource_manager.callbackIDAccumulator;
    basis.g.resource_manager.callbackIDAccumulator += 1;

    const data = ResourceCallbackData{
        .id = id,
        .callback = callback,
        .resourceCppPtr = resource.cppPtr,
    };

    basis.g.resource_manager.registeredResourceCallbacks.append(data) catch @panic("OOM");

    basis.bindings.api.ResourceManager_registerResourceReloadedCallback(
        data.resourceCppPtr,
        data.id,
    );
}

pub fn unregisterResourceReloadedCallback(resource: anytype, callback: ResourceCallback) void {
    lock();
    defer unlock();

    for (basis.g.resource_manager.registeredResourceCallbacks.items, 0..) |element, i| {
        if (callback.eql(element.callback) and resource.cppPtr == element.resourceCppPtr) {
            const data = basis.g.resource_manager.registeredResourceCallbacks.swapRemove(i);

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

    var interopMappings =
        basis.ArrayList(basis.bindings.InteropLooseFileMapping).init(basis.g.allocator);
    defer interopMappings.deinit();

    for (fileMappings) |mapping| {
        const interopMapping = basis.bindings.InteropLooseFileMapping{
            .sourceFilePath = basis.string.toInteropString(mapping.sourceFilePath),
            .resourcePath = basis.string.toInteropString(mapping.resourcePath),
            .resourceType = @intFromEnum(mapping.resourceType),
        };

        interopMappings.append(interopMapping) catch @panic("OOM");
    }

    const interopName = basis.string.toInteropString(resourcePackName);
    const count: u32 = @as(u32, @intCast(fileMappings.len));

    basis.bindings.api.ResourceManager_addLooseFileResourcePack(
        basis.g.resource_manager.resourceManagerCppPtr,
        &interopName,
        &interopMappings.items[0],
        count,
    );
}

pub fn getSourceFilePathForResource(resourcePath: []const u8) ?[]const u8 {
    const interopResourcePath = basis.string.toInteropString(resourcePath);
    var interopSourceFilePath: basis.bindings.InteropString = undefined;

    if (basis.bindings.api.ResourceManager_getSourceFilePathForResource(
        basis.g.resource_manager.resourceManagerCppPtr,
        &interopResourcePath,
        &interopSourceFilePath,
    ) == 1) {
        return basis.string.fromInteropString(&interopSourceFilePath);
    }

    return null;
}

//----------------------------------------------------
// Resource manager boilerplate. Don't call directly.

pub fn init() void {
    basis.g.resource_manager.resourceManagerCppPtr = basis.bindings.api.ResourceManager_init();
    basis.g.resource_manager.registeredResourceCallbacks = .init(basis.g.allocator);
}

pub fn deinit() void {
    basis.g.resource_manager.registeredResourceCallbacks.deinit();
    basis.bindings.api.ResourceManager_deinit();
}

pub fn _resourceWasReloaded(resourceCppPtr: basis.CppPtr, callbackID: u32) void {
    lock();
    defer unlock();

    _ = resourceCppPtr;

    for (basis.g.resource_manager.registeredResourceCallbacks.items) |element| {
        if (element.id == callbackID) {
            element.callback.call();
            return;
        }
    }
}

//----------------------------------------------------
// Private functions:

fn lock() void {
    basis.bindings.api.ResourceManager_lock(basis.g.resource_manager.resourceManagerCppPtr);
}

fn unlock() void {
    basis.bindings.api.ResourceManager_unlock(basis.g.resource_manager.resourceManagerCppPtr);
}

//----------------------------------------------------

const CallbackMap = basis.ArrayList(ResourceCallbackData);

const ResourceCallbackData = struct {
    id: u32,
    callback: ResourceCallback,
    resourceCppPtr: basis.CppPtr,
};

pub const GlobalData = struct {
    resourceManagerCppPtr: basis.CppPtr = 0,
    callbackIDAccumulator: u32 = 0,
    registeredResourceCallbacks: CallbackMap = undefined,
};
