// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Allocator = std.mem.Allocator;

// A polymorphic interface for ComponentFactories.
pub const ComponentFactoryInterface = struct {
    const Self = @This();
    object: basis.IntPtr = undefined,
    vTable: *const VirtualTable = undefined,

    const VirtualTable = struct {
        // Methods for the actual component factory:
        deinit: *const fn (*Self) void,
        newComponent: *const fn (*Self, basis.bindings.InteropTypedPtr, bool) basis.IntPtr,
        deleteComponent: *const fn (*Self, bool, basis.IntPtr) void,
        update: *const fn (*Self, bool, f32) void,
        preTick: *const fn (*Self, bool, f32) void,
        tick: *const fn (*Self, bool, f32) void,
        createBlueprintProperties: *const fn (*Self) basis.IntPtr,
        bpPropsLoadJSON: *const fn (*Self, basis.IntPtr, []const u8) bool,
        setBlueprintProperties: *const fn (*Self, basis.IntPtr, basis.IntPtr) void,
        readExposedPropertyLayout: *const fn (*Self, basis.CppPtr) void,
        readExposedPropertyMeta: *const fn (*Self, [*c]basis.bindings.InteropExposedPropertyMeta, u32, [*c]basis.bindings.InteropBuffer, [*c]basis.bindings.InteropBuffer) u32,
        registerAngelScript: *const fn (*Self, basis.CppPtr) void,

        // Methods forwarded to individual components:
        create: *const fn (*Self, basis.IntPtr) void,
        onObjectCreated: *const fn (*Self, basis.IntPtr) void,
        drawEditor: *const fn (*Self, basis.IntPtr, bool, bool) void,
        onMessageReceived: *const fn (*Self, basis.IntPtr, basis.messaging.Message, basis.string.StringHash, basis.messaging.MessageParametersPtr) void,
        onPipeDataReceived: *const fn (*Self, basis.IntPtr, u64, []const u8) void,
        onBecameClientLocalAvatar: *const fn (*Self, basis.IntPtr) void,
        onLostClientLocalAvatar: *const fn (*Self, basis.IntPtr) void,
        onBecameServerAvatar: *const fn (*Self, basis.IntPtr, i32) void,
        onLostServerAvatar: *const fn (*Self, basis.IntPtr, i32) void,
        syncExposedPropertyValues: *const fn (*Self, basis.IntPtr, [*c]basis.bindings.InteropBuffer, i32) void,
        exposedPropertyEvent: *const fn (*Self, basis.IntPtr, *const basis.bindings.InteropString, i32) i32,
        exportLevel: *const fn (*Self, basis.IntPtr, i32, basis.CppPtr) i32,
        serializeEditorState: *const fn (*Self, basis.IntPtr, *basis.bindings.InteropBuffer) void,
        deserializeEditorState: *const fn (*Self, basis.IntPtr, *const basis.bindings.InteropString) void,
        resetEditorState: *const fn (*Self, basis.IntPtr) void,
        editorStateModeChanged: *const fn (*Self, basis.IntPtr, bool) void,
    };

    //----------------------------------------------------

    // Note that we have to supply "self" as the first parameter here manually.

    pub fn deinit(self: *Self) void {
        self.vTable.deinit(self);
    }

    pub fn newComponent(self: *Self, cppContextPtr: basis.bindings.InteropTypedPtr, onClient: bool) basis.IntPtr {
        return self.vTable.newComponent(self, cppContextPtr, onClient);
    }

    pub fn deleteComponent(self: *Self, onClient: bool, componentIntPtr: basis.IntPtr) void {
        self.vTable.deleteComponent(self, onClient, componentIntPtr);
    }

    pub fn update(self: *Self, onClient: bool, deltaTime: f32) void {
        self.vTable.update(self, onClient, deltaTime);
    }

    pub fn preTick(self: *Self, onClient: bool, tickDeltaTime: f32) void {
        self.vTable.preTick(self, onClient, tickDeltaTime);
    }

    pub fn tick(self: *Self, onClient: bool, tickDeltaTime: f32) void {
        self.vTable.tick(self, onClient, tickDeltaTime);
    }

    pub fn createBlueprintProperties(self: *Self) basis.IntPtr {
        return self.vTable.createBlueprintProperties(self);
    }

    pub fn bpPropsLoadJSON(self: *Self, bpPropsIntPtr: basis.IntPtr, json: []const u8) bool {
        return self.vTable.bpPropsLoadJSON(self, bpPropsIntPtr, json);
    }

    pub fn setBlueprintProperties(self: *Self, componentIntPtr: basis.IntPtr, bpPropsIntPtr: basis.IntPtr) void {
        self.vTable.setBlueprintProperties(self, componentIntPtr, bpPropsIntPtr);
    }

    pub fn readExposedPropertyLayout(self: *Self, readerIntPtr: basis.CppPtr) void {
        self.vTable.readExposedPropertyLayout(self, readerIntPtr);
    }

    pub fn readExposedPropertyMeta(
        self: *Self,
        metaBuffer: [*c]basis.bindings.InteropExposedPropertyMeta,
        metaBufferLength: u32,
        defaultValueBuffer: [*c]basis.bindings.InteropBuffer,
        stringBuffer: [*c]basis.bindings.InteropBuffer,
    ) u32 {
        return self.vTable.readExposedPropertyMeta(self, metaBuffer, metaBufferLength, defaultValueBuffer, stringBuffer);
    }

    pub fn registerAngelScript(self: *Self, componentRegistrationIntPtr: basis.CppPtr) void {
        self.vTable.registerAngelScript(self, componentRegistrationIntPtr);
    }

    pub fn create(self: *Self, componentIntPtr: basis.IntPtr) void {
        self.vTable.create(self, componentIntPtr);
    }

    pub fn onObjectCreated(self: *Self, componentIntPtr: basis.IntPtr) void {
        self.vTable.onObjectCreated(self, componentIntPtr);
    }

    pub fn drawEditor(self: *Self, componentIntPtr: basis.IntPtr, selected: bool, hoveredOver: bool) void {
        self.vTable.drawEditor(self, componentIntPtr, selected, hoveredOver);
    }

    pub fn onMessageReceived(
        self: *Self,
        componentIntPtr: basis.IntPtr,
        message: basis.messaging.Message,
        senderNameHash: basis.string.StringHash,
        parameters: basis.messaging.MessageParametersPtr,
    ) void {
        self.vTable.onMessageReceived(self, componentIntPtr, message, senderNameHash, parameters);
    }

    pub fn onPipeDataReceived(
        self: *Self,
        componentIntPtr: basis.IntPtr,
        pipe: u64,
        data: []const u8,
    ) void {
        self.vTable.onPipeDataReceived(self, componentIntPtr, pipe, data);
    }

    pub fn onBecameClientLocalAvatar(self: *Self, componentIntPtr: basis.IntPtr) void {
        self.vTable.onBecameClientLocalAvatar(self, componentIntPtr);
    }

    pub fn onLostClientLocalAvatar(self: *Self, componentIntPtr: basis.IntPtr) void {
        self.vTable.onLostClientLocalAvatar(self, componentIntPtr);
    }

    pub fn onBecameServerAvatar(self: *Self, componentIntPtr: basis.IntPtr, hostID: i32) void {
        self.vTable.onBecameServerAvatar(self, componentIntPtr, hostID);
    }

    pub fn onLostServerAvatar(self: *Self, componentIntPtr: basis.IntPtr, hostID: i32) void {
        self.vTable.onLostServerAvatar(self, componentIntPtr, hostID);
    }

    pub fn syncExposedPropertyValues(
        self: *Self,
        componentIntPtr: basis.IntPtr,
        valueBuffer: [*c]basis.bindings.InteropBuffer,
        direction: i32,
    ) void {
        self.vTable.syncExposedPropertyValues(self, componentIntPtr, valueBuffer, direction);
    }

    pub fn exposedPropertyEvent(
        self: *Self,
        componentIntPtr: basis.IntPtr,
        propertyName: [*c]const basis.bindings.InteropString,
        eventType: i32,
    ) i32 {
        return self.vTable.exposedPropertyEvent(self, componentIntPtr, propertyName, eventType);
    }

    pub fn exportLevel(
        self: *Self,
        componentIntPtr: basis.IntPtr,
        phase: i32,
        dataBlockMgrCppPtr: basis.CppPtr,
    ) i32 {
        return self.vTable.exportLevel(self, componentIntPtr, phase, dataBlockMgrCppPtr);
    }

    pub fn serializeEditorState(
        self: *Self,
        componentIntPtr: basis.IntPtr,
        stateData: [*c]basis.bindings.InteropBuffer,
    ) void {
        self.vTable.serializeEditorState(self, componentIntPtr, stateData);
    }

    pub fn deserializeEditorState(
        self: *Self,
        componentIntPtr: basis.IntPtr,
        stateData: *const basis.bindings.InteropString,
    ) void {
        self.vTable.deserializeEditorState(self, componentIntPtr, stateData);
    }

    pub fn resetEditorState(
        self: *Self,
        componentIntPtr: basis.IntPtr,
    ) void {
        self.vTable.resetEditorState(self, componentIntPtr);
    }

    pub fn editorStateModeChanged(
        self: *Self,
        componentIntPtr: basis.IntPtr,
        editingEnabled: bool,
    ) void {
        self.vTable.editorStateModeChanged(self, componentIntPtr, editingEnabled);
    }

    //----------------------------------------------------

    pub fn make(factoryPtr: anytype) Self {
        const FactoryPtrType = @TypeOf(factoryPtr);
        return Self{
            .object = @intFromPtr(factoryPtr),
            .vTable = &.{
                .deinit = struct {
                    fn wrapCall(self: *Self) void {
                        var typedFactory = @as(FactoryPtrType, @ptrFromInt(self.object));
                        typedFactory.deinit();
                    }
                }.wrapCall,
                .newComponent = struct {
                    fn wrapCall(self: *Self, cppContextPtr: basis.bindings.InteropTypedPtr, onClient: bool) basis.IntPtr {
                        var typedFactory = @as(FactoryPtrType, @ptrFromInt(self.object));
                        return typedFactory.newComponent(cppContextPtr, onClient) catch |err| {
                            basis.fatalErrorWithFormat(@src(), "Error in newComponent(): {s}", .{@errorName(err)});
                            unreachable;
                        };
                    }
                }.wrapCall,
                .deleteComponent = struct {
                    fn wrapCall(self: *Self, onClient: bool, componentIntPtr: basis.IntPtr) void {
                        var typedFactory = @as(FactoryPtrType, @ptrFromInt(self.object));
                        typedFactory.deleteComponent(onClient, componentIntPtr);
                    }
                }.wrapCall,
                .update = struct {
                    fn wrapCall(self: *Self, onClient: bool, deltaTime: f32) void {
                        var typedFactory = @as(FactoryPtrType, @ptrFromInt(self.object));
                        typedFactory.update(onClient, deltaTime);
                    }
                }.wrapCall,
                .preTick = struct {
                    fn wrapCall(self: *Self, onClient: bool, deltaTime: f32) void {
                        var typedFactory = @as(FactoryPtrType, @ptrFromInt(self.object));
                        typedFactory.preTick(onClient, deltaTime);
                    }
                }.wrapCall,
                .tick = struct {
                    fn wrapCall(self: *Self, onClient: bool, deltaTime: f32) void {
                        var typedFactory = @as(FactoryPtrType, @ptrFromInt(self.object));
                        typedFactory.tick(onClient, deltaTime);
                    }
                }.wrapCall,
                .createBlueprintProperties = struct {
                    fn wrapCall(self: *Self) basis.IntPtr {
                        var typedFactory = @as(FactoryPtrType, @ptrFromInt(self.object));
                        return typedFactory.createBlueprintProperties();
                    }
                }.wrapCall,
                .bpPropsLoadJSON = struct {
                    fn wrapCall(self: *Self, bpPropsIntPtr: basis.IntPtr, json: []const u8) bool {
                        var typedFactory = @as(FactoryPtrType, @ptrFromInt(self.object));
                        return typedFactory.bpPropsLoadJSON(bpPropsIntPtr, json);
                    }
                }.wrapCall,
                .setBlueprintProperties = struct {
                    fn wrapCall(self: *Self, componentIntPtr: basis.IntPtr, bpPropsIntPtr: basis.IntPtr) void {
                        var typedFactory = @as(FactoryPtrType, @ptrFromInt(self.object));
                        typedFactory.setBlueprintProperties(componentIntPtr, bpPropsIntPtr);
                    }
                }.wrapCall,
                .readExposedPropertyLayout = struct {
                    fn wrapCall(self: *Self, readerIntPtr: basis.CppPtr) void {
                        var typedFactory = @as(FactoryPtrType, @ptrFromInt(self.object));
                        typedFactory.readExposedPropertyLayout(readerIntPtr);
                    }
                }.wrapCall,
                .readExposedPropertyMeta = struct {
                    fn wrapCall(
                        self: *Self,
                        metaBuffer: [*c]basis.bindings.InteropExposedPropertyMeta,
                        metaBufferLength: u32,
                        defaultValueBuffer: [*c]basis.bindings.InteropBuffer,
                        stringBuffer: [*c]basis.bindings.InteropBuffer,
                    ) u32 {
                        var typedFactory = @as(FactoryPtrType, @ptrFromInt(self.object));
                        return typedFactory.readExposedPropertyMeta(metaBuffer, metaBufferLength, defaultValueBuffer, stringBuffer);
                    }
                }.wrapCall,
                .registerAngelScript = struct {
                    fn wrapCall(self: *Self, componentRegistrationIntPtr: basis.CppPtr) void {
                        var typedFactory = @as(FactoryPtrType, @ptrFromInt(self.object));
                        typedFactory.registerAngelScript(componentRegistrationIntPtr);
                    }
                }.wrapCall,
                .create = struct {
                    fn wrapCall(self: *Self, componentIntPtr: basis.IntPtr) void {
                        var typedFactory = @as(FactoryPtrType, @ptrFromInt(self.object));
                        typedFactory.create(componentIntPtr);
                    }
                }.wrapCall,
                .onObjectCreated = struct {
                    fn wrapCall(self: *Self, componentIntPtr: basis.IntPtr) void {
                        var typedFactory = @as(FactoryPtrType, @ptrFromInt(self.object));
                        typedFactory.onObjectCreated(componentIntPtr);
                    }
                }.wrapCall,
                .drawEditor = struct {
                    fn wrapCall(self: *Self, componentIntPtr: basis.IntPtr, selected: bool, hoveredOver: bool) void {
                        var typedFactory = @as(FactoryPtrType, @ptrFromInt(self.object));
                        typedFactory.drawEditor(componentIntPtr, selected, hoveredOver);
                    }
                }.wrapCall,
                .onMessageReceived = struct {
                    fn wrapCall(
                        self: *Self,
                        componentIntPtr: basis.IntPtr,
                        message: basis.messaging.Message,
                        senderNameHash: basis.string.StringHash,
                        parameters: basis.messaging.MessageParametersPtr,
                    ) void {
                        var typedFactory = @as(FactoryPtrType, @ptrFromInt(self.object));
                        typedFactory.onMessageReceived(componentIntPtr, message, senderNameHash, parameters);
                    }
                }.wrapCall,
                .onPipeDataReceived = struct {
                    fn wrapCall(
                        self: *Self,
                        componentIntPtr: basis.IntPtr,
                        pipe: u64,
                        data: []const u8,
                    ) void {
                        var typedFactory = @as(FactoryPtrType, @ptrFromInt(self.object));
                        typedFactory.onPipeDataReceived(componentIntPtr, pipe, data);
                    }
                }.wrapCall,
                .onBecameClientLocalAvatar = struct {
                    fn wrapCall(self: *Self, componentIntPtr: basis.IntPtr) void {
                        var typedFactory = @as(FactoryPtrType, @ptrFromInt(self.object));
                        typedFactory.onBecameClientLocalAvatar(componentIntPtr);
                    }
                }.wrapCall,
                .onLostClientLocalAvatar = struct {
                    fn wrapCall(self: *Self, componentIntPtr: basis.IntPtr) void {
                        var typedFactory = @as(FactoryPtrType, @ptrFromInt(self.object));
                        typedFactory.onLostClientLocalAvatar(componentIntPtr);
                    }
                }.wrapCall,
                .onBecameServerAvatar = struct {
                    fn wrapCall(self: *Self, componentIntPtr: basis.IntPtr, hostID: i32) void {
                        var typedFactory = @as(FactoryPtrType, @ptrFromInt(self.object));
                        typedFactory.onBecameServerAvatar(componentIntPtr, hostID);
                    }
                }.wrapCall,
                .onLostServerAvatar = struct {
                    fn wrapCall(self: *Self, componentIntPtr: basis.IntPtr, hostID: i32) void {
                        var typedFactory = @as(FactoryPtrType, @ptrFromInt(self.object));
                        typedFactory.onLostServerAvatar(componentIntPtr, hostID);
                    }
                }.wrapCall,
                .syncExposedPropertyValues = struct {
                    fn wrapCall(
                        self: *Self,
                        componentIntPtr: basis.IntPtr,
                        valueBuffer: [*c]basis.bindings.InteropBuffer,
                        direction: i32,
                    ) void {
                        var typedFactory = @as(FactoryPtrType, @ptrFromInt(self.object));
                        typedFactory.syncExposedPropertyValues(componentIntPtr, valueBuffer, direction);
                    }
                }.wrapCall,
                .exposedPropertyEvent = struct {
                    fn wrapCall(
                        self: *Self,
                        componentIntPtr: basis.IntPtr,
                        propertyName: *const basis.bindings.InteropString,
                        eventType: i32,
                    ) i32 {
                        var typedFactory = @as(FactoryPtrType, @ptrFromInt(self.object));
                        return typedFactory.exposedPropertyEvent(componentIntPtr, propertyName, eventType);
                    }
                }.wrapCall,
                .exportLevel = struct {
                    fn wrapCall(
                        self: *Self,
                        componentIntPtr: basis.IntPtr,
                        phase: i32,
                        dataBlockMgrCppPtr: basis.CppPtr,
                    ) i32 {
                        var typedFactory = @as(FactoryPtrType, @ptrFromInt(self.object));
                        return typedFactory.exportLevel(componentIntPtr, phase, dataBlockMgrCppPtr);
                    }
                }.wrapCall,
                .serializeEditorState = struct {
                    fn wrapCall(
                        self: *Self,
                        componentIntPtr: basis.IntPtr,
                        stateData: *basis.bindings.InteropBuffer,
                    ) void {
                        var typedFactory = @as(FactoryPtrType, @ptrFromInt(self.object));
                        typedFactory.serializeEditorState(componentIntPtr, stateData);
                    }
                }.wrapCall,
                .deserializeEditorState = struct {
                    fn wrapCall(
                        self: *Self,
                        componentIntPtr: basis.IntPtr,
                        stateData: *const basis.bindings.InteropString,
                    ) void {
                        var typedFactory = @as(FactoryPtrType, @ptrFromInt(self.object));
                        typedFactory.deserializeEditorState(componentIntPtr, stateData);
                    }
                }.wrapCall,
                .resetEditorState = struct {
                    fn wrapCall(
                        self: *Self,
                        componentIntPtr: basis.IntPtr,
                    ) void {
                        var typedFactory = @as(FactoryPtrType, @ptrFromInt(self.object));
                        typedFactory.resetEditorState(componentIntPtr);
                    }
                }.wrapCall,
                .editorStateModeChanged = struct {
                    fn wrapCall(
                        self: *Self,
                        componentIntPtr: basis.IntPtr,
                        editingEnabled: bool,
                    ) void {
                        var typedFactory = @as(FactoryPtrType, @ptrFromInt(self.object));
                        typedFactory.editorStateModeChanged(componentIntPtr, editingEnabled);
                    }
                }.wrapCall,
            },
        };
    }
};

// Empty types used as placeholders for components that don't use blueprint properties.
const EmptyBPProps = struct {};
const EmptyBPPropList = struct {};

fn DetermineBPPropsType(comptime T: type) type {
    // Components that have blueprint properties should have a field named
    // "blueprintProperties" which should be an optional const pointer to the
    // blueprint properties type.

    const bpPropsFieldType: type = std.meta.fieldInfo(T, .blueprintProperties).type;

    switch (@typeInfo(bpPropsFieldType)) {
        .optional => {
            // The type is an "optional something", so far so good. Use Child()
            // to look at the inner type of the optional.
            const childType = std.meta.Child(bpPropsFieldType);

            switch (@typeInfo(childType)) {
                .pointer => |ptr| {
                    // A pointer, good. Make sure it is const and if it is, return
                    // the type pointed to. This will be our BP properties type.

                    if (ptr.is_const) {
                        // The type is valid. Use another call to Child() to strip off
                        // the pointer from the type.
                        return std.meta.Child(childType);
                    }
                },
                else => {},
            }
        },
        else => {},
    }

    @compileError("The blueprint properties field must be an optional const pointer.");
}

// This function returns a generic component factory, given the
// type to use as the component type. Any struct can be used as
// a component type as long as it has a context field.
pub fn GameObjectComponentFactory(comptime T: type) type {
    const hasBPProps = @hasField(T, "blueprintProperties");

    const BPPropType = if (hasBPProps) DetermineBPPropsType(T) else EmptyBPProps;
    const BPPropList = if (hasBPProps) basis.ArrayList(*BPPropType) else EmptyBPPropList;

    return struct {
        const Self = @This();
        const ComponentList = basis.ArrayList(*T);

        pub const ctxtType = std.meta.fieldInfo(T, .context).type;
        pub const hasBlueprintProperties = hasBPProps;
        pub const hasUpdate = @hasDecl(T, "update");
        pub const hasPreTick = @hasDecl(T, "preTick");
        pub const hasTick = @hasDecl(T, "tick");
        pub const hasDrawEditor = @hasDecl(T, "drawEditor");
        pub const hasEditorState = basis.components.hasEditorState(T);
        pub const hasExposedProperties = basis.components.hasExposedProperties(T);
        pub const isScripted = basis.components.isScripted(T);
        pub const needsExport = basis.components.needsExport(T);

        //----------------------------------------------------

        allocator: Allocator,
        interface: ComponentFactoryInterface,
        clientComponents: ComponentList,
        serverComponents: ComponentList,

        typeName: []const u8 = basis.components.getComponentTypeName(T),
        updateSortingKey: u32 = basis.components.getComponentUpdateOrder(T),

        contextTypeName: []const u8 = @typeName(ctxtType),

        bpPropList: BPPropList,

        //----------------------------------------------------

        pub fn init(allocator: Allocator) !*GameObjectComponentFactory(T) {
            const factory = try allocator.create(GameObjectComponentFactory(T));
            errdefer allocator.destroy(factory);

            factory.* = GameObjectComponentFactory(T){
                .allocator = allocator,
                .interface = ComponentFactoryInterface.make(factory),
                .clientComponents = ComponentList.init(allocator),
                .serverComponents = ComponentList.init(allocator),
                .bpPropList = if (hasBPProps) BPPropList.init(allocator) else EmptyBPPropList{},
            };

            return factory;
        }

        pub fn deinit(self: *Self) void {
            if (hasBPProps) {
                for (self.bpPropList.items) |bpProps| {
                    if (@hasDecl(BPPropType, "deinit")) {
                        bpProps.deinit();
                    }

                    self.allocator.destroy(bpProps);
                }

                self.bpPropList.deinit();
            }

            self.clientComponents.deinit();
            self.serverComponents.deinit();

            // Release the memory for the factory itself.
            self.allocator.destroy(self);
        }

        //----------------------------------------------------

        // The following functions implement ComponentFactoryInterface:

        pub fn newComponent(self: *Self, cppContextPtr: basis.bindings.InteropTypedPtr, onClient: bool) !basis.IntPtr {
            // Allocate the component on the heap.
            const componentPtr = try self.allocator.create(T);
            errdefer self.allocator.destroy(componentPtr);

            componentPtr.* = try T.init(ctxtType.init(self.allocator, cppContextPtr, onClient));

            if (onClient) {
                try self.clientComponents.append(componentPtr);
            } else {
                try self.serverComponents.append(componentPtr);
            }

            return @intFromPtr(componentPtr);
        }

        pub fn deleteComponent(self: *Self, onClient: bool, componentIntPtr: basis.IntPtr) void {
            var componentPtr = @as(*T, @ptrFromInt(componentIntPtr));

            if (@hasDecl(T, "destroy")) {
                componentPtr.destroy() catch |err| {
                    basis.fatalErrorWithFormat(@src(), "Error in component destroy(): {s}", .{@errorName(err)});
                };
            }

            // Remove the component ptr from the correct list.
            if (onClient) {
                for (self.clientComponents.items, 0..) |element, i| {
                    if (componentPtr == element) {
                        _ = self.clientComponents.swapRemove(i);
                        break;
                    }
                }
            } else {
                for (self.serverComponents.items, 0..) |element, i| {
                    if (componentPtr == element) {
                        _ = self.serverComponents.swapRemove(i);
                        break;
                    }
                }
            }

            self.allocator.destroy(componentPtr);
        }

        pub fn update(self: *Self, onClient: bool, deltaTime: f32) void {
            if (hasUpdate) {
                const components = getComponentList(self, onClient);
                for (components.items) |componentPtr| {
                    componentPtr.update(deltaTime) catch |err| {
                        basis.fatalErrorWithFormat(@src(), "Error in component update(): {s}", .{@errorName(err)});
                    };
                }
            }
        }

        pub fn preTick(self: *Self, onClient: bool, tickDeltaTime: f32) void {
            if (hasPreTick) {
                const components = getComponentList(self, onClient);
                for (components.items) |componentPtr| {
                    componentPtr.preTick(tickDeltaTime) catch |err| {
                        basis.fatalErrorWithFormat(@src(), "Error in component preTick(): {s}", .{@errorName(err)});
                    };
                }
            }
        }

        pub fn tick(self: *Self, onClient: bool, tickDeltaTime: f32) void {
            if (hasTick) {
                //basis.profiling.beginSample("GameObjectComponentFactory(" ++ @typeName(T) ++ ").tick()");
                //defer basis.profiling.endSample();

                const components = getComponentList(self, onClient);
                for (components.items) |componentPtr| {
                    componentPtr.tick(tickDeltaTime) catch |err| {
                        basis.fatalErrorWithFormat(@src(), "Error in component tick(): {s}", .{@errorName(err)});
                    };
                }
            }
        }

        pub fn createBlueprintProperties(self: *Self) basis.IntPtr {
            if (hasBlueprintProperties) {
                const propertiesPtr = self.allocator.create(BPPropType) catch unreachable;
                propertiesPtr.* = BPPropType.init(self.allocator) catch |err| {
                    basis.fatalErrorWithFormat(@src(), "BP property init error: {s}", .{@errorName(err)});
                    return 0;
                };

                self.bpPropList.append(propertiesPtr) catch unreachable;

                return @intFromPtr(propertiesPtr);
            } else {
                return 0;
            }
        }

        pub fn bpPropsLoadJSON(self: *const Self, bpPropsIntPtr: basis.IntPtr, json: []const u8) bool {
            if (hasBlueprintProperties) {
                var typedBPProps = @as(*BPPropType, @ptrFromInt(bpPropsIntPtr));

                typedBPProps.loadJSON(json) catch |err| {
                    basis.fatalErrorWithFormat(
                        @src(),
                        "Error loading blueprint properties for component \"{s}\". JSON error: {s}",
                        .{ self.typeName, @errorName(err) },
                    );
                };

                return true;
            } else {
                return false;
            }
        }

        pub fn setBlueprintProperties(self: *const Self, componentIntPtr: basis.IntPtr, bpPropsIntPtr: basis.IntPtr) void {
            _ = self;
            if (hasBlueprintProperties) {
                var componentPtr = @as(*T, @ptrFromInt(componentIntPtr));
                const typedBPProps = @as(*BPPropType, @ptrFromInt(bpPropsIntPtr));

                componentPtr.blueprintProperties = typedBPProps;
            }
        }

        pub fn readExposedPropertyLayout(self: *const Self, readerIntPtr: basis.CppPtr) void {
            if (hasExposedProperties) {
                const reader = basis.exposed_properties.ExposedPropertyLayoutReaderPtr{
                    .cppPtr = readerIntPtr,
                    .allocator = self.allocator,
                };

                reader.init(1); // TODO: Currently always version 1.

                inline for (T.ExposedPropertyMap) |p| {
                    p.readLayout(reader);
                }

                reader.allPropertiesProcessed();
            }
        }

        pub fn readExposedPropertyMeta(
            self: *const Self,
            metaBuffer: [*c]basis.bindings.InteropExposedPropertyMeta,
            metaBufferLength: u32,
            defaultValueBuffer: [*c]basis.bindings.InteropBuffer,
            stringBuffer: [*c]basis.bindings.InteropBuffer,
        ) u32 {
            if (hasExposedProperties) {
                basis.assertd(@src(), metaBufferLength >= T.ExposedPropertyMap.len, "Exposed property meta buffer too small.");

                var defaultValueStream = basis.binary_stream.BinaryWriteStream.init(
                    defaultValueBuffer.*.ptr[0..defaultValueBuffer.*.capacity],
                    true,
                );

                var stringStream = basis.binary_stream.BinaryWriteStream.init(stringBuffer.*.ptr[0..stringBuffer.*.capacity], true);

                inline for (T.ExposedPropertyMap, 0..) |p, i| {
                    const isProperty = (p.PropertyType == basis.exposed_properties.ExposedPropertyType.Property);

                    metaBuffer[i].exposedPropertyType = p.PropertyType.asInt();
                    metaBuffer[i].typeID = if (isProperty) p.DataType.asInt() else basis.typeinfo.TypeID.BASIS_TYPE_EMPTY.asInt();

                    const name: []const u8 = p.Name;
                    metaBuffer[i].nameStartOffset = @intCast(stringStream.cursorPosition);
                    metaBuffer[i].nameLength = @intCast(name.len);
                    if (name.len > 0) {
                        stringStream.write(name);
                    }

                    metaBuffer[i].versionAdded = if (isProperty) p.VersionAdded else -1;

                    const options: []const u8 = p.Options;
                    metaBuffer[i].optionsStartOffset = @intCast(stringStream.cursorPosition);
                    metaBuffer[i].optionsLength = @intCast(options.len);
                    if (options.len > 0) {
                        stringStream.write(options);
                    }

                    if (isProperty) {
                        metaBuffer[i].defaultValueBufferOffset = @as(i32, @intCast(defaultValueStream.cursorPosition));
                        p.serializeDefaultValue(&defaultValueStream, self.allocator);
                    }
                }

                defaultValueBuffer.*.len = @intCast(defaultValueStream.cursorPosition);
                stringBuffer.*.len = @intCast(stringStream.cursorPosition);

                return @intCast(T.ExposedPropertyMap.len);
            }

            return 0;
        }

        pub fn registerAngelScript(self: *const Self, componentRegistrationIntPtr: basis.CppPtr) void {
            _ = self;

            if (@hasDecl(T, "registerAngelScript")) {
                const reg = basis.angelscript.ComponentRegistration.init(componentRegistrationIntPtr);
                T.registerAngelScript(reg) catch |err| {
                    basis.fatalErrorWithFormat(@src(), "Error in component registerAngelScript(): {s}", .{@errorName(err)});
                };
            }
        }

        //----------------------------------------------------

        // The following functions are forwarded to individual components.
        // The factory is only used to figure out the type to cast to,
        // using @ptrFromInt().

        pub fn create(self: *Self, componentIntPtr: basis.IntPtr) void {
            _ = self;
            if (@hasDecl(T, "create")) {
                var componentPtr = @as(*T, @ptrFromInt(componentIntPtr));
                componentPtr.create() catch |err| {
                    basis.fatalErrorWithFormat(@src(), "Error in component create(): {s}", .{@errorName(err)});
                };
            }
        }

        pub fn onObjectCreated(self: *Self, componentIntPtr: basis.IntPtr) void {
            _ = self;
            if (@hasDecl(T, "onObjectCreated")) {
                var componentPtr = @as(*T, @ptrFromInt(componentIntPtr));
                componentPtr.onObjectCreated() catch |err| {
                    basis.fatalErrorWithFormat(@src(), "Error in component onObjectCreated(): {s}", .{@errorName(err)});
                };
            }
        }

        pub fn drawEditor(
            self: *Self,
            componentIntPtr: basis.IntPtr,
            selected: bool,
            hoveredOver: bool,
        ) void {
            _ = self;
            if (hasDrawEditor) {
                var componentPtr = @as(*T, @ptrFromInt(componentIntPtr));
                componentPtr.drawEditor(selected, hoveredOver) catch |err| {
                    basis.fatalErrorWithFormat(@src(), "Error in component drawEditor(): {s}", .{@errorName(err)});
                };
            }
        }

        pub fn onMessageReceived(
            self: *Self,
            componentIntPtr: basis.IntPtr,
            message: basis.messaging.Message,
            senderNameHash: basis.string.StringHash,
            parameters: basis.messaging.MessageParametersPtr,
        ) void {
            _ = self;
            if (@hasDecl(T, "onMessageReceived")) {
                var componentPtr = @as(*T, @ptrFromInt(componentIntPtr));
                componentPtr.onMessageReceived(message, senderNameHash, parameters) catch |err| {
                    basis.fatalErrorWithFormat(@src(), "Error in component onMessageReceived(): {s}", .{@errorName(err)});
                };
            }
        }

        pub fn onPipeDataReceived(
            self: *Self,
            componentIntPtr: basis.IntPtr,
            pipe: basis.network.PipeID,
            data: []const u8,
        ) void {
            _ = self;
            if (@hasDecl(T, "onPipeDataReceived")) {
                var componentPtr = @as(*T, @ptrFromInt(componentIntPtr));
                componentPtr.onPipeDataReceived(pipe, data) catch |err| {
                    basis.fatalErrorWithFormat(@src(), "Error in component onPipeDataReceived(): {s}", .{@errorName(err)});
                };
            }
        }

        pub fn onBecameClientLocalAvatar(self: *Self, componentIntPtr: basis.IntPtr) void {
            _ = self;
            if (@hasDecl(T, "onBecameClientLocalAvatar")) {
                var componentPtr = @as(*T, @ptrFromInt(componentIntPtr));
                componentPtr.onBecameClientLocalAvatar() catch |err| {
                    basis.fatalErrorWithFormat(@src(), "Error in component onBecameClientLocalAvatar(): {s}", .{@errorName(err)});
                };
            }
        }

        pub fn onLostClientLocalAvatar(self: *Self, componentIntPtr: basis.IntPtr) void {
            _ = self;
            if (@hasDecl(T, "onLostClientLocalAvatar")) {
                var componentPtr = @as(*T, @ptrFromInt(componentIntPtr));
                componentPtr.onLostClientLocalAvatar() catch |err| {
                    basis.fatalErrorWithFormat(@src(), "Error in component onLostClientLocalAvatar(): {s}", .{@errorName(err)});
                };
            }
        }

        pub fn onBecameServerAvatar(self: *Self, componentIntPtr: basis.IntPtr, hostID: i32) void {
            _ = self;
            if (@hasDecl(T, "onBecameServerAvatar")) {
                var componentPtr = @as(*T, @ptrFromInt(componentIntPtr));
                componentPtr.onBecameServerAvatar(hostID) catch |err| {
                    basis.fatalErrorWithFormat(@src(), "Error in component onBecameServerAvatar(): {s}", .{@errorName(err)});
                };
            }
        }

        pub fn onLostServerAvatar(self: *Self, componentIntPtr: basis.IntPtr, hostID: i32) void {
            _ = self;
            if (@hasDecl(T, "onLostServerAvatar")) {
                var componentPtr = @as(*T, @ptrFromInt(componentIntPtr));
                componentPtr.onLostServerAvatar(hostID) catch |err| {
                    basis.fatalErrorWithFormat(@src(), "Error in component onLostServerAvatar(): {s}", .{@errorName(err)});
                };
            }
        }

        pub fn syncExposedPropertyValues(
            self: *Self,
            componentIntPtr: basis.IntPtr,
            valueBuffer: [*c]basis.bindings.InteropBuffer,
            direction: i32,
        ) void {
            _ = self;
            if (hasExposedProperties) {
                const componentPtr = @as(*T, @ptrFromInt(componentIntPtr));

                if (direction == 0) {
                    // Direction: C++ -> Zig

                    var valueStream = basis.binary_stream.BinaryReadStream.init(
                        valueBuffer.*.ptr[0..valueBuffer.*.capacity],
                        true,
                    );

                    inline for (T.ExposedPropertyMap) |p| {
                        if (p.PropertyType == basis.exposed_properties.ExposedPropertyType.Property) {
                            p.deserializeValue(componentPtr, &valueStream);
                        }
                    }

                    valueBuffer.*.len = @as(u32, @intCast(valueStream.cursorPosition));
                } else {
                    // Direction Zig -> C++

                    var valueStream = basis.binary_stream.BinaryWriteStream.init(
                        valueBuffer.*.ptr[0..valueBuffer.*.capacity],
                        true,
                    );

                    inline for (T.ExposedPropertyMap) |p| {
                        if (p.PropertyType == basis.exposed_properties.ExposedPropertyType.Property) {
                            p.serializeValue(componentPtr, &valueStream);
                        }
                    }

                    valueBuffer.*.len = @as(u32, @intCast(valueStream.cursorPosition));
                }
            }
        }

        pub fn exposedPropertyEvent(
            self: *Self,
            componentIntPtr: basis.IntPtr,
            propertyName: *const basis.bindings.InteropString,
            eventType: i32,
        ) i32 {
            _ = self;

            const EXP_PROP_EVENT_WILL_CHANGE = 0;
            const EXP_PROP_EVENT_CHANGED = 1;
            const EXP_PROP_EVENT_ACTION_EXECUTED = 2;
            const EXP_PROP_EVENT_IS_VISIBLE = 3;

            var componentPtr = @as(*T, @ptrFromInt(componentIntPtr));
            const name = propertyName.ptr[0..propertyName.len];

            switch (eventType) {
                EXP_PROP_EVENT_WILL_CHANGE => {
                    if (@hasDecl(T, "exposedPropertyValueWillChange")) {
                        componentPtr.exposedPropertyValueWillChange(name) catch |err| {
                            basis.fatalErrorWithFormat(@src(), "Error in component exposedPropertyValueWillChange(): {s}", .{@errorName(err)});
                        };
                    }
                },
                EXP_PROP_EVENT_CHANGED => {
                    if (@hasDecl(T, "exposedPropertyValueChanged")) {
                        componentPtr.exposedPropertyValueChanged(name) catch |err| {
                            basis.fatalErrorWithFormat(@src(), "Error in component exposedPropertyValueChanged(): {s}", .{@errorName(err)});
                        };
                    }
                },
                EXP_PROP_EVENT_ACTION_EXECUTED => {
                    if (@hasDecl(T, "editorButtonActionExecuted")) {
                        componentPtr.editorButtonActionExecuted(name) catch |err| {
                            basis.fatalErrorWithFormat(@src(), "Error in component editorButtonActionExecuted(): {s}", .{@errorName(err)});
                        };
                    }
                },
                EXP_PROP_EVENT_IS_VISIBLE => {
                    if (@hasDecl(T, "isExposedPropertyVisible")) {
                        return if (componentPtr.isExposedPropertyVisible(name)) 1 else 0;
                    } else {
                        return 1; // Default: true (ie. visible)
                    }
                },
                else => {},
            }

            return 0;
        }

        pub fn exportLevel(
            self: *Self,
            componentIntPtr: basis.IntPtr,
            phase: i32,
            dataBlockMgrCppPtr: basis.CppPtr,
        ) i32 {
            if (@hasDecl(T, "exportLevel")) {
                const mgr = basis.level_data.LevelDataBlockManagerPtr{
                    .cppPtr = dataBlockMgrCppPtr,
                    .constPtr = false,
                };

                var componentPtr = @as(*T, @ptrFromInt(componentIntPtr));
                componentPtr.exportLevel(phase, mgr) catch |err| {
                    basis.editor.printError(self.allocator, "Export error: {s}", .{@errorName(err)});
                    return 1; // Nonzero = error
                };
            }

            return 0; // Zero = success
        }

        pub fn serializeEditorState(
            self: *Self,
            componentIntPtr: basis.IntPtr,
            stateData: *basis.bindings.InteropBuffer,
        ) void {
            _ = self; // autofix

            if (@hasDecl(T, "serializeEditorState")) {
                var componentPtr = @as(*T, @ptrFromInt(componentIntPtr));
                componentPtr.serializeEditorState(stateData) catch |err| {
                    basis.fatalErrorWithFormat(@src(), "Error in serializeEditorState(): {s}", .{@errorName(err)});
                    unreachable;
                };
            }
        }

        pub fn deserializeEditorState(
            self: *Self,
            componentIntPtr: basis.IntPtr,
            stateData: *const basis.bindings.InteropString,
        ) void {
            _ = self; // autofix

            if (@hasDecl(T, "deserializeEditorState")) {
                const json = basis.string.fromInteropString(stateData);

                var componentPtr = @as(*T, @ptrFromInt(componentIntPtr));
                componentPtr.deserializeEditorState(json) catch |err| {
                    basis.fatalErrorWithFormat(@src(), "Error in deserializeEditorState(): {s}", .{@errorName(err)});
                    unreachable;
                };
            }
        }

        pub fn resetEditorState(
            self: *Self,
            componentIntPtr: basis.IntPtr,
        ) void {
            _ = self; // autofix
            if (@hasDecl(T, "resetEditorState")) {
                var componentPtr = @as(*T, @ptrFromInt(componentIntPtr));

                componentPtr.resetEditorState() catch |err| {
                    basis.fatalErrorWithFormat(@src(), "Error in resetEditorState(): {s}", .{@errorName(err)});
                    unreachable;
                };
            }
        }

        pub fn editorStateModeChanged(
            self: *Self,
            componentIntPtr: basis.IntPtr,
            editingEnabled: bool,
        ) void {
            _ = self; // autofix
            if (@hasDecl(T, "editorStateModeChanged")) {
                var componentPtr = @as(*T, @ptrFromInt(componentIntPtr));

                componentPtr.editorStateModeChanged(editingEnabled) catch |err| {
                    basis.fatalErrorWithFormat(@src(), "Error in editorStateModeChanged(): {s}", .{@errorName(err)});
                    unreachable;
                };
            }
        }

        //----------------------------------------------------

        // Private helper functions:

        fn getComponentList(self: *Self, onClient: bool) *ComponentList {
            if (onClient) {
                return &self.clientComponents;
            } else {
                return &self.serverComponents;
            }
        }
    };
}
