// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const InteropTypedPtr = basis.bindings.InteropTypedPtr;
const PlayerControllerInterface = basis.player_controller.PlayerControllerInterface;
const ComponentFactoryInterface = basis.component_factory.ComponentFactoryInterface;
const PropagatedValue = basis.network.PropagatedValue;
const PropagatedAction = basis.network.PropagatedAction;
const FlowStateInterface = basis.flow_state_interface.FlowStateInterface;
const MessageNode = basis.messaging.MessageNode;

//----------------------------------------------------

// Note! Keep this in sync with the C++ side.
pub const ZigLibraryType = enum(u32) {
    Unknown = 0,
    NativeDynamicLibrary = 1,
    WASMClient = 2,
    WASMServer = 3,
};

// Note! Keep this in sync with the C++ side.
pub const ZigBasisInitFlags = enum(u32) {
    None = 0,
    BindGoofy = (1 << 0),
    BindTimbre = (1 << 1),
    BindNemo = (1 << 2),
    BindMerlin = (1 << 3),
    BindTrampoline = (1 << 4),

    pub fn asInt(self: ZigBasisInitFlags) u32 {
        return @intFromEnum(self);
    }
};

var _gZigLibCppPtr: InteropTypedPtr = InteropTypedPtr{
    .ptr = 0,
    .type = 0,
};

pub fn getZigLibCppPtr() InteropTypedPtr {
    return _gZigLibCppPtr;
}

fn castIntPtr(comptime T: type, intPtr: basis.IntPtr64) *T {
    const ptr: *T = @ptrFromInt(basis.bindings.libIntPtrFromHost(intPtr));
    return ptr;
}

pub fn getZigLibraryType() ZigLibraryType {
    return @enumFromInt(_gZigLibCppPtr.type);
}

//----------------------------------------------------

// Exported engine C-api:

export fn basisInit(zigLibCppPtr: InteropTypedPtr) u32 {
    _gZigLibCppPtr = zigLibCppPtr;

    var flags: u32 = 0;

    // By default we bind everything.
    // TODO: Make this adjustable, eg. using zig build system options.
    flags |= ZigBasisInitFlags.BindGoofy.asInt();
    flags |= ZigBasisInitFlags.BindTimbre.asInt();
    flags |= ZigBasisInitFlags.BindNemo.asInt();
    flags |= ZigBasisInitFlags.BindMerlin.asInt();
    flags |= ZigBasisInitFlags.BindTrampoline.asInt();

    return flags;
}

export fn basisInit_WASM(buffer: [*]u8, bufferLength: u32) u32 {
    basis.assert(@src(), bufferLength == @sizeOf(InteropTypedPtr));

    // We can do either...
    const zigLibCppPtr: InteropTypedPtr = @bitCast(buffer[0..@sizeOf(InteropTypedPtr)].*);
    //------
    // ...or...
    //------
    //var zigLibCppPtr: InteropTypedPtr = undefined;
    //const addr = std.mem.asBytes(&zigLibCppPtr);
    //@memcpy(addr[0..bufferLength], buffer[0..bufferLength]);
    //------
    // ...to create the structured data out of the buffer.
    return basisInit(zigLibCppPtr);
}

// export fn basisDeinit() void {
//     // Any cleanup to do?
// }

// App / Mod controller:

comptime {
    // The library API looks a bit different depending on whether we are building
    // the app or a mod, so import the correct functions here.
    _ = if (basis.build_options.buildAsMod)
        @import("library_api_mod.zig")
    else
        @import("library_api_app.zig");
}

// Player controller:

export fn PlayerController_update(playerControllerInterfaceIntPtr: basis.IntPtr64, deltaTime: f32) void {
    var playerControllerInterfacePtr = castIntPtr(PlayerControllerInterface, playerControllerInterfaceIntPtr);
    playerControllerInterfacePtr.update(deltaTime);
}

export fn PlayerController_tick(playerControllerInterfaceIntPtr: basis.IntPtr64, tickDeltaTime: f32) void {
    var playerControllerInterfacePtr = castIntPtr(PlayerControllerInterface, playerControllerInterfaceIntPtr);
    playerControllerInterfacePtr.tick(tickDeltaTime);
}

export fn PlayerController_onMessageReceived(playerControllerInterfaceIntPtr: basis.IntPtr64, message: i32, senderNameHash: u32, parametersIntPtr: basis.CppPtr) void {
    var playerControllerInterfacePtr = castIntPtr(PlayerControllerInterface, playerControllerInterfaceIntPtr);
    const parameters = basis.messaging.MessageParametersPtr.init(parametersIntPtr);
    playerControllerInterfacePtr.onMessageReceived(message, senderNameHash, parameters);
}

// Component factory:

export fn CFactory_newComponent(factoryInterfaceIntPtr: basis.IntPtr64, cppContextPtr: InteropTypedPtr, onClient: bool) basis.IntPtr64 {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    const componentIntPtr = factoryInterfacePtr.newComponent(cppContextPtr, onClient);
    return basis.bindings.hostIntPtrFromLib(componentIntPtr);
}

export fn CFactory_newComponent_WASM(factoryInterfaceIntPtr: basis.IntPtr64, cppContextPtr_0: basis.CppPtr, cppContextPtr_1: u32, onClient: bool) basis.IntPtr64 {
    return CFactory_newComponent(
        factoryInterfaceIntPtr,
        InteropTypedPtr{ .ptr = cppContextPtr_0, .type = cppContextPtr_1 },
        onClient,
    );
}

export fn CFactory_deleteComponent(factoryInterfaceIntPtr: basis.IntPtr64, onClient: bool, componentIntPtr: basis.IntPtr64) void {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    const compIntPtr = basis.bindings.libIntPtrFromHost(componentIntPtr);
    factoryInterfacePtr.deleteComponent(onClient, compIntPtr);
}

export fn CFactory_updateComponents(factoryInterfaceIntPtr: basis.IntPtr64, onClient: bool, deltaTime: f32) void {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    factoryInterfacePtr.update(onClient, deltaTime);
}

export fn CFactory_preTickComponents(factoryInterfaceIntPtr: basis.IntPtr64, onClient: bool, tickDeltaTime: f32) void {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    factoryInterfacePtr.preTick(onClient, tickDeltaTime);
}

export fn CFactory_tickComponents(factoryInterfaceIntPtr: basis.IntPtr64, onClient: bool, tickDeltaTime: f32) void {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    factoryInterfacePtr.tick(onClient, tickDeltaTime);
}

export fn CFactory_createBlueprintProperties(factoryInterfaceIntPtr: basis.IntPtr64) basis.IntPtr64 {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    const bppPropsIntPtr = factoryInterfacePtr.createBlueprintProperties();
    return basis.bindings.hostIntPtrFromLib(bppPropsIntPtr);
}

export fn CFactory_loadBlueprintPropertiesJSON(factoryInterfaceIntPtr: basis.IntPtr64, bpPropsIntPtr: basis.IntPtr64, json: *const basis.bindings.InteropString) i32 {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    return if (factoryInterfacePtr.bpPropsLoadJSON(basis.bindings.libIntPtrFromHost(bpPropsIntPtr), json.ptr[0..json.len])) 1 else 0;
}

export fn CFactory_loadBlueprintPropertiesJSON_WASM(factoryInterfaceIntPtr: basis.IntPtr64, bpPropsIntPtr: basis.IntPtr64, jsonPtr: [*]const u8, jsonLength: u32) i32 {
    const json = jsonPtr[0..jsonLength];
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    return if (factoryInterfacePtr.bpPropsLoadJSON(basis.bindings.libIntPtrFromHost(bpPropsIntPtr), json)) 1 else 0;
}

export fn CFactory_setBlueprintProperties(factoryInterfaceIntPtr: basis.IntPtr64, componentIntPtr: basis.IntPtr64, bpPropsIntPtr: basis.IntPtr64) void {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    factoryInterfacePtr.setBlueprintProperties(
        basis.bindings.libIntPtrFromHost(componentIntPtr),
        basis.bindings.libIntPtrFromHost(bpPropsIntPtr),
    );
}

export fn CFactory_readExposedPropertyLayout(factoryInterfaceIntPtr: basis.IntPtr64, readerIntPtr: basis.CppPtr) void {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    factoryInterfacePtr.readExposedPropertyLayout(readerIntPtr);
}

export fn CFactory_readExposedPropertyMeta(
    factoryInterfaceIntPtr: basis.IntPtr64,
    metaBuffer: [*c]basis.bindings.InteropExposedPropertyMeta,
    metaBufferLength: u32,
    defaultValueBuffer: [*c]basis.bindings.InteropBuffer,
    stringBuffer: [*c]basis.bindings.InteropBuffer,
) u32 {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    return factoryInterfacePtr.readExposedPropertyMeta(metaBuffer, metaBufferLength, defaultValueBuffer, stringBuffer);
}

export fn CFactory_readExposedPropertyMeta_WASM(
    factoryInterfaceIntPtr: basis.IntPtr64,
    metaBufferLength: u32, // In InteropExposedPropertyMeta elements
    metaBufferPtr: [*c]u8,
    metaBufferByteLength: u32,
    defaultValueBufferPtr: [*c]u8,
    defaultValueBufferLength: u32,
    stringBufferPtr: [*c]u8,
    stringBufferLength: u32,
) u32 {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);

    const META_BUFFER_MAX_COUNT = 64;
    var metaBuffer: [META_BUFFER_MAX_COUNT]basis.bindings.InteropExposedPropertyMeta = undefined;

    var defaultValueBuffer = basis.bindings.InteropBuffer{
        .ptr = defaultValueBufferPtr,
        .capacity = defaultValueBufferLength,
        .len = 0,
    };
    var stringBuffer = basis.bindings.InteropBuffer{
        .ptr = stringBufferPtr,
        .capacity = stringBufferLength,
        .len = 0,
    };

    const propertyCount = factoryInterfacePtr.readExposedPropertyMeta(
        &metaBuffer,
        @min(metaBufferLength, META_BUFFER_MAX_COUNT),
        &defaultValueBuffer,
        &stringBuffer,
    );

    if (propertyCount > 0) {
        const metaBufferSlice = metaBufferPtr[0..metaBufferByteLength];
        var stream = basis.BinaryWriteStream.init(metaBufferSlice, true);

        // NOTE! If this serialization is changed, the counterpart in C++ in
        // ZigWamrLibrary::CFactory_readExposedPropertyMeta() also must be changed.

        // Prepend the data with the number of bytes written to the two other buffers.
        stream.putInt(u32, defaultValueBuffer.len);
        stream.putInt(u32, stringBuffer.len);

        for (0..propertyCount) |i| {
            stream.putInt(i32, metaBuffer[i].exposedPropertyType);
            stream.putInt(i32, metaBuffer[i].typeID);
            stream.putInt(i32, metaBuffer[i].versionAdded);
            stream.putInt(i32, metaBuffer[i].defaultValueBufferOffset);

            stream.putInt(u32, metaBuffer[i].nameStartOffset);
            stream.putInt(u32, metaBuffer[i].nameLength);
            stream.putInt(u32, metaBuffer[i].optionsStartOffset);
            stream.putInt(u32, metaBuffer[i].optionsLength);
        }
    }

    return propertyCount;
}

export fn CFactory_registerAngelScript(
    factoryInterfaceIntPtr: basis.IntPtr64,
    componentRegistrationIntPtr: basis.CppPtr,
) void {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    factoryInterfacePtr.registerAngelScript(componentRegistrationIntPtr);
}

export fn CFactory_create(factoryInterfaceIntPtr: basis.IntPtr64, componentIntPtr: basis.IntPtr64) void {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    factoryInterfacePtr.create(basis.bindings.libIntPtrFromHost(componentIntPtr));
}

export fn CFactory_onObjectCreated(factoryInterfaceIntPtr: basis.IntPtr64, componentIntPtr: basis.IntPtr64) void {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    factoryInterfacePtr.onObjectCreated(basis.bindings.libIntPtrFromHost(componentIntPtr));
}

export fn CFactory_drawEditor(factoryInterfaceIntPtr: basis.IntPtr64, componentIntPtr: basis.IntPtr64, selected: bool, hoveredOver: bool) void {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    factoryInterfacePtr.drawEditor(basis.bindings.libIntPtrFromHost(componentIntPtr), selected, hoveredOver);
}

export fn CFactory_onMessageReceived(factoryInterfaceIntPtr: basis.IntPtr64, componentIntPtr: basis.IntPtr64, message: i32, senderNameHash: u32, parametersIntPtr: basis.CppPtr) void {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    const parameters = basis.messaging.MessageParametersPtr.init(parametersIntPtr);
    factoryInterfacePtr.onMessageReceived(basis.bindings.libIntPtrFromHost(componentIntPtr), message, senderNameHash, parameters);
}

export fn CFactory_onPipeDataReceived(factoryInterfaceIntPtr: basis.IntPtr64, componentIntPtr: basis.IntPtr64, pipe: u64, data: [*c]const u8, dataLength: u32) void {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    const dataSlice: []const u8 = data[0..dataLength];
    factoryInterfacePtr.onPipeDataReceived(basis.bindings.libIntPtrFromHost(componentIntPtr), pipe, dataSlice);
}

export fn CFactory_onBecameClientLocalAvatar(factoryInterfaceIntPtr: basis.IntPtr64, componentIntPtr: basis.IntPtr64) void {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    factoryInterfacePtr.onBecameClientLocalAvatar(basis.bindings.libIntPtrFromHost(componentIntPtr));
}

export fn CFactory_onLostClientLocalAvatar(factoryInterfaceIntPtr: basis.IntPtr64, componentIntPtr: basis.IntPtr64) void {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    factoryInterfacePtr.onLostClientLocalAvatar(basis.bindings.libIntPtrFromHost(componentIntPtr));
}

export fn CFactory_onBecameServerAvatar(factoryInterfaceIntPtr: basis.IntPtr64, componentIntPtr: basis.IntPtr64, hostID: i32) void {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    factoryInterfacePtr.onBecameServerAvatar(basis.bindings.libIntPtrFromHost(componentIntPtr), hostID);
}

export fn CFactory_onLostServerAvatar(factoryInterfaceIntPtr: basis.IntPtr64, componentIntPtr: basis.IntPtr64, hostID: i32) void {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    factoryInterfacePtr.onLostServerAvatar(basis.bindings.libIntPtrFromHost(componentIntPtr), hostID);
}

export fn CFactory_syncExposedPropertyValues(
    factoryInterfaceIntPtr: basis.IntPtr64,
    componentIntPtr: basis.IntPtr64,
    valueBuffer: [*c]basis.bindings.InteropBuffer,
    direction: i32,
) void {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    factoryInterfacePtr.syncExposedPropertyValues(basis.bindings.libIntPtrFromHost(componentIntPtr), valueBuffer, direction);
}

export fn CFactory_exposedPropertyEvent(
    factoryInterfaceIntPtr: basis.IntPtr64,
    componentIntPtr: basis.IntPtr64,
    propertyName: [*c]const basis.bindings.InteropString,
    eventType: i32,
) i32 {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    return factoryInterfacePtr.exposedPropertyEvent(basis.bindings.libIntPtrFromHost(componentIntPtr), propertyName, eventType);
}

export fn CFactory_exportLevel(
    factoryInterfaceIntPtr: basis.IntPtr64,
    componentIntPtr: basis.IntPtr64,
    phase: i32,
    dataBlockMgrCppPtr: basis.CppPtr,
) i32 {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    return factoryInterfacePtr.exportLevel(basis.bindings.libIntPtrFromHost(componentIntPtr), phase, dataBlockMgrCppPtr);
}

export fn CFactory_serializeEditorState(
    factoryInterfaceIntPtr: basis.IntPtr64,
    componentIntPtr: basis.IntPtr64,
    stateData: [*c]basis.bindings.InteropBuffer,
) void {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    factoryInterfacePtr.serializeEditorState(basis.bindings.libIntPtrFromHost(componentIntPtr), stateData);
}

export fn CFactory_deserializeEditorState(
    factoryInterfaceIntPtr: basis.IntPtr64,
    componentIntPtr: basis.IntPtr64,
    stateData: [*c]const basis.bindings.InteropString,
) void {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    factoryInterfacePtr.deserializeEditorState(basis.bindings.libIntPtrFromHost(componentIntPtr), stateData);
}

export fn CFactory_resetEditorState(
    factoryInterfaceIntPtr: basis.IntPtr64,
    componentIntPtr: basis.IntPtr64,
) void {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    factoryInterfacePtr.resetEditorState(basis.bindings.libIntPtrFromHost(componentIntPtr));
}

export fn CFactory_editorStateModeChanged(
    factoryInterfaceIntPtr: basis.IntPtr64,
    componentIntPtr: basis.IntPtr64,
    editingEnabled: bool,
) void {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    factoryInterfacePtr.editorStateModeChanged(basis.bindings.libIntPtrFromHost(componentIntPtr), editingEnabled);
}

export fn CFactory_getAngelScriptPreface(
    factoryInterfaceIntPtr: basis.IntPtr64,
    componentIntPtr: basis.IntPtr64,
    outBuffer: [*c]basis.bindings.InteropBuffer,
) void {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    factoryInterfacePtr.getAngelScriptPreface(basis.bindings.libIntPtrFromHost(componentIntPtr), outBuffer);
}

export fn CFactory_appendAngelScriptMethodAutoCompleteItems(
    factoryInterfaceIntPtr: basis.IntPtr64,
    componentIntPtr: basis.IntPtr64,
    vectorPtr: basis.IntPtr,
) void {
    var factoryInterfacePtr = castIntPtr(ComponentFactoryInterface, factoryInterfaceIntPtr);
    factoryInterfacePtr.appendAngelScriptMethodAutoCompleteItems(basis.bindings.libIntPtrFromHost(componentIntPtr), vectorPtr);
}

// Propagated value:

export fn PV_updateFloat(pvPtr: basis.IntPtr64, value: f32, localChange: bool, valueTime: f64) void {
    var pv = castIntPtr(PropagatedValue(f32), pvPtr);
    pv._setPropagated(value, localChange, valueTime);
}

export fn PV_updateDouble(pvPtr: basis.IntPtr64, value: f64, localChange: bool, valueTime: f64) void {
    var pv = castIntPtr(PropagatedValue(f64), pvPtr);
    pv._setPropagated(value, localChange, valueTime);
}

export fn PV_updateInt32(pvPtr: basis.IntPtr64, value: i32, localChange: bool, valueTime: f64) void {
    var pv = castIntPtr(PropagatedValue(i32), pvPtr);
    pv._setPropagated(value, localChange, valueTime);
}

export fn PV_updateUint32(pvPtr: basis.IntPtr64, value: u32, localChange: bool, valueTime: f64) void {
    var pv = castIntPtr(PropagatedValue(u32), pvPtr);
    pv._setPropagated(value, localChange, valueTime);
}

export fn PV_updateInt16(pvPtr: basis.IntPtr64, value: i16, localChange: bool, valueTime: f64) void {
    var pv = castIntPtr(PropagatedValue(i16), pvPtr);
    pv._setPropagated(value, localChange, valueTime);
}

export fn PV_updateUint16(pvPtr: basis.IntPtr64, value: u16, localChange: bool, valueTime: f64) void {
    var pv = castIntPtr(PropagatedValue(u16), pvPtr);
    pv._setPropagated(value, localChange, valueTime);
}

export fn PV_updateInt64(pvPtr: basis.IntPtr64, value: i64, localChange: bool, valueTime: f64) void {
    var pv = castIntPtr(PropagatedValue(i64), pvPtr);
    pv._setPropagated(value, localChange, valueTime);
}

export fn PV_updateUint64(pvPtr: basis.IntPtr64, value: u64, localChange: bool, valueTime: f64) void {
    var pv = castIntPtr(PropagatedValue(u64), pvPtr);
    pv._setPropagated(value, localChange, valueTime);
}

export fn PV_updateInt8(pvPtr: basis.IntPtr64, value: i8, localChange: bool, valueTime: f64) void {
    var pv = castIntPtr(PropagatedValue(i8), pvPtr);
    pv._setPropagated(value, localChange, valueTime);
}

export fn PV_updateUint8(pvPtr: basis.IntPtr64, value: u8, localChange: bool, valueTime: f64) void {
    var pv = castIntPtr(PropagatedValue(u8), pvPtr);
    pv._setPropagated(value, localChange, valueTime);
}

export fn PV_updateBool(pvPtr: basis.IntPtr64, value: bool, localChange: bool, valueTime: f64) void {
    var pv = castIntPtr(PropagatedValue(bool), pvPtr);
    pv._setPropagated(value, localChange, valueTime);
}

export fn PV_updateVec2(pvPtr: basis.IntPtr64, value: *basis.bindings.InteropVec2, localChange: bool, valueTime: f64) void {
    const v = basis.math.Vec2.fromInterop(value.*);
    var pv = castIntPtr(PropagatedValue(basis.math.Vec2), pvPtr);
    pv._setPropagated(v, localChange, valueTime);
}

export fn PV_updateVec2_WASM(pvPtr: basis.IntPtr64, x: f32, y: f32, localChange: bool, valueTime: f64) void {
    const v = basis.math.Vec2.init(x, y);
    var pv = castIntPtr(PropagatedValue(basis.math.Vec2), pvPtr);
    pv._setPropagated(v, localChange, valueTime);
}

export fn PV_updateVec3(pvPtr: basis.IntPtr64, value: *basis.bindings.InteropVec3, localChange: bool, valueTime: f64) void {
    const v = basis.math.Vec3.fromInterop(value.*);
    var pv = castIntPtr(PropagatedValue(basis.math.Vec3), pvPtr);
    pv._setPropagated(v, localChange, valueTime);
}

export fn PV_updateVec3_WASM(pvPtr: basis.IntPtr64, x: f32, y: f32, z: f32, localChange: bool, valueTime: f64) void {
    const v = basis.math.Vec3.init(x, y, z);
    var pv = castIntPtr(PropagatedValue(basis.math.Vec3), pvPtr);
    pv._setPropagated(v, localChange, valueTime);
}

export fn PV_updateVec4(pvPtr: basis.IntPtr64, value: *basis.bindings.InteropVec4, localChange: bool, valueTime: f64) void {
    const v = basis.math.Vec4.fromInterop(value.*);
    var pv = castIntPtr(PropagatedValue(basis.math.Vec4), pvPtr);
    pv._setPropagated(v, localChange, valueTime);
}

export fn PV_updateVec4_WASM(pvPtr: basis.IntPtr64, x: f32, y: f32, z: f32, w: f32, localChange: bool, valueTime: f64) void {
    const v = basis.math.Vec4.init(x, y, z, w);
    var pv = castIntPtr(PropagatedValue(basis.math.Vec4), pvPtr);
    pv._setPropagated(v, localChange, valueTime);
}

export fn PV_updateQuaternion(pvPtr: basis.IntPtr64, value: *basis.bindings.InteropQuaternion, localChange: bool, valueTime: f64) void {
    const q = basis.math.Quaternion.fromInterop(value.*);
    var pv = castIntPtr(PropagatedValue(basis.math.Quaternion), pvPtr);
    pv._setPropagated(q, localChange, valueTime);
}

export fn PV_updateQuaternion_WASM(pvPtr: basis.IntPtr64, w: f32, x: f32, y: f32, z: f32, localChange: bool, valueTime: f64) void {
    const q = basis.math.Quaternion.init(w, x, y, z);
    var pv = castIntPtr(PropagatedValue(basis.math.Quaternion), pvPtr);
    pv._setPropagated(q, localChange, valueTime);
}

export fn PV_updateMat43(pvPtr: basis.IntPtr64, value: *basis.bindings.InteropMat43, localChange: bool, valueTime: f64) void {
    const m = basis.math.Mat43.fromInterop(value.*);
    var pv = castIntPtr(PropagatedValue(basis.math.Mat43), pvPtr);
    pv._setPropagated(m, localChange, valueTime);
}

export fn PA_fire(paPtr: basis.IntPtr64, localChange: bool, valueTime: f64) void {
    var pa = castIntPtr(PropagatedAction, paPtr);
    pa._firePropagated(localChange, valueTime);
}

// Resource mananger:

export fn ResourceManager_resourceWasReloaded(resourceCppPtr: basis.CppPtr, callbackID: u32) void {
    basis.resources.resource_manager._resourceWasReloaded(resourceCppPtr, callbackID);
}

// Flow state:

export fn FlowState_deinit(flowStateInterfaceIntPtr: basis.IntPtr64) void {
    var flowStateInterfacePtr = castIntPtr(FlowStateInterface, flowStateInterfaceIntPtr);
    flowStateInterfacePtr.deinit();
}

export fn FlowState_onEnter(flowStateInterfaceIntPtr: basis.IntPtr64) void {
    var flowStateInterfacePtr = castIntPtr(FlowStateInterface, flowStateInterfaceIntPtr);
    flowStateInterfacePtr.onEnter();
}

export fn FlowState_onExit(flowStateInterfaceIntPtr: basis.IntPtr64) void {
    var flowStateInterfacePtr = castIntPtr(FlowStateInterface, flowStateInterfaceIntPtr);
    flowStateInterfacePtr.onExit();
}

export fn FlowState_update(flowStateInterfaceIntPtr: basis.IntPtr64, deltaTime: f32) void {
    var flowStateInterfacePtr = castIntPtr(FlowStateInterface, flowStateInterfaceIntPtr);
    flowStateInterfacePtr.update(deltaTime);
}

export fn FlowState_isLoadingComplete(flowStateInterfaceIntPtr: basis.IntPtr64) i32 {
    var flowStateInterfacePtr = castIntPtr(FlowStateInterface, flowStateInterfaceIntPtr);
    return if (flowStateInterfacePtr.isLoadingComplete()) 1 else 0;
}

export fn FlowState_onMessageReceived(flowStateInterfaceIntPtr: basis.IntPtr64, message: i32, senderNameHash: u32, parametersIntPtr: basis.CppPtr) void {
    var flowStateInterfacePtr = castIntPtr(FlowStateInterface, flowStateInterfaceIntPtr);
    const parameters = basis.messaging.MessageParametersPtr.init(parametersIntPtr);
    flowStateInterfacePtr.onMessageReceived(message, senderNameHash, parameters);
}

// Debug overlay:

export fn DebugOverlay_runImGuiMenuBarCallbacks() void {
    basis.debug_overlay._runImGuiMenuBarCallbacks();
}

export fn DebugOverlay_runImGuiCallbacks() void {
    basis.debug_overlay._runImGuiCallbacks();
}

// Message node:

export fn MessageNode_onMessageReceived(nodeIntPtr: basis.IntPtr64, message: i32, senderNameHash: u32, parametersIntPtr: basis.CppPtr) void {
    const node = castIntPtr(MessageNode, nodeIntPtr);
    const parameters = basis.messaging.MessageParametersPtr.init(parametersIntPtr);
    if (node.onMessageReceived) |delegate| {
        delegate.call(message, senderNameHash, parameters);
    }
}

// Physics:

export fn Physics_onTriggerEnterEvent(triggerActorIntPtr: basis.CppPtr, otherActorIntPtr: basis.CppPtr, otherActorType: u32) void {
    basis.physics.physics_trigger._onTriggerEnterEvent(triggerActorIntPtr, otherActorIntPtr, otherActorType);
}

export fn Physics_onTriggerExitEvent(triggerActorIntPtr: basis.CppPtr, otherActorIntPtr: basis.CppPtr, otherActorType: u32, otherActorRemoved: bool) void {
    basis.physics.physics_trigger._onTriggerExitEvent(triggerActorIntPtr, otherActorIntPtr, otherActorType, otherActorRemoved);
}

export fn Physics_onCollisionCallback(sceneIntPtr: basis.CppPtr, interopCollisionData: *const basis.bindings.InteropCollisionData) void {
    var collisionData = basis.physics.CollisionData{};

    collisionData.shape0 = basis.physics.PhysicsShapePtr{ .cppPtr = interopCollisionData.shape0 };
    collisionData.shape1 = basis.physics.PhysicsShapePtr{ .cppPtr = interopCollisionData.shape1 };

    // Leave the actors as .Null when there is no associated actor (e.g. a removed actor),
    // since PhysicsActorType has no zero value to build from.
    if (interopCollisionData.actor0 != 0) {
        collisionData.actor0 = basis.physics.PhysicsActorPtr{
            .cppPtr = interopCollisionData.actor0,
            .actorType = @enumFromInt(interopCollisionData.actor0Type),
        };
    }
    if (interopCollisionData.actor1 != 0) {
        collisionData.actor1 = basis.physics.PhysicsActorPtr{
            .cppPtr = interopCollisionData.actor1,
            .actorType = @enumFromInt(interopCollisionData.actor1Type),
        };
    }

    collisionData.collisionPoints.len = @intCast(interopCollisionData.collisionPointCount);
    for (0..interopCollisionData.collisionPointCount) |i| {
        const src = interopCollisionData.collisionPoints[i];
        var point: *basis.physics.physics_scene.CollisionPoint = &collisionData.collisionPoints.slice()[i];

        point.position = basis.math.Vec3.fromInterop(src.position);
        point.normal = basis.math.Vec3.fromInterop(src.normal);
        point.impulse = basis.math.Vec3.fromInterop(src.impulse);
        point.force = src.force;
        point.material0 = basis.physics.PhysicsMaterialPtr{ .cppPtr = src.material0 };
        point.material1 = basis.physics.PhysicsMaterialPtr{ .cppPtr = src.material1 };
    }

    basis.physics.physics_scene._onCollisionCallback(sceneIntPtr, &collisionData);
}
