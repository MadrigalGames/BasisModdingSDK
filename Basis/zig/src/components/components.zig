// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

// Note! Keep this in sync with the C++ side.
pub const ZigComponentFlags = enum(u32) {
    None = 0,
    HasUpdate = (1 << 0),
    HasPreTick = (1 << 1),
    HasTick = (1 << 2),
    HasExposedProperties = (1 << 3),
    HasBlueprintProperties = (1 << 4),
    NeedsExport = (1 << 5),
    IsTransformComponent = (1 << 6),
    IsScripted = (1 << 7),
    HasDrawEditor = (1 << 8),
    HasEditorState = (1 << 9),

    pub fn asInt(self: ZigComponentFlags) u32 {
        return @intFromEnum(self);
    }
};

/// We cannot access MeshComponents directly from Zig since they are written in C++
/// but we can get the pointers to the interesting members of the MeshComponent.
/// This struct contains all of the interesting members in one place.
pub const MeshComponentData = struct {
    sceneNode: basis.math.SceneNodePtr = basis.math.SceneNodePtr.Null,
    mesh: basis.renderer.MeshPtr = basis.renderer.MeshPtr.Null,
    meshInstance: basis.renderer.MeshInstancePtr = basis.renderer.MeshInstancePtr.Null,
};

pub const GlobalData = struct {
    // Keep a list of all factory interface pointers here. We currently support
    // up to 200 factories on the c++ side, so let's do the same here.
    factoryInterfacePointers: [200]*basis.component_factory.ComponentFactoryInterface = undefined,
    factoryInterfaceCount: usize = 0,
};

//----------------------------------------------------

pub fn getComponentTypeName(comptime T: type) []const u8 {
    // If an explicit registration name is given, use that. Otherwise fall back to the
    // full type name of the component type, which can be quite long.
    return if (@hasDecl(T, "RegistrationName")) T.RegistrationName else @typeName(T);
}

pub fn getComponentUpdateOrder(comptime T: type) u32 {
    // If an explicit update order has been given, use that. Otherwise use a default of 50.
    return if (@hasDecl(T, "UpdateOrder")) T.UpdateOrder else 50;
}

pub fn hasExposedProperties(comptime T: type) bool {
    return @hasDecl(T, "ExposedPropertyMap");
}

pub fn isScripted(comptime T: type) bool {
    //return @hasField(T, "scriptCode") and @hasDecl(T, "registerAngelScript");

    // Should be enough to check that the type has a registerAngelScript() method.
    // We can figure out which exposed property to use for the script code from C++.
    return @hasDecl(T, "registerAngelScript");
}

pub fn needsExport(comptime T: type) bool {
    return @hasDecl(T, "exportLevel");
}

pub fn hasEditorState(comptime T: type) bool {
    return @hasDecl(T, "serializeEditorState") and @hasDecl(T, "deserializeEditorState");
}

// WASM registration doesn't use a function pointer here. Rather the callback is hardcoded to a specific extern function.
// Would be nice to have it as "void" in WASM but "parameter of type 'void' not allowed in function with calling
// convention 'wasm_watc'", so we'll have to pass a dummy integer.
pub const ComponentRegistrationCallback =
    if (basis.build_options.buildAsWASM) i32 else basis.bindings.basis_zig_component_reg_cb;

pub fn initComponentTypes(
    comptime T: []const type,
    allocator: std.mem.Allocator,
    io: std.Io,
    callback: ComponentRegistrationCallback,
) void {
    inline for (T, 0..) |componentType, i| {
        initComponentType(componentType, allocator, io, callback, i);
    }
    //basis.printf("Registered {0} component types\n", .{factoryInterfaceCount});
}

pub fn beforeHotReload() void {
    // Make all factories call beforeHotReload() on their components, if they have that method.
    for (0..basis.g.components.factoryInterfaceCount) |i| {
        basis.g.components.factoryInterfacePointers[i].beforeHotReload();
    }
}

pub fn afterHotReload(comptime ComponentTypes: []const type) void {
    // Fix up the VTables to point to the functions of the new DLL.
    for (0..basis.g.components.factoryInterfaceCount) |i| {
        inline for (ComponentTypes, 0..) |T, typeIndex| {
            if (basis.g.components.factoryInterfacePointers[i].typeIndex == typeIndex) {
                //basis.printf("Component factory VTable fixup, type: {s}, index: {}\n", .{ @typeName(T), i });
                basis.g.components.factoryInterfacePointers[i].setupVTable(basis.component_factory.GameObjectComponentFactory(T));
            }
        }
    }

    // Make all factories call afterHotReload() on their components, if they have that method.
    for (0..basis.g.components.factoryInterfaceCount) |i| {
        basis.g.components.factoryInterfacePointers[i].afterHotReload();
    }
}

pub fn deinitComponentTypes() void {
    for (0..basis.g.components.factoryInterfaceCount) |i| {
        basis.g.components.factoryInterfacePointers[i].deinit();
        //basis.printf("Deinited factory {0}\n", .{i});
    }
    basis.g.components.factoryInterfaceCount = 0;
}

//----------------------------------------------------

fn initComponentType(
    comptime T: type,
    allocator: std.mem.Allocator,
    io: std.Io,
    callback: ComponentRegistrationCallback,
    typeIndex: usize,
) void {
    const Factory = basis.component_factory.GameObjectComponentFactory(T);

    const factory = Factory.init(
        allocator,
        io,
        typeIndex,
    ) catch |err| {
        basis.fatalErrorWithFormat(@src(), "Error initializing component factory: {s}", .{@errorName(err)});
        return;
    };

    const typeName = basis.string.toInteropString(factory.typeName);
    const typeNameHash = basis.string.makeStringHash(factory.typeName);
    const contextTypeName = basis.string.toInteropString(factory.contextTypeName);

    var flags: u32 = 0;

    if (Factory.hasUpdate) {
        flags |= ZigComponentFlags.HasUpdate.asInt();
    }

    if (Factory.hasPreTick) {
        flags |= ZigComponentFlags.HasPreTick.asInt();
    }

    if (Factory.hasTick) {
        flags |= ZigComponentFlags.HasTick.asInt();
    }

    if (Factory.hasExposedProperties) {
        flags |= ZigComponentFlags.HasExposedProperties.asInt();
    }

    if (Factory.hasBlueprintProperties) {
        flags |= ZigComponentFlags.HasBlueprintProperties.asInt();
    }

    if (Factory.needsExport) {
        flags |= ZigComponentFlags.NeedsExport.asInt();
    }

    // Not supported yet...
    // if (Factory.isTransformComponent) {
    //     flags |= ZigComponentFlags.IsTransformComponent.asInt();
    // }

    if (Factory.isScripted) {
        flags |= ZigComponentFlags.IsScripted.asInt();
    }

    if (Factory.hasDrawEditor) {
        flags |= ZigComponentFlags.HasDrawEditor.asInt();
    }

    if (Factory.hasEditorState) {
        flags |= ZigComponentFlags.HasEditorState.asInt();
    }

    const factoryInterfacePtr: basis.IntPtr = @intFromPtr(&factory.interface);

    basis.g.components.factoryInterfacePointers[typeIndex] = &factory.interface;
    basis.g.components.factoryInterfaceCount += 1;

    const libCppPtr = basis.library_api.getZigLibCppPtr();

    if (basis.build_options.buildAsWASM) {
        basis.bindings.api.componentRegistrationCallback_WASM(
            libCppPtr.ptr,
            libCppPtr.type,
            typeName.ptr,
            typeName.len,
            typeNameHash,
            contextTypeName.ptr,
            contextTypeName.len,
            factory.updateSortingKey,
            basis.bindings.hostIntPtrFromLib(factoryInterfacePtr),
            flags,
        );
    } else {
        callback(
            libCppPtr,
            &typeName,
            typeNameHash,
            &contextTypeName,
            factory.updateSortingKey,
            basis.bindings.hostIntPtrFromLib(factoryInterfacePtr),
            flags,
        );
    }
}
