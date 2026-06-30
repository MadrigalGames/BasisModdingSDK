// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const isWasm = basis.build_options.buildAsWASM;

const access = if (isWasm)
    @import("wasm_extern_functions.zig")
else
    .{}; // TODO: Replace this with some module that contains the DLL interface.

// We only need to expose this when compiling to WASM.
pub const componentRegistrationCallback_WASM = if (isWasm) access.componentRegistrationCallback_WASM else void;

const Vec2 = basis.math.Vec2;
const Vec3 = basis.math.Vec3;
const Vec4 = basis.math.Vec4;
const Quaternion = basis.math.Quaternion;
const Mat43 = basis.math.Mat43;
const Mat4 = basis.math.Mat4;

const Vec3Size = 3 * @sizeOf(f32);
const Vec4Size = 4 * @sizeOf(f32);
const QuaternionSize = 4 * @sizeOf(f32);
const Mat43Size = 4 * 3 * @sizeOf(f32);
const Mat4Size = 4 * 4 * @sizeOf(f32);

const TypeID = basis.typeinfo.TypeID;

//----------------------------------------------------

// In WASM we need a bit of temp memory owned by the WASM module which we
// can read from and write to. This is used, for example, with functions
// that would normally return a string found in C++ memory. We use a ring
// buffer which returns a temporary fixed-size buffer which is valid until
// another call reuses the same slot for another temp buffer, so we need
// to be a bit careful with any function using this buffer.

// Since the C and S get separate module instances for WASM, we only need
// a single buffer here and the C/S will each get their own.
var gWASMTempMemoryBuffer: basis.utils.TempMemoryRingBuffer = undefined;

const WASMTempMemorySize = 2048;

pub fn init(allocator: std.mem.Allocator) void {
    if (isWasm) {
        gWASMTempMemoryBuffer = basis.utils.TempMemoryRingBuffer.init(allocator, 32, WASMTempMemorySize) catch |err| {
            basis.fatalErrorWithName(@src(), err);
            unreachable;
        };
    }

    // Note! If we need to have any global data here which is used in the native
    // (ie. non-WASM) version, that needs to go into the basis.g global data object
    // so that it can be moved between libraries on hot-reload.
}

pub fn deinit() void {
    if (isWasm) {
        gWASMTempMemoryBuffer.deinit();
    }
}

//----------------------------------------------------

// class Core

pub fn Core_showAssertDialog(message: [*c]const basis.bindings.InteropString, caption: [*c]const basis.bindings.InteropString) c_int {
    if (isWasm) {
        return access.Core_showAssertDialog_WASM(
            message.*.ptr,
            message.*.len,
            caption.*.ptr,
            caption.*.len,
        );
    } else {
        return basis.bindings.fp._Core_showAssertDialog(message, caption);
    }
}

pub fn Core_heapAlloc(len: u64, alignment: u64) [*c]u8 {
    if (isWasm) {
        @compileError("Core_heapAlloc not supported on WASM.");
    } else {
        return basis.bindings.fp._Core_heapAlloc(len, alignment);
    }
}

pub fn Core_heapFree(buf: [*c]u8) void {
    if (isWasm) {
        @compileError("Core_heapFree not supported on WASM.");
    } else {
        basis.bindings.fp._Core_heapFree(buf);
    }
}

pub fn Core_printOnHost(str: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        access.Core_printOnHost_WASM(str.*.ptr, str.*.len);
    } else {
        return basis.bindings.fp._Core_printOnHost(str);
    }
}

pub fn Core_beginProfilingSample(name: [*c]const u8) void {
    if (isWasm) {
        @compileError("Core_beginProfilingSample not implemented for WASM yet.");
    } else {
        basis.bindings.fp._Core_beginProfilingSample(name);
    }
}

pub fn Core_endProfilingSample() void {
    if (isWasm) {
        @compileError("Core_endProfilingSample not implemented for WASM yet.");
    } else {
        basis.bindings.fp._Core_endProfilingSample();
    }
}

pub fn Core_getRandomSeed() u64 {
    if (isWasm) {
        return access.Core_getRandomSeed_WASM();
    } else {
        return basis.bindings.fp._Core_getRandomSeed();
    }
}

// ===============================

// class App

pub fn App_createApp(zigLibCppPtr: basis.bindings.InteropTypedPtr, zigAppInterfacePtr: basis.IntPtr) basis.CppPtr {
    if (isWasm) {
        return access.App_createApp_WASM(
            zigLibCppPtr.ptr,
            zigLibCppPtr.type,
            basis.bindings.hostIntPtrFromLib((zigAppInterfacePtr)),
        );
    } else {
        return basis.bindings.fp._App_createApp(zigLibCppPtr, zigAppInterfacePtr);
    }
}

pub fn App_getAppMode(cppPtr: basis.CppPtr) i32 {
    if (isWasm) {
        return access.App_getAppMode_WASM(cppPtr);
    } else {
        return basis.bindings.fp._App_getAppMode(cppPtr);
    }
}

pub fn App_getClient(cppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.App_getClient_WASM(cppPtr);
    } else {
        return basis.bindings.fp._App_getClient(cppPtr);
    }
}

pub fn App_getServer(cppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.App_getServer_WASM(cppPtr);
    } else {
        return basis.bindings.fp._App_getServer(cppPtr);
    }
}

pub fn App_addInput(cppPtr: basis.CppPtr, inputID: u16, inputType: c_int) void {
    if (isWasm) {
        access.App_addInput_WASM(cppPtr, inputID, inputType);
    } else {
        basis.bindings.fp._App_addInput(cppPtr, inputID, inputType);
    }
}

pub fn App_getInputBufferSize(cppPtr: basis.CppPtr) u32 {
    if (isWasm) {
        return access.App_getInputBufferSize_WASM(cppPtr);
    } else {
        return basis.bindings.fp._App_getInputBufferSize(cppPtr);
    }
}

pub fn App_clearInputMappings(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.App_clearInputMappings_WASM(cppPtr);
    } else {
        basis.bindings.fp._App_clearInputMappings(cppPtr);
    }
}

pub fn App_mapInput(cppPtr: basis.CppPtr, inputID: u16, source: c_int, contextID: u8, valueMultiplier: f32, flags: c_int) void {
    if (isWasm) {
        access.App_mapInput_WASM(cppPtr, inputID, source, contextID, valueMultiplier, flags);
    } else {
        basis.bindings.fp._App_mapInput(cppPtr, inputID, source, contextID, valueMultiplier, flags);
    }
}

pub fn App_mapKeyboardInput(cppPtr: basis.CppPtr, inputID: u16, keyCode: c_int, contextID: u8, flags: c_int) void {
    if (isWasm) {
        access.App_mapKeyboardInput_WASM(cppPtr, inputID, keyCode, contextID, flags);
    } else {
        basis.bindings.fp._App_mapKeyboardInput(cppPtr, inputID, keyCode, contextID, flags);
    }
}

pub fn App_mapMouseButtonInput(cppPtr: basis.CppPtr, inputID: u16, mouseButton: c_int, contextID: u8, flags: c_int) void {
    if (isWasm) {
        access.App_mapMouseButtonInput_WASM(cppPtr, inputID, mouseButton, contextID, flags);
    } else {
        basis.bindings.fp._App_mapMouseButtonInput(cppPtr, inputID, mouseButton, contextID, flags);
    }
}

pub fn App_mapGamepadButtonInput(cppPtr: basis.CppPtr, inputID: u16, gamepadButton: c_int, contextID: u8, flags: c_int) void {
    if (isWasm) {
        access.App_mapGamepadButtonInput_WASM(cppPtr, inputID, gamepadButton, contextID, flags);
    } else {
        basis.bindings.fp._App_mapGamepadButtonInput(cppPtr, inputID, gamepadButton, contextID, flags);
    }
}

pub fn App_registerMessage(cppPtr: basis.CppPtr, message: i32, category: i32) void {
    if (isWasm) {
        access.App_registerMessage_WASM(cppPtr, message, category);
    } else {
        basis.bindings.fp._App_registerMessage(cppPtr, message, category);
    }
}

pub fn App_getClientGameFlowStateMachine(cppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.App_getClientGameFlowStateMachine_WASM(cppPtr);
    } else {
        return basis.bindings.fp._App_getClientGameFlowStateMachine(cppPtr);
    }
}

pub fn App_getServerGameFlowStateMachine(cppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.App_getServerGameFlowStateMachine_WASM(cppPtr);
    } else {
        return basis.bindings.fp._App_getServerGameFlowStateMachine(cppPtr);
    }
}

pub fn App_createAndLoadSPGame(
    cppPtr: basis.CppPtr,
    gameName: [*c]const basis.bindings.InteropString,
    levelPath: [*c]const basis.bindings.InteropString,
    layers: [*c]const basis.bindings.InteropString,
    layerCount: u32,
    sessionObjects: [*c]const u64,
    sessionObjectCount: u32,
    continuous: c_int,
    callback: basis.bindings.FP_void_IntPtr64_i32,
    callbackContext: basis.IntPtr64,
) void {
    if (isWasm) {
        @compileError("App_createAndLoadSPGame not implemented for WASM yet.");
    } else {
        basis.bindings.fp._App_createAndLoadSPGame(cppPtr, gameName, levelPath, layers, layerCount, sessionObjects, sessionObjectCount, continuous, callback, callbackContext);
    }
}

pub fn App_createSPGame(
    cppPtr: basis.CppPtr,
    gameName: [*c]const basis.bindings.InteropString,
    continuous: c_int,
    callback: basis.bindings.FP_void_IntPtr64_i32,
    callbackContext: basis.IntPtr64,
) void {
    if (isWasm) {
        @compileError("App_createSPGame not implemented for WASM yet.");
    } else {
        basis.bindings.fp._App_createSPGame(cppPtr, gameName, continuous, callback, callbackContext);
    }
}

pub fn App_loadSPGame(cppPtr: basis.CppPtr, levelPath: [*c]const basis.bindings.InteropString, layers: [*c]const basis.bindings.InteropString, layerCount: u32, sessionObjects: [*c]const u64, sessionObjectCount: u32) void {
    if (isWasm) {
        @compileError("App_loadSPGame not implemented for WASM yet.");
    } else {
        basis.bindings.fp._App_loadSPGame(cppPtr, levelPath, layers, layerCount, sessionObjects, sessionObjectCount);
    }
}

pub fn App_leaveGame(cppPtr: basis.CppPtr, alsoDisconnectFromServer: c_int, callback: basis.bindings.FP_void_IntPtr64_i32, callbackContext: basis.IntPtr64) void {
    if (isWasm) {
        @compileError("App_leaveGame not implemented for WASM yet.");
    } else {
        basis.bindings.fp._App_leaveGame(cppPtr, alsoDisconnectFromServer, callback, callbackContext);
    }
}

pub fn App_isLocalServerRunning() c_int {
    if (isWasm) {
        return access.App_isLocalServerRunning_WASM();
    } else {
        return basis.bindings.fp._App_isLocalServerRunning();
    }
}

pub fn App_isServerThreadRunning() c_int {
    if (isWasm) {
        return access.App_isServerThreadRunning_WASM();
    } else {
        return basis.bindings.fp._App_isServerThreadRunning();
    }
}

pub fn App_hasCommandLineParameter(parameter: [*c]const basis.bindings.InteropString) c_int {
    if (isWasm) {
        return access.App_hasCommandLineParameter_WASM(parameter.*.ptr, parameter.*.len);
    } else {
        return basis.bindings.fp._App_hasCommandLineParameter(parameter);
    }
}

pub fn App_getCommandLineParameter(parameter: [*c]const basis.bindings.InteropString, value: [*c]basis.bindings.InteropString) void {
    if (isWasm) {
        const tempMemory = gWASMTempMemoryBuffer.get();
        const length = access.App_getCommandLineParameter_WASM(parameter.*.ptr, parameter.*.len, tempMemory.ptr, WASMTempMemorySize);
        value.*.ptr = tempMemory.ptr;
        value.*.len = @intCast(length);
    } else {
        basis.bindings.fp._App_getCommandLineParameter(parameter, value);
    }
}

pub fn App_getConfigOptions() basis.CppPtr {
    if (isWasm) {
        @compileError("App_getConfigOptions not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._App_getConfigOptions();
    }
}

// ===============================

// ModController

pub fn ModController_createModController(zigLibCppPtr: basis.bindings.InteropTypedPtr, zigModControllerInterfacePtr: basis.IntPtr) basis.CppPtr {
    if (isWasm) {
        return access.Mod_createModController_WASM(
            zigLibCppPtr.ptr,
            zigLibCppPtr.type,
            basis.bindings.hostIntPtrFromLib((zigModControllerInterfacePtr)),
        );
    } else {
        return basis.bindings.fp._ModController_createModController(zigLibCppPtr, zigModControllerInterfacePtr);
    }
}

pub fn ModController_getAppMode(cppPtr: basis.CppPtr) i32 {
    if (isWasm) {
        return access.Mod_getAppMode_WASM(cppPtr);
    } else {
        return basis.bindings.fp._ModController_getAppMode(cppPtr);
    }
}

pub fn ModController_getClient(cppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.Mod_getClient_WASM(cppPtr);
    } else {
        return basis.bindings.fp._ModController_getClient(cppPtr);
    }
}

pub fn ModController_getServer(cppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.Mod_getServer_WASM(cppPtr);
    } else {
        return basis.bindings.fp._ModController_getServer(cppPtr);
    }
}

pub fn ModController_registerMessage(cppPtr: basis.CppPtr, message: i32, category: i32) void {
    if (isWasm) {
        access.Mod_registerMessage_WASM(cppPtr, message, category);
    } else {
        basis.bindings.fp._ModController_registerMessage(cppPtr, message, category);
    }
}

// ===============================

// class Client

pub fn Client_getHostID(cppPtr: basis.CppPtr) i32 {
    if (isWasm) {
        return access.Client_getHostID_WASM(cppPtr);
    } else {
        return basis.bindings.fp._Client_getHostID(cppPtr);
    }
}

pub fn Client_getRenderer(cppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.Client_getRenderer_WASM(cppPtr);
    } else {
        return basis.bindings.fp._Client_getRenderer(cppPtr);
    }
}

pub fn Client_getGameSession(cppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.Client_getGameSession_WASM(cppPtr);
    } else {
        return basis.bindings.fp._Client_getGameSession(cppPtr);
    }
}

pub fn Client_getGameState(cppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.Client_getGameState_WASM(cppPtr);
    } else {
        return basis.bindings.fp._Client_getGameState(cppPtr);
    }
}

pub fn Client_getPhysicsEnginePtr(cppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.Client_getPhysicsEnginePtr_WASM(cppPtr);
    } else {
        return basis.bindings.fp._Client_getPhysicsEnginePtr(cppPtr);
    }
}

pub fn Client_getPrimaryPhysicsScene(cppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.Client_getPrimaryPhysicsScene_WASM(cppPtr);
    } else {
        return basis.bindings.fp._Client_getPrimaryPhysicsScene(cppPtr);
    }
}

pub fn Client_getInterpolationFactor(cppPtr: basis.CppPtr) f64 {
    if (isWasm) {
        return access.Client_getInterpolationFactor_WASM(cppPtr);
    } else {
        return basis.bindings.fp._Client_getInterpolationFactor(cppPtr);
    }
}

pub fn Client_createMessageNode(zigLibCppPtr: basis.bindings.InteropTypedPtr, cppPtr: basis.CppPtr, messageNodeName: [*c]const basis.bindings.InteropString, zigNodePtr: basis.IntPtr) basis.CppPtr {
    if (isWasm) {
        return access.Client_createMessageNode_WASM(
            zigLibCppPtr.ptr,
            zigLibCppPtr.type,
            cppPtr,
            messageNodeName.*.ptr,
            messageNodeName.*.len,
            basis.bindings.hostIntPtrFromLib(zigNodePtr),
        );
    } else {
        return basis.bindings.fp._Client_createMessageNode(zigLibCppPtr, cppPtr, messageNodeName, zigNodePtr);
    }
}

pub fn Client_addRPCListener(cppPtr: basis.CppPtr, onRPCReceivedPtr: u64, userData: u64) u64 {
    if (isWasm) {
        @compileError("Client_addRPCListener not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._Client_addRPCListener(cppPtr, onRPCReceivedPtr, userData);
    }
}

pub fn Client_removeRPCListener(cppPtr: basis.CppPtr, listenerPtr: u64) void {
    if (isWasm) {
        @compileError("Client_removeRPCListener not implemented for WASM yet.");
    } else {
        basis.bindings.fp._Client_removeRPCListener(cppPtr, listenerPtr);
    }
}

pub fn Client_sendNetworkMessageToHostID(cppPtr: basis.CppPtr, data: [*c]const u8, dataLength: u32, reliable: bool, hostID: i32) void {
    if (isWasm) {
        access.Client_sendNetworkMessageToHostID_WASM(cppPtr, data, dataLength, reliable, hostID);
    } else {
        basis.bindings.fp._Client_sendNetworkMessageToHostID(cppPtr, data, dataLength, if (reliable) 1 else 0, hostID);
    }
}

pub fn Client_sendNetworkMessageToPeer(cppPtr: basis.CppPtr, data: [*c]const u8, dataLength: u32, reliable: bool, peerCppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.Client_sendNetworkMessageToPeer_WASM(cppPtr, data, dataLength, reliable, peerCppPtr);
    } else {
        basis.bindings.fp._Client_sendNetworkMessageToPeer(cppPtr, data, dataLength, if (reliable) 1 else 0, peerCppPtr);
    }
}

pub fn Client_isConnected(cppPtr: basis.CppPtr) i32 {
    if (isWasm) {
        return access.Client_isConnected_WASM(cppPtr);
    } else {
        return basis.bindings.fp._Client_isConnected(cppPtr);
    }
}

// ===============================

// class Server

pub fn Server_getGameSession(cppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.Server_getGameSession_WASM(cppPtr);
    } else {
        return basis.bindings.fp._Server_getGameSession(cppPtr);
    }
}

pub fn Server_getGameState(cppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.Server_getGameState_WASM(cppPtr);
    } else {
        return basis.bindings.fp._Server_getGameState(cppPtr);
    }
}

pub fn Server_getPhysicsEnginePtr(cppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.Server_getPhysicsEnginePtr_WASM(cppPtr);
    } else {
        return basis.bindings.fp._Server_getPhysicsEnginePtr(cppPtr);
    }
}

pub fn Server_getPrimaryPhysicsScene(cppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.Server_getPrimaryPhysicsScene_WASM(cppPtr);
    } else {
        return basis.bindings.fp._Server_getPrimaryPhysicsScene(cppPtr);
    }
}

pub fn Server_createMessageNode(zigLibCppPtr: basis.bindings.InteropTypedPtr, cppPtr: basis.CppPtr, messageNodeName: [*c]const basis.bindings.InteropString, zigNodePtr: basis.IntPtr) basis.CppPtr {
    if (isWasm) {
        return access.Server_createMessageNode_WASM(
            zigLibCppPtr.ptr,
            zigLibCppPtr.type,
            cppPtr,
            messageNodeName.*.ptr,
            messageNodeName.*.len,
            basis.bindings.hostIntPtrFromLib(zigNodePtr),
        );
    } else {
        return basis.bindings.fp._Server_createMessageNode(zigLibCppPtr, cppPtr, messageNodeName, zigNodePtr);
    }
}

pub fn Server_addRPCListener(cppPtr: basis.CppPtr, onRPCReceivedPtr: u64, userData: u64) u64 {
    if (isWasm) {
        @compileError("Server_addRPCListener not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._Server_addRPCListener(cppPtr, onRPCReceivedPtr, userData);
    }
}

pub fn Server_removeRPCListener(cppPtr: basis.CppPtr, listenerPtr: u64) void {
    if (isWasm) {
        @compileError("Server_removeRPCListener not implemented for WASM yet.");
    } else {
        basis.bindings.fp._Server_removeRPCListener(cppPtr, listenerPtr);
    }
}

pub fn Server_sendNetworkMessageToHostID(cppPtr: basis.CppPtr, data: [*c]const u8, dataLength: u32, reliable: bool, hostID: i32) void {
    if (isWasm) {
        access.Server_sendNetworkMessageToHostID_WASM(cppPtr, data, dataLength, reliable, hostID);
    } else {
        basis.bindings.fp._Server_sendNetworkMessageToHostID(cppPtr, data, dataLength, if (reliable) 1 else 0, hostID);
    }
}

pub fn Server_sendNetworkMessageToPeer(cppPtr: basis.CppPtr, data: [*c]const u8, dataLength: u32, reliable: bool, peerCppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.Server_sendNetworkMessageToPeer_WASM(cppPtr, data, dataLength, reliable, peerCppPtr);
    } else {
        basis.bindings.fp._Server_sendNetworkMessageToPeer(cppPtr, data, dataLength, if (reliable) 1 else 0, peerCppPtr);
    }
}

pub fn Server_endGameSession(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.Server_endGameSession_WASM(cppPtr);
    } else {
        basis.bindings.fp._Server_endGameSession(cppPtr);
    }
}

// ===============================

// class CommandPrompt

pub fn CommandPrompt_parseCommand(command: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        access.CommandPrompt_parseCommand_WASM(command.*.ptr, command.*.len);
    } else {
        basis.bindings.fp._CommandPrompt_parseCommand(command);
    }
}

pub fn CommandPrompt_registerIntValue(
    nameSpace: [*c]const basis.bindings.InteropString,
    name: [*c]const basis.bindings.InteropString,
    setCallback: basis.bindings.FP_void_i32,
    getCallback: basis.bindings.FP_i32,
    onServer: c_int,
    helpText: [*c]const basis.bindings.InteropString,
) void {
    if (isWasm) {
        const setCallbackIntPtr: basis.IntPtr = @intFromPtr(setCallback);
        const getCallbackIntPtr: basis.IntPtr = @intFromPtr(getCallback);
        access.CommandPrompt_registerIntValue_WASM(
            nameSpace.*.ptr,
            nameSpace.*.len,
            name.*.ptr,
            name.*.len,
            @intCast(setCallbackIntPtr),
            @intCast(getCallbackIntPtr),
            onServer,
            helpText.*.ptr,
            helpText.*.len,
        );
    } else {
        basis.bindings.fp._CommandPrompt_registerIntValue(nameSpace, name, setCallback, getCallback, onServer, helpText);
    }
}

pub fn CommandPrompt_registerFloatValue(
    nameSpace: [*c]const basis.bindings.InteropString,
    name: [*c]const basis.bindings.InteropString,
    setCallback: basis.bindings.FP_void_f32,
    getCallback: basis.bindings.FP_f32,
    onServer: c_int,
    helpText: [*c]const basis.bindings.InteropString,
) void {
    if (isWasm) {
        const setCallbackIntPtr: basis.IntPtr = @intFromPtr(setCallback);
        const getCallbackIntPtr: basis.IntPtr = @intFromPtr(getCallback);
        access.CommandPrompt_registerFloatValue_WASM(
            nameSpace.*.ptr,
            nameSpace.*.len,
            name.*.ptr,
            name.*.len,
            @intCast(setCallbackIntPtr),
            @intCast(getCallbackIntPtr),
            onServer,
            helpText.*.ptr,
            helpText.*.len,
        );
    } else {
        basis.bindings.fp._CommandPrompt_registerFloatValue(nameSpace, name, setCallback, getCallback, onServer, helpText);
    }
}

pub fn CommandPrompt_registerBoolValue(
    nameSpace: [*c]const basis.bindings.InteropString,
    name: [*c]const basis.bindings.InteropString,
    setCallback: basis.bindings.FP_void_bool,
    getCallback: basis.bindings.FP_bool,
    onServer: c_int,
    helpText: [*c]const basis.bindings.InteropString,
) void {
    if (isWasm) {
        const setCallbackIntPtr: basis.IntPtr = @intFromPtr(setCallback);
        const getCallbackIntPtr: basis.IntPtr = @intFromPtr(getCallback);
        access.CommandPrompt_registerBoolValue_WASM(
            nameSpace.*.ptr,
            nameSpace.*.len,
            name.*.ptr,
            name.*.len,
            @intCast(setCallbackIntPtr),
            @intCast(getCallbackIntPtr),
            onServer,
            helpText.*.ptr,
            helpText.*.len,
        );
    } else {
        basis.bindings.fp._CommandPrompt_registerBoolValue(nameSpace, name, setCallback, getCallback, onServer, helpText);
    }
}

pub fn CommandPrompt_registerFunction(
    nameSpace: [*c]const basis.bindings.InteropString,
    name: [*c]const basis.bindings.InteropString,
    callback: basis.bindings.FP_void,
    paramTypes: [*c]i32,
    paramCount: u32,
    onServer: c_int,
    helpText: [*c]const basis.bindings.InteropString,
) void {
    if (isWasm) {
        const callbackIntPtr: basis.IntPtr = @intFromPtr(callback);
        const paramTypesBytes = std.mem.asBytes(&paramTypes[0]);

        access.CommandPrompt_registerFunction_WASM(
            nameSpace.*.ptr,
            nameSpace.*.len,
            name.*.ptr,
            name.*.len,
            @intCast(callbackIntPtr),
            paramTypesBytes,
            paramCount,
            onServer,
            helpText.*.ptr,
            helpText.*.len,
        );
    } else {
        basis.bindings.fp._CommandPrompt_registerFunction(nameSpace, name, callback, paramTypes, paramCount, onServer, helpText);
    }
}

pub fn CommandPrompt_unregister(nameSpace: [*c]const basis.bindings.InteropString, name: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        access.CommandPrompt_unregister_WASM(nameSpace.*.ptr, nameSpace.*.len, name.*.ptr, name.*.len);
    } else {
        basis.bindings.fp._CommandPrompt_unregister(nameSpace, name);
    }
}

pub fn CommandPrompt_outputLine(line: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        access.CommandPrompt_outputLine_WASM(line.*.ptr, line.*.len);
    } else {
        basis.bindings.fp._CommandPrompt_outputLine(line);
    }
}

pub fn CommandPrompt_outputErrorLine(line: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        access.CommandPrompt_outputErrorLine_WASM(line.*.ptr, line.*.len);
    } else {
        basis.bindings.fp._CommandPrompt_outputErrorLine(line);
    }
}

pub fn CommandPrompt_getIntParameter() i32 {
    if (isWasm) {
        return access.CommandPrompt_getIntParameter_WASM();
    } else {
        return basis.bindings.fp._CommandPrompt_getIntParameter();
    }
}

pub fn CommandPrompt_getFloatParameter() f32 {
    if (isWasm) {
        return access.CommandPrompt_getFloatParameter_WASM();
    } else {
        return basis.bindings.fp._CommandPrompt_getFloatParameter();
    }
}

pub fn CommandPrompt_getBoolParameter() c_int {
    if (isWasm) {
        return access.CCommandPrompt_getBoolParameter_WASM();
    } else {
        return basis.bindings.fp._CommandPrompt_getBoolParameter();
    }
}

pub fn CommandPrompt_getStringParameter(str: [*c]basis.bindings.InteropString) void {
    if (isWasm) {
        //The C++ side should be good to go, but unclear how we want to allocate storage for the string in Zig.
        @compileError("CommandPrompt_getStringParameter not implemented for WASM yet.");
    } else {
        basis.bindings.fp._CommandPrompt_getStringParameter(str);
    }
}

// ===============================

// class ConfigOptions

pub fn ConfigOptions_addString(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString, value: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("ConfigOptions_addString not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ConfigOptions_addString(cppPtr, name, value);
    }
}

pub fn ConfigOptions_addFloat(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString, value: f32) void {
    if (isWasm) {
        @compileError("ConfigOptions_addFloat not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ConfigOptions_addFloat(cppPtr, name, value);
    }
}

pub fn ConfigOptions_addInteger(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString, value: i32) void {
    if (isWasm) {
        @compileError("ConfigOptions_addInteger not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ConfigOptions_addInteger(cppPtr, name, value);
    }
}

pub fn ConfigOptions_addBool(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString, value: bool) void {
    if (isWasm) {
        @compileError("ConfigOptions_addBool not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ConfigOptions_addBool(cppPtr, name, if (value) 1 else 0);
    }
}

pub fn ConfigOptions_getString(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString, value: [*c]basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("ConfigOptions_getString not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ConfigOptions_getString(cppPtr, name, value);
    }
}

pub fn ConfigOptions_getFloat(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString) f32 {
    if (isWasm) {
        @compileError("ConfigOptions_getFloat not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._ConfigOptions_getFloat(cppPtr, name);
    }
}

pub fn ConfigOptions_getInteger(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString) i32 {
    if (isWasm) {
        @compileError("ConfigOptions_getInteger not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._ConfigOptions_getInteger(cppPtr, name);
    }
}

pub fn ConfigOptions_getBool(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString) bool {
    if (isWasm) {
        @compileError("ConfigOptions_getBool not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._ConfigOptions_getBool(cppPtr, name) == 1;
    }
}

pub fn ConfigOptions_setString(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString, value: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("ConfigOptions_setString not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ConfigOptions_setString(cppPtr, name, value);
    }
}

pub fn ConfigOptions_setFloat(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString, value: f32) void {
    if (isWasm) {
        @compileError("ConfigOptions_setFloat not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ConfigOptions_setFloat(cppPtr, name, value);
    }
}

pub fn ConfigOptions_setInteger(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString, value: i32) void {
    if (isWasm) {
        @compileError("ConfigOptions_setInteger not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ConfigOptions_setInteger(cppPtr, name, value);
    }
}

pub fn ConfigOptions_setBool(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString, value: bool) void {
    if (isWasm) {
        @compileError("ConfigOptions_setBool not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ConfigOptions_setBool(cppPtr, name, if (value) 1 else 0);
    }
}

pub fn ConfigOptions_hasString(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString) bool {
    if (isWasm) {
        @compileError("ConfigOptions_hasString not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._ConfigOptions_hasString(cppPtr, name) == 1;
    }
}

pub fn ConfigOptions_hasFloat(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString) bool {
    if (isWasm) {
        @compileError("ConfigOptions_hasFloat not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._ConfigOptions_hasFloat(cppPtr, name) == 1;
    }
}

pub fn ConfigOptions_hasInteger(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString) bool {
    if (isWasm) {
        @compileError("ConfigOptions_hasInteger not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._ConfigOptions_hasInteger(cppPtr, name) == 1;
    }
}

pub fn ConfigOptions_hasBool(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString) bool {
    if (isWasm) {
        @compileError("ConfigOptions_hasBool not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._ConfigOptions_hasBool(cppPtr, name) == 1;
    }
}

pub fn ConfigOptions_save(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        @compileError("ConfigOptions_save not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ConfigOptions_save(cppPtr);
    }
}

// ===============================

// class PlayerController

pub fn PlayerController_getClient(thisPtr: basis.bindings.InteropTypedPtr) u64 {
    if (isWasm) {
        @compileError("PlayerController_getClient not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._PlayerController_getClient(thisPtr);
    }
}

pub fn PlayerController_getServer(thisPtr: basis.bindings.InteropTypedPtr) u64 {
    if (isWasm) {
        @compileError("PlayerController_getServer not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._PlayerController_getServer(thisPtr);
    }
}

pub fn PlayerController_getInputRange(thisPtr: basis.bindings.InteropTypedPtr, inputID: u16) f32 {
    if (isWasm) {
        @compileError("PlayerController_getInputRange not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._PlayerController_getInputRange(thisPtr, inputID);
    }
}

pub fn PlayerController_getInputState(thisPtr: basis.bindings.InteropTypedPtr, inputID: u16) bool {
    if (isWasm) {
        @compileError("PlayerController_getInputState not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._PlayerController_getInputState(thisPtr, inputID) == 1;
    }
}

pub fn PlayerController_getInputAction(thisPtr: basis.bindings.InteropTypedPtr, inputID: u16) bool {
    if (isWasm) {
        @compileError("PlayerController_getInputAction not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._PlayerController_getInputAction(thisPtr, inputID) == 1;
    }
}

pub fn PlayerController_subscribeToMessageCategory(thisPtr: basis.bindings.InteropTypedPtr, cat: i32) void {
    if (isWasm) {
        @compileError("PlayerController_subscribeToMessageCategory not implemented for WASM yet.");
    } else {
        basis.bindings.fp._PlayerController_subscribeToMessageCategory(thisPtr, cat);
    }
}

pub fn PlayerController_allocMsgParams(thisPtr: basis.bindings.InteropTypedPtr) u64 {
    if (isWasm) {
        @compileError("PlayerController_allocMsgParams not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._PlayerController_allocMsgParams(thisPtr);
    }
}

pub fn PlayerController_sendMessage(thisPtr: basis.bindings.InteropTypedPtr, message: i32, parameters: u64) void {
    if (isWasm) {
        @compileError("PlayerController_sendMessage not implemented for WASM yet.");
    } else {
        basis.bindings.fp._PlayerController_sendMessage(thisPtr, message, parameters);
    }
}

// ===============================

// class DebugDraw

pub fn DebugDraw_drawLine2D(x1: c_int, y1: c_int, x2: c_int, y2: c_int, color1: [*c]const basis.bindings.InteropColor, color2: [*c]const basis.bindings.InteropColor) void {
    if (isWasm) {
        const SIZE = 6 * 4;
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.putInt(i32, @intCast(x1));
        stream.putInt(i32, @intCast(y1));
        stream.putInt(i32, @intCast(x2));
        stream.putInt(i32, @intCast(y2));
        stream.put(basis.Color, basis.Color.fromInterop(color1.*));
        stream.put(basis.Color, basis.Color.fromInterop(color2.*));

        access.DebugDraw_drawLine2D_WASM(&buffer, SIZE);
    } else {
        basis.bindings.fp._DebugDraw_drawLine2D(x1, y1, x2, y2, color1, color2);
    }
}

pub fn DebugDraw_drawLine3D(p1: [*c]const basis.bindings.InteropVec3, p2: [*c]const basis.bindings.InteropVec3, color1: [*c]const basis.bindings.InteropColor, color2: [*c]const basis.bindings.InteropColor) void {
    if (isWasm) {
        const SIZE = (6 * @sizeOf(f32)) + (2 * 4);
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.put(Vec3, Vec3.fromInterop(p1.*));
        stream.put(Vec3, Vec3.fromInterop(p2.*));
        stream.put(basis.Color, basis.Color.fromInterop(color1.*));
        stream.put(basis.Color, basis.Color.fromInterop(color2.*));

        access.DebugDraw_drawLine3D_WASM(&buffer, SIZE);
    } else {
        basis.bindings.fp._DebugDraw_drawLine3D(p1, p2, color1, color2);
    }
}

pub fn DebugDraw_drawAxisCross(point: [*c]const basis.bindings.InteropVec3, scale: f32) void {
    if (isWasm) {
        access.DebugDraw_drawAxisCross_WASM(point.*.x, point.*.y, point.*.z, scale);
    } else {
        basis.bindings.fp._DebugDraw_drawAxisCross(point, scale);
    }
}

pub fn DebugDraw_drawSphere(center: [*c]const basis.bindings.InteropVec3, radius: f32, color: [*c]const basis.bindings.InteropColor, pointCount: c_int) void {
    if (isWasm) {
        access.DebugDraw_drawSphere_WASM(center.*.x, center.*.y, center.*.z, radius, color.*.r, color.*.g, color.*.b, color.*.a, pointCount);
    } else {
        basis.bindings.fp._DebugDraw_drawSphere(center, radius, color, pointCount);
    }
}

pub fn DebugDraw_drawTriangle3D(
    p1: [*c]const basis.bindings.InteropVec3,
    p2: [*c]const basis.bindings.InteropVec3,
    p3: [*c]const basis.bindings.InteropVec3,
    color1: [*c]const basis.bindings.InteropColor,
    color2: [*c]const basis.bindings.InteropColor,
    color3: [*c]const basis.bindings.InteropColor,
) void {
    if (isWasm) {
        const SIZE = (9 * @sizeOf(f32)) + (3 * 4);
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.put(Vec3, Vec3.fromInterop(p1.*));
        stream.put(Vec3, Vec3.fromInterop(p2.*));
        stream.put(Vec3, Vec3.fromInterop(p3.*));
        stream.put(basis.Color, basis.Color.fromInterop(color1.*));
        stream.put(basis.Color, basis.Color.fromInterop(color2.*));
        stream.put(basis.Color, basis.Color.fromInterop(color3.*));

        access.DebugDraw_drawTriangle3D_WASM(&buffer, SIZE);
    } else {
        basis.bindings.fp._DebugDraw_drawTriangle3D(p1, p2, p3, color1, color2, color3);
    }
}

pub fn DebugDraw_drawString(text: [*c]const basis.bindings.InteropString, worldPosition: [*c]const basis.bindings.InteropVec3, color: [*c]const basis.bindings.InteropColor) void {
    if (isWasm) {
        const SIZE = @sizeOf(f32) + 4;
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.put(Vec3, Vec3.fromInterop(worldPosition.*));
        stream.put(basis.Color, basis.Color.fromInterop(color.*));

        access.DebugDraw_drawString_WASM(
            text.*.ptr,
            text.*.len,
            &buffer,
            SIZE,
        );
    } else {
        basis.bindings.fp._DebugDraw_drawString(text, worldPosition, color);
    }
}

pub fn DebugDraw_drawStringXY(text: [*c]const basis.bindings.InteropString, x: c_int, y: c_int, color: [*c]const basis.bindings.InteropColor, pivot: c_int) void {
    if (isWasm) {
        const SIZE = 16;
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.putInt(i32, x);
        stream.putInt(i32, y);
        stream.put(basis.Color, basis.Color.fromInterop(color.*));
        stream.putInt(i32, pivot);

        access.DebugDraw_drawStringXY_WASM(
            text.*.ptr,
            text.*.len,
            &buffer,
            SIZE,
        );
    } else {
        basis.bindings.fp._DebugDraw_drawStringXY(text, x, y, color, pivot);
    }
}

// ===============================

// class GameObject

pub fn GameObject_getName(cppPtr: basis.CppPtr, str: [*c]basis.bindings.InteropString) void {
    if (isWasm) {
        const tempMemory = gWASMTempMemoryBuffer.get();
        const length = access.GameObject_getName_WASM(cppPtr, tempMemory.ptr, WASMTempMemorySize);
        str.*.ptr = tempMemory.ptr;
        str.*.len = @intCast(length);
    } else {
        basis.bindings.fp._GameObject_getName(cppPtr, str);
    }
}

pub fn GameObject_getType(cppPtr: basis.CppPtr, str: [*c]basis.bindings.InteropString) void {
    if (isWasm) {
        const tempMemory = gWASMTempMemoryBuffer.get();
        const length = access.GameObject_getType_WASM(cppPtr, tempMemory.ptr, WASMTempMemorySize);
        str.*.ptr = tempMemory.ptr;
        str.*.len = @intCast(length);
    } else {
        basis.bindings.fp._GameObject_getType(cppPtr, str);
    }
}

pub fn GameObject_getComponentPtrByShortName(cppPtr: basis.CppPtr, shortName: [*c]const basis.bindings.InteropString) basis.IntPtr {
    if (isWasm) {
        const hostPtr = access.GameObject_getComponentPtrByShortName_WASM(cppPtr, shortName.*.ptr, shortName.*.len);
        return basis.bindings.libIntPtrFromHost(hostPtr);
    } else {
        return basis.bindings.fp._GameObject_getComponentPtrByShortName(cppPtr, shortName);
    }
}

pub fn GameObject_getComponentPtrByTypeName(cppPtr: basis.CppPtr, typeName: [*c]const basis.bindings.InteropString) basis.IntPtr {
    if (isWasm) {
        const hostPtr = access.GameObject_getComponentPtrByTypeName_WASM(cppPtr, typeName.*.ptr, typeName.*.len);
        return basis.bindings.libIntPtrFromHost(hostPtr);
    } else {
        return basis.bindings.fp._GameObject_getComponentPtrByTypeName(cppPtr, typeName);
    }
}

pub fn GameObject_addGameObjectMeshInstanceMapping(cppPtr: basis.CppPtr, meshInstancePtr: basis.CppPtr) void {
    if (isWasm) {
        access.GameObject_addGameObjectMeshInstanceMapping_WASM(cppPtr, meshInstancePtr);
    } else {
        basis.bindings.fp._GameObject_addGameObjectMeshInstanceMapping(cppPtr, meshInstancePtr);
    }
}

pub fn GameObject_removeGameObjectMeshInstanceMapping(cppPtr: basis.CppPtr, meshInstancePtr: basis.CppPtr) void {
    if (isWasm) {
        access.GameObject_removeGameObjectMeshInstanceMapping_WASM(cppPtr, meshInstancePtr);
    } else {
        basis.bindings.fp._GameObject_removeGameObjectMeshInstanceMapping(cppPtr, meshInstancePtr);
    }
}

pub fn GameObject_getNameHash(cppPtr: basis.CppPtr) u32 {
    if (isWasm) {
        return access.GameObject_getNameHash_WASM(cppPtr);
    } else {
        return basis.bindings.fp._GameObject_getNameHash(cppPtr);
    }
}

pub fn GameObject_getWorldTransform(cppPtr: basis.CppPtr, position: [*c]basis.bindings.InteropVec3, orientation: [*c]basis.bindings.InteropQuaternion) c_int {
    if (isWasm) {
        const SIZE = 7 * @sizeOf(f32); // One Vec3 + One Quat = 7 floats
        var buffer: [SIZE]u8 = undefined;

        const ret = access.GameObject_getWorldTransform_WASM(cppPtr, &buffer, SIZE);
        if (ret == 0) {
            return ret;
        }
        var stream = basis.BinaryReadStream.init(&buffer, true);
        const v = stream.get(Vec3);
        const q = stream.get(Quaternion);
        position.* = v.toInterop();
        orientation.* = q.toInterop();
        return ret;
    } else {
        return basis.bindings.fp._GameObject_getWorldTransform(cppPtr, position, orientation);
    }
}

pub fn GameObject_setWorldTransform(cppPtr: basis.CppPtr, position: [*c]const basis.bindings.InteropVec3, orientation: [*c]const basis.bindings.InteropQuaternion, teleport: bool) c_int {
    if (isWasm) {
        const SIZE = 8 * @sizeOf(f32); // One Vec3 + One Quat + One bool = 8 floats
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.put(Vec3, Vec3.fromInterop(position.*));
        stream.put(Quaternion, Quaternion.fromInterop(orientation.*));
        stream.putBool(teleport);

        return access.GameObject_setWorldTransform_WASM(cppPtr, &buffer, SIZE);
    } else {
        return basis.bindings.fp._GameObject_setWorldTransform(cppPtr, position, orientation, if (teleport) 1 else 0);
    }
}

pub fn GameObject_getMeshComponentData(cppPtr: basis.CppPtr, componentShortName: [*c]const basis.bindings.InteropString, sceneNodePtr: [*c]u64, meshPtr: [*c]u64, meshInstancePtr: [*c]u64) c_int {
    if (isWasm) {
        const SIZE = 3 * @sizeOf(basis.CppPtr);
        var buffer: [SIZE]u8 = undefined;

        const ret = access.GameObject_getMeshComponentData_WASM(
            cppPtr,
            componentShortName.*.ptr,
            componentShortName.*.len,
            &buffer,
            SIZE,
        );
        if (ret == 0) {
            return ret;
        }

        var stream = basis.BinaryReadStream.init(&buffer, true);
        sceneNodePtr.* = stream.getInt(basis.CppPtr);
        meshPtr.* = stream.getInt(basis.CppPtr);
        meshInstancePtr.* = stream.getInt(basis.CppPtr);

        return ret;
    } else {
        return basis.bindings.fp._GameObject_getMeshComponentData(cppPtr, componentShortName, sceneNodePtr, meshPtr, meshInstancePtr);
    }
}

pub fn GameObject_getPhysicsActor(cppPtr: basis.CppPtr, actorCppPtr: [*c]u64, actorType: [*c]u32) c_int {
    if (isWasm) {
        const SIZE = @sizeOf(basis.CppPtr) + @sizeOf(u32);
        var buffer: [SIZE]u8 = undefined;

        const ret = access.GameObject_getPhysicsActor_WASM(cppPtr, &buffer, SIZE);
        if (ret == 0) {
            return ret;
        }

        var stream = basis.BinaryReadStream.init(&buffer, true);
        actorCppPtr.* = stream.getInt(basis.CppPtr);
        actorType.* = stream.getInt(u32);

        return ret;
    } else {
        return basis.bindings.fp._GameObject_getPhysicsActor(cppPtr, actorCppPtr, actorType);
    }
}

pub fn GameObject_setGameTag(cppPtr: basis.CppPtr, tag: u32) void {
    if (isWasm) {
        access.GameObject_setGameTag_WASM(cppPtr, tag);
    } else {
        basis.bindings.fp._GameObject_setGameTag(cppPtr, tag);
    }
}

pub fn GameObject_getGameTag(cppPtr: basis.CppPtr) u32 {
    if (isWasm) {
        return access.GameObject_getGameTag_WASM(cppPtr);
    } else {
        return basis.bindings.fp._GameObject_getGameTag(cppPtr);
    }
}

pub fn GameObject_getRenderSceneNode(cppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.GameObject_getRenderSceneNode_WASM(cppPtr);
    } else {
        return basis.bindings.fp._GameObject_getRenderSceneNode(cppPtr);
    }
}

pub fn GameObject_getNavMeshObstacleIDs(cppPtr: basis.CppPtr, navMeshID: u32, outIDs: [*c]u32, maxCount: u32) u32 {
    if (isWasm) {
        @compileError("GameObject_getNavMeshObstacleIDs not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._GameObject_getNavMeshObstacleIDs(cppPtr, navMeshID, outIDs, maxCount);
    }
}

// ===============================

// class ComponentContext

pub fn ComponentContext_getName(thisPtr: basis.bindings.InteropTypedPtr, str: [*c]basis.bindings.InteropString) void {
    if (isWasm) {
        const tempMemory = gWASMTempMemoryBuffer.get();
        const length = access.ComponentContext_getName_WASM(thisPtr.ptr, thisPtr.type, tempMemory.ptr, WASMTempMemorySize);
        str.*.ptr = tempMemory.ptr;
        str.*.len = @intCast(length);
    } else {
        basis.bindings.fp._ComponentContext_getName(thisPtr, str);
    }
}

pub fn ComponentContext_onClient(thisPtr: basis.bindings.InteropTypedPtr) bool {
    if (isWasm) {
        return access.ComponentContext_onClient_WASM(thisPtr.ptr, thisPtr.type);
    } else {
        return basis.bindings.fp._ComponentContext_onClient(thisPtr) == 1;
    }
}

pub fn ComponentContext_inEditor(thisPtr: basis.bindings.InteropTypedPtr) bool {
    if (isWasm) {
        return access.ComponentContext_inEditor_WASM(thisPtr.ptr, thisPtr.type);
    } else {
        return basis.bindings.fp._ComponentContext_inEditor(thisPtr) == 1;
    }
}

pub fn ComponentContext_getClient(thisPtr: basis.bindings.InteropTypedPtr) basis.CppPtr {
    if (isWasm) {
        return access.ComponentContext_getClient_WASM(thisPtr.ptr, thisPtr.type);
    } else {
        return basis.bindings.fp._ComponentContext_getClient(thisPtr);
    }
}

pub fn ComponentContext_getServer(thisPtr: basis.bindings.InteropTypedPtr) basis.CppPtr {
    if (isWasm) {
        return access.ComponentContext_getServer_WASM(thisPtr.ptr, thisPtr.type);
    } else {
        return basis.bindings.fp._ComponentContext_getServer(thisPtr);
    }
}

pub fn ComponentContext_getGameObject(thisPtr: basis.bindings.InteropTypedPtr) basis.CppPtr {
    if (isWasm) {
        return access.ComponentContext_getGameObject_WASM(thisPtr.ptr, thisPtr.type);
    } else {
        return basis.bindings.fp._ComponentContext_getGameObject(thisPtr);
    }
}

pub fn ComponentContext_subscribeToMessageCategory(thisPtr: basis.bindings.InteropTypedPtr, cat: i32) void {
    if (isWasm) {
        access.ComponentContext_subscribeToMessageCategory_WASM(thisPtr.ptr, thisPtr.type, cat);
    } else {
        basis.bindings.fp._ComponentContext_subscribeToMessageCategory(thisPtr, cat);
    }
}

pub fn ComponentContext_allocMsgParams(thisPtr: basis.bindings.InteropTypedPtr) basis.CppPtr {
    if (isWasm) {
        return access.ComponentContext_allocMsgParams_WASM(thisPtr.ptr, thisPtr.type);
    } else {
        return basis.bindings.fp._ComponentContext_allocMsgParams(thisPtr);
    }
}

pub fn ComponentContext_sendMessage(thisPtr: basis.bindings.InteropTypedPtr, message: i32, parameters: basis.CppPtr) void {
    if (isWasm) {
        access.ComponentContext_sendMessage_WASM(thisPtr.ptr, thisPtr.type, message, parameters);
    } else {
        basis.bindings.fp._ComponentContext_sendMessage(thisPtr, message, parameters);
    }
}

pub fn ComponentContext_getPhysicsEnginePtr(thisPtr: basis.bindings.InteropTypedPtr) basis.CppPtr {
    if (isWasm) {
        return access.ComponentContext_getPhysicsEnginePtr_WASM(thisPtr.ptr, thisPtr.type);
    } else {
        return basis.bindings.fp._ComponentContext_getPhysicsEnginePtr(thisPtr);
    }
}

pub fn ComponentContext_getPrimaryPhysicsScene(thisPtr: basis.bindings.InteropTypedPtr) basis.CppPtr {
    if (isWasm) {
        return access.ComponentContext_getPrimaryPhysicsScene_WASM(thisPtr.ptr, thisPtr.type);
    } else {
        return basis.bindings.fp._ComponentContext_getPrimaryPhysicsScene(thisPtr);
    }
}

pub fn ComponentContext_getRenderer(thisPtr: basis.bindings.InteropTypedPtr) basis.CppPtr {
    if (isWasm) {
        return access.ComponentContext_getRenderer_WASM(thisPtr.ptr, thisPtr.type);
    } else {
        return basis.bindings.fp._ComponentContext_getRenderer(thisPtr);
    }
}

pub fn ComponentContext_getGameSession(thisPtr: basis.bindings.InteropTypedPtr) basis.CppPtr {
    if (isWasm) {
        return access.ComponentContext_getGameSession_WASM(thisPtr.ptr, thisPtr.type);
    } else {
        return basis.bindings.fp._ComponentContext_getGameSession(thisPtr);
    }
}

pub fn ComponentContext_getGameState(thisPtr: basis.bindings.InteropTypedPtr) basis.CppPtr {
    if (isWasm) {
        return access.ComponentContext_getGameState_WASM(thisPtr.ptr, thisPtr.type);
    } else {
        return basis.bindings.fp._ComponentContext_getGameState(thisPtr);
    }
}

pub fn ComponentContext_getPosition(thisPtr: basis.bindings.InteropTypedPtr, returnValue: [*c]basis.bindings.InteropVec3) void {
    if (isWasm) {
        const SIZE = 3 * @sizeOf(u32);
        var buffer: [SIZE]u8 = undefined;

        access.ComponentContext_getPosition_WASM(thisPtr.ptr, thisPtr.type, &buffer, SIZE);

        var stream = basis.BinaryReadStream.init(&buffer, true);
        returnValue.* = stream.get(Vec3).toInterop();
    } else {
        basis.bindings.fp._ComponentContext_getPosition(thisPtr, returnValue);
    }
}

pub fn ComponentContext_setPosition(thisPtr: basis.bindings.InteropTypedPtr, p: [*c]const basis.bindings.InteropVec3) void {
    if (isWasm) {
        access.ComponentContext_setPosition_WASM(thisPtr.ptr, thisPtr.type, p.*.x, p.*.y, p.*.z);
    } else {
        basis.bindings.fp._ComponentContext_setPosition(thisPtr, p);
    }
}

pub fn ComponentContext_getOrientation(thisPtr: basis.bindings.InteropTypedPtr, returnValue: [*c]basis.bindings.InteropQuaternion) void {
    if (isWasm) {
        const SIZE = 4 * @sizeOf(u32);
        var buffer: [SIZE]u8 = undefined;

        access.ComponentContext_getOrientation_WASM(thisPtr.ptr, thisPtr.type, &buffer, SIZE);

        var stream = basis.BinaryReadStream.init(&buffer, true);
        returnValue.* = stream.get(Quaternion).toInterop();
    } else {
        basis.bindings.fp._ComponentContext_getOrientation(thisPtr, returnValue);
    }
}

pub fn ComponentContext_setOrientation(thisPtr: basis.bindings.InteropTypedPtr, o: [*c]const basis.bindings.InteropQuaternion) void {
    if (isWasm) {
        access.ComponentContext_setOrientation_WASM(thisPtr.ptr, thisPtr.type, o.*.w, o.*.x, o.*.y, o.*.z);
    } else {
        basis.bindings.fp._ComponentContext_setOrientation(thisPtr, o);
    }
}

pub fn ComponentContext_getLinearVelocity(thisPtr: basis.bindings.InteropTypedPtr, returnValue: [*c]basis.bindings.InteropVec3) void {
    if (isWasm) {
        const SIZE = 3 * @sizeOf(u32);
        var buffer: [SIZE]u8 = undefined;

        access.ComponentContext_getLinearVelocity_WASM(thisPtr.ptr, thisPtr.type, &buffer, SIZE);

        var stream = basis.BinaryReadStream.init(&buffer, true);
        returnValue.* = stream.get(Vec3).toInterop();
    } else {
        basis.bindings.fp._ComponentContext_getLinearVelocity(thisPtr, returnValue);
    }
}

pub fn ComponentContext_getAngularVelocity(thisPtr: basis.bindings.InteropTypedPtr, returnValue: [*c]basis.bindings.InteropVec3) void {
    if (isWasm) {
        const SIZE = 3 * @sizeOf(u32);
        var buffer: [SIZE]u8 = undefined;

        access.ComponentContext_getAngularVelocity_WASM(thisPtr.ptr, thisPtr.type, &buffer, SIZE);

        var stream = basis.BinaryReadStream.init(&buffer, true);
        returnValue.* = stream.get(Vec3).toInterop();
    } else {
        basis.bindings.fp._ComponentContext_getAngularVelocity(thisPtr, returnValue);
    }
}

pub fn ComponentContext_setTransform(
    thisPtr: basis.bindings.InteropTypedPtr,
    position: [*c]const basis.bindings.InteropVec3,
    orientation: [*c]const basis.bindings.InteropQuaternion,
    teleport: bool,
) void {
    if (isWasm) {
        const SIZE = 8 * @sizeOf(f32); // One Vec3 + One Quat + One bool = 8 floats
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.put(Vec3, Vec3.fromInterop(position.*));
        stream.put(Quaternion, Quaternion.fromInterop(orientation.*));
        stream.putBool(teleport);

        access.ComponentContext_setTransform_WASM(thisPtr.ptr, thisPtr.type, &buffer, SIZE);
    } else {
        basis.bindings.fp._ComponentContext_setTransform(thisPtr, position, orientation, if (teleport) 1 else 0);
    }
}

pub fn ComponentContext_setTransformWithVelocities(
    thisPtr: basis.bindings.InteropTypedPtr,
    position: [*c]const basis.bindings.InteropVec3,
    orientation: [*c]const basis.bindings.InteropQuaternion,
    linVel: [*c]const basis.bindings.InteropVec3,
    angVel: [*c]const basis.bindings.InteropVec3,
    teleport: bool,
) void {
    if (isWasm) {
        const SIZE = 14 * @sizeOf(f32); // Three Vec3s + One Quat + One bool = 14 floats
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.put(Vec3, Vec3.fromInterop(position.*));
        stream.put(Quaternion, Quaternion.fromInterop(orientation.*));
        stream.put(Vec3, Vec3.fromInterop(linVel.*));
        stream.put(Vec3, Vec3.fromInterop(angVel.*));
        stream.putBool(teleport);

        access.ComponentContext_setTransformWithVelocities_WASM(thisPtr.ptr, thisPtr.type, &buffer, SIZE);
    } else {
        basis.bindings.fp._ComponentContext_setTransformWithVelocities(thisPtr, position, orientation, linVel, angVel, if (teleport) 1 else 0);
    }
}

pub fn ComponentContext_getWorldMatrix(thisPtr: basis.bindings.InteropTypedPtr, returnValue: [*c]basis.bindings.InteropMat43) void {
    if (isWasm) {
        const SIZE = 4 * 3 * @sizeOf(u32);
        var buffer: [SIZE]u8 = undefined;

        access.ComponentContext_getWorldMatrix_WASM(thisPtr.ptr, thisPtr.type, &buffer, SIZE);

        var stream = basis.BinaryReadStream.init(&buffer, true);
        returnValue.* = stream.get(basis.math.Mat43).toInterop();
    } else {
        basis.bindings.fp._ComponentContext_getWorldMatrix(thisPtr, returnValue);
    }
}

pub fn ComponentContext_getRenderSceneNode(thisPtr: basis.bindings.InteropTypedPtr) basis.CppPtr {
    if (isWasm) {
        return access.ComponentContext_getRenderSceneNode_WASM(thisPtr.ptr, thisPtr.type);
    } else {
        return basis.bindings.fp._ComponentContext_getRenderSceneNode(thisPtr);
    }
}

pub fn ComponentContext_isClientLocalAvatar(thisPtr: basis.bindings.InteropTypedPtr) bool {
    if (isWasm) {
        return access.ComponentContext_isClientLocalAvatar_WASM(thisPtr.ptr, thisPtr.type);
    } else {
        return basis.bindings.fp._ComponentContext_isClientLocalAvatar(thisPtr) == 1;
    }
}

pub fn ComponentContext_getAvatarHostID(thisPtr: basis.bindings.InteropTypedPtr) i32 {
    if (isWasm) {
        return access.ComponentContext_getAvatarHostID_WASM(thisPtr.ptr, thisPtr.type);
    } else {
        return basis.bindings.fp._ComponentContext_getAvatarHostID(thisPtr);
    }
}

pub fn ComponentContext_getInputRange(thisPtr: basis.bindings.InteropTypedPtr, inputID: u16) f32 {
    if (isWasm) {
        return access.ComponentContext_getInputRange_WASM(thisPtr.ptr, thisPtr.type, inputID);
    } else {
        return basis.bindings.fp._ComponentContext_getInputRange(thisPtr, inputID);
    }
}

pub fn ComponentContext_getInputState(thisPtr: basis.bindings.InteropTypedPtr, inputID: u16) bool {
    if (isWasm) {
        return access.ComponentContext_getInputState_WASM(thisPtr.ptr, thisPtr.type, inputID);
    } else {
        return basis.bindings.fp._ComponentContext_getInputState(thisPtr, inputID) == 1;
    }
}

pub fn ComponentContext_getInputAction(thisPtr: basis.bindings.InteropTypedPtr, inputID: u16) bool {
    if (isWasm) {
        return access.ComponentContext_getInputAction_WASM(thisPtr.ptr, thisPtr.type, inputID);
    } else {
        return basis.bindings.fp._ComponentContext_getInputAction(thisPtr, inputID) == 1;
    }
}

pub fn ComponentContext_getCharacterController(thisPtr: basis.bindings.InteropTypedPtr) basis.CppPtr {
    if (isWasm) {
        return access.ComponentContext_getCharacterController_WASM(thisPtr.ptr, thisPtr.type);
    } else {
        return basis.bindings.fp._ComponentContext_getCharacterController(thisPtr);
    }
}

pub fn ComponentContext_getPhysicsActor(thisPtr: basis.bindings.InteropTypedPtr, actorCppPtr: [*c]u64, actorType: [*c]u32) c_int {
    if (isWasm) {
        const SIZE = @sizeOf(u64) + @sizeOf(u32);
        var buffer: [SIZE]u8 = undefined;

        if (access.ComponentContext_getPhysicsActor_WASM(
            thisPtr.ptr,
            thisPtr.type,
            &buffer,
            SIZE,
        ) == 0) {
            return 0;
        }

        var stream = basis.BinaryReadStream.init(&buffer, true);
        actorCppPtr.* = stream.getInt(u64);
        actorType.* = stream.getInt(u32);

        return 1;
    } else {
        return basis.bindings.fp._ComponentContext_getPhysicsActor(thisPtr, actorCppPtr, actorType);
    }
}

pub fn ComponentContext_flushExposedProperties(thisPtr: basis.bindings.InteropTypedPtr) void {
    if (isWasm) {
        access.ComponentContext_flushExposedProperties_WASM(thisPtr.ptr, thisPtr.type);
    } else {
        basis.bindings.fp._ComponentContext_flushExposedProperties(thisPtr);
    }
}

pub fn ComponentContext_getParentGameObject(thisPtr: basis.bindings.InteropTypedPtr) basis.CppPtr {
    if (isWasm) {
        return access.ComponentContext_getParentGameObject_WASM(thisPtr.ptr, thisPtr.type);
    } else {
        return basis.bindings.fp._ComponentContext_getParentGameObject(thisPtr);
    }
}

pub fn ComponentContext_registerPipe(thisPtr: basis.bindings.InteropTypedPtr, pipename: [*c]const basis.bindings.InteropString, direction: c_int, reliable: bool) u64 {
    if (isWasm) {
        return access.ComponentContext_registerPipe_WASM(
            thisPtr.ptr,
            thisPtr.type,
            pipename.*.ptr,
            pipename.*.len,
            direction,
            reliable,
        );
    } else {
        return basis.bindings.fp._ComponentContext_registerPipe(thisPtr, pipename, direction, if (reliable) 1 else 0);
    }
}

pub fn ComponentContext_writeToPipe(thisPtr: basis.bindings.InteropTypedPtr, pipe: u64, data: [*c]const u8, dataLength: u32) void {
    if (isWasm) {
        access.ComponentContext_writeToPipe_WASM(thisPtr.ptr, thisPtr.type, pipe, data, dataLength);
    } else {
        basis.bindings.fp._ComponentContext_writeToPipe(thisPtr, pipe, data, dataLength);
    }
}

pub fn ComponentContext_callScriptOnTick(thisPtr: basis.bindings.InteropTypedPtr, tickDeltaTime: f32) void {
    if (isWasm) {
        access.ComponentContext_callScriptOnTick_WASM(thisPtr.ptr, thisPtr.type, tickDeltaTime);
    } else {
        basis.bindings.fp._ComponentContext_callScriptOnTick(thisPtr, tickDeltaTime);
    }
}

pub fn ComponentContext_getScriptFunctionByDecl(thisPtr: basis.bindings.InteropTypedPtr, decl: [*c]const basis.bindings.InteropString) basis.CppPtr {
    if (isWasm) {
        return access.ComponentContext_getScriptFunctionByDecl_WASM(thisPtr.ptr, thisPtr.type, decl.*.ptr, decl.*.len);
    } else {
        return basis.bindings.fp._ComponentContext_getScriptFunctionByDecl(thisPtr, decl);
    }
}

pub fn ComponentContext_getScriptFunctionByASFuncPtr(thisPtr: basis.bindings.InteropTypedPtr, funcPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.ComponentContext_getScriptFunctionByASFuncPtr_WASM(thisPtr.ptr, thisPtr.type, funcPtr);
    } else {
        return basis.bindings.fp._ComponentContext_getScriptFunctionByASFuncPtr(thisPtr, funcPtr);
    }
}

pub fn ComponentContext_setScriptGlobalHandle(thisPtr: basis.bindings.InteropTypedPtr, handleName: [*c]const basis.bindings.InteropString, value: basis.CppPtr) void {
    if (isWasm) {
        access.ComponentContext_setScriptGlobalHandle_WASM(thisPtr.ptr, thisPtr.type, handleName.*.ptr, handleName.*.len, value);
    } else {
        basis.bindings.fp._ComponentContext_setScriptGlobalHandle(thisPtr, handleName, value);
    }
}

// ===============================

// class AngelScriptFunction

pub fn AngelScriptFunction_prepareCall(thisPtr: u64) void {
    if (isWasm) {
        @compileError("AngelScriptFunction_prepareCall not implemented for WASM yet.");
    } else {
        basis.bindings.fp._AngelScriptFunction_prepareCall(thisPtr);
    }
}

pub fn AngelScriptFunction_setBoolParam(thisPtr: u64, i: u32, value: bool) void {
    if (isWasm) {
        @compileError("AngelScriptFunction_setBoolParam not implemented for WASM yet.");
    } else {
        basis.bindings.fp._AngelScriptFunction_setBoolParam(thisPtr, i, if (value) 1 else 0);
    }
}

pub fn AngelScriptFunction_setIntParam(thisPtr: u64, i: u32, value: c_int) void {
    if (isWasm) {
        @compileError("AngelScriptFunction_setIntParam not implemented for WASM yet.");
    } else {
        basis.bindings.fp._AngelScriptFunction_setIntParam(thisPtr, i, value);
    }
}

pub fn AngelScriptFunction_setUintParam(thisPtr: u64, i: u32, value: u32) void {
    if (isWasm) {
        @compileError("AngelScriptFunction_setUintParam not implemented for WASM yet.");
    } else {
        basis.bindings.fp._AngelScriptFunction_setUintParam(thisPtr, i, value);
    }
}

pub fn AngelScriptFunction_setFloatParam(thisPtr: u64, i: u32, value: f32) void {
    if (isWasm) {
        @compileError("AngelScriptFunction_setFloatParam not implemented for WASM yet.");
    } else {
        basis.bindings.fp._AngelScriptFunction_setFloatParam(thisPtr, i, value);
    }
}

pub fn AngelScriptFunction_setStringParam(thisPtr: u64, i: u32, value: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("AngelScriptFunction_setStringParam not implemented for WASM yet.");
    } else {
        basis.bindings.fp._AngelScriptFunction_setStringParam(thisPtr, i, value);
    }
}

pub fn AngelScriptFunction_setGameObjectRefParam(thisPtr: u64, i: u32, objectNameHash: u32, hostCppPtr: u64, hostIsClient: bool) void {
    if (isWasm) {
        @compileError("AngelScriptFunction_setGameObjectRefParam not implemented for WASM yet.");
    } else {
        basis.bindings.fp._AngelScriptFunction_setGameObjectRefParam(thisPtr, i, objectNameHash, hostCppPtr, if (hostIsClient) 1 else 0);
    }
}

pub fn AngelScriptFunction_getReturnBool(thisPtr: u64) i32 {
    if (isWasm) {
        @compileError("AngelScriptFunction_getReturnBool not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._AngelScriptFunction_getReturnBool(thisPtr);
    }
}

pub fn AngelScriptFunction_getReturnInt(thisPtr: u64) i32 {
    if (isWasm) {
        @compileError("AngelScriptFunction_getReturnInt not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._AngelScriptFunction_getReturnInt(thisPtr);
    }
}

pub fn AngelScriptFunction_getReturnUint(thisPtr: u64) u32 {
    if (isWasm) {
        @compileError("AngelScriptFunction_getReturnUint not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._AngelScriptFunction_getReturnUint(thisPtr);
    }
}

pub fn AngelScriptFunction_getReturnFloat(thisPtr: u64) f32 {
    if (isWasm) {
        @compileError("AngelScriptFunction_getReturnFloat not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._AngelScriptFunction_getReturnFloat(thisPtr);
    }
}

pub fn AngelScriptFunction_executeCall(thisPtr: u64) void {
    if (isWasm) {
        @compileError("AngelScriptFunction_executeCall not implemented for WASM yet.");
    } else {
        basis.bindings.fp._AngelScriptFunction_executeCall(thisPtr);
    }
}

// ===============================

// class MessageParameters

pub fn MessageParameters_addInt(thisPtr: basis.CppPtr, p: i32) void {
    if (isWasm) {
        access.MessageParameters_addInt_WASM(thisPtr, p);
    } else {
        basis.bindings.fp._MessageParameters_addInt(thisPtr, p);
    }
}

pub fn MessageParameters_getInt(thisPtr: basis.CppPtr) i32 {
    if (isWasm) {
        return access.MessageParameters_getInt_WASM(thisPtr);
    } else {
        return basis.bindings.fp._MessageParameters_getInt(thisPtr);
    }
}

pub fn MessageParameters_addUint(thisPtr: basis.CppPtr, p: u32) void {
    if (isWasm) {
        access.MessageParameters_addUint_WASM(thisPtr, p);
    } else {
        basis.bindings.fp._MessageParameters_addUint(thisPtr, p);
    }
}

pub fn MessageParameters_getUint(thisPtr: basis.CppPtr) u32 {
    if (isWasm) {
        return access.MessageParameters_getUint_WASM(thisPtr);
    } else {
        return basis.bindings.fp._MessageParameters_getUint(thisPtr);
    }
}

pub fn MessageParameters_addUint64(thisPtr: basis.CppPtr, p: u64) void {
    if (isWasm) {
        access.MessageParameters_addUint64_WASM(thisPtr, p);
    } else {
        basis.bindings.fp._MessageParameters_addUint64(thisPtr, p);
    }
}

pub fn MessageParameters_getUint64(thisPtr: basis.CppPtr) u64 {
    if (isWasm) {
        return access.MessageParameters_getUint64_WASM(thisPtr);
    } else {
        return basis.bindings.fp._MessageParameters_getUint64(thisPtr);
    }
}

pub fn MessageParameters_addFloat(thisPtr: basis.CppPtr, p: f32) void {
    if (isWasm) {
        access.MessageParameters_addFloat_WASM(thisPtr, p);
    } else {
        basis.bindings.fp._MessageParameters_addFloat(thisPtr, p);
    }
}

pub fn MessageParameters_getFloat(thisPtr: basis.CppPtr) f32 {
    if (isWasm) {
        return access.MessageParameters_getFloat_WASM(thisPtr);
    } else {
        return basis.bindings.fp._MessageParameters_getFloat(thisPtr);
    }
}

pub fn MessageParameters_addVec3(thisPtr: basis.CppPtr, p: [*c]const basis.bindings.InteropVec3) void {
    if (isWasm) {
        const SIZE = 3 * @sizeOf(f32);
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.put(Vec3, Vec3.fromInterop(p.*));

        access.MessageParameters_addVec3_WASM(thisPtr, &buffer, SIZE);
    } else {
        basis.bindings.fp._MessageParameters_addVec3(thisPtr, p);
    }
}

pub fn MessageParameters_getVec3(thisPtr: basis.CppPtr, returnValue: [*c]basis.bindings.InteropVec3) void {
    if (isWasm) {
        const SIZE = 3 * @sizeOf(f32);
        var buffer: [SIZE]u8 = undefined;

        access.MessageParameters_getVec3_WASM(thisPtr, &buffer, SIZE);

        var stream = basis.BinaryReadStream.init(&buffer, true);
        returnValue.* = stream.get(Vec3).toInterop();
    } else {
        basis.bindings.fp._MessageParameters_getVec3(thisPtr, returnValue);
    }
}

pub fn MessageParameters_addVec4(thisPtr: basis.CppPtr, p: [*c]const basis.bindings.InteropVec4) void {
    if (isWasm) {
        const SIZE = 4 * @sizeOf(f32);
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.put(Vec4, Vec4.fromInterop(p.*));

        access.MessageParameters_addVec4_WASM(thisPtr, &buffer, SIZE);
    } else {
        basis.bindings.fp._MessageParameters_addVec4(thisPtr, p);
    }
}

pub fn MessageParameters_getVec4(thisPtr: basis.CppPtr, returnValue: [*c]basis.bindings.InteropVec4) void {
    if (isWasm) {
        const SIZE = 4 * @sizeOf(f32);
        var buffer: [SIZE]u8 = undefined;

        access.MessageParameters_getVec4_WASM(thisPtr, &buffer, SIZE);

        var stream = basis.BinaryReadStream.init(&buffer, true);
        returnValue.* = stream.get(Vec4).toInterop();
    } else {
        basis.bindings.fp._MessageParameters_getVec4(thisPtr, returnValue);
    }
}

pub fn MessageParameters_addQuaternion(thisPtr: basis.CppPtr, p: [*c]const basis.bindings.InteropQuaternion) void {
    if (isWasm) {
        const SIZE = 4 * @sizeOf(f32);
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.put(Quaternion, Quaternion.fromInterop(p.*));

        access.MessageParameters_addQuaternion_WASM(thisPtr, &buffer, SIZE);
    } else {
        basis.bindings.fp._MessageParameters_addQuaternion(thisPtr, p);
    }
}

pub fn MessageParameters_getQuaternion(thisPtr: basis.CppPtr, returnValue: [*c]basis.bindings.InteropQuaternion) void {
    if (isWasm) {
        const SIZE = 4 * @sizeOf(f32);
        var buffer: [SIZE]u8 = undefined;

        access.MessageParameters_getQuaternion_WASM(thisPtr, &buffer, SIZE);

        var stream = basis.BinaryReadStream.init(&buffer, true);
        returnValue.* = stream.get(Quaternion).toInterop();
    } else {
        basis.bindings.fp._MessageParameters_getQuaternion(thisPtr, returnValue);
    }
}

pub fn MessageParameters_addString(thisPtr: basis.CppPtr, p: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        access.MessageParameters_addString_WASM(thisPtr, p.*.ptr, p.*.len);
    } else {
        basis.bindings.fp._MessageParameters_addString(thisPtr, p);
    }
}

pub fn MessageParameters_getString(thisPtr: basis.CppPtr, returnValue: [*c]basis.bindings.InteropString) void {
    if (isWasm) {
        const tempMemory = gWASMTempMemoryBuffer.get();
        const length = access.MessageParameters_getString_WASM(thisPtr, tempMemory.ptr, WASMTempMemorySize);
        returnValue.*.ptr = tempMemory.ptr;
        returnValue.*.len = @intCast(length);
    } else {
        basis.bindings.fp._MessageParameters_getString(thisPtr, returnValue);
    }
}

// ===============================

// class MessageNode

pub fn MessageNode_destroy(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.MessageNode_destroy_WASM(cppPtr);
    } else {
        basis.bindings.fp._MessageNode_destroy(cppPtr);
    }
}

pub fn MessageNode_subscribeToMessageCategory(cppPtr: basis.CppPtr, cat: i32) void {
    if (isWasm) {
        access.MessageNode_subscribeToMessageCategory_WASM(cppPtr, cat);
    } else {
        basis.bindings.fp._MessageNode_subscribeToMessageCategory(cppPtr, cat);
    }
}

pub fn MessageNode_allocMsgParams(cppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.MessageNode_allocMsgParams_WASM(cppPtr);
    } else {
        return basis.bindings.fp._MessageNode_allocMsgParams(cppPtr);
    }
}

pub fn MessageNode_sendMessage(cppPtr: basis.CppPtr, message: i32, parameters: basis.CppPtr) void {
    if (isWasm) {
        access.MessageNode_sendMessage_WASM(cppPtr, message, parameters);
    } else {
        basis.bindings.fp._MessageNode_sendMessage(cppPtr, message, parameters);
    }
}

// ===============================

// class InputManager

pub fn InputManager_addGameInputContextToFront(context: u8) void {
    if (isWasm) {
        access.InputManager_addGameInputContextToFront_WASM(context);
    } else {
        basis.bindings.fp._InputManager_addGameInputContextToFront(context);
    }
}

pub fn InputManager_addGameInputContextToBack(context: u8) void {
    if (isWasm) {
        access.InputManager_addGameInputContextToBack_WASM(context);
    } else {
        basis.bindings.fp._InputManager_addGameInputContextToBack(context);
    }
}

pub fn InputManager_isGameInputContextEnabled(context: u8) bool {
    if (isWasm) {
        return access.InputManager_isGameInputContextEnabled_WASM(context);
    } else {
        return basis.bindings.fp._InputManager_isGameInputContextEnabled(context) == 1;
    }
}

pub fn InputManager_removeGameInputContext(context: u8) void {
    if (isWasm) {
        access.InputManager_removeGameInputContext_WASM(context);
    } else {
        basis.bindings.fp._InputManager_removeGameInputContext(context);
    }
}

pub fn InputManager_getNFirstEnabledInputContexts(contexts: [*c]u8, count: u32) u32 {
    if (isWasm) {
        @compileError("InputManager_getNFirstEnabledInputContexts not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._InputManager_getNFirstEnabledInputContexts(contexts, count);
    }
}

pub fn InputManager_isCursorLocked() bool {
    if (isWasm) {
        return access.InputManager_isCursorLocked_WASM();
    } else {
        return basis.bindings.fp._InputManager_isCursorLocked() == 1;
    }
}

pub fn InputManager_lockCursor() void {
    if (isWasm) {
        access.InputManager_lockCursor_WASM();
    } else {
        basis.bindings.fp._InputManager_lockCursor();
    }
}

pub fn InputManager_releaseCursor() void {
    if (isWasm) {
        access.InputManager_releaseCursor_WASM();
    } else {
        basis.bindings.fp._InputManager_releaseCursor();
    }
}

pub fn InputManager_getGameInputMode() i32 {
    if (isWasm) {
        return access.InputManager_getGameInputMode_WASM();
    } else {
        return basis.bindings.fp._InputManager_getGameInputMode();
    }
}

pub fn InputManager_isKeyPressed(keyCode: u32) bool {
    if (isWasm) {
        return access.InputManager_isKeyPressed_WASM(keyCode);
    } else {
        return basis.bindings.fp._InputManager_isKeyPressed(keyCode) == 1;
    }
}

pub fn InputManager_isMouseButtonPressed(id: u32) bool {
    if (isWasm) {
        return access.InputManager_isMouseButtonPressed_WASM(id);
    } else {
        return basis.bindings.fp._InputManager_isMouseButtonPressed(id) == 1;
    }
}

pub fn InputManager_isGamepadButtonDown(button: i32) bool {
    if (isWasm) {
        return access.InputManager_isGamepadButtonDown_WASM(button);
    } else {
        return basis.bindings.fp._InputManager_isGamepadButtonDown(button) == 1;
    }
}

pub fn InputManager_setGamepadVibration(index: i32, lowFrequency: f32, highFrequency: f32) void {
    if (isWasm) {
        access.InputManager_setGamepadVibration_WASM(index, lowFrequency, highFrequency);
    } else {
        basis.bindings.fp._InputManager_setGamepadVibration(index, lowFrequency, highFrequency);
    }
}

pub fn InputManager_getMappedKeyCode(inputID: u16, context: u8, flags: i32, keyCode: [*c]i32) bool {
    if (isWasm) {
        const val = access.InputManager_getMappedKeyCode_WASM(inputID, context, flags);

        if (val == -1) {
            return false;
        }

        keyCode.* = val;
        return true;
    } else {
        return basis.bindings.fp._InputManager_getMappedKeyCode(inputID, context, flags, keyCode) == 1;
    }
}

pub fn InputManager_getMappedMouseButton(inputID: u16, context: u8, flags: i32, mouseButton: [*c]i32) bool {
    if (isWasm) {
        const val = access.InputManager_getMappedMouseButton_WASM(inputID, context, flags);

        if (val == -1) {
            return false;
        }

        mouseButton.* = val;
        return true;
    } else {
        return basis.bindings.fp._InputManager_getMappedMouseButton(inputID, context, flags, mouseButton) == 1;
    }
}

pub fn InputManager_getMappedGamepadButton(inputID: u16, context: u8, flags: i32, gamepadButton: [*c]i32) bool {
    if (isWasm) {
        const val = access.InputManager_getMappedGamepadButton_WASM(inputID, context, flags);

        if (val == -1) {
            return false;
        }

        gamepadButton.* = val;
        return true;
    } else {
        return basis.bindings.fp._InputManager_getMappedGamepadButton(inputID, context, flags, gamepadButton) == 1;
    }
}

pub fn InputManager_getMappedInputSource(inputID: u16, context: u8, flags: i32, gameInputMode: i32, source: [*c]i32) bool {
    if (isWasm) {
        @compileError("InputManager_getMappedInputSource not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._InputManager_getMappedInputSource(inputID, context, flags, gameInputMode, source) == 1;
    }
}

pub fn InputManager_getFirstPressedKey() i32 {
    if (isWasm) {
        @compileError("InputManager_getFirstPressedKey not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._InputManager_getFirstPressedKey();
    }
}

pub fn InputManager_getFirstPressedMouseButton() i32 {
    if (isWasm) {
        @compileError("InputManager_getFirstPressedMouseButton not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._InputManager_getFirstPressedMouseButton();
    }
}

pub fn InputManager_getKeyName(keyCode: u32, buffer: [*c]u8, bufferLen: u32) u32 {
    if (isWasm) {
        @compileError("InputManager_getKeyName not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._InputManager_getKeyName(keyCode, buffer, bufferLen);
    }
}

// ===============================

// class PropagatedValue

fn packPVCreationData(buffer: []u8, reliablePropagation: bool, immediatePropagation: bool, initialValue: anytype) u32 {
    const ValueType = @TypeOf(initialValue);
    const typeID = basis.typeinfo.getTypeID(ValueType);

    var stream = basis.BinaryWriteStream.init(buffer, true);

    stream.putBool(reliablePropagation);
    stream.putBool(immediatePropagation);
    stream.putInt(i32, typeID.asInt());

    switch (ValueType) {
        f32 => stream.putFloat(initialValue),
        i8, u8, i16, u16, i32, u32, i64, u64 => stream.putInt(ValueType, initialValue),
        bool => stream.putBool(initialValue),
        else => stream.put(ValueType, initialValue),
    }

    return @intCast(stream.cursorPosition);
}

pub fn PropagatedValue_createFloat(
    thisPtr: basis.bindings.InteropTypedPtr,
    zigPVPtr: u64,
    name: [*c]const basis.bindings.InteropString,
    reliablePropagation: bool,
    immediatePropagation: bool,
    initialValue: f32,
) basis.CppPtr {
    if (isWasm) {
        var buffer: [64]u8 = undefined;
        const dataSize = packPVCreationData(&buffer, reliablePropagation, immediatePropagation, initialValue);
        return access.PropagatedValue_create_WASM(thisPtr.ptr, thisPtr.type, zigPVPtr, name.*.ptr, name.*.len, &buffer, dataSize);
    } else {
        return basis.bindings.fp._PropagatedValue_createFloat(
            thisPtr,
            zigPVPtr,
            name,
            if (reliablePropagation) 1 else 0,
            if (immediatePropagation) 1 else 0,
            initialValue,
        );
    }
}

pub fn PropagatedValue_createDouble(
    thisPtr: basis.bindings.InteropTypedPtr,
    zigPVPtr: u64,
    name: [*c]const basis.bindings.InteropString,
    reliablePropagation: bool,
    immediatePropagation: bool,
    initialValue: f64,
) basis.CppPtr {
    if (isWasm) {
        @compileError("PropagatedValue_createDouble not implemented for WASM yet.");
        // TODO: putDouble() missing from the stream.
    } else {
        return basis.bindings.fp._PropagatedValue_createDouble(
            thisPtr,
            zigPVPtr,
            name,
            if (reliablePropagation) 1 else 0,
            if (immediatePropagation) 1 else 0,
            initialValue,
        );
    }
}

pub fn PropagatedValue_createInt32(
    thisPtr: basis.bindings.InteropTypedPtr,
    zigPVPtr: u64,
    name: [*c]const basis.bindings.InteropString,
    reliablePropagation: bool,
    immediatePropagation: bool,
    initialValue: i32,
) basis.CppPtr {
    if (isWasm) {
        var buffer: [64]u8 = undefined;
        const dataSize = packPVCreationData(&buffer, reliablePropagation, immediatePropagation, initialValue);
        return access.PropagatedValue_create_WASM(thisPtr.ptr, thisPtr.type, zigPVPtr, name.*.ptr, name.*.len, &buffer, dataSize);
    } else {
        return basis.bindings.fp._PropagatedValue_createInt32(
            thisPtr,
            zigPVPtr,
            name,
            if (reliablePropagation) 1 else 0,
            if (immediatePropagation) 1 else 0,
            initialValue,
        );
    }
}

pub fn PropagatedValue_createUint32(
    thisPtr: basis.bindings.InteropTypedPtr,
    zigPVPtr: u64,
    name: [*c]const basis.bindings.InteropString,
    reliablePropagation: bool,
    immediatePropagation: bool,
    initialValue: u32,
) basis.CppPtr {
    if (isWasm) {
        var buffer: [64]u8 = undefined;
        const dataSize = packPVCreationData(&buffer, reliablePropagation, immediatePropagation, initialValue);
        return access.PropagatedValue_create_WASM(thisPtr.ptr, thisPtr.type, zigPVPtr, name.*.ptr, name.*.len, &buffer, dataSize);
    } else {
        return basis.bindings.fp._PropagatedValue_createUint32(
            thisPtr,
            zigPVPtr,
            name,
            if (reliablePropagation) 1 else 0,
            if (immediatePropagation) 1 else 0,
            initialValue,
        );
    }
}

pub fn PropagatedValue_createInt16(
    thisPtr: basis.bindings.InteropTypedPtr,
    zigPVPtr: u64,
    name: [*c]const basis.bindings.InteropString,
    reliablePropagation: bool,
    immediatePropagation: bool,
    initialValue: i16,
) basis.CppPtr {
    if (isWasm) {
        var buffer: [64]u8 = undefined;
        const dataSize = packPVCreationData(&buffer, reliablePropagation, immediatePropagation, initialValue);
        return access.PropagatedValue_create_WASM(thisPtr.ptr, thisPtr.type, zigPVPtr, name.*.ptr, name.*.len, &buffer, dataSize);
    } else {
        return basis.bindings.fp._PropagatedValue_createInt16(
            thisPtr,
            zigPVPtr,
            name,
            if (reliablePropagation) 1 else 0,
            if (immediatePropagation) 1 else 0,
            initialValue,
        );
    }
}

pub fn PropagatedValue_createUint16(
    thisPtr: basis.bindings.InteropTypedPtr,
    zigPVPtr: u64,
    name: [*c]const basis.bindings.InteropString,
    reliablePropagation: bool,
    immediatePropagation: bool,
    initialValue: u16,
) basis.CppPtr {
    if (isWasm) {
        var buffer: [64]u8 = undefined;
        const dataSize = packPVCreationData(&buffer, reliablePropagation, immediatePropagation, initialValue);
        return access.PropagatedValue_create_WASM(thisPtr.ptr, thisPtr.type, zigPVPtr, name.*.ptr, name.*.len, &buffer, dataSize);
    } else {
        return basis.bindings.fp._PropagatedValue_createUint16(
            thisPtr,
            zigPVPtr,
            name,
            if (reliablePropagation) 1 else 0,
            if (immediatePropagation) 1 else 0,
            initialValue,
        );
    }
}

pub fn PropagatedValue_createInt64(
    thisPtr: basis.bindings.InteropTypedPtr,
    zigPVPtr: u64,
    name: [*c]const basis.bindings.InteropString,
    reliablePropagation: bool,
    immediatePropagation: bool,
    initialValue: i64,
) basis.CppPtr {
    if (isWasm) {
        var buffer: [64]u8 = undefined;
        const dataSize = packPVCreationData(&buffer, reliablePropagation, immediatePropagation, initialValue);
        return access.PropagatedValue_create_WASM(thisPtr.ptr, thisPtr.type, zigPVPtr, name.*.ptr, name.*.len, &buffer, dataSize);
    } else {
        return basis.bindings.fp._PropagatedValue_createInt64(
            thisPtr,
            zigPVPtr,
            name,
            if (reliablePropagation) 1 else 0,
            if (immediatePropagation) 1 else 0,
            initialValue,
        );
    }
}

pub fn PropagatedValue_createUint64(
    thisPtr: basis.bindings.InteropTypedPtr,
    zigPVPtr: u64,
    name: [*c]const basis.bindings.InteropString,
    reliablePropagation: bool,
    immediatePropagation: bool,
    initialValue: u64,
) basis.CppPtr {
    if (isWasm) {
        var buffer: [64]u8 = undefined;
        const dataSize = packPVCreationData(&buffer, reliablePropagation, immediatePropagation, initialValue);
        return access.PropagatedValue_create_WASM(thisPtr.ptr, thisPtr.type, zigPVPtr, name.*.ptr, name.*.len, &buffer, dataSize);
    } else {
        return basis.bindings.fp._PropagatedValue_createUint64(
            thisPtr,
            zigPVPtr,
            name,
            if (reliablePropagation) 1 else 0,
            if (immediatePropagation) 1 else 0,
            initialValue,
        );
    }
}

pub fn PropagatedValue_createInt8(
    thisPtr: basis.bindings.InteropTypedPtr,
    zigPVPtr: u64,
    name: [*c]const basis.bindings.InteropString,
    reliablePropagation: bool,
    immediatePropagation: bool,
    initialValue: i8,
) basis.CppPtr {
    if (isWasm) {
        var buffer: [64]u8 = undefined;
        const dataSize = packPVCreationData(&buffer, reliablePropagation, immediatePropagation, initialValue);
        return access.PropagatedValue_create_WASM(thisPtr.ptr, thisPtr.type, zigPVPtr, name.*.ptr, name.*.len, &buffer, dataSize);
    } else {
        return basis.bindings.fp._PropagatedValue_createInt8(
            thisPtr,
            zigPVPtr,
            name,
            if (reliablePropagation) 1 else 0,
            if (immediatePropagation) 1 else 0,
            initialValue,
        );
    }
}

pub fn PropagatedValue_createUint8(
    thisPtr: basis.bindings.InteropTypedPtr,
    zigPVPtr: u64,
    name: [*c]const basis.bindings.InteropString,
    reliablePropagation: bool,
    immediatePropagation: bool,
    initialValue: u8,
) basis.CppPtr {
    if (isWasm) {
        var buffer: [64]u8 = undefined;
        const dataSize = packPVCreationData(&buffer, reliablePropagation, immediatePropagation, initialValue);
        return access.PropagatedValue_create_WASM(thisPtr.ptr, thisPtr.type, zigPVPtr, name.*.ptr, name.*.len, &buffer, dataSize);
    } else {
        return basis.bindings.fp._PropagatedValue_createUint8(
            thisPtr,
            zigPVPtr,
            name,
            if (reliablePropagation) 1 else 0,
            if (immediatePropagation) 1 else 0,
            initialValue,
        );
    }
}

pub fn PropagatedValue_createBool(
    thisPtr: basis.bindings.InteropTypedPtr,
    zigPVPtr: u64,
    name: [*c]const basis.bindings.InteropString,
    reliablePropagation: bool,
    immediatePropagation: bool,
    initialValue: bool,
) basis.CppPtr {
    if (isWasm) {
        var buffer: [64]u8 = undefined;
        const dataSize = packPVCreationData(&buffer, reliablePropagation, immediatePropagation, initialValue);
        return access.PropagatedValue_create_WASM(thisPtr.ptr, thisPtr.type, zigPVPtr, name.*.ptr, name.*.len, &buffer, dataSize);
    } else {
        return basis.bindings.fp._PropagatedValue_createBool(
            thisPtr,
            zigPVPtr,
            name,
            if (reliablePropagation) 1 else 0,
            if (immediatePropagation) 1 else 0,
            if (initialValue) 1 else 0,
        );
    }
}

pub fn PropagatedValue_createVec2(
    thisPtr: basis.bindings.InteropTypedPtr,
    zigPVPtr: u64,
    name: [*c]const basis.bindings.InteropString,
    reliablePropagation: bool,
    immediatePropagation: bool,
    initialValue: [*c]const basis.bindings.InteropVec2,
) basis.CppPtr {
    if (isWasm) {
        var buffer: [64]u8 = undefined;
        const dataSize = packPVCreationData(&buffer, reliablePropagation, immediatePropagation, Vec2.fromInterop(initialValue.*));
        return access.PropagatedValue_create_WASM(thisPtr.ptr, thisPtr.type, zigPVPtr, name.*.ptr, name.*.len, &buffer, dataSize);
    } else {
        return basis.bindings.fp._PropagatedValue_createVec2(
            thisPtr,
            zigPVPtr,
            name,
            if (reliablePropagation) 1 else 0,
            if (immediatePropagation) 1 else 0,
            initialValue,
        );
    }
}

pub fn PropagatedValue_createVec3(
    thisPtr: basis.bindings.InteropTypedPtr,
    zigPVPtr: u64,
    name: [*c]const basis.bindings.InteropString,
    reliablePropagation: bool,
    immediatePropagation: bool,
    initialValue: [*c]const basis.bindings.InteropVec3,
) basis.CppPtr {
    if (isWasm) {
        var buffer: [64]u8 = undefined;
        const dataSize = packPVCreationData(&buffer, reliablePropagation, immediatePropagation, Vec3.fromInterop(initialValue.*));
        return access.PropagatedValue_create_WASM(thisPtr.ptr, thisPtr.type, zigPVPtr, name.*.ptr, name.*.len, &buffer, dataSize);
    } else {
        return basis.bindings.fp._PropagatedValue_createVec3(
            thisPtr,
            zigPVPtr,
            name,
            if (reliablePropagation) 1 else 0,
            if (immediatePropagation) 1 else 0,
            initialValue,
        );
    }
}

pub fn PropagatedValue_createVec4(
    thisPtr: basis.bindings.InteropTypedPtr,
    zigPVPtr: u64,
    name: [*c]const basis.bindings.InteropString,
    reliablePropagation: bool,
    immediatePropagation: bool,
    initialValue: [*c]const basis.bindings.InteropVec4,
) basis.CppPtr {
    if (isWasm) {
        var buffer: [64]u8 = undefined;
        const dataSize = packPVCreationData(&buffer, reliablePropagation, immediatePropagation, Vec4.fromInterop(initialValue.*));
        return access.PropagatedValue_create_WASM(thisPtr.ptr, thisPtr.type, zigPVPtr, name.*.ptr, name.*.len, &buffer, dataSize);
    } else {
        return basis.bindings.fp._PropagatedValue_createVec4(
            thisPtr,
            zigPVPtr,
            name,
            if (reliablePropagation) 1 else 0,
            if (immediatePropagation) 1 else 0,
            initialValue,
        );
    }
}

pub fn PropagatedValue_createQuaternion(
    thisPtr: basis.bindings.InteropTypedPtr,
    zigPVPtr: u64,
    name: [*c]const basis.bindings.InteropString,
    reliablePropagation: bool,
    immediatePropagation: bool,
    initialValue: [*c]const basis.bindings.InteropQuaternion,
) basis.CppPtr {
    if (isWasm) {
        var buffer: [64]u8 = undefined;
        const dataSize = packPVCreationData(&buffer, reliablePropagation, immediatePropagation, Quaternion.fromInterop(initialValue.*));
        return access.PropagatedValue_create_WASM(thisPtr.ptr, thisPtr.type, zigPVPtr, name.*.ptr, name.*.len, &buffer, dataSize);
    } else {
        return basis.bindings.fp._PropagatedValue_createQuaternion(
            thisPtr,
            zigPVPtr,
            name,
            if (reliablePropagation) 1 else 0,
            if (immediatePropagation) 1 else 0,
            initialValue,
        );
    }
}

pub fn PropagatedValue_createMat43(
    thisPtr: basis.bindings.InteropTypedPtr,
    zigPVPtr: u64,
    name: [*c]const basis.bindings.InteropString,
    reliablePropagation: bool,
    immediatePropagation: bool,
    initialValue: [*c]const basis.bindings.InteropMat43,
) basis.CppPtr {
    if (isWasm) {
        // TODO: The creation is done, but unsure how to actually send over the Mat43 in ZigWamrLibrary::PV_updateMat43()...
        @compileError("PropagatedValue_createMat43 not implemented for WASM yet.");

        //var buffer: [64]u8 = undefined;
        //const dataSize = packPVCreationData(&buffer, reliablePropagation, immediatePropagation, Mat43.fromInterop(initialValue.*));
        //return access.PropagatedValue_create_WASM(thisPtr.ptr, thisPtr.type, zigPVPtr, name.*.ptr, name.*.len, &buffer, dataSize);
    } else {
        return basis.bindings.fp._PropagatedValue_createMat43(
            thisPtr,
            zigPVPtr,
            name,
            if (reliablePropagation) 1 else 0,
            if (immediatePropagation) 1 else 0,
            initialValue,
        );
    }
}

fn packPVData(buffer: []u8, value: anytype) u32 {
    const ValueType = @TypeOf(value);
    const typeID = basis.typeinfo.getTypeID(ValueType);
    var stream = basis.BinaryWriteStream.init(buffer, true);
    stream.putInt(i32, typeID.asInt());

    switch (ValueType) {
        f32 => stream.putFloat(value),
        i8, u8, i16, u16, i32, u32, i64, u64 => stream.putInt(ValueType, value),
        bool => stream.putBool(value),
        else => stream.put(ValueType, value),
    }

    return @intCast(stream.cursorPosition);
}

pub fn PropagatedValue_setFloat(cppPVPtr: basis.CppPtr, value: f32) void {
    if (isWasm) {
        var buffer: [64]u8 = undefined;
        const dataSize = packPVData(&buffer, value);
        access.PropagatedValue_set_WASM(cppPVPtr, &buffer, dataSize);
    } else {
        basis.bindings.fp._PropagatedValue_setFloat(cppPVPtr, value);
    }
}

pub fn PropagatedValue_setDouble(cppPVPtr: basis.CppPtr, value: f64) void {
    if (isWasm) {
        @compileError("PropagatedValue_setDouble not implemented for WASM yet.");
        // TODO: putDouble() missing from the stream.
    } else {
        basis.bindings.fp._PropagatedValue_setDouble(cppPVPtr, value);
    }
}

pub fn PropagatedValue_setInt32(cppPVPtr: basis.CppPtr, value: i32) void {
    if (isWasm) {
        var buffer: [64]u8 = undefined;
        const dataSize = packPVData(&buffer, value);
        access.PropagatedValue_set_WASM(cppPVPtr, &buffer, dataSize);
    } else {
        basis.bindings.fp._PropagatedValue_setInt32(cppPVPtr, value);
    }
}

pub fn PropagatedValue_setUint32(cppPVPtr: basis.CppPtr, value: u32) void {
    if (isWasm) {
        var buffer: [64]u8 = undefined;
        const dataSize = packPVData(&buffer, value);
        access.PropagatedValue_set_WASM(cppPVPtr, &buffer, dataSize);
    } else {
        basis.bindings.fp._PropagatedValue_setUint32(cppPVPtr, value);
    }
}

pub fn PropagatedValue_setInt16(cppPVPtr: basis.CppPtr, value: i16) void {
    if (isWasm) {
        var buffer: [64]u8 = undefined;
        const dataSize = packPVData(&buffer, value);
        access.PropagatedValue_set_WASM(cppPVPtr, &buffer, dataSize);
    } else {
        basis.bindings.fp._PropagatedValue_setInt16(cppPVPtr, value);
    }
}

pub fn PropagatedValue_setUint16(cppPVPtr: basis.CppPtr, value: u16) void {
    if (isWasm) {
        var buffer: [64]u8 = undefined;
        const dataSize = packPVData(&buffer, value);
        access.PropagatedValue_set_WASM(cppPVPtr, &buffer, dataSize);
    } else {
        basis.bindings.fp._PropagatedValue_setUint16(cppPVPtr, value);
    }
}

pub fn PropagatedValue_setInt64(cppPVPtr: basis.CppPtr, value: i64) void {
    if (isWasm) {
        var buffer: [64]u8 = undefined;
        const dataSize = packPVData(&buffer, value);
        access.PropagatedValue_set_WASM(cppPVPtr, &buffer, dataSize);
    } else {
        basis.bindings.fp._PropagatedValue_setInt64(cppPVPtr, value);
    }
}

pub fn PropagatedValue_setUint64(cppPVPtr: basis.CppPtr, value: u64) void {
    if (isWasm) {
        var buffer: [64]u8 = undefined;
        const dataSize = packPVData(&buffer, value);
        access.PropagatedValue_set_WASM(cppPVPtr, &buffer, dataSize);
    } else {
        basis.bindings.fp._PropagatedValue_setUint64(cppPVPtr, value);
    }
}

pub fn PropagatedValue_setInt8(cppPVPtr: basis.CppPtr, value: i8) void {
    if (isWasm) {
        var buffer: [64]u8 = undefined;
        const dataSize = packPVData(&buffer, value);
        access.PropagatedValue_set_WASM(cppPVPtr, &buffer, dataSize);
    } else {
        basis.bindings.fp._PropagatedValue_setInt8(cppPVPtr, value);
    }
}

pub fn PropagatedValue_setUint8(cppPVPtr: basis.CppPtr, value: u8) void {
    if (isWasm) {
        var buffer: [64]u8 = undefined;
        const dataSize = packPVData(&buffer, value);
        access.PropagatedValue_set_WASM(cppPVPtr, &buffer, dataSize);
    } else {
        basis.bindings.fp._PropagatedValue_setUint8(cppPVPtr, value);
    }
}

pub fn PropagatedValue_setBool(cppPVPtr: basis.CppPtr, value: bool) void {
    if (isWasm) {
        var buffer: [64]u8 = undefined;
        const dataSize = packPVData(&buffer, value);
        access.PropagatedValue_set_WASM(cppPVPtr, &buffer, dataSize);
    } else {
        basis.bindings.fp._PropagatedValue_setBool(cppPVPtr, if (value) 1 else 0);
    }
}

pub fn PropagatedValue_setVec2(cppPVPtr: basis.CppPtr, value: [*c]const basis.bindings.InteropVec2) void {
    if (isWasm) {
        var buffer: [64]u8 = undefined;
        const dataSize = packPVData(&buffer, Vec2.fromInterop(value.*));
        access.PropagatedValue_set_WASM(cppPVPtr, &buffer, dataSize);
    } else {
        basis.bindings.fp._PropagatedValue_setVec2(cppPVPtr, value);
    }
}

pub fn PropagatedValue_setVec3(cppPVPtr: basis.CppPtr, value: [*c]const basis.bindings.InteropVec3) void {
    if (isWasm) {
        var buffer: [64]u8 = undefined;
        const dataSize = packPVData(&buffer, Vec3.fromInterop(value.*));
        access.PropagatedValue_set_WASM(cppPVPtr, &buffer, dataSize);
    } else {
        basis.bindings.fp._PropagatedValue_setVec3(cppPVPtr, value);
    }
}

pub fn PropagatedValue_setVec4(cppPVPtr: basis.CppPtr, value: [*c]const basis.bindings.InteropVec4) void {
    if (isWasm) {
        var buffer: [64]u8 = undefined;
        const dataSize = packPVData(&buffer, Vec4.fromInterop(value.*));
        access.PropagatedValue_set_WASM(cppPVPtr, &buffer, dataSize);
    } else {
        basis.bindings.fp._PropagatedValue_setVec4(cppPVPtr, value);
    }
}

pub fn PropagatedValue_setQuaternion(cppPVPtr: basis.CppPtr, value: [*c]const basis.bindings.InteropQuaternion) void {
    if (isWasm) {
        var buffer: [64]u8 = undefined;
        const dataSize = packPVData(&buffer, Quaternion.fromInterop(value.*));
        access.PropagatedValue_set_WASM(cppPVPtr, &buffer, dataSize);
    } else {
        basis.bindings.fp._PropagatedValue_setQuaternion(cppPVPtr, value);
    }
}

pub fn PropagatedValue_setMat43(cppPVPtr: basis.CppPtr, value: [*c]const basis.bindings.InteropMat43) void {
    if (isWasm) {
        var buffer: [64]u8 = undefined;
        const dataSize = packPVData(&buffer, Mat43.fromInterop(value.*));
        access.PropagatedValue_set_WASM(cppPVPtr, &buffer, dataSize);
    } else {
        basis.bindings.fp._PropagatedValue_setMat43(cppPVPtr, value);
    }
}

pub fn PropagatedValue_createAction(
    thisPtr: basis.bindings.InteropTypedPtr,
    zigPAPtr: u64,
    name: [*c]const basis.bindings.InteropString,
    reliablePropagation: bool,
    immediatePropagation: bool,
) basis.CppPtr {
    if (isWasm) {
        return access.PropagatedValue_createAction_WASM(
            thisPtr.ptr,
            thisPtr.type,
            zigPAPtr,
            name.*.ptr,
            name.*.len,
            reliablePropagation,
            immediatePropagation,
        );
    } else {
        return basis.bindings.fp._PropagatedValue_createAction(
            thisPtr,
            zigPAPtr,
            name,
            if (reliablePropagation) 1 else 0,
            if (immediatePropagation) 1 else 0,
        );
    }
}

pub fn PropagatedValue_fireAction(cppPAPtr: basis.CppPtr) void {
    if (isWasm) {
        access.PropagatedValue_fireAction_WASM(cppPAPtr);
    } else {
        basis.bindings.fp._PropagatedValue_fireAction(cppPAPtr);
    }
}

// ===============================

// class SceneNode

pub fn SceneNode_newNode() u64 {
    if (isWasm) {
        return access.SceneNode_newNode_WASM();
    } else {
        return basis.bindings.fp._SceneNode_newNode();
    }
}

pub fn SceneNode_deleteNode(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.SceneNode_deleteNode_WASM(cppPtr);
    } else {
        basis.bindings.fp._SceneNode_deleteNode(cppPtr);
    }
}

pub fn SceneNode_createChildNode(cppPtr: basis.CppPtr) u64 {
    if (isWasm) {
        return access.SceneNode_createChildNode_WASM(cppPtr);
    } else {
        return basis.bindings.fp._SceneNode_createChildNode(cppPtr);
    }
}

pub fn SceneNode_destroyChildNode(cppPtr: basis.CppPtr, cppChildPtr: u64) void {
    if (isWasm) {
        access.SceneNode_destroyChildNode_WASM(cppChildPtr, cppChildPtr);
    } else {
        basis.bindings.fp._SceneNode_destroyChildNode(cppPtr, cppChildPtr);
    }
}

pub fn SceneNode_detachAll(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.SceneNode_detachAll_WASM(cppPtr);
    } else {
        basis.bindings.fp._SceneNode_detachAll(cppPtr);
    }
}

pub fn SceneNode_destroyAllChildNodes(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.SceneNode_destroyAllChildNodes_WASM(cppPtr);
    } else {
        basis.bindings.fp._SceneNode_destroyAllChildNodes(cppPtr);
    }
}

pub fn SceneNode_setPosition(cppPtr: basis.CppPtr, position: [*c]const basis.bindings.InteropVec3, space: c_int, immediateUpdate: bool) void {
    if (isWasm) {
        const SIZE = (3 * @sizeOf(f32)) + @sizeOf(i32) + 1;
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.put(Vec3, Vec3.fromInterop(position.*));
        stream.putInt(i32, @intCast(space));
        stream.putBool(immediateUpdate);

        access.SceneNode_setPosition_WASM(cppPtr, &buffer, SIZE);
    } else {
        basis.bindings.fp._SceneNode_setPosition(cppPtr, position, space, if (immediateUpdate) 1 else 0);
    }
}

pub fn SceneNode_getPosition(cppPtr: basis.CppPtr, space: c_int, returnValue: [*c]basis.bindings.InteropVec3) void {
    if (isWasm) {
        const SIZE = 3 * @sizeOf(f32);
        var buffer: [SIZE]u8 = undefined;

        access.SceneNode_getPosition_WASM(cppPtr, @intCast(space), &buffer, SIZE);
        var stream = basis.BinaryReadStream.init(&buffer, true);
        const v = stream.get(Vec3);
        returnValue.* = v.toInterop();
    } else {
        basis.bindings.fp._SceneNode_getPosition(cppPtr, space, returnValue);
    }
}

pub fn SceneNode_setOrientation(cppPtr: basis.CppPtr, orientation: [*c]const basis.bindings.InteropQuaternion, space: c_int, immediateUpdate: bool) void {
    if (isWasm) {
        const SIZE = (4 * @sizeOf(f32)) + @sizeOf(i32) + 1;
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.put(Quaternion, Quaternion.fromInterop(orientation.*));
        stream.putInt(i32, @intCast(space));
        stream.putBool(immediateUpdate);

        access.SceneNode_setOrientation_WASM(cppPtr, &buffer, SIZE);
    } else {
        basis.bindings.fp._SceneNode_setOrientation(cppPtr, orientation, space, if (immediateUpdate) 1 else 0);
    }
}

pub fn SceneNode_getOrientation(cppPtr: basis.CppPtr, space: c_int, returnValue: [*c]basis.bindings.InteropQuaternion) void {
    if (isWasm) {
        const SIZE = 4 * @sizeOf(f32);
        var buffer: [SIZE]u8 = undefined;

        access.SceneNode_getOrientation_WASM(cppPtr, @intCast(space), &buffer, SIZE);
        var stream = basis.BinaryReadStream.init(&buffer, true);
        const v = stream.get(Quaternion);
        returnValue.* = v.toInterop();
    } else {
        basis.bindings.fp._SceneNode_getOrientation(cppPtr, space, returnValue);
    }
}

pub fn SceneNode_setScale(cppPtr: basis.CppPtr, scale: [*c]const basis.bindings.InteropVec3, immediateUpdate: bool) void {
    if (isWasm) {
        const SIZE = (3 * @sizeOf(f32)) + 1;
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.put(Vec3, Vec3.fromInterop(scale.*));
        stream.putBool(immediateUpdate);

        access.SceneNode_setScale_WASM(cppPtr, &buffer, SIZE);
    } else {
        basis.bindings.fp._SceneNode_setScale(cppPtr, scale, if (immediateUpdate) 1 else 0);
    }
}

pub fn SceneNode_getScale(cppPtr: basis.CppPtr, returnValue: [*c]basis.bindings.InteropVec3) void {
    if (isWasm) {
        const SIZE = 3 * @sizeOf(f32);
        var buffer: [SIZE]u8 = undefined;

        access.SceneNode_getScale_WASM(cppPtr, &buffer, SIZE);
        var stream = basis.BinaryReadStream.init(&buffer, true);
        const v = stream.get(Vec3);
        returnValue.* = v.toInterop();
    } else {
        basis.bindings.fp._SceneNode_getScale(cppPtr, returnValue);
    }
}

pub fn SceneNode_translate(cppPtr: basis.CppPtr, translation: [*c]const basis.bindings.InteropVec3, space: c_int, immediateUpdate: bool) void {
    if (isWasm) {
        const SIZE = (3 * @sizeOf(f32)) + @sizeOf(i32) + 1;
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.put(Vec3, Vec3.fromInterop(translation.*));
        stream.putInt(i32, @intCast(space));
        stream.putBool(immediateUpdate);

        access.SceneNode_translate_WASM(cppPtr, &buffer, SIZE);
    } else {
        basis.bindings.fp._SceneNode_translate(cppPtr, translation, space, if (immediateUpdate) 1 else 0);
    }
}

pub fn SceneNode_yaw(cppPtr: basis.CppPtr, angle: f32, space: c_int, immediateUpdate: bool) void {
    if (isWasm) {
        access.SceneNode_yaw_WASM(cppPtr, angle, space, immediateUpdate);
    } else {
        basis.bindings.fp._SceneNode_yaw(cppPtr, angle, space, if (immediateUpdate) 1 else 0);
    }
}

pub fn SceneNode_pitch(cppPtr: basis.CppPtr, angle: f32, space: c_int, immediateUpdate: bool) void {
    if (isWasm) {
        access.SceneNode_pitch_WASM(cppPtr, angle, space, immediateUpdate);
    } else {
        basis.bindings.fp._SceneNode_pitch(cppPtr, angle, space, if (immediateUpdate) 1 else 0);
    }
}

pub fn SceneNode_roll(cppPtr: basis.CppPtr, angle: f32, space: c_int, immediateUpdate: bool) void {
    if (isWasm) {
        access.SceneNode_roll_WASM(cppPtr, angle, space, immediateUpdate);
    } else {
        basis.bindings.fp._SceneNode_roll(cppPtr, angle, space, if (immediateUpdate) 1 else 0);
    }
}

pub fn SceneNode_lookAtSceneNode(cppPtr: basis.CppPtr, targetCppPtr: basis.CppPtr, immediateUpdate: bool) void {
    if (isWasm) {
        access.SceneNode_lookAtSceneNode_WASM(cppPtr, targetCppPtr, immediateUpdate);
    } else {
        basis.bindings.fp._SceneNode_lookAtSceneNode(cppPtr, targetCppPtr, if (immediateUpdate) 1 else 0);
    }
}

pub fn SceneNode_attachMeshInstance(cppPtr: basis.CppPtr, meshInstanceCppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.SceneNode_attachMeshInstance_WASM(cppPtr, meshInstanceCppPtr);
    } else {
        basis.bindings.fp._SceneNode_attachMeshInstance(cppPtr, meshInstanceCppPtr);
    }
}

pub fn SceneNode_detachMeshInstance(cppPtr: basis.CppPtr, meshInstanceCppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.SceneNode_detachMeshInstance_WASM(cppPtr, meshInstanceCppPtr);
    } else {
        basis.bindings.fp._SceneNode_detachMeshInstance(cppPtr, meshInstanceCppPtr);
    }
}

pub fn SceneNode_isMeshInstanceAttached(cppPtr: basis.CppPtr, meshInstanceCppPtr: basis.CppPtr) i32 {
    if (isWasm) {
        return access.SceneNode_isMeshInstanceAttached_WASM(cppPtr, meshInstanceCppPtr);
    } else {
        return basis.bindings.fp._SceneNode_isMeshInstanceAttached(cppPtr, meshInstanceCppPtr);
    }
}

pub fn SceneNode_attachCamera(cppPtr: basis.CppPtr, cameraCppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.SceneNode_attachCamera_WASM(cppPtr, cameraCppPtr);
    } else {
        basis.bindings.fp._SceneNode_attachCamera(cppPtr, cameraCppPtr);
    }
}

pub fn SceneNode_detachCamera(cppPtr: basis.CppPtr, cameraCppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.SceneNode_detachCamera_WASM(cppPtr, cameraCppPtr);
    } else {
        basis.bindings.fp._SceneNode_detachCamera(cppPtr, cameraCppPtr);
    }
}

pub fn SceneNode_isCameraAttached(cppPtr: basis.CppPtr, cameraCppPtr: basis.CppPtr) i32 {
    if (isWasm) {
        return access.SceneNode_isCameraAttached_WASM(cppPtr, cameraCppPtr);
    } else {
        return basis.bindings.fp._SceneNode_isCameraAttached(cppPtr, cameraCppPtr);
    }
}

pub fn SceneNode_getLocalToParentTransform(cppPtr: basis.CppPtr, returnValue: [*c]basis.bindings.InteropMat43) void {
    if (isWasm) {
        const SIZE = 4 * 3 * @sizeOf(u32);
        var buffer: [SIZE]u8 = undefined;

        access.SceneNode_getLocalToParentTransform_WASM(cppPtr, &buffer, SIZE);

        var stream = basis.BinaryReadStream.init(&buffer, true);
        returnValue.* = stream.get(basis.math.Mat43).toInterop();
    } else {
        basis.bindings.fp._SceneNode_getLocalToParentTransform(cppPtr, returnValue);
    }
}

pub fn SceneNode_getLocalToWorldTransform(cppPtr: basis.CppPtr, returnValue: [*c]basis.bindings.InteropMat43) void {
    if (isWasm) {
        const SIZE = 4 * 3 * @sizeOf(u32);
        var buffer: [SIZE]u8 = undefined;

        access.SceneNode_getLocalToWorldTransform_WASM(cppPtr, &buffer, SIZE);

        var stream = basis.BinaryReadStream.init(&buffer, true);
        returnValue.* = stream.get(basis.math.Mat43).toInterop();
    } else {
        basis.bindings.fp._SceneNode_getLocalToWorldTransform(cppPtr, returnValue);
    }
}

pub fn SceneNode_getLocalToAncestorTransform(cppPtr: basis.CppPtr, ancestorCppPtr: u64, returnValue: [*c]basis.bindings.InteropMat43) void {
    if (isWasm) {
        const SIZE = 4 * 3 * @sizeOf(u32);
        var buffer: [SIZE]u8 = undefined;

        access.SceneNode_getLocalToAncestorTransform_WASM(cppPtr, ancestorCppPtr, &buffer, SIZE);

        var stream = basis.BinaryReadStream.init(&buffer, true);
        returnValue.* = stream.get(basis.math.Mat43).toInterop();
    } else {
        basis.bindings.fp._SceneNode_getLocalToAncestorTransform(cppPtr, ancestorCppPtr, returnValue);
    }
}

// ===============================

// class PhysicsScene

pub fn PhysicsScene_addActor(sceneCppPtr: basis.CppPtr, actorCppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.PhysicsScene_addActor_WASM(sceneCppPtr, actorCppPtr);
    } else {
        basis.bindings.fp._PhysicsScene_addActor(sceneCppPtr, actorCppPtr);
    }
}

pub fn PhysicsScene_removeActor(sceneCppPtr: basis.CppPtr, actorCppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.PhysicsScene_removeActor_WASM(sceneCppPtr, actorCppPtr);
    } else {
        basis.bindings.fp._PhysicsScene_removeActor(sceneCppPtr, actorCppPtr);
    }
}

pub fn PhysicsScene_addVehicleController(sceneCppPtr: basis.CppPtr, vehicleControllerCppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.PhysicsScene_addVehicleController_WASM(sceneCppPtr, vehicleControllerCppPtr);
    } else {
        basis.bindings.fp._PhysicsScene_addVehicleController(sceneCppPtr, vehicleControllerCppPtr);
    }
}

pub fn PhysicsScene_removeVehicleController(sceneCppPtr: basis.CppPtr, vehicleControllerCppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.PhysicsScene_removeVehicleController_WASM(sceneCppPtr, vehicleControllerCppPtr);
    } else {
        basis.bindings.fp._PhysicsScene_removeVehicleController(sceneCppPtr, vehicleControllerCppPtr);
    }
}

pub fn PhysicsScene_addJoint(sceneCppPtr: basis.CppPtr, jointCppPtr: basis.CppPtr, jointType: u32) void {
    if (isWasm) {
        access.PhysicsScene_addJoint_WASM(sceneCppPtr, jointCppPtr, jointType);
    } else {
        basis.bindings.fp._PhysicsScene_addJoint(sceneCppPtr, jointCppPtr, jointType);
    }
}

pub fn PhysicsScene_removeJoint(sceneCppPtr: basis.CppPtr, jointCppPtr: basis.CppPtr, jointType: u32) void {
    if (isWasm) {
        access.PhysicsScene_removeJoint_WASM(sceneCppPtr, jointCppPtr, jointType);
    } else {
        basis.bindings.fp._PhysicsScene_removeJoint(sceneCppPtr, jointCppPtr, jointType);
    }
}

pub fn PhysicsScene_applyRadialForce(sceneCppPtr: basis.CppPtr, center: [*c]const basis.bindings.InteropVec3, radius: f32, strength: f32, falloff: u32, accelerationChange: bool) void {
    if (isWasm) {
        const SIZE = (3 * @sizeOf(f32)) + @sizeOf(f32) + @sizeOf(f32) + @sizeOf(u32) + 1;
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.put(Vec3, Vec3.fromInterop(center.*));
        stream.putFloat(radius);
        stream.putFloat(strength);
        stream.putInt(u32, falloff);
        stream.putBool(accelerationChange);

        access.PhysicsScene_applyRadialForce_WASM(sceneCppPtr, &buffer, SIZE);
    } else {
        basis.bindings.fp._PhysicsScene_applyRadialForce(sceneCppPtr, center, radius, strength, falloff, if (accelerationChange) 1 else 0);
    }
}

pub fn PhysicsScene_applyRadialImpulse(sceneCppPtr: basis.CppPtr, center: [*c]const basis.bindings.InteropVec3, radius: f32, strength: f32, falloff: u32, velocityChange: bool) void {
    if (isWasm) {
        const SIZE = (3 * @sizeOf(f32)) + @sizeOf(f32) + @sizeOf(f32) + @sizeOf(u32) + 1;
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.put(Vec3, Vec3.fromInterop(center.*));
        stream.putFloat(radius);
        stream.putFloat(strength);
        stream.putInt(u32, falloff);
        stream.putBool(velocityChange);

        access.PhysicsScene_applyRadialImpulse_WASM(sceneCppPtr, &buffer, SIZE);
    } else {
        basis.bindings.fp._PhysicsScene_applyRadialImpulse(sceneCppPtr, center, radius, strength, falloff, if (velocityChange) 1 else 0);
    }
}

pub fn PhysicsScene_sphereSweep(
    sceneCppPtr: basis.CppPtr,
    sphereRadius: f32,
    origin: [*c]const basis.bindings.InteropVec3,
    direction: [*c]const basis.bindings.InteropVec3,
    maxDistance: f32,
    result: [*c]basis.bindings.PhysicsInteropRayCastResult,
) c_int {
    if (isWasm) {
        var buffer: [128]u8 = undefined;

        var writePos: usize = 0;
        {
            var stream = basis.BinaryWriteStream.init(&buffer, true);
            stream.putFloat(sphereRadius);
            stream.put(Vec3, Vec3.fromInterop(origin));
            stream.put(Vec3, Vec3.fromInterop(direction));
            stream.putFloat(maxDistance);
            writePos = @intCast(stream.cursorPosition);
        }

        const ret = access.PhysicsScene_sphereSweep_WASM(sceneCppPtr, &buffer, writePos);

        if (ret == 1) {
            var stream = basis.BinaryReadStream.init(&buffer, true);

            result.*.hitPoint = stream.get(Vec3).toInterop();
            result.*.hitPointNormal = stream.get(Vec3).toInterop();
            result.*.distance = stream.getFloat();
            result.*.hitGameObjectCppPtr = stream.getInt(usize);
            result.*.hitPhysicsActorCppPtr = stream.getInt(usize);
            result.*.hitPhysicsActorType = stream.getInt(u32);
        }

        return ret;
    } else {
        return basis.bindings.fp._PhysicsScene_sphereSweep(sceneCppPtr, sphereRadius, origin, direction, maxDistance, result);
    }
}

pub fn PhysicsScene_sphereSweepEx(
    sceneCppPtr: basis.CppPtr,
    sphereRadius: f32,
    origin: [*c]const basis.bindings.InteropVec3,
    direction: [*c]const basis.bindings.InteropVec3,
    maxDistance: f32,
    resultArray: [*c]basis.bindings.PhysicsInteropRayCastResult,
    resultArraySize: u32,
    blockingActorTypes: u32,
) u32 {
    if (isWasm) {
        @compileError("PhysicsScene_sphereSweepEx not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._PhysicsScene_sphereSweepEx(sceneCppPtr, sphereRadius, origin, direction, maxDistance, resultArray, resultArraySize, blockingActorTypes);
    }
}

pub fn PhysicsScene_getSphereOverlapping(sceneCppPtr: basis.CppPtr, center: [*c]const basis.bindings.InteropVec3, radius: f32) u32 {
    if (isWasm) {
        @compileError("PhysicsScene_getSphereOverlapping not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._PhysicsScene_getSphereOverlapping(sceneCppPtr, center, radius);
    }
}

pub fn PhysicsScene_castRay(
    sceneCppPtr: basis.CppPtr,
    origin: [*c]const basis.bindings.InteropVec3,
    direction: [*c]const basis.bindings.InteropVec3,
    maxDistance: f32,
    result: [*c]basis.bindings.PhysicsInteropRayCastResult,
) c_int {
    if (isWasm) {
        var buffer: [128]u8 = undefined;

        var writePos: usize = 0;
        {
            var stream = basis.BinaryWriteStream.init(&buffer, true);
            stream.put(Vec3, Vec3.fromInterop(origin));
            stream.put(Vec3, Vec3.fromInterop(direction));
            stream.putFloat(maxDistance);
            writePos = @intCast(stream.cursorPosition);
        }

        const ret = access.PhysicsScene_castRay_WASM(sceneCppPtr, &buffer, writePos);

        if (ret == 1) {
            var stream = basis.BinaryReadStream.init(&buffer, true);

            result.*.hitPoint = stream.get(Vec3).toInterop();
            result.*.hitPointNormal = stream.get(Vec3).toInterop();
            result.*.distance = stream.getFloat();
            result.*.hitGameObjectCppPtr = stream.getInt(usize);
            result.*.hitPhysicsActorCppPtr = stream.getInt(usize);
            result.*.hitPhysicsActorType = stream.getInt(u32);
        }

        return ret;
    } else {
        return basis.bindings.fp._PhysicsScene_castRay(sceneCppPtr, origin, direction, maxDistance, result);
    }
}

pub fn PhysicsScene_castRayEx(
    sceneCppPtr: basis.CppPtr,
    origin: [*c]const basis.bindings.InteropVec3,
    direction: [*c]const basis.bindings.InteropVec3,
    maxDistance: f32,
    result: [*c]basis.bindings.PhysicsInteropRayCastResult,
    blockingActorTypes: u32,
) c_int {
    if (isWasm) {
        var buffer: [128]u8 = undefined;

        var writePos: usize = 0;
        {
            var stream = basis.BinaryWriteStream.init(&buffer, true);
            stream.put(Vec3, Vec3.fromInterop(origin));
            stream.put(Vec3, Vec3.fromInterop(direction));
            stream.putFloat(maxDistance);
            stream.putInt(u32, blockingActorTypes);
            writePos = @intCast(stream.cursorPosition);
        }

        const ret = access.PhysicsScene_castRay_WASM(sceneCppPtr, &buffer, writePos);

        if (ret == 1) {
            var stream = basis.BinaryReadStream.init(&buffer, true);

            result.*.hitPoint = stream.get(Vec3).toInterop();
            result.*.hitPointNormal = stream.get(Vec3).toInterop();
            result.*.distance = stream.getFloat();
            result.*.hitGameObjectCppPtr = stream.getInt(usize);
            result.*.hitPhysicsActorCppPtr = stream.getInt(usize);
            result.*.hitPhysicsActorType = stream.getInt(u32);
        }

        return ret;
    } else {
        return basis.bindings.fp._PhysicsScene_castRayEx(sceneCppPtr, origin, direction, maxDistance, result, blockingActorTypes);
    }
}

pub fn PhysicsScene_castRayWithCallback(
    sceneCppPtr: basis.CppPtr,
    origin: [*c]const basis.bindings.InteropVec3,
    direction: [*c]const basis.bindings.InteropVec3,
    maxDistance: f32,
    result: [*c]basis.bindings.PhysicsInteropRayCastResult,
    blockingActorTypes: u32,
    callbackPtr: u64,
    needsPostFilter: bool,
    shouldReportHit: basis.bindings.FP_i32_IntPtr_IntPtr64_u32,
    shouldReportHitPostFilter: basis.bindings.FP_i32_IntPtr_IntPtr64_u32_Vec3_Vec3,
) c_int {
    if (isWasm) {
        @compileError("PhysicsScene_castRayWithCallback not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._PhysicsScene_castRayWithCallback(
            sceneCppPtr,
            origin,
            direction,
            maxDistance,
            result,
            blockingActorTypes,
            callbackPtr,
            if (needsPostFilter) 1 else 0,
            shouldReportHit,
            shouldReportHitPostFilter,
        );
    }
}

pub fn PhysicsScene_setCollisionCallbacksEnabled(sceneCppPtr: basis.CppPtr, enabled: c_int) void {
    if (isWasm) {
        @compileError("PhysicsScene_setCollisionCallbacksEnabled not implemented for WASM yet.");
    } else {
        basis.bindings.fp._PhysicsScene_setCollisionCallbacksEnabled(sceneCppPtr, enabled);
    }
}

// ===============================

// class PhysicsMaterial

pub fn PhysicsMaterial_getDefaultMaterial(physicsEngineCppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.PhysicsMaterial_getDefaultMaterial_WASM(physicsEngineCppPtr);
    } else {
        return basis.bindings.fp._PhysicsMaterial_getDefaultMaterial(physicsEngineCppPtr);
    }
}

pub fn PhysicsMaterial_getBaseMaterial(physicsEngineCppPtr: basis.CppPtr, materialIndex: u32) basis.CppPtr {
    if (isWasm) {
        return access.PhysicsMaterial_getBaseMaterial_WASM(physicsEngineCppPtr, materialIndex);
    } else {
        return basis.bindings.fp._PhysicsMaterial_getBaseMaterial(physicsEngineCppPtr, materialIndex);
    }
}

pub fn PhysicsMaterial_createMaterial(
    physicsEngineCppPtr: basis.CppPtr,
    materialType: c_int,
    staticFriction: f32,
    dynamicFriction: f32,
    restitution: f32,
    drivable: bool,
    walkable: bool,
) basis.CppPtr {
    if (isWasm) {
        const SIZE = @sizeOf(i32) + @sizeOf(f32) + @sizeOf(f32) + @sizeOf(f32) + 1 + 1;
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.putInt(i32, materialType);
        stream.putFloat(staticFriction);
        stream.putFloat(dynamicFriction);
        stream.putFloat(restitution);
        stream.putBool(drivable);
        stream.putBool(walkable);

        return access.PhysicsMaterial_createMaterial_WASM(physicsEngineCppPtr, &buffer, SIZE);
    } else {
        return basis.bindings.fp._PhysicsMaterial_createMaterial(
            physicsEngineCppPtr,
            materialType,
            staticFriction,
            dynamicFriction,
            restitution,
            if (drivable) 1 else 0,
            if (walkable) 1 else 0,
        );
    }
}

pub fn PhysicsMaterial_getBasePhysicsMaterialName(cppPtr: basis.CppPtr) u32 {
    if (isWasm) {
        return access.PhysicsMaterial_getBasePhysicsMaterialName_WASM(cppPtr);
    } else {
        return basis.bindings.fp._PhysicsMaterial_getBasePhysicsMaterialName(cppPtr);
    }
}

pub fn PhysicsMaterial_addRef(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.PhysicsMaterial_addRef_WASM(cppPtr);
    } else {
        basis.bindings.fp._PhysicsMaterial_addRef(cppPtr);
    }
}

pub fn PhysicsMaterial_release(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.PhysicsMaterial_release_WASM(cppPtr);
    } else {
        basis.bindings.fp._PhysicsMaterial_release(cppPtr);
    }
}

// ===============================

// class PhysicsShape

pub fn PhysicsShape_createBox(
    physicsEngineCppPtr: basis.CppPtr,
    width: f32,
    height: f32,
    depth: f32,
    material: basis.CppPtr,
    localPosition: [*c]const basis.bindings.InteropVec3,
    localOrientation: [*c]const basis.bindings.InteropQuaternion,
    exclusive: bool,
) basis.CppPtr {
    if (isWasm) {
        const SIZE = @sizeOf(f32) + @sizeOf(f32) + @sizeOf(f32) + @sizeOf(basis.CppPtr) + (3 * @sizeOf(f32)) + (4 * @sizeOf(f32)) + 1;
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.putFloat(width);
        stream.putFloat(height);
        stream.putFloat(depth);
        stream.putInt(basis.CppPtr, material);
        stream.put(Vec3, Vec3.fromInterop(localPosition.*));
        stream.put(Quaternion, Quaternion.fromInterop(localOrientation.*));
        stream.putBool(exclusive);

        return access.PhysicsShape_createBox_WASM(physicsEngineCppPtr, &buffer, SIZE);
    } else {
        return basis.bindings.fp._PhysicsShape_createBox(physicsEngineCppPtr, width, height, depth, material, localPosition, localOrientation, if (exclusive) 1 else 0);
    }
}

pub fn PhysicsShape_createSphere(
    physicsEngineCppPtr: basis.CppPtr,
    radius: f32,
    material: basis.CppPtr,
    localPosition: [*c]const basis.bindings.InteropVec3,
    localOrientation: [*c]const basis.bindings.InteropQuaternion,
    exclusive: bool,
) basis.CppPtr {
    if (isWasm) {
        const SIZE = @sizeOf(f32) + @sizeOf(basis.CppPtr) + (3 * @sizeOf(f32)) + (4 * @sizeOf(f32)) + 1;
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.putFloat(radius);
        stream.putInt(basis.CppPtr, material);
        stream.put(Vec3, Vec3.fromInterop(localPosition.*));
        stream.put(Quaternion, Quaternion.fromInterop(localOrientation.*));
        stream.putBool(exclusive);

        return access.PhysicsShape_createSphere_WASM(physicsEngineCppPtr, &buffer, SIZE);
    } else {
        return basis.bindings.fp._PhysicsShape_createSphere(physicsEngineCppPtr, radius, material, localPosition, localOrientation, if (exclusive) 1 else 0);
    }
}

pub fn PhysicsShape_createCapsule(
    physicsEngineCppPtr: basis.CppPtr,
    radius: f32,
    height: f32,
    material: basis.CppPtr,
    localPosition: [*c]const basis.bindings.InteropVec3,
    localOrientation: [*c]const basis.bindings.InteropQuaternion,
    exclusive: bool,
) basis.CppPtr {
    if (isWasm) {
        const SIZE = @sizeOf(f32) + @sizeOf(f32) + @sizeOf(basis.CppPtr) + (3 * @sizeOf(f32)) + (4 * @sizeOf(f32)) + 1;
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.putFloat(radius);
        stream.putFloat(height);
        stream.putInt(basis.CppPtr, material);
        stream.put(Vec3, Vec3.fromInterop(localPosition.*));
        stream.put(Quaternion, Quaternion.fromInterop(localOrientation.*));
        stream.putBool(exclusive);

        return access.PhysicsShape_createCapsule_WASM(physicsEngineCppPtr, &buffer, SIZE);
    } else {
        return basis.bindings.fp._PhysicsShape_createCapsule(physicsEngineCppPtr, radius, height, material, localPosition, localOrientation, if (exclusive) 1 else 0);
    }
}

pub fn PhysicsShape_createCylinder(
    physicsEngineCppPtr: basis.CppPtr,
    radius: f32,
    height: f32,
    material: basis.CppPtr,
    localPosition: [*c]const basis.bindings.InteropVec3,
    localOrientation: [*c]const basis.bindings.InteropQuaternion,
    exclusive: bool,
) basis.CppPtr {
    if (isWasm) {
        const SIZE = @sizeOf(f32) + @sizeOf(f32) + @sizeOf(basis.CppPtr) + (3 * @sizeOf(f32)) + (4 * @sizeOf(f32)) + 1;
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.putFloat(radius);
        stream.putFloat(height);
        stream.putInt(basis.CppPtr, material);
        stream.put(Vec3, Vec3.fromInterop(localPosition.*));
        stream.put(Quaternion, Quaternion.fromInterop(localOrientation.*));
        stream.putBool(exclusive);

        return access.PhysicsShape_createCylinder_WASM(physicsEngineCppPtr, &buffer, SIZE);
    } else {
        return basis.bindings.fp._PhysicsShape_createCylinder(physicsEngineCppPtr, radius, height, material, localPosition, localOrientation, if (exclusive) 1 else 0);
    }
}

pub fn PhysicsShape_createCylinderX(
    physicsEngineCppPtr: basis.CppPtr,
    radius: f32,
    height: f32,
    material: basis.CppPtr,
    localPosition: [*c]const basis.bindings.InteropVec3,
    localOrientation: [*c]const basis.bindings.InteropQuaternion,
    exclusive: bool,
) basis.CppPtr {
    if (isWasm) {
        const SIZE = @sizeOf(f32) + @sizeOf(f32) + @sizeOf(basis.CppPtr) + (3 * @sizeOf(f32)) + (4 * @sizeOf(f32)) + 1;
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.putFloat(radius);
        stream.putFloat(height);
        stream.putInt(basis.CppPtr, material);
        stream.put(Vec3, Vec3.fromInterop(localPosition.*));
        stream.put(Quaternion, Quaternion.fromInterop(localOrientation.*));
        stream.putBool(exclusive);

        return access.PhysicsShape_createCylinderX_WASM(physicsEngineCppPtr, &buffer, SIZE);
    } else {
        return basis.bindings.fp._PhysicsShape_createCylinderX(physicsEngineCppPtr, radius, height, material, localPosition, localOrientation, if (exclusive) 1 else 0);
    }
}

pub fn PhysicsShape_createCylinderZ(
    physicsEngineCppPtr: basis.CppPtr,
    radius: f32,
    height: f32,
    material: basis.CppPtr,
    localPosition: [*c]const basis.bindings.InteropVec3,
    localOrientation: [*c]const basis.bindings.InteropQuaternion,
    exclusive: bool,
) basis.CppPtr {
    if (isWasm) {
        const SIZE = @sizeOf(f32) + @sizeOf(f32) + @sizeOf(basis.CppPtr) + (3 * @sizeOf(f32)) + (4 * @sizeOf(f32)) + 1;
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.putFloat(radius);
        stream.putFloat(height);
        stream.putInt(basis.CppPtr, material);
        stream.put(Vec3, Vec3.fromInterop(localPosition.*));
        stream.put(Quaternion, Quaternion.fromInterop(localOrientation.*));
        stream.putBool(exclusive);

        return access.PhysicsShape_createCylinderZ_WASM(physicsEngineCppPtr, &buffer, SIZE);
    } else {
        return basis.bindings.fp._PhysicsShape_createCylinderZ(physicsEngineCppPtr, radius, height, material, localPosition, localOrientation, if (exclusive) 1 else 0);
    }
}

pub fn PhysicsShape_addRef(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.PhysicsShape_addRef_WASM(cppPtr);
    } else {
        basis.bindings.fp._PhysicsShape_addRef(cppPtr);
    }
}

pub fn PhysicsShape_release(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.PhysicsShape_release_WASM(cppPtr);
    } else {
        basis.bindings.fp._PhysicsShape_release(cppPtr);
    }
}

// ===============================

// class PhysicsActor

pub fn PhysicsActor_createRigidBodyDynamic(
    physicsEngineCppPtr: u64,
    shapes: [*c]basis.CppPtr,
    shapeCount: u32,
    mass: f32,
    CoM: [*c]const basis.bindings.InteropVec3,
    initialPosition: [*c]const basis.bindings.InteropVec3,
    initialOrientation: [*c]const basis.bindings.InteropQuaternion,
    kinematic: bool,
    useCCD: bool,
) basis.CppPtr {
    if (isWasm) {
        const SIZE = 128;
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.putInt(u32, shapeCount);
        for (0..shapeCount) |i| {
            stream.putInt(basis.CppPtr, shapes[i]);
        }
        stream.putFloat(mass);
        stream.put(Vec3, Vec3.fromInterop(CoM.*));
        stream.put(Vec3, Vec3.fromInterop(initialPosition.*));
        stream.put(Quaternion, Quaternion.fromInterop(initialOrientation.*));
        stream.putBool(kinematic);
        stream.putBool(useCCD);

        return access.PhysicsActor_createRigidBodyDynamic_WASM(physicsEngineCppPtr, &buffer, @intCast(stream.cursorPosition));
    } else {
        return basis.bindings.fp._PhysicsActor_createRigidBodyDynamic(
            physicsEngineCppPtr,
            shapes,
            shapeCount,
            mass,
            CoM,
            initialPosition,
            initialOrientation,
            if (kinematic) 1 else 0,
            if (useCCD) 1 else 0,
        );
    }
}

pub fn PhysicsActor_createRigidBodyStatic(
    physicsEngineCppPtr: basis.CppPtr,
    shapes: [*c]basis.CppPtr,
    shapeCount: u32,
    initialPosition: [*c]const basis.bindings.InteropVec3,
    initialOrientation: [*c]const basis.bindings.InteropQuaternion,
) basis.CppPtr {
    if (isWasm) {
        const SIZE = 128;
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.putInt(u32, shapeCount);
        for (0..shapeCount) |i| {
            stream.putInt(basis.CppPtr, shapes[i]);
        }
        stream.put(Vec3, Vec3.fromInterop(initialPosition.*));
        stream.put(Quaternion, Quaternion.fromInterop(initialOrientation.*));

        return access.PhysicsActor_createRigidBodyStatic_WASM(physicsEngineCppPtr, &buffer, @intCast(stream.cursorPosition));
    } else {
        return basis.bindings.fp._PhysicsActor_createRigidBodyStatic(physicsEngineCppPtr, shapes, shapeCount, initialPosition, initialOrientation);
    }
}

pub fn PhysicsActor_createBoxTrigger(
    zigLibCppPtr: basis.bindings.InteropTypedPtr,
    physicsEngineCppPtr: basis.CppPtr,
    width: f32,
    height: f32,
    depth: f32,
    initialPosition: [*c]const basis.bindings.InteropVec3,
    initialOrientation: [*c]const basis.bindings.InteropQuaternion,
    ignoreStaticObjects: bool,
    ignoreRemovedObjects: bool,
) basis.CppPtr {
    if (isWasm) {
        // The below code works, but the C++ side isn't finished yet.
        @compileError("PhysicsActor_createBoxTrigger not implemented for WASM yet.");

        // const SIZE = 128;
        // var buffer: [SIZE]u8 = undefined;

        // var stream = basis.BinaryWriteStream.init(&buffer, true);
        // stream.putFloat(width);
        // stream.putFloat(height);
        // stream.putFloat(depth);
        // stream.put(Vec3, Vec3.fromInterop(initialPosition.*));
        // stream.put(Quaternion, Quaternion.fromInterop(initialOrientation.*));
        // stream.putBool(ignoreStaticObjects);
        // stream.putBool(ignoreRemovedObjects);

        // return access.PhysicsActor_createBoxTrigger_WASM(
        //     zigLibCppPtr.ptr,
        //     zigLibCppPtr.type,
        //     physicsEngineCppPtr,
        //     &buffer,
        //     @intCast(stream.cursorPosition),
        // );
    } else {
        return basis.bindings.fp._PhysicsActor_createBoxTrigger(
            zigLibCppPtr,
            physicsEngineCppPtr,
            width,
            height,
            depth,
            initialPosition,
            initialOrientation,
            if (ignoreStaticObjects) 1 else 0,
            if (ignoreRemovedObjects) 1 else 0,
        );
    }
}

pub fn PhysicsActor_createSphereTrigger(
    zigLibCppPtr: basis.bindings.InteropTypedPtr,
    physicsEngineCppPtr: basis.CppPtr,
    radius: f32,
    initialPosition: [*c]const basis.bindings.InteropVec3,
    initialOrientation: [*c]const basis.bindings.InteropQuaternion,
    ignoreStaticObjects: bool,
    ignoreRemovedObjects: bool,
) basis.CppPtr {
    if (isWasm) {
        // The below code works, but the C++ side isn't finished yet.
        @compileError("PhysicsActor_createSphereTrigger not implemented for WASM yet.");

        // const SIZE = 128;
        // var buffer: [SIZE]u8 = undefined;

        // var stream = basis.BinaryWriteStream.init(&buffer, true);
        // stream.putFloat(radius);
        // stream.put(Vec3, Vec3.fromInterop(initialPosition.*));
        // stream.put(Quaternion, Quaternion.fromInterop(initialOrientation.*));
        // stream.putBool(ignoreStaticObjects);
        // stream.putBool(ignoreRemovedObjects);

        // return access.PhysicsActor_createSphereTrigger_WASM(
        //     zigLibCppPtr.ptr,
        //     zigLibCppPtr.type,
        //     physicsEngineCppPtr,
        //     &buffer,
        //     @intCast(stream.cursorPosition),
        // );
    } else {
        return basis.bindings.fp._PhysicsActor_createSphereTrigger(
            zigLibCppPtr,
            physicsEngineCppPtr,
            radius,
            initialPosition,
            initialOrientation,
            if (ignoreStaticObjects) 1 else 0,
            if (ignoreRemovedObjects) 1 else 0,
        );
    }
}

pub fn PhysicsActor_setWorldTransform(cppPtr: basis.CppPtr, position: [*c]const basis.bindings.InteropVec3, orientation: [*c]const basis.bindings.InteropQuaternion) void {
    if (isWasm) {
        const SIZE = Vec3Size + QuaternionSize;
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.put(Vec3, Vec3.fromInterop(position.*));
        stream.put(Quaternion, Quaternion.fromInterop(orientation.*));

        access.PhysicsActor_setWorldTransform_WASM(cppPtr, &buffer, SIZE);
    } else {
        basis.bindings.fp._PhysicsActor_setWorldTransform(cppPtr, position, orientation);
    }
}

pub fn PhysicsActor_getWorldTransform(cppPtr: basis.CppPtr, position: [*c]basis.bindings.InteropVec3, orientation: [*c]basis.bindings.InteropQuaternion) void {
    if (isWasm) {
        const SIZE = Vec3Size + QuaternionSize;
        var buffer: [SIZE]u8 = undefined;

        access.PhysicsActor_getWorldTransform_WASM(cppPtr, &buffer, SIZE);
        var stream = basis.BinaryReadStream.init(&buffer, true);
        const v = stream.get(Vec3);
        const o = stream.get(Quaternion);
        position.* = v.toInterop();
        orientation.* = o.toInterop();
    } else {
        basis.bindings.fp._PhysicsActor_getWorldTransform(cppPtr, position, orientation);
    }
}

pub fn PhysicsActor_setKinematicTarget(cppPtr: basis.CppPtr, position: [*c]const basis.bindings.InteropVec3, orientation: [*c]const basis.bindings.InteropQuaternion) void {
    if (isWasm) {
        const SIZE = Vec3Size + QuaternionSize;
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.put(Vec3, Vec3.fromInterop(position.*));
        stream.put(Quaternion, Quaternion.fromInterop(orientation.*));

        access.PhysicsActor_setKinematicTarget_WASM(cppPtr, &buffer, SIZE);
    } else {
        basis.bindings.fp._PhysicsActor_setKinematicTarget(cppPtr, position, orientation);
    }
}

pub fn PhysicsActor_setMassData(cppPtr: basis.CppPtr, mass: f32, centerOfMass: [*c]const basis.bindings.InteropVec3) void {
    if (isWasm) {
        access.PhysicsActor_setMassData_WASM(cppPtr, mass, centerOfMass.*.x, centerOfMass.*.y, centerOfMass.*.z);
    } else {
        basis.bindings.fp._PhysicsActor_setMassData(cppPtr, mass, centerOfMass);
    }
}

pub fn PhysicsActor_setContactReportThreshold(cppPtr: basis.CppPtr, threshold: f32) void {
    if (isWasm) {
        access.PhysicsActor_setContactReportThreshold_WASM(cppPtr, threshold);
    } else {
        basis.bindings.fp._PhysicsActor_setContactReportThreshold(cppPtr, threshold);
    }
}

pub fn PhysicsActor_setSolverIterationCounts(cppPtr: basis.CppPtr, minPositionIters: u32, minVelocityIters: u32) void {
    if (isWasm) {
        access.PhysicsActor_setSolverIterationCounts_WASM(cppPtr, minPositionIters, minVelocityIters);
    } else {
        basis.bindings.fp._PhysicsActor_setSolverIterationCounts(cppPtr, minPositionIters, minVelocityIters);
    }
}

pub fn PhysicsActor_setAngularDamping(cppPtr: basis.CppPtr, damping: f32) void {
    if (isWasm) {
        access.PhysicsActor_setAngularDamping_WASM(cppPtr, damping);
    } else {
        basis.bindings.fp._PhysicsActor_setAngularDamping(cppPtr, damping);
    }
}

pub fn PhysicsActor_setMaxAngularVelocity(cppPtr: basis.CppPtr, maxAngVel: f32) void {
    if (isWasm) {
        access.PhysicsActor_setMaxAngularVelocity_WASM(cppPtr, maxAngVel);
    } else {
        basis.bindings.fp._PhysicsActor_setMaxAngularVelocity(cppPtr, maxAngVel);
    }
}

pub fn PhysicsActor_getWorldBounds(cppPtr: basis.CppPtr, boundsMin: [*c]basis.bindings.InteropVec3, boundsMax: [*c]basis.bindings.InteropVec3) void {
    if (isWasm) {
        const SIZE = 2 * Vec3Size;
        var buffer: [SIZE]u8 = undefined;

        access.PhysicsActor_getWorldBounds_WASM(cppPtr, &buffer, SIZE);
        var stream = basis.BinaryReadStream.init(&buffer, true);
        const min = stream.get(Vec3);
        const max = stream.get(Vec3);
        boundsMin.* = min.toInterop();
        boundsMax.* = max.toInterop();
    } else {
        basis.bindings.fp._PhysicsActor_getWorldBounds(cppPtr, boundsMin, boundsMax);
    }
}

pub fn PhysicsActor_associateWithGameObject(cppPtr: basis.CppPtr, gameObjectCppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.PhysicsActor_associateWithGameObject_WASM(cppPtr, gameObjectCppPtr);
    } else {
        basis.bindings.fp._PhysicsActor_associateWithGameObject(cppPtr, gameObjectCppPtr);
    }
}

pub fn PhysicsActor_getAssociatedGameObject(cppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.PhysicsActor_getAssociatedGameObject_WASM(cppPtr);
    } else {
        return basis.bindings.fp._PhysicsActor_getAssociatedGameObject(cppPtr);
    }
}

pub fn PhysicsActor_isSleeping(cppPtr: basis.CppPtr) c_int {
    if (isWasm) {
        return access.PhysicsActor_isSleeping_WASM(cppPtr);
    } else {
        return basis.bindings.fp._PhysicsActor_isSleeping(cppPtr);
    }
}

pub fn PhysicsActor_wakeUp(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.PhysicsActor_wakeUp_WASM(cppPtr);
    } else {
        basis.bindings.fp._PhysicsActor_wakeUp(cppPtr);
    }
}

pub fn PhysicsActor_putToSleep(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.PhysicsActor_putToSleep_WASM(cppPtr);
    } else {
        basis.bindings.fp._PhysicsActor_putToSleep(cppPtr);
    }
}

pub fn PhysicsActor_setLinearVelocity(cppPtr: basis.CppPtr, linVel: [*c]const basis.bindings.InteropVec3) void {
    if (isWasm) {
        const SIZE = Vec3Size;
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.put(Vec3, Vec3.fromInterop(linVel.*));

        access.PhysicsActor_setLinearVelocity_WASM(cppPtr, &buffer, SIZE);
    } else {
        basis.bindings.fp._PhysicsActor_setLinearVelocity(cppPtr, linVel);
    }
}

pub fn PhysicsActor_getLinearVelocity(cppPtr: basis.CppPtr, linVel: [*c]basis.bindings.InteropVec3) void {
    if (isWasm) {
        const SIZE = Vec3Size;
        var buffer: [SIZE]u8 = undefined;

        access.PhysicsActor_getLinearVelocity_WASM(cppPtr, &buffer, SIZE);
        var stream = basis.BinaryReadStream.init(&buffer, true);
        const v = stream.get(Vec3);
        linVel.* = v.toInterop();
    } else {
        basis.bindings.fp._PhysicsActor_getLinearVelocity(cppPtr, linVel);
    }
}

pub fn PhysicsActor_setAngularVelocity(cppPtr: basis.CppPtr, angVel: [*c]const basis.bindings.InteropVec3) void {
    if (isWasm) {
        const SIZE = Vec3Size;
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.put(Vec3, Vec3.fromInterop(angVel.*));

        access.PhysicsActor_setAngularVelocity_WASM(cppPtr, &buffer, SIZE);
    } else {
        basis.bindings.fp._PhysicsActor_setAngularVelocity(cppPtr, angVel);
    }
}

pub fn PhysicsActor_getAngularVelocity(cppPtr: basis.CppPtr, angVel: [*c]basis.bindings.InteropVec3) void {
    if (isWasm) {
        const SIZE = Vec3Size;
        var buffer: [SIZE]u8 = undefined;

        access.PhysicsActor_getAngularVelocity_WASM(&buffer, SIZE);
        var stream = basis.BinaryReadStream.init(&buffer, true);
        const v = stream.get(Vec3);
        angVel.* = v.toInterop();
    } else {
        basis.bindings.fp._PhysicsActor_getAngularVelocity(cppPtr, angVel);
    }
}

pub fn PhysicsActor_addForce(cppPtr: basis.CppPtr, force: [*c]const basis.bindings.InteropVec3, position: [*c]const basis.bindings.InteropVec3, wakeUp: bool) void {
    if (isWasm) {
        const SIZE = Vec3Size + Vec3Size + 1;
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.put(Vec3, Vec3.fromInterop(force.*));
        stream.put(Vec3, Vec3.fromInterop(position.*));
        stream.putBool(wakeUp);

        access.PhysicsActor_addForce_WASM(cppPtr, &buffer, SIZE);
    } else {
        basis.bindings.fp._PhysicsActor_addForce(cppPtr, force, position, if (wakeUp) 1 else 0);
    }
}

pub fn PhysicsActor_addImpulse(cppPtr: basis.CppPtr, impulse: [*c]const basis.bindings.InteropVec3, position: [*c]const basis.bindings.InteropVec3, wakeUp: bool) void {
    if (isWasm) {
        const SIZE = Vec3Size + Vec3Size + 1;
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.put(Vec3, Vec3.fromInterop(impulse.*));
        stream.put(Vec3, Vec3.fromInterop(position.*));
        stream.putBool(wakeUp);

        access.PhysicsActor_addImpulse_WASM(cppPtr, &buffer, SIZE);
    } else {
        basis.bindings.fp._PhysicsActor_addImpulse(cppPtr, impulse, position, if (wakeUp) 1 else 0);
    }
}

pub fn PhysicsActor_addRef(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.PhysicsActor_addRef_WASM(cppPtr);
    } else {
        basis.bindings.fp._PhysicsActor_addRef(cppPtr);
    }
}

pub fn PhysicsActor_release(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.PhysicsActor_release_WASM(cppPtr);
    } else {
        basis.bindings.fp._PhysicsActor_release(cppPtr);
    }
}

// ===============================

// class PhysicsJoint

pub fn PhysicsJoint_createFixedJoint(physicsEngineCppPtr: u64, actorACppPtr: u64, actorAPosition: [*c]const basis.bindings.InteropVec3, actorAOrientation: [*c]const basis.bindings.InteropQuaternion, actorBCppPtr: u64, actorBPosition: [*c]const basis.bindings.InteropVec3, actorBOrientation: [*c]const basis.bindings.InteropQuaternion) u64 {
    if (isWasm) {
        @compileError("PhysicsJoint_createFixedJoint not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._PhysicsJoint_createFixedJoint(physicsEngineCppPtr, actorACppPtr, actorAPosition, actorAOrientation, actorBCppPtr, actorBPosition, actorBOrientation);
    }
}

pub fn PhysicsJoint_createSphericalJoint(physicsEngineCppPtr: u64, actorACppPtr: u64, actorAPosition: [*c]const basis.bindings.InteropVec3, actorAOrientation: [*c]const basis.bindings.InteropQuaternion, actorBCppPtr: u64, actorBPosition: [*c]const basis.bindings.InteropVec3, actorBOrientation: [*c]const basis.bindings.InteropQuaternion) u64 {
    if (isWasm) {
        @compileError("PhysicsJoint_createSphericalJoint not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._PhysicsJoint_createSphericalJoint(physicsEngineCppPtr, actorACppPtr, actorAPosition, actorAOrientation, actorBCppPtr, actorBPosition, actorBOrientation);
    }
}

pub fn PhysicsJoint_createDistanceJoint(physicsEngineCppPtr: u64, actorACppPtr: u64, actorAPosition: [*c]const basis.bindings.InteropVec3, actorAOrientation: [*c]const basis.bindings.InteropQuaternion, actorBCppPtr: u64, actorBPosition: [*c]const basis.bindings.InteropVec3, actorBOrientation: [*c]const basis.bindings.InteropQuaternion) u64 {
    if (isWasm) {
        @compileError("PhysicsJoint_createDistanceJoint not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._PhysicsJoint_createDistanceJoint(physicsEngineCppPtr, actorACppPtr, actorAPosition, actorAOrientation, actorBCppPtr, actorBPosition, actorBOrientation);
    }
}

pub fn PhysicsJoint_createDof6Joint(physicsEngineCppPtr: u64, actorACppPtr: u64, actorAPosition: [*c]const basis.bindings.InteropVec3, actorAOrientation: [*c]const basis.bindings.InteropQuaternion, actorBCppPtr: u64, actorBPosition: [*c]const basis.bindings.InteropVec3, actorBOrientation: [*c]const basis.bindings.InteropQuaternion) u64 {
    if (isWasm) {
        @compileError("PhysicsJoint_createDof6Joint not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._PhysicsJoint_createDof6Joint(physicsEngineCppPtr, actorACppPtr, actorAPosition, actorAOrientation, actorBCppPtr, actorBPosition, actorBOrientation);
    }
}

pub fn PhysicsJoint_createSphericalSpringJoint(physicsEngineCppPtr: u64, actorACppPtr: u64, actorAPosition: [*c]const basis.bindings.InteropVec3, actorAOrientation: [*c]const basis.bindings.InteropQuaternion, actorBCppPtr: u64, actorBPosition: [*c]const basis.bindings.InteropVec3, actorBOrientation: [*c]const basis.bindings.InteropQuaternion, stiffness: f32, damping: f32, forceLimit: f32) u64 {
    if (isWasm) {
        @compileError("PhysicsJoint_createSphericalSpringJoint not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._PhysicsJoint_createSphericalSpringJoint(physicsEngineCppPtr, actorACppPtr, actorAPosition, actorAOrientation, actorBCppPtr, actorBPosition, actorBOrientation, stiffness, damping, forceLimit);
    }
}

pub fn PhysicsJoint_enableProjection(cppPtr: basis.CppPtr, jointType: u32, projectToActor0: bool, linearTolerance: f32, angularTolerance: f32) void {
    if (isWasm) {
        @compileError("PhysicsJoint_enableProjection not implemented for WASM yet.");
    } else {
        basis.bindings.fp._PhysicsJoint_enableProjection(cppPtr, jointType, if (projectToActor0) 1 else 0, linearTolerance, angularTolerance);
    }
}

pub fn PhysicsJoint_setBreakForce(cppPtr: basis.CppPtr, jointType: u32, force: f32, torque: f32) void {
    if (isWasm) {
        @compileError("PhysicsJoint_setBreakForce not implemented for WASM yet.");
    } else {
        basis.bindings.fp._PhysicsJoint_setBreakForce(cppPtr, jointType, force, torque);
    }
}

pub fn PhysicsJoint_setDof6Motion(cppPtr: basis.CppPtr, axis: u32, motion: u32) void {
    if (isWasm) {
        @compileError("PhysicsJoint_setDof6Motion not implemented for WASM yet.");
    } else {
        basis.bindings.fp._PhysicsJoint_setDof6Motion(cppPtr, axis, motion);
    }
}

pub fn PhysicsJoint_setDof6Drive(cppPtr: basis.CppPtr, drive: u32, driveStiffness: f32, driveDamping: f32, driveForceLimit: f32, isAcceleration: bool) void {
    if (isWasm) {
        @compileError("PhysicsJoint_setDof6Drive not implemented for WASM yet.");
    } else {
        basis.bindings.fp._PhysicsJoint_setDof6Drive(cppPtr, drive, driveStiffness, driveDamping, driveForceLimit, if (isAcceleration) 1 else 0);
    }
}

pub fn PhysicsJoint_setDof6TwistLimit(cppPtr: basis.CppPtr, lower: f32, upper: f32) void {
    if (isWasm) {
        @compileError("PhysicsJoint_setDof6TwistLimit not implemented for WASM yet.");
    } else {
        basis.bindings.fp._PhysicsJoint_setDof6TwistLimit(cppPtr, lower, upper);
    }
}

pub fn PhysicsJoint_setDriveGoalPose(cppPtr: basis.CppPtr, jointType: u32, posePosition: [*c]const basis.bindings.InteropVec3, poseOrientation: [*c]const basis.bindings.InteropQuaternion) void {
    if (isWasm) {
        @compileError("PhysicsJoint_setDriveGoalPose not implemented for WASM yet.");
    } else {
        basis.bindings.fp._PhysicsJoint_setDriveGoalPose(cppPtr, jointType, posePosition, poseOrientation);
    }
}

pub fn PhysicsJoint_getConstraintForce(cppPtr: basis.CppPtr, jointType: u32, linear: [*c]basis.bindings.InteropVec3, angular: [*c]basis.bindings.InteropVec3) void {
    if (isWasm) {
        @compileError("PhysicsJoint_getConstraintForce not implemented for WASM yet.");
    } else {
        basis.bindings.fp._PhysicsJoint_getConstraintForce(cppPtr, jointType, linear, angular);
    }
}

pub fn PhysicsJoint_setInvMassScale0(cppPtr: basis.CppPtr, jointType: u32, invMassScale: f32) void {
    if (isWasm) {
        @compileError("PhysicsJoint_setInvMassScale0 not implemented for WASM yet.");
    } else {
        basis.bindings.fp._PhysicsJoint_setInvMassScale0(cppPtr, jointType, invMassScale);
    }
}

pub fn PhysicsJoint_setInvInertiaScale0(cppPtr: basis.CppPtr, jointType: u32, invInertiaScale: f32) void {
    if (isWasm) {
        @compileError("PhysicsJoint_setInvInertiaScale0 not implemented for WASM yet.");
    } else {
        basis.bindings.fp._PhysicsJoint_setInvInertiaScale0(cppPtr, jointType, invInertiaScale);
    }
}

pub fn PhysicsJoint_setInvMassScale1(cppPtr: basis.CppPtr, jointType: u32, invMassScale: f32) void {
    if (isWasm) {
        @compileError("PhysicsJoint_setInvMassScale1 not implemented for WASM yet.");
    } else {
        basis.bindings.fp._PhysicsJoint_setInvMassScale1(cppPtr, jointType, invMassScale);
    }
}

pub fn PhysicsJoint_setInvInertiaScale1(cppPtr: basis.CppPtr, jointType: u32, invInertiaScale: f32) void {
    if (isWasm) {
        @compileError("PhysicsJoint_setInvInertiaScale1 not implemented for WASM yet.");
    } else {
        basis.bindings.fp._PhysicsJoint_setInvInertiaScale1(cppPtr, jointType, invInertiaScale);
    }
}

pub fn PhysicsJoint_getInvMassScale0(cppPtr: basis.CppPtr, jointType: u32) f32 {
    if (isWasm) {
        @compileError("PhysicsJoint_getInvMassScale0 not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._PhysicsJoint_getInvMassScale0(cppPtr, jointType);
    }
}

pub fn PhysicsJoint_getInvInertiaScale0(cppPtr: basis.CppPtr, jointType: u32) f32 {
    if (isWasm) {
        @compileError("PhysicsJoint_getInvInertiaScale0 not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._PhysicsJoint_getInvInertiaScale0(cppPtr, jointType);
    }
}

pub fn PhysicsJoint_getInvMassScale1(cppPtr: basis.CppPtr, jointType: u32) f32 {
    if (isWasm) {
        @compileError("PhysicsJoint_getInvMassScale1 not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._PhysicsJoint_getInvMassScale1(cppPtr, jointType);
    }
}

pub fn PhysicsJoint_getInvInertiaScale1(cppPtr: basis.CppPtr, jointType: u32) f32 {
    if (isWasm) {
        @compileError("PhysicsJoint_getInvInertiaScale1 not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._PhysicsJoint_getInvInertiaScale1(cppPtr, jointType);
    }
}

pub fn PhysicsJoint_addRef(cppPtr: basis.CppPtr, jointType: u32) void {
    if (isWasm) {
        @compileError("PhysicsJoint_addRef not implemented for WASM yet.");
    } else {
        basis.bindings.fp._PhysicsJoint_addRef(cppPtr, jointType);
    }
}

pub fn PhysicsJoint_release(cppPtr: basis.CppPtr, jointType: u32) void {
    if (isWasm) {
        @compileError("PhysicsJoint_release not implemented for WASM yet.");
    } else {
        basis.bindings.fp._PhysicsJoint_release(cppPtr, jointType);
    }
}

// ===============================

// class PhysicsTriMesh

pub fn PhysicsTriMesh_createTriMesh(physicsEngineCppPtr: u64, data: [*c]const basis.bindings.InteropString) u64 {
    if (isWasm) {
        @compileError("PhysicsTriMesh_createTriMesh not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._PhysicsTriMesh_createTriMesh(physicsEngineCppPtr, data);
    }
}

pub fn PhysicsTriMesh_getTriangleCount(cppPtr: basis.CppPtr) u32 {
    if (isWasm) {
        @compileError("PhysicsTriMesh_getTriangleCount not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._PhysicsTriMesh_getTriangleCount(cppPtr);
    }
}

pub fn PhysicsTriMesh_getTriangleVertices(cppPtr: basis.CppPtr, triangle: u32, p0: [*c]basis.bindings.InteropVec3, p1: [*c]basis.bindings.InteropVec3, p2: [*c]basis.bindings.InteropVec3) void {
    if (isWasm) {
        @compileError("PhysicsTriMesh_getTriangleVertices not implemented for WASM yet.");
    } else {
        basis.bindings.fp._PhysicsTriMesh_getTriangleVertices(cppPtr, triangle, p0, p1, p2);
    }
}

pub fn PhysicsTriMesh_pointDistance(cppPtr: basis.CppPtr, point: [*c]const basis.bindings.InteropVec3, meshPosition: [*c]const basis.bindings.InteropVec3, meshOrientation: [*c]const basis.bindings.InteropQuaternion, closestPoint: [*c]basis.bindings.InteropVec3, closestIndex: [*c]u32) f32 {
    if (isWasm) {
        @compileError("PhysicsTriMesh_pointDistance not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._PhysicsTriMesh_pointDistance(cppPtr, point, meshPosition, meshOrientation, closestPoint, closestIndex);
    }
}

pub fn PhysicsTriMesh_addRef(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        @compileError("PhysicsTriMesh_addRef not implemented for WASM yet.");
    } else {
        basis.bindings.fp._PhysicsTriMesh_addRef(cppPtr);
    }
}

pub fn PhysicsTriMesh_release(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        @compileError("PhysicsTriMesh_release not implemented for WASM yet.");
    } else {
        basis.bindings.fp._PhysicsTriMesh_release(cppPtr);
    }
}

// ===============================

// class CharacterController

pub fn CharacterController_setMovementVector(cppPtr: basis.CppPtr, movementVector: [*c]const basis.bindings.InteropVec2) void {
    if (isWasm) {
        @compileError("CharacterController_setMovementVector not implemented for WASM yet.");
    } else {
        basis.bindings.fp._CharacterController_setMovementVector(cppPtr, movementVector);
    }
}

pub fn CharacterController_getMovementVector(cppPtr: basis.CppPtr, movementVector: [*c]basis.bindings.InteropVec2) void {
    if (isWasm) {
        @compileError("CharacterController_getMovementVector not implemented for WASM yet.");
    } else {
        basis.bindings.fp._CharacterController_getMovementVector(cppPtr, movementVector);
    }
}

pub fn CharacterController_getLinearVelocity(cppPtr: basis.CppPtr, linearVelocity: [*c]basis.bindings.InteropVec3) void {
    if (isWasm) {
        @compileError("CharacterController_getLinearVelocity not implemented for WASM yet.");
    } else {
        basis.bindings.fp._CharacterController_getLinearVelocity(cppPtr, linearVelocity);
    }
}

pub fn CharacterController_addRef(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        @compileError("CharacterController_addRef not implemented for WASM yet.");
    } else {
        basis.bindings.fp._CharacterController_addRef(cppPtr);
    }
}

pub fn CharacterController_release(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        @compileError("CharacterController_release not implemented for WASM yet.");
    } else {
        basis.bindings.fp._CharacterController_release(cppPtr);
    }
}

// ===============================

// class VehicleController

pub fn VehicleController_createVehicleController(physicsEngineCppPtr: u64, desc: [*c]const basis.bindings.InteropVehCtrlDesc, controllerType: i32) u64 {
    if (isWasm) {
        @compileError("VehicleController_createVehicleController not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._VehicleController_createVehicleController(physicsEngineCppPtr, desc, controllerType);
    }
}

pub fn VehicleController_reinit(cppPtr: basis.CppPtr, desc: [*c]const basis.bindings.InteropVehCtrlDesc) void {
    if (isWasm) {
        @compileError("VehicleController_reinit not implemented for WASM yet.");
    } else {
        basis.bindings.fp._VehicleController_reinit(cppPtr, desc);
    }
}

pub fn VehicleController_setInputData(cppPtr: basis.CppPtr, inputData: [*c]const basis.bindings.InteropVehInputData) void {
    if (isWasm) {
        @compileError("VehicleController_setInputData not implemented for WASM yet.");
    } else {
        basis.bindings.fp._VehicleController_setInputData(cppPtr, inputData);
    }
}

pub fn VehicleController_getInputData(cppPtr: basis.CppPtr, inputData: [*c]basis.bindings.InteropVehInputData) void {
    if (isWasm) {
        @compileError("VehicleController_getInputData not implemented for WASM yet.");
    } else {
        basis.bindings.fp._VehicleController_getInputData(cppPtr, inputData);
    }
}

pub fn VehicleController_startGearChange(cppPtr: basis.CppPtr, targetGear: i32) void {
    if (isWasm) {
        @compileError("VehicleController_startGearChange not implemented for WASM yet.");
    } else {
        basis.bindings.fp._VehicleController_startGearChange(cppPtr, targetGear);
    }
}

pub fn VehicleController_forceGearChange(cppPtr: basis.CppPtr, targetGear: i32) void {
    if (isWasm) {
        @compileError("VehicleController_forceGearChange not implemented for WASM yet.");
    } else {
        basis.bindings.fp._VehicleController_forceGearChange(cppPtr, targetGear);
    }
}

pub fn VehicleController_freezeInputData(cppPtr: basis.CppPtr, forceBrakes: c_int) void {
    if (isWasm) {
        @compileError("VehicleController_freezeInputData not implemented for WASM yet.");
    } else {
        basis.bindings.fp._VehicleController_freezeInputData(cppPtr, forceBrakes);
    }
}

pub fn VehicleController_unfreezeInputData(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        @compileError("VehicleController_unfreezeInputData not implemented for WASM yet.");
    } else {
        basis.bindings.fp._VehicleController_unfreezeInputData(cppPtr);
    }
}

pub fn VehicleController_getWheelCount(cppPtr: basis.CppPtr) u32 {
    if (isWasm) {
        @compileError("VehicleController_getWheelCount not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._VehicleController_getWheelCount(cppPtr);
    }
}

pub fn VehicleController_getWheelStateInfo(cppPtr: basis.CppPtr, wheelIndex: u32, stateInfo: [*c]basis.bindings.InteropVehWheelStateInfo) void {
    if (isWasm) {
        @compileError("VehicleController_getWheelStateInfo not implemented for WASM yet.");
    } else {
        basis.bindings.fp._VehicleController_getWheelStateInfo(cppPtr, wheelIndex, stateInfo);
    }
}

pub fn VehicleController_getStateInfo(cppPtr: basis.CppPtr, stateInfo: [*c]basis.bindings.InteropVehStateInfo) void {
    if (isWasm) {
        @compileError("VehicleController_getStateInfo not implemented for WASM yet.");
    } else {
        basis.bindings.fp._VehicleController_getStateInfo(cppPtr, stateInfo);
    }
}

pub fn VehicleController_getFastestWheelRotationSpeed(cppPtr: basis.CppPtr) f32 {
    if (isWasm) {
        @compileError("VehicleController_getFastestWheelRotationSpeed not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._VehicleController_getFastestWheelRotationSpeed(cppPtr);
    }
}

pub fn VehicleController_addRef(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        @compileError("VehicleController_addRef not implemented for WASM yet.");
    } else {
        basis.bindings.fp._VehicleController_addRef(cppPtr);
    }
}

pub fn VehicleController_release(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        @compileError("VehicleController_release not implemented for WASM yet.");
    } else {
        basis.bindings.fp._VehicleController_release(cppPtr);
    }
}

// ===============================

// class ResourceManager

pub fn ResourceManager_init() basis.CppPtr {
    if (isWasm) {
        return access.ResourceManager_init_WASM();
    } else {
        return basis.bindings.fp._ResourceManager_init();
    }
}

pub fn ResourceManager_deinit() void {
    if (isWasm) {
        access.ResourceManager_deinit_WASM();
    } else {
        basis.bindings.fp._ResourceManager_deinit();
    }
}

pub fn ResourceManager_acquireResource(cppPtr: basis.CppPtr, resourcePath: [*c]const basis.bindings.InteropString, resourceType: i32) basis.CppPtr {
    if (isWasm) {
        return access.ResourceManager_acquireResource_WASM(cppPtr, resourcePath.*.ptr, resourcePath.*.len, resourceType);
    } else {
        return basis.bindings.fp._ResourceManager_acquireResource(cppPtr, resourcePath, resourceType);
    }
}

pub fn ResourceManager_lock(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.ResourceManager_lock_WASM(cppPtr);
    } else {
        basis.bindings.fp._ResourceManager_lock(cppPtr);
    }
}

pub fn ResourceManager_unlock(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.ResourceManager_unlock_WASM(cppPtr);
    } else {
        basis.bindings.fp._ResourceManager_unlock(cppPtr);
    }
}

pub fn ResourceManager_registerResourceReloadedCallback(resourceCppPtr: basis.CppPtr, callbackID: u32) void {
    if (isWasm) {
        access.ResourceManager_registerResourceReloadedCallback_WASM(resourceCppPtr, callbackID);
    } else {
        basis.bindings.fp._ResourceManager_registerResourceReloadedCallback(resourceCppPtr, callbackID);
    }
}

pub fn ResourceManager_unregisterResourceReloadedCallback(resourceCppPtr: basis.CppPtr, callbackID: u32) void {
    if (isWasm) {
        access.ResourceManager_unregisterResourceReloadedCallback_WASM(resourceCppPtr, callbackID);
    } else {
        basis.bindings.fp._ResourceManager_unregisterResourceReloadedCallback(resourceCppPtr, callbackID);
    }
}

pub fn ResourceManager_beginGetResourcesWithFileExtension(cppPtr: basis.CppPtr, fileExtension: [*c]const basis.bindings.InteropString, resourceCount: [*c]u32) [*c]const basis.bindings.InteropString {
    if (isWasm) {
        @compileError("ResourceManager_beginGetResourcesWithFileExtension not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._ResourceManager_beginGetResourcesWithFileExtension(cppPtr, fileExtension, resourceCount);
    }
}

pub fn ResourceManager_endGetResourcesWithFileExtension() void {
    if (isWasm) {
        @compileError("ResourceManager_endGetResourcesWithFileExtension not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ResourceManager_endGetResourcesWithFileExtension();
    }
}

pub fn ResourceManager_addLooseFileResourcePack(cppPtr: basis.CppPtr, resourcePackName: [*c]const basis.bindings.InteropString, mappings: [*c]const basis.bindings.InteropLooseFileMapping, mappingCount: u32) void {
    if (isWasm) {
        @compileError("ResourceManager_addLooseFileResourcePack not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ResourceManager_addLooseFileResourcePack(cppPtr, resourcePackName, mappings, mappingCount);
    }
}

pub fn ResourceManager_getSourceFilePathForResource(cppPtr: basis.CppPtr, resourcePath: [*c]const basis.bindings.InteropString, sourceFilePath: [*c]basis.bindings.InteropString) c_int {
    if (isWasm) {
        @compileError("ResourceManager_getSourceFilePathForResource not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._ResourceManager_getSourceFilePathForResource(cppPtr, resourcePath, sourceFilePath);
    }
}

// ===============================

// class Resource

pub fn Resource_getSharedMesh(cppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.Resource_getSharedMesh_WASM(cppPtr);
    } else {
        return basis.bindings.fp._Resource_getSharedMesh(cppPtr);
    }
}

pub fn Resource_hasPhysicsMesh(cppPtr: basis.CppPtr) c_int {
    if (isWasm) {
        return access.Resource_hasPhysicsMesh_WASM(cppPtr);
    } else {
        return basis.bindings.fp._Resource_hasPhysicsMesh(cppPtr);
    }
}

pub fn Resource_getPhysicsMeshData(cppPtr: basis.CppPtr, data: [*c]basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("Resource_getPhysicsMeshData not implemented for WASM yet.");
    } else {
        basis.bindings.fp._Resource_getPhysicsMeshData(cppPtr, data);
    }
}

pub fn Resource_getSharedMaterial(cppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.Resource_getSharedMaterial_WASM(cppPtr);
    } else {
        return basis.bindings.fp._Resource_getSharedMaterial(cppPtr);
    }
}

pub fn Resource_getRawData(cppPtr: basis.CppPtr, data: [*c]basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("Resource_getRawData not implemented for WASM yet.");
    } else {
        basis.bindings.fp._Resource_getRawData(cppPtr, data);
    }
}

pub fn Resource_addRef(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.Resource_addRef_WASM(cppPtr);
    } else {
        basis.bindings.fp._Resource_addRef(cppPtr);
    }
}

pub fn Resource_release(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.Resource_release_WASM(cppPtr);
    } else {
        basis.bindings.fp._Resource_release(cppPtr);
    }
}

// ===============================

// class Renderer

pub fn Renderer_getPrimaryScene(cppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.Renderer_getPrimaryScene_WASM(cppPtr);
    } else {
        return basis.bindings.fp._Renderer_getPrimaryScene(cppPtr);
    }
}

pub fn Renderer_addCameraToBackOfQueue(cppPtr: basis.CppPtr, cameraCppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.Renderer_addCameraToBackOfQueue_WASM(cppPtr, cameraCppPtr);
    } else {
        basis.bindings.fp._Renderer_addCameraToBackOfQueue(cppPtr, cameraCppPtr);
    }
}

pub fn Renderer_addCameraToFrontOfQueue(cppPtr: basis.CppPtr, cameraCppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.Renderer_addCameraToFrontOfQueue_WASM(cppPtr, cameraCppPtr);
    } else {
        basis.bindings.fp._Renderer_addCameraToFrontOfQueue(cppPtr, cameraCppPtr);
    }
}

pub fn Renderer_removeCameraFromQueue(cppPtr: basis.CppPtr, cameraCppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.Renderer_removeCameraFromQueue_WASM(cppPtr, cameraCppPtr);
    } else {
        basis.bindings.fp._Renderer_removeCameraFromQueue(cppPtr, cameraCppPtr);
    }
}

pub fn Renderer_getMainCamera(cppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.Renderer_getMainCamera_WASM(cppPtr);
    } else {
        return basis.bindings.fp._Renderer_getMainCamera(cppPtr);
    }
}

pub fn Renderer_getWindowWidth(cppPtr: basis.CppPtr) u32 {
    if (isWasm) {
        return access.Renderer_getWindowWidth_WASM(cppPtr);
    } else {
        return basis.bindings.fp._Renderer_getWindowWidth(cppPtr);
    }
}

pub fn Renderer_getWindowHeight(cppPtr: basis.CppPtr) u32 {
    if (isWasm) {
        return access.Renderer_getWindowHeight_WASM(cppPtr);
    } else {
        return basis.bindings.fp._Renderer_getWindowHeight(cppPtr);
    }
}

pub fn Renderer_getRenderWidth(cppPtr: basis.CppPtr) u32 {
    if (isWasm) {
        return access.Renderer_getRenderWidth_WASM(cppPtr);
    } else {
        return basis.bindings.fp._Renderer_getRenderWidth(cppPtr);
    }
}

pub fn Renderer_getRenderHeight(cppPtr: basis.CppPtr) u32 {
    if (isWasm) {
        return access.Renderer_getRenderHeight_WASM(cppPtr);
    } else {
        return basis.bindings.fp._Renderer_getRenderHeight(cppPtr);
    }
}

pub fn Renderer_getRenderScale(cppPtr: basis.CppPtr) f32 {
    if (isWasm) {
        return access.Renderer_getRenderScale_WASM(cppPtr);
    } else {
        return basis.bindings.fp._Renderer_getRenderScale(cppPtr);
    }
}

pub fn Renderer_setRenderScale(cppPtr: basis.CppPtr, scale: f32) void {
    if (isWasm) {
        access.Renderer_setRenderScale_WASM(cppPtr, scale);
    } else {
        basis.bindings.fp._Renderer_setRenderScale(cppPtr, scale);
    }
}

pub fn Renderer_setGraphicsOption(cppPtr: basis.CppPtr, optionId: c_int, value: c_int) void {
    if (isWasm) {
        @compileError("Renderer_setGraphicsOption is not available in WASM.");
    } else {
        basis.bindings.fp._Renderer_setGraphicsOption(cppPtr, optionId, value);
    }
}

pub fn Renderer_createMesh(cppPtr: basis.CppPtr, geomCppPtr: basis.CppPtr, createImmutableGPUBuffers: bool, debugName: [*c]const basis.bindings.InteropString) basis.CppPtr {
    if (isWasm) {
        return access.Renderer_createMesh_WASM(
            cppPtr,
            geomCppPtr,
            createImmutableGPUBuffers,
            debugName.*.ptr,
            debugName.*.len,
        );
    } else {
        return basis.bindings.fp._Renderer_createMesh(cppPtr, geomCppPtr, if (createImmutableGPUBuffers) 1 else 0, debugName);
    }
}

pub fn Renderer_createMeshManual(cppPtr: basis.CppPtr, vertexFormatType: c_int, vertexCount: u32, indexCount: u32, debugName: [*c]const basis.bindings.InteropString) basis.CppPtr {
    if (isWasm) {
        return access.Renderer_createMeshManual_WASM(
            cppPtr,
            vertexFormatType,
            vertexCount,
            indexCount,
            debugName.*.ptr,
            debugName.*.len,
        );
    } else {
        return basis.bindings.fp._Renderer_createMeshManual(cppPtr, vertexFormatType, vertexCount, indexCount, debugName);
    }
}

pub fn Renderer_captureSinglePre2DFrame(cppPtr: basis.CppPtr, outputFolderPath: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("Renderer_captureSinglePre2DFrame not implemented for WASM yet.");
    } else {
        basis.bindings.fp._Renderer_captureSinglePre2DFrame(cppPtr, outputFolderPath);
    }
}

pub fn Renderer_captureSingleFullEndUserFrame(cppPtr: basis.CppPtr, outputFolderPath: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("Renderer_captureSingleFullEndUserFrame not implemented for WASM yet.");
    } else {
        basis.bindings.fp._Renderer_captureSingleFullEndUserFrame(cppPtr, outputFolderPath);
    }
}

pub fn Renderer_captureSingleFullFrame(cppPtr: basis.CppPtr, outputFolderPath: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("Renderer_captureSingleFullFrame not implemented for WASM yet.");
    } else {
        basis.bindings.fp._Renderer_captureSingleFullFrame(cppPtr, outputFolderPath);
    }
}

pub fn Renderer_startCapturingPre2DFrames(cppPtr: basis.CppPtr, outputFolderPath: [*c]const basis.bindings.InteropString, debugDrawInfo: c_int, interval: u32) void {
    if (isWasm) {
        @compileError("Renderer_startCapturingPre2DFrames not implemented for WASM yet.");
    } else {
        basis.bindings.fp._Renderer_startCapturingPre2DFrames(cppPtr, outputFolderPath, debugDrawInfo, interval);
    }
}

pub fn Renderer_startCapturingFullEndUserFrames(cppPtr: basis.CppPtr, outputFolderPath: [*c]const basis.bindings.InteropString, debugDrawInfo: c_int, interval: u32) void {
    if (isWasm) {
        @compileError("Renderer_startCapturingFullEndUserFrames not implemented for WASM yet.");
    } else {
        basis.bindings.fp._Renderer_startCapturingFullEndUserFrames(cppPtr, outputFolderPath, debugDrawInfo, interval);
    }
}

pub fn Renderer_startCapturingFullFrames(cppPtr: basis.CppPtr, outputFolderPath: [*c]const basis.bindings.InteropString, debugDrawInfo: c_int, interval: u32) void {
    if (isWasm) {
        @compileError("Renderer_startCapturingFullFrames not implemented for WASM yet.");
    } else {
        basis.bindings.fp._Renderer_startCapturingFullFrames(cppPtr, outputFolderPath, debugDrawInfo, interval);
    }
}

pub fn Renderer_stopCapturingFrames(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        @compileError("Renderer_stopCapturingFrames not implemented for WASM yet.");
    } else {
        basis.bindings.fp._Renderer_stopCapturingFrames(cppPtr);
    }
}

pub fn Renderer_applyDisplayOptions(cppPtr: basis.CppPtr, renderWindowMode: i32, width: i32, height: i32, vsync: bool, framerateLimit: i32) void {
    if (isWasm) {
        @compileError("Renderer_applyDisplayOptions not implemented for WASM yet.");
    } else {
        basis.bindings.fp._Renderer_applyDisplayOptions(cppPtr, renderWindowMode, width, height, if (vsync) 1 else 0, framerateLimit);
    }
}

pub fn Renderer_applyVsyncAndFramerateLimit(cppPtr: basis.CppPtr, vsync: bool, framerateLimit: i32) void {
    if (isWasm) {
        @compileError("Renderer_applyVsyncAndFramerateLimit not implemented for WASM yet.");
    } else {
        basis.bindings.fp._Renderer_applyVsyncAndFramerateLimit(cppPtr, if (vsync) 1 else 0, framerateLimit);
    }
}

pub fn Renderer_getWindowMode(cppPtr: basis.CppPtr) i32 {
    if (isWasm) {
        @compileError("Renderer_getWindowMode not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._Renderer_getWindowMode(cppPtr);
    }
}

pub fn Renderer_getDisplacementEffectRenderer(cppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        @compileError("Renderer_getDisplacementEffectRenderer not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._Renderer_getDisplacementEffectRenderer(cppPtr);
    }
}

// ===============================

// class RenderScene

pub fn RenderScene_getRootSceneNode(cppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.RenderScene_getRootSceneNode_WASM(cppPtr);
    } else {
        return basis.bindings.fp._RenderScene_getRootSceneNode(cppPtr);
    }
}

pub fn RenderScene_destroySceneNode(cppPtr: basis.CppPtr, sceneNodeCppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.RenderScene_destroySceneNode_WASM(cppPtr, sceneNodeCppPtr);
    } else {
        basis.bindings.fp._RenderScene_destroySceneNode(cppPtr, sceneNodeCppPtr);
    }
}

pub fn RenderScene_createCamera(cppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.RenderScene_createCamera_WASM(cppPtr);
    } else {
        return basis.bindings.fp._RenderScene_createCamera(cppPtr);
    }
}

pub fn RenderScene_destroyCamera(cppPtr: basis.CppPtr, cameraCppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.RenderScene_destroyCamera_WASM(cppPtr, cameraCppPtr);
    } else {
        basis.bindings.fp._RenderScene_destroyCamera(cppPtr, cameraCppPtr);
    }
}

pub fn RenderScene_createDynamicMeshInstance(cppPtr: basis.CppPtr, mesh: basis.CppPtr, materials: [*c]basis.CppPtr, materialCount: u32) basis.CppPtr {
    if (isWasm) {
        var buffer: [128]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.putInt(basis.CppPtr, mesh);
        stream.putInt(u32, materialCount);
        for (0..materialCount) |i| {
            stream.putInt(basis.CppPtr, materials[i]);
        }
        return access.RenderScene_createDynamicMeshInstance_WASM(cppPtr, &buffer, @intCast(stream.cursorPosition));
    } else {
        return basis.bindings.fp._RenderScene_createDynamicMeshInstance(cppPtr, mesh, materials, materialCount);
    }
}

pub fn RenderScene_createStaticMeshInstance(cppPtr: basis.CppPtr, mesh: basis.CppPtr, materials: [*c]basis.CppPtr, materialCount: u32, addToBVH: bool) basis.CppPtr {
    if (isWasm) {
        var buffer: [128]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.putInt(basis.CppPtr, mesh);
        stream.putInt(u32, materialCount);
        for (0..materialCount) |i| {
            stream.putInt(basis.CppPtr, materials[i]);
        }
        return access.RenderScene_createStaticMeshInstance_WASM(cppPtr, &buffer, @intCast(stream.cursorPosition), addToBVH);
    } else {
        return basis.bindings.fp._RenderScene_createStaticMeshInstance(cppPtr, mesh, materials, materialCount, if (addToBVH) 1 else 0);
    }
}

pub fn RenderScene_destroyMeshInstance(cppPtr: basis.CppPtr, meshInstanceCppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.RenderScene_destroyMeshInstance_WASM(cppPtr, meshInstanceCppPtr);
    } else {
        basis.bindings.fp._RenderScene_destroyMeshInstance(cppPtr, meshInstanceCppPtr);
    }
}

pub fn RenderScene_castRay(
    cppPtr: basis.CppPtr,
    rayOrigin: [*c]const basis.bindings.InteropVec3,
    rayDirection: [*c]const basis.bindings.InteropVec3,
    result: [*c]basis.bindings.RendererInteropRayCastResult,
    hitGroupMask: u32,
    onlyAABB: c_int,
) c_int {
    if (isWasm) {
        var buffer: [128]u8 = undefined;

        var writePos: usize = 0;
        {
            var stream = basis.BinaryWriteStream.init(&buffer, true);
            stream.put(Vec3, Vec3.fromInterop(rayOrigin));
            stream.put(Vec3, Vec3.fromInterop(rayDirection));
            stream.putInt(u32, hitGroupMask);
            stream.putBool(onlyAABB == 1);
            writePos = @intCast(stream.cursorPosition);
        }

        const ret = access.RenderScene_castRay_WASM(cppPtr, &buffer, writePos);

        if (ret == 1) {
            var stream = basis.BinaryReadStream.init(&buffer, true);

            result.*.hitPoint = stream.get(Vec3).toInterop();
            result.*.hitPointNormal = stream.get(Vec3).toInterop();
            result.*.hitObject = stream.getInt(usize);
        }

        return ret;
    } else {
        return basis.bindings.fp._RenderScene_castRay(cppPtr, rayOrigin, rayDirection, result, hitGroupMask, onlyAABB);
    }
}

pub fn RenderScene_getTireTrackRenderer(cppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.RenderScene_getTireTrackRenderer_WASM(cppPtr);
    } else {
        return basis.bindings.fp._RenderScene_getTireTrackRenderer(cppPtr);
    }
}

// ===============================

// class TireTrackRenderer

pub fn TireTrackRenderer_clear(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        @compileError("TireTrackRenderer_clear not implemented for WASM yet.");
    } else {
        basis.bindings.fp._TireTrackRenderer_clear(cppPtr);
    }
}

pub fn TireTrackRenderer_registerTire(cppPtr: basis.CppPtr, width: f32, isRightSideTire: bool, tireType: u32) u32 {
    if (isWasm) {
        @compileError("TireTrackRenderer_registerTire not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._TireTrackRenderer_registerTire(cppPtr, width, if (isRightSideTire) 1 else 0, tireType);
    }
}

pub fn TireTrackRenderer_unregisterTire(cppPtr: basis.CppPtr, id: u32) void {
    if (isWasm) {
        @compileError("TireTrackRenderer_unregisterTire not implemented for WASM yet.");
    } else {
        basis.bindings.fp._TireTrackRenderer_unregisterTire(cppPtr, id);
    }
}

pub fn TireTrackRenderer_beginTireTrack(cppPtr: basis.CppPtr, id: u32) void {
    if (isWasm) {
        @compileError("TireTrackRenderer_beginTireTrack not implemented for WASM yet.");
    } else {
        basis.bindings.fp._TireTrackRenderer_beginTireTrack(cppPtr, id);
    }
}

pub fn TireTrackRenderer_endTireTrack(cppPtr: basis.CppPtr, id: u32) void {
    if (isWasm) {
        @compileError("TireTrackRenderer_endTireTrack not implemented for WASM yet.");
    } else {
        basis.bindings.fp._TireTrackRenderer_endTireTrack(cppPtr, id);
    }
}

pub fn TireTrackRenderer_updateTireTrack(cppPtr: basis.CppPtr, id: u32, contactPosition: [*c]const basis.bindings.InteropVec3, movementDirection: [*c]const basis.bindings.InteropVec3, longitudinalSlip: f32, lateralSlip: f32, groundNormal: [*c]const basis.bindings.InteropVec3) void {
    if (isWasm) {
        @compileError("TireTrackRenderer_updateTireTrack not implemented for WASM yet.");
    } else {
        basis.bindings.fp._TireTrackRenderer_updateTireTrack(cppPtr, id, contactPosition, movementDirection, longitudinalSlip, lateralSlip, groundNormal);
    }
}

pub fn TireTrackRenderer_beginStaticTireTrack(cppPtr: basis.CppPtr, width: f32, isRightSideTire: bool, tireType: u32) u32 {
    if (isWasm) {
        @compileError("TireTrackRenderer_beginStaticTireTrack not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._TireTrackRenderer_beginStaticTireTrack(cppPtr, width, if (isRightSideTire) 1 else 0, tireType);
    }
}

pub fn TireTrackRenderer_addPointToStaticTireTrack(cppPtr: basis.CppPtr, id: u32, contactPosition: [*c]const basis.bindings.InteropVec3, movementDirection: [*c]const basis.bindings.InteropVec3, longitudinalSlip: f32, lateralSlip: f32, groundNormal: [*c]const basis.bindings.InteropVec3, alpha: f32) void {
    if (isWasm) {
        @compileError("TireTrackRenderer_addPointToStaticTireTrack not implemented for WASM yet.");
    } else {
        basis.bindings.fp._TireTrackRenderer_addPointToStaticTireTrack(cppPtr, id, contactPosition, movementDirection, longitudinalSlip, lateralSlip, groundNormal, alpha);
    }
}

pub fn TireTrackRenderer_endStaticTireTrack(cppPtr: basis.CppPtr, id: u32) void {
    if (isWasm) {
        @compileError("TireTrackRenderer_endStaticTireTrack not implemented for WASM yet.");
    } else {
        basis.bindings.fp._TireTrackRenderer_endStaticTireTrack(cppPtr, id);
    }
}

pub fn TireTrackRenderer_removeStaticTireTrack(cppPtr: basis.CppPtr, id: u32) void {
    if (isWasm) {
        @compileError("TireTrackRenderer_removeStaticTireTrack not implemented for WASM yet.");
    } else {
        basis.bindings.fp._TireTrackRenderer_removeStaticTireTrack(cppPtr, id);
    }
}

// ===============================

// class MeshGeometry

pub fn MeshGeometry_newGeometry() u64 {
    if (isWasm) {
        @compileError("MeshGeometry_newGeometry not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._MeshGeometry_newGeometry();
    }
}

pub fn MeshGeometry_deleteGeometry(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        @compileError("MeshGeometry_deleteGeometry not implemented for WASM yet.");
    } else {
        basis.bindings.fp._MeshGeometry_deleteGeometry(cppPtr);
    }
}

pub fn MeshGeometry_clear(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        @compileError("MeshGeometry_clear not implemented for WASM yet.");
    } else {
        basis.bindings.fp._MeshGeometry_clear(cppPtr);
    }
}

pub fn MeshGeometry_addLodLevel(cppPtr: basis.CppPtr) u64 {
    if (isWasm) {
        @compileError("MeshGeometry_addLodLevel not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._MeshGeometry_addLodLevel(cppPtr);
    }
}

pub fn MeshGeometry_getLodLevel(cppPtr: basis.CppPtr, lodLevelIndex: u8) u64 {
    if (isWasm) {
        @compileError("MeshGeometry_getLodLevel not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._MeshGeometry_getLodLevel(cppPtr, lodLevelIndex);
    }
}

pub fn MeshGeometry_getLodLevelCount(cppPtr: basis.CppPtr) u8 {
    if (isWasm) {
        @compileError("MeshGeometry_getLodLevelCount not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._MeshGeometry_getLodLevelCount(cppPtr);
    }
}

// ===============================

// class MeshGeometryLodLevel

pub fn MeshGeometryLodLevel_clear(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        @compileError("MeshGeometryLodLevel_clear not implemented for WASM yet.");
    } else {
        basis.bindings.fp._MeshGeometryLodLevel_clear(cppPtr);
    }
}

pub fn MeshGeometryLodLevel_addSubMesh(cppPtr: basis.CppPtr, vertexFormatType: c_int) u64 {
    if (isWasm) {
        @compileError("MeshGeometryLodLevel_addSubMesh not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._MeshGeometryLodLevel_addSubMesh(cppPtr, vertexFormatType);
    }
}

pub fn MeshGeometryLodLevel_getSubMesh(cppPtr: basis.CppPtr, subMeshIndex: u8) u64 {
    if (isWasm) {
        @compileError("MeshGeometryLodLevel_getSubMesh not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._MeshGeometryLodLevel_getSubMesh(cppPtr, subMeshIndex);
    }
}

pub fn MeshGeometryLodLevel_getSubMeshCount(cppPtr: basis.CppPtr) u8 {
    if (isWasm) {
        @compileError("MeshGeometryLodLevel_getSubMeshCount not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._MeshGeometryLodLevel_getSubMeshCount(cppPtr);
    }
}

// ===============================

// class MeshGeometrySubMesh

pub fn MeshGeometrySubMesh_clear(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        @compileError("MeshGeometrySubMesh_clear not implemented for WASM yet.");
    } else {
        basis.bindings.fp._MeshGeometrySubMesh_clear(cppPtr);
    }
}

pub fn MeshGeometrySubMesh_addIndex(cppPtr: basis.CppPtr, index: u16) void {
    if (isWasm) {
        @compileError("MeshGeometrySubMesh_addIndex not implemented for WASM yet.");
    } else {
        basis.bindings.fp._MeshGeometrySubMesh_addIndex(cppPtr, index);
    }
}

pub fn MeshGeometrySubMesh_addFace(cppPtr: basis.CppPtr, index0: u16, index1: u16, index2: u16) void {
    if (isWasm) {
        @compileError("MeshGeometrySubMesh_addFace not implemented for WASM yet.");
    } else {
        basis.bindings.fp._MeshGeometrySubMesh_addFace(cppPtr, index0, index1, index2);
    }
}

pub fn MeshGeometrySubMesh_addVertex(cppPtr: basis.CppPtr, vertex: [*c]const u8, vertexSize: u32) void {
    if (isWasm) {
        @compileError("MeshGeometrySubMesh_addVertex not implemented for WASM yet.");
    } else {
        basis.bindings.fp._MeshGeometrySubMesh_addVertex(cppPtr, vertex, vertexSize);
    }
}

pub fn MeshGeometrySubMesh_getVertexFormatType(cppPtr: basis.CppPtr) c_int {
    if (isWasm) {
        @compileError("MeshGeometrySubMesh_getVertexFormatType not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._MeshGeometrySubMesh_getVertexFormatType(cppPtr);
    }
}

pub fn MeshGeometrySubMesh_getVertexCount(cppPtr: basis.CppPtr) u32 {
    if (isWasm) {
        @compileError("MeshGeometrySubMesh_getVertexCount not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._MeshGeometrySubMesh_getVertexCount(cppPtr);
    }
}

pub fn MeshGeometrySubMesh_getIndexCount(cppPtr: basis.CppPtr) u32 {
    if (isWasm) {
        @compileError("MeshGeometrySubMesh_getIndexCount not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._MeshGeometrySubMesh_getIndexCount(cppPtr);
    }
}

// ===============================

// class Mesh

pub fn Mesh_getLodLevelCount(cppPtr: basis.CppPtr) u8 {
    if (isWasm) {
        return access.Mesh_getLodLevelCount_WASM(cppPtr);
    } else {
        return basis.bindings.fp._Mesh_getLodLevelCount(cppPtr);
    }
}

pub fn Mesh_getLodLevel(cppPtr: basis.CppPtr, lodLevelIndex: u8) basis.CppPtr {
    if (isWasm) {
        return access.Mesh_getLodLevel_WASM(cppPtr, lodLevelIndex);
    } else {
        return basis.bindings.fp._Mesh_getLodLevel(cppPtr, lodLevelIndex);
    }
}

pub fn Mesh_addRef(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.Mesh_addRef_WASM(cppPtr);
    } else {
        basis.bindings.fp._Mesh_addRef(cppPtr);
    }
}

pub fn Mesh_release(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.Mesh_release_WASM(cppPtr);
    } else {
        basis.bindings.fp._Mesh_release(cppPtr);
    }
}

// ===============================

// class MeshLodLevel

pub fn MeshLodLevel_getSubMeshCount(cppPtr: basis.CppPtr) u8 {
    if (isWasm) {
        @compileError("MeshLodLevel_getSubMeshCount not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._MeshLodLevel_getSubMeshCount(cppPtr);
    }
}

pub fn MeshLodLevel_setSubMeshCount(cppPtr: basis.CppPtr, count: u8) void {
    if (isWasm) {
        @compileError("MeshLodLevel_setSubMeshCount not implemented for WASM yet.");
    } else {
        basis.bindings.fp._MeshLodLevel_setSubMeshCount(cppPtr, count);
    }
}

pub fn MeshLodLevel_getSubMesh(cppPtr: basis.CppPtr, subMeshIndex: u8) u64 {
    if (isWasm) {
        @compileError("MeshLodLevel_getSubMesh not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._MeshLodLevel_getSubMesh(cppPtr, subMeshIndex);
    }
}

pub fn MeshLodLevel_getBounds(cppPtr: basis.CppPtr, min: [*c]basis.bindings.InteropVec3, max: [*c]basis.bindings.InteropVec3) void {
    if (isWasm) {
        @compileError("MeshLodLevel_getBounds not implemented for WASM yet.");
    } else {
        basis.bindings.fp._MeshLodLevel_getBounds(cppPtr, min, max);
    }
}

pub fn MeshLodLevel_setBounds(cppPtr: basis.CppPtr, min: [*c]const basis.bindings.InteropVec3, max: [*c]const basis.bindings.InteropVec3) void {
    if (isWasm) {
        @compileError("MeshLodLevel_setBounds not implemented for WASM yet.");
    } else {
        basis.bindings.fp._MeshLodLevel_setBounds(cppPtr, min, max);
    }
}

// ===============================

// class MeshSubMesh

pub fn MeshSubMesh_getVertexFormatType(cppPtr: basis.CppPtr) c_int {
    if (isWasm) {
        @compileError("MeshSubMesh_getVertexFormatType not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._MeshSubMesh_getVertexFormatType(cppPtr);
    }
}

pub fn MeshSubMesh_getVertexCount(cppPtr: basis.CppPtr) u32 {
    if (isWasm) {
        @compileError("MeshSubMesh_getVertexCount not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._MeshSubMesh_getVertexCount(cppPtr);
    }
}

pub fn MeshSubMesh_setVertexCount(cppPtr: basis.CppPtr, count: u32) void {
    if (isWasm) {
        @compileError("MeshSubMesh_setVertexCount not implemented for WASM yet.");
    } else {
        basis.bindings.fp._MeshSubMesh_setVertexCount(cppPtr, count);
    }
}

pub fn MeshSubMesh_getIndexCount(cppPtr: basis.CppPtr) u32 {
    if (isWasm) {
        @compileError("MeshSubMesh_getIndexCount not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._MeshSubMesh_getIndexCount(cppPtr);
    }
}

pub fn MeshSubMesh_setIndexCount(cppPtr: basis.CppPtr, count: u32) void {
    if (isWasm) {
        @compileError("MeshSubMesh_setIndexCount not implemented for WASM yet.");
    } else {
        basis.bindings.fp._MeshSubMesh_setIndexCount(cppPtr, count);
    }
}

pub fn MeshSubMesh_getVertices(cppPtr: basis.CppPtr, bufferSize: [*c]u32) [*c]u8 {
    if (isWasm) {
        @compileError("MeshSubMesh_getVertices not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._MeshSubMesh_getVertices(cppPtr, bufferSize);
    }
}

pub fn MeshSubMesh_getIndices(cppPtr: basis.CppPtr, bufferSize: [*c]u32) [*c]u16 {
    if (isWasm) {
        @compileError("MeshSubMesh_getIndices not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._MeshSubMesh_getIndices(cppPtr, bufferSize);
    }
}

// ===============================

// class Material

pub fn Material_addRef(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.Material_addRef_WASM(cppPtr);
    } else {
        basis.bindings.fp._Material_addRef(cppPtr);
    }
}

pub fn Material_release(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.Material_release_WASM(cppPtr);
    } else {
        basis.bindings.fp._Material_release(cppPtr);
    }
}

// ===============================

// class MeshInstance

pub fn MeshInstance_setVisible(cppPtr: basis.CppPtr, visible: bool) void {
    if (isWasm) {
        access.MeshInstance_setVisible_WASM(cppPtr, visible);
    } else {
        basis.bindings.fp._MeshInstance_setVisible(cppPtr, if (visible) 1 else 0);
    }
}

pub fn MeshInstance_isVisible(cppPtr: basis.CppPtr) bool {
    if (isWasm) {
        return access.MeshInstance_isVisible_WASM(cppPtr);
    } else {
        return basis.bindings.fp._MeshInstance_isVisible(cppPtr) == 1;
    }
}

pub fn MeshInstance_getMaterial(cppPtr: basis.CppPtr, subMeshIndex: u32) basis.CppPtr {
    if (isWasm) {
        return access.MeshInstance_getMaterial_WASM(cppPtr, subMeshIndex);
    } else {
        return basis.bindings.fp._MeshInstance_getMaterial(cppPtr, subMeshIndex);
    }
}

pub fn MeshInstance_setMaterial(cppPtr: basis.CppPtr, materialCppPtr: basis.CppPtr, subMeshIndex: u32) void {
    if (isWasm) {
        access.MeshInstance_setMaterial_WASM(cppPtr, materialCppPtr, subMeshIndex);
    } else {
        basis.bindings.fp._MeshInstance_setMaterial(cppPtr, materialCppPtr, subMeshIndex);
    }
}

pub fn MeshInstance_getFlags(cppPtr: basis.CppPtr) c_int {
    if (isWasm) {
        return access.MeshInstance_getFlags_WASM(cppPtr);
    } else {
        return basis.bindings.fp._MeshInstance_getFlags(cppPtr);
    }
}

pub fn MeshInstance_isFlagSet(cppPtr: basis.CppPtr, flag: c_int) c_int {
    if (isWasm) {
        return access.MeshInstance_isFlagSet_WASM(cppPtr, flag);
    } else {
        return basis.bindings.fp._MeshInstance_isFlagSet(cppPtr, flag);
    }
}

pub fn MeshInstance_setFlagValue(cppPtr: basis.CppPtr, flag: c_int, value: c_int) void {
    if (isWasm) {
        access.MeshInstance_setFlagValue_WASM(cppPtr, flag, value);
    } else {
        basis.bindings.fp._MeshInstance_setFlagValue(cppPtr, flag, value);
    }
}

pub fn MeshInstance_updateLightProbeData(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.MeshInstance_updateLightProbeData_WASM(cppPtr);
    } else {
        basis.bindings.fp._MeshInstance_updateLightProbeData(cppPtr);
    }
}

pub fn MeshInstance_getParentSceneNode(cppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.MeshInstance_getParentSceneNode_WASM(cppPtr);
    } else {
        return basis.bindings.fp._MeshInstance_getParentSceneNode(cppPtr);
    }
}

pub fn MeshInstance_setCullDistanceMultiplier(cppPtr: basis.CppPtr, multiplier: f32) void {
    if (isWasm) {
        @compileError("MeshInstance_setCullDistanceMultiplier not implemented for WASM yet.");
    } else {
        basis.bindings.fp._MeshInstance_setCullDistanceMultiplier(cppPtr, multiplier);
    }
}

pub fn MeshInstance_getCullDistanceMultiplier(cppPtr: basis.CppPtr) f32 {
    if (isWasm) {
        @compileError("MeshInstance_getCullDistanceMultiplier not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._MeshInstance_getCullDistanceMultiplier(cppPtr);
    }
}

// ===============================

// class Camera

pub fn Camera_setPerspective(cppPtr: basis.CppPtr, fovY: f32, aspectRatio: f32, nearClip: f32, farClip: f32) void {
    if (isWasm) {
        access.Camera_setPerspective_WASM(cppPtr, fovY, aspectRatio, nearClip, farClip);
    } else {
        basis.bindings.fp._Camera_setPerspective(cppPtr, fovY, aspectRatio, nearClip, farClip);
    }
}

pub fn Camera_setOrthographic(cppPtr: basis.CppPtr, width: f32, height: f32, nearClip: f32, farClip: f32) void {
    if (isWasm) {
        access.Camera_setOrthographic_WASM(cppPtr, width, height, nearClip, farClip);
    } else {
        basis.bindings.fp._Camera_setOrthographic(cppPtr, width, height, nearClip, farClip);
    }
}

pub fn Camera_getWorldPosition(cppPtr: basis.CppPtr, worldPosition: [*c]basis.bindings.InteropVec3) void {
    if (isWasm) {
        const SIZE = Vec3Size;
        var buffer: [SIZE]u8 = undefined;

        access.Camera_getWorldPosition_WASM(cppPtr, &buffer, SIZE);
        var stream = basis.BinaryReadStream.init(&buffer, true);
        const v = stream.get(Vec3);
        worldPosition.* = v.toInterop();
    } else {
        basis.bindings.fp._Camera_getWorldPosition(cppPtr, worldPosition);
    }
}

pub fn Camera_getForwardDirection(cppPtr: basis.CppPtr, forwardDirection: [*c]basis.bindings.InteropVec3) void {
    if (isWasm) {
        const SIZE = Vec3Size;
        var buffer: [SIZE]u8 = undefined;

        access.Camera_getForwardDirection_WASM(cppPtr, &buffer, SIZE);
        var stream = basis.BinaryReadStream.init(&buffer, true);
        const v = stream.get(Vec3);
        forwardDirection.* = v.toInterop();
    } else {
        basis.bindings.fp._Camera_getForwardDirection(cppPtr, forwardDirection);
    }
}

pub fn Camera_getFovY(cppPtr: basis.CppPtr) f32 {
    if (isWasm) {
        return access.Camera_getFovY_WASM(cppPtr);
    } else {
        return basis.bindings.fp._Camera_getFovY(cppPtr);
    }
}

pub fn Camera_getFovX(cppPtr: basis.CppPtr) f32 {
    if (isWasm) {
        return access.Camera_getFovX_WASM(cppPtr);
    } else {
        return basis.bindings.fp._Camera_getFovX(cppPtr);
    }
}

pub fn Camera_getNearClip(cppPtr: basis.CppPtr) f32 {
    if (isWasm) {
        return access.Camera_getNearClip_WASM(cppPtr);
    } else {
        return basis.bindings.fp._Camera_getNearClip(cppPtr);
    }
}

pub fn Camera_getFarClip(cppPtr: basis.CppPtr) f32 {
    if (isWasm) {
        return access.Camera_getFarClip_WASM(cppPtr);
    } else {
        return basis.bindings.fp._Camera_getFarClip(cppPtr);
    }
}

pub fn Camera_getPickRay(cppPtr: basis.CppPtr, screenX: c_int, screenY: c_int, space: c_int, rayOrigin: [*c]basis.bindings.InteropVec3, rayDirection: [*c]basis.bindings.InteropVec3) void {
    if (isWasm) {
        const SIZE = 2 * Vec3Size;
        var buffer: [SIZE]u8 = undefined;

        access.Camera_getPickRay_WASM(cppPtr, screenX, screenY, space, &buffer, SIZE);
        var stream = basis.BinaryReadStream.init(&buffer, true);
        const o = stream.get(Vec3);
        const d = stream.get(Vec3);
        rayOrigin.* = o.toInterop();
        rayDirection.* = d.toInterop();
    } else {
        basis.bindings.fp._Camera_getPickRay(cppPtr, screenX, screenY, space, rayOrigin, rayDirection);
    }
}

pub fn Camera_worldToScreen(cppPtr: basis.CppPtr, worldPos: [*c]const basis.bindings.InteropVec3, x: [*c]f32, y: [*c]f32) bool {
    if (isWasm) {
        const SIZE = 2 * @sizeOf(f32);
        var buffer: [SIZE]u8 = undefined;

        const ret = access.Camera_worldToScreen_WASM(cppPtr, worldPos.x, worldPos.y, worldPos.z, &buffer, SIZE);
        if (!ret) return false;
        var stream = basis.BinaryReadStream.init(&buffer, true);
        x.* = stream.getFloat();
        y.* = stream.getFloat();
        return true;
    } else {
        return basis.bindings.fp._Camera_worldToScreen(cppPtr, worldPos, x, y) == 1;
    }
}

pub fn Camera_worldToScreenUnbounded(cppPtr: basis.CppPtr, worldPos: [*c]const basis.bindings.InteropVec3, x: [*c]f32, y: [*c]f32) void {
    if (isWasm) {
        const SIZE = 2 * @sizeOf(f32);
        var buffer: [SIZE]u8 = undefined;

        access.Camera_worldToScreenUnbounded_WASM(cppPtr, worldPos.x, worldPos.y, worldPos.z, &buffer, SIZE);
        var stream = basis.BinaryReadStream.init(&buffer, true);
        x.* = stream.getFloat();
        y.* = stream.getFloat();
    } else {
        basis.bindings.fp._Camera_worldToScreenUnbounded(cppPtr, worldPos, x, y);
    }
}

pub fn Camera_getViewMatrix(cppPtr: basis.CppPtr, returnValue: [*c]basis.bindings.InteropMat43) void {
    if (isWasm) {
        const SIZE = Mat43Size;
        var buffer: [SIZE]u8 = undefined;

        access.Camera_getViewMatrix_WASM(cppPtr, &buffer, SIZE);
        var stream = basis.BinaryReadStream.init(&buffer, true);
        const m = stream.get(Mat43);
        returnValue.* = m.toInterop();
    } else {
        basis.bindings.fp._Camera_getViewMatrix(cppPtr, returnValue);
    }
}

pub fn Camera_getProjectionMatrix(cppPtr: basis.CppPtr, returnValue: [*c]basis.bindings.InteropMat4) void {
    if (isWasm) {
        const SIZE = Mat43Size;
        var buffer: [SIZE]u8 = undefined;

        access.Camera_getProjectionMatrix_WASM(cppPtr, &buffer, SIZE);
        var stream = basis.BinaryReadStream.init(&buffer, true);
        const m = stream.get(Mat4);
        returnValue.* = m.toInterop();
    } else {
        basis.bindings.fp._Camera_getProjectionMatrix(cppPtr, returnValue);
    }
}

pub fn Camera_getParentSceneNode(cppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.Camera_getParentSceneNode_WASM(cppPtr);
    } else {
        return basis.bindings.fp._Camera_getParentSceneNode(cppPtr);
    }
}

// ===============================

// class DisplacementEffectRenderer

pub fn DisplacementEffectRenderer_createShockwaveEffect(cppPtr: basis.CppPtr, position: [*c]const basis.bindings.InteropVec3, radius: f32, duration: f32) u32 {
    if (isWasm) {
        @compileError("DisplacementEffectRenderer_createShockwaveEffect not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._DisplacementEffectRenderer_createShockwaveEffect(cppPtr, position, radius, duration);
    }
}

pub fn DisplacementEffectRenderer_createForceFieldEffect(cppPtr: basis.CppPtr, position: [*c]const basis.bindings.InteropVec3, radius: f32, animationSpeed: f32) u32 {
    if (isWasm) {
        @compileError("DisplacementEffectRenderer_createForceFieldEffect not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._DisplacementEffectRenderer_createForceFieldEffect(cppPtr, position, radius, animationSpeed);
    }
}

pub fn DisplacementEffectRenderer_createGravityCraneEffect(cppPtr: basis.CppPtr, position: [*c]const basis.bindings.InteropVec3, radius: f32, animationSpeed: f32) u32 {
    if (isWasm) {
        @compileError("DisplacementEffectRenderer_createGravityCraneEffect not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._DisplacementEffectRenderer_createGravityCraneEffect(cppPtr, position, radius, animationSpeed);
    }
}

pub fn DisplacementEffectRenderer_setEffectCutoffDistance(cppPtr: basis.CppPtr, id: u32, cutoffDistance: f32) void {
    if (isWasm) {
        @compileError("DisplacementEffectRenderer_setEffectCutoffDistance not implemented for WASM yet.");
    } else {
        basis.bindings.fp._DisplacementEffectRenderer_setEffectCutoffDistance(cppPtr, id, cutoffDistance);
    }
}

pub fn DisplacementEffectRenderer_setEffectPosition(cppPtr: basis.CppPtr, id: u32, position: [*c]const basis.bindings.InteropVec3) void {
    if (isWasm) {
        @compileError("DisplacementEffectRenderer_setEffectPosition not implemented for WASM yet.");
    } else {
        basis.bindings.fp._DisplacementEffectRenderer_setEffectPosition(cppPtr, id, position);
    }
}

pub fn DisplacementEffectRenderer_setEffectStrength(cppPtr: basis.CppPtr, id: u32, strength: f32) void {
    if (isWasm) {
        @compileError("DisplacementEffectRenderer_setEffectStrength not implemented for WASM yet.");
    } else {
        basis.bindings.fp._DisplacementEffectRenderer_setEffectStrength(cppPtr, id, strength);
    }
}

pub fn DisplacementEffectRenderer_stopEffect(cppPtr: basis.CppPtr, id: u32) void {
    if (isWasm) {
        @compileError("DisplacementEffectRenderer_stopEffect not implemented for WASM yet.");
    } else {
        basis.bindings.fp._DisplacementEffectRenderer_stopEffect(cppPtr, id);
    }
}

pub fn DisplacementEffectRenderer_killEffect(cppPtr: basis.CppPtr, id: u32) void {
    if (isWasm) {
        @compileError("DisplacementEffectRenderer_killEffect not implemented for WASM yet.");
    } else {
        basis.bindings.fp._DisplacementEffectRenderer_killEffect(cppPtr, id);
    }
}

pub fn DisplacementEffectRenderer_killAllEffects(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        @compileError("DisplacementEffectRenderer_killAllEffects not implemented for WASM yet.");
    } else {
        basis.bindings.fp._DisplacementEffectRenderer_killAllEffects(cppPtr);
    }
}

// ===============================

// class GameSession

pub fn GameSession_getSessionType(cppPtr: basis.CppPtr) i32 {
    if (isWasm) {
        return access.GameSession_getSessionType_WASM(cppPtr);
    } else {
        return basis.bindings.fp._GameSession_getSessionType(cppPtr);
    }
}

pub fn GameSession_getClientCount(cppPtr: basis.CppPtr) u32 {
    if (isWasm) {
        return access.GameSession_getClientCount_WASM(cppPtr);
    } else {
        return basis.bindings.fp._GameSession_getClientCount(cppPtr);
    }
}

pub fn GameSession_getClient(cppPtr: basis.CppPtr, clientIndex: u32, client: [*c]basis.bindings.InteropClientProxy) void {
    if (isWasm) {
        const SIZE = @sizeOf(i32);
        var buffer: [SIZE]u8 = undefined;

        access.GameSession_getClient_WASM(cppPtr, clientIndex, &buffer, SIZE);
        var stream = basis.BinaryReadStream.init(&buffer, true);
        client.*.hostID = stream.get(i32);
    } else {
        basis.bindings.fp._GameSession_getClient(cppPtr, clientIndex, client);
    }
}

pub fn GameSession_isPaused(cppPtr: basis.CppPtr) i32 {
    if (isWasm) {
        return access.GameSession_isPaused_WASM(cppPtr);
    } else {
        return basis.bindings.fp._GameSession_isPaused(cppPtr);
    }
}

pub fn GameSession_requestPause(cppPtr: basis.CppPtr, paused: i32) void {
    if (isWasm) {
        access.GameSession_requestPause_WASM(cppPtr, paused);
    } else {
        basis.bindings.fp._GameSession_requestPause(cppPtr, paused);
    }
}

pub fn GameSession_getTickLevel(cppPtr: basis.CppPtr) u32 {
    if (isWasm) {
        return access.GameSession_getTickLevel_WASM(cppPtr);
    } else {
        return basis.bindings.fp._GameSession_getTickLevel(cppPtr);
    }
}

pub fn GameSession_setTickLevel(cppPtr: basis.CppPtr, level: u32) void {
    if (isWasm) {
        access.GameSession_setTickLevel_WASM(cppPtr, level);
    } else {
        basis.bindings.fp._GameSession_setTickLevel(cppPtr, level);
    }
}

pub fn GameSession_requestSetTickLevel(cppPtr: basis.CppPtr, level: u32) void {
    if (isWasm) {
        access.GameSession_requestSetTickLevel_WASM(cppPtr, level);
    } else {
        basis.bindings.fp._GameSession_requestSetTickLevel(cppPtr, level);
    }
}

pub fn GameSession_hasStarted(cppPtr: basis.CppPtr) i32 {
    if (isWasm) {
        return access.GameSession_hasStarted_WASM(cppPtr);
    } else {
        return basis.bindings.fp._GameSession_hasStarted(cppPtr);
    }
}

pub fn GameSession_hasEnded(cppPtr: basis.CppPtr) i32 {
    if (isWasm) {
        return access.GameSession_hasEnded_WASM(cppPtr);
    } else {
        return basis.bindings.fp._GameSession_hasEnded(cppPtr);
    }
}

pub fn GameSession_getLevelData(cppPtr: basis.CppPtr) u64 {
    if (isWasm) {
        return access.GameSession_getLevelData_WASM(cppPtr);
    } else {
        return basis.bindings.fp._GameSession_getLevelData(cppPtr);
    }
}

pub fn GameSession_isContinuousSession(cppPtr: basis.CppPtr) i32 {
    if (isWasm) {
        return access.GameSession_isContinuousSession_WASM(cppPtr);
    } else {
        return basis.bindings.fp._GameSession_isContinuousSession(cppPtr);
    }
}

// ===============================

// class GameState

pub fn GameState_getGameObject(cppPtr: basis.CppPtr, objectNameHash: u32) basis.CppPtr {
    if (isWasm) {
        return access.GameState_getGameObject_WASM(cppPtr, objectNameHash);
    } else {
        return basis.bindings.fp._GameState_getGameObject(cppPtr, objectNameHash);
    }
}

pub fn GameState_getGameObjectFromRenderable(cppPtr: basis.CppPtr, renderableCppPtr: basis.CppPtr) basis.CppPtr {
    if (isWasm) {
        return access.GameState_getGameObjectFromRenderable_WASM(cppPtr, renderableCppPtr);
    } else {
        return basis.bindings.fp._GameState_getGameObjectFromRenderable(cppPtr, renderableCppPtr);
    }
}

pub fn GameState_createGameObject(
    cppPtr: basis.CppPtr,
    objectName: [*c]const basis.bindings.InteropString,
    objectType: [*c]const basis.bindings.InteropString,
    propagate: bool,
) void {
    if (isWasm) {
        const tempMemory = gWASMTempMemoryBuffer.get();

        var stream = basis.BinaryWriteStream.init(tempMemory, true);
        stream.putString(objectName);
        stream.putString(objectType);
        stream.putString(propagate);

        access.GameState_createGameObject_WASM(cppPtr, tempMemory.ptr, @intCast(stream.cursorPosition));
    } else {
        basis.bindings.fp._GameState_createGameObject(cppPtr, objectName, objectType, if (propagate) 1 else 0);
    }
}

pub fn GameState_createGameObjectWithStartTransform(
    cppPtr: basis.CppPtr,
    objectName: [*c]const basis.bindings.InteropString,
    objectType: [*c]const basis.bindings.InteropString,
    pos: [*c]const basis.bindings.InteropVec3,
    ori: [*c]const basis.bindings.InteropQuaternion,
    propagate: bool,
) void {
    if (isWasm) {
        const tempMemory = gWASMTempMemoryBuffer.get();

        var stream = basis.BinaryWriteStream.init(tempMemory, true);
        stream.putString(objectName);
        stream.putString(objectType);
        stream.put(Vec3, Vec3.fromInterop(pos.*));
        stream.put(Quaternion, Quaternion.fromInterop(ori.*));
        stream.putString(propagate);

        access.GameState_createGameObjectWithStartTransform_WASM(cppPtr, tempMemory.ptr, @intCast(stream.cursorPosition));
    } else {
        basis.bindings.fp._GameState_createGameObjectWithStartTransform(cppPtr, objectName, objectType, pos, ori, if (propagate) 1 else 0);
    }
}

pub fn GameState_createGameObjectWithSpawnPointIndex(
    cppPtr: basis.CppPtr,
    objectName: [*c]const basis.bindings.InteropString,
    objectType: [*c]const basis.bindings.InteropString,
    spawnPointIndex: u32,
    propagate: bool,
) void {
    if (isWasm) {
        const tempMemory = gWASMTempMemoryBuffer.get();

        var stream = basis.BinaryWriteStream.init(tempMemory, true);
        stream.putString(objectName);
        stream.putString(objectType);
        stream.putInt(u32, spawnPointIndex);
        stream.putString(propagate);

        access.GameState_createGameObjectWithSpawnPointIndex_WASM(cppPtr, tempMemory.ptr, @intCast(stream.cursorPosition));
    } else {
        basis.bindings.fp._GameState_createGameObjectWithSpawnPointIndex(cppPtr, objectName, objectType, spawnPointIndex, if (propagate) 1 else 0);
    }
}

pub fn GameState_createGameObjectWithSpawnPointName(
    cppPtr: basis.CppPtr,
    objectName: [*c]const basis.bindings.InteropString,
    objectType: [*c]const basis.bindings.InteropString,
    spawnPointName: [*c]const basis.bindings.InteropString,
    propagate: bool,
) void {
    if (isWasm) {
        const tempMemory = gWASMTempMemoryBuffer.get();

        var stream = basis.BinaryWriteStream.init(tempMemory, true);
        stream.putString(objectName);
        stream.putString(objectType);
        stream.putString(spawnPointName);
        stream.putString(propagate);

        access.GameState_createGameObjectWithSpawnPointName_WASM(cppPtr, tempMemory.ptr, @intCast(stream.cursorPosition));
    } else {
        basis.bindings.fp._GameState_createGameObjectWithSpawnPointName(cppPtr, objectName, objectType, spawnPointName, if (propagate) 1 else 0);
    }
}

pub fn GameState_createGameObjectWithParameters(cppPtr: basis.CppPtr, paramsCppPtr: u64, propagate: bool) void {
    if (isWasm) {
        access.GameState_createGameObjectWithParameters_WASM(cppPtr, paramsCppPtr, propagate);
    } else {
        basis.bindings.fp._GameState_createGameObjectWithParameters(cppPtr, paramsCppPtr, if (propagate) 1 else 0);
    }
}

pub fn GameState_destroyGameObject(cppPtr: basis.CppPtr, objectNameHash: u32, propagate: bool, destroyImmediately: bool) void {
    if (isWasm) {
        access.GameState_destroyGameObject_WASM(cppPtr, objectNameHash, propagate, destroyImmediately);
    } else {
        basis.bindings.fp._GameState_destroyGameObject(cppPtr, objectNameHash, if (propagate) 1 else 0, if (destroyImmediately) 1 else 0);
    }
}

pub fn GameState_hasGameObject(cppPtr: basis.CppPtr, objectNameHash: u32) bool {
    if (isWasm) {
        return access.GameState_hasGameObject_WASM(cppPtr, objectNameHash);
    } else {
        return basis.bindings.fp._GameState_hasGameObject(cppPtr, objectNameHash) == 1;
    }
}

pub fn GameState_setAvatarObject(cppPtr: basis.CppPtr, objectNameHash: u32, hostID: i32) void {
    if (isWasm) {
        access.GameState_setAvatarObject_WASM(cppPtr, objectNameHash, hostID);
    } else {
        basis.bindings.fp._GameState_setAvatarObject(cppPtr, objectNameHash, hostID);
    }
}

pub fn GameState_clearAvatarObject(cppPtr: basis.CppPtr, hostID: i32) void {
    if (isWasm) {
        access.GameState_clearAvatarObject_WASM(cppPtr, hostID);
    } else {
        basis.bindings.fp._GameState_clearAvatarObject(cppPtr, hostID);
    }
}

pub fn GameState_getAvatarObjectByHostID(cppPtr: basis.CppPtr, hostID: c_int) u32 {
    if (isWasm) {
        return access.GameState_getAvatarObjectByHostID_WASM(cppPtr, hostID);
    } else {
        return basis.bindings.fp._GameState_getAvatarObjectByHostID(cppPtr, hostID);
    }
}

pub fn GameState_getHostIDByAvatarObject(cppPtr: basis.CppPtr, avatarNameHash: u32) c_int {
    if (isWasm) {
        return access.GameState_getHostIDByAvatarObject_WASM(cppPtr, avatarNameHash);
    } else {
        return basis.bindings.fp._GameState_getHostIDByAvatarObject(cppPtr, avatarNameHash);
    }
}

pub fn GameState_broadcastScriptMessage(cppPtr: basis.CppPtr, senderCppPtr: basis.CppPtr, message: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        access.GameState_broadcastScriptMessage_WASM(cppPtr, senderCppPtr, message.*.ptr, message.*.len);
    } else {
        basis.bindings.fp._GameState_broadcastScriptMessage(cppPtr, senderCppPtr, message);
    }
}

pub fn GameState_sendScriptMessageToGameObject(cppPtr: basis.CppPtr, senderCppPtr: basis.CppPtr, receiverName: [*c]const basis.bindings.InteropString, message: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        access.GameState_sendScriptMessageToGameObject_WASM(cppPtr, senderCppPtr, receiverName.*.ptr, receiverName.*.len, message.*.ptr, message.*.len);
    } else {
        basis.bindings.fp._GameState_sendScriptMessageToGameObject(cppPtr, senderCppPtr, receiverName, message);
    }
}

pub fn GameState_generateGameObjectName(cppPtr: basis.CppPtr, prefix: [*c]const basis.bindings.InteropString, randomPartLength: c_int, result: [*c]basis.bindings.InteropString) void {
    if (isWasm) {
        const tempMemory = gWASMTempMemoryBuffer.get();
        const length = access.GameState_generateGameObjectName_WASM(cppPtr, prefix.*.ptr, prefix.*.len, randomPartLength, tempMemory.ptr, WASMTempMemorySize);
        result.*.ptr = tempMemory.ptr;
        result.*.len = @intCast(length);
    } else {
        basis.bindings.fp._GameState_generateGameObjectName(cppPtr, prefix, randomPartLength, result);
    }
}

// ===============================

// class LevelData

pub fn LevelData_getDataBlockManager(cppPtr: basis.CppPtr) u64 {
    if (isWasm) {
        @compileError("LevelData_getDataBlockManager not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._LevelData_getDataBlockManager(cppPtr);
    }
}

// ===============================

// class LevelDataBlockManager

pub fn LevelDataBlockManager_getDataBlock(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString) u64 {
    if (isWasm) {
        @compileError("LevelDataBlockManager_getDataBlock not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._LevelDataBlockManager_getDataBlock(cppPtr, name);
    }
}

pub fn LevelDataBlockManager_addDataBlock(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString, bufferSize: u32) u64 {
    if (isWasm) {
        @compileError("LevelDataBlockManager_addDataBlock not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._LevelDataBlockManager_addDataBlock(cppPtr, name, bufferSize);
    }
}

pub fn LevelDataBlockManager_addDataBlockIfDoesNotExist(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString, bufferSize: u32) u64 {
    if (isWasm) {
        @compileError("LevelDataBlockManager_addDataBlockIfDoesNotExist not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._LevelDataBlockManager_addDataBlockIfDoesNotExist(cppPtr, name, bufferSize);
    }
}

pub fn LevelDataBlockManager_getMutableDataBlock(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString) u64 {
    if (isWasm) {
        @compileError("LevelDataBlockManager_getMutableDataBlock not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._LevelDataBlockManager_getMutableDataBlock(cppPtr, name);
    }
}

pub fn LevelDataBlockManager_hasDataBlock(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString) c_int {
    if (isWasm) {
        @compileError("LevelDataBlockManager_hasDataBlock not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._LevelDataBlockManager_hasDataBlock(cppPtr, name);
    }
}

// ===============================

// class LevelDataBlock

pub fn LevelDataBlock_getReadBuffer(cppPtr: basis.CppPtr, bufferSize: [*c]u32) [*c]const u8 {
    if (isWasm) {
        @compileError("LevelDataBlock_getReadBuffer not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._LevelDataBlock_getReadBuffer(cppPtr, bufferSize);
    }
}

pub fn LevelDataBlock_getChunkStartReadBufferPosition(cppPtr: basis.CppPtr, chunkIndex: u32) u32 {
    if (isWasm) {
        @compileError("LevelDataBlock_getChunkStartReadBufferPosition not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._LevelDataBlock_getChunkStartReadBufferPosition(cppPtr, chunkIndex);
    }
}

pub fn LevelDataBlock_setReadBufferPosition(cppPtr: basis.CppPtr, position: u32) void {
    if (isWasm) {
        @compileError("LevelDataBlock_setReadBufferPosition not implemented for WASM yet.");
    } else {
        basis.bindings.fp._LevelDataBlock_setReadBufferPosition(cppPtr, position);
    }
}

pub fn LevelDataBlock_getWriteBuffer(cppPtr: basis.CppPtr, bufferSize: [*c]u32) [*c]u8 {
    if (isWasm) {
        @compileError("LevelDataBlock_getWriteBuffer not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._LevelDataBlock_getWriteBuffer(cppPtr, bufferSize);
    }
}

pub fn LevelDataBlock_beginWritingChunk(cppPtr: basis.CppPtr) u32 {
    if (isWasm) {
        @compileError("LevelDataBlock_beginWritingChunk not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._LevelDataBlock_beginWritingChunk(cppPtr);
    }
}

pub fn LevelDataBlock_finishWritingChunk(cppPtr: basis.CppPtr, position: u32) void {
    if (isWasm) {
        @compileError("LevelDataBlock_finishWritingChunk not implemented for WASM yet.");
    } else {
        basis.bindings.fp._LevelDataBlock_finishWritingChunk(cppPtr, position);
    }
}

pub fn LevelDataBlock_getChunkCount(cppPtr: basis.CppPtr) u32 {
    if (isWasm) {
        @compileError("LevelDataBlock_getChunkCount not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._LevelDataBlock_getChunkCount(cppPtr);
    }
}

// ===============================

// class NavMeshRuntime

pub fn NavMeshRuntime_hasNavMesh(navMeshID: u32) bool {
    if (isWasm) {
        @compileError("NavMeshRuntime_hasNavMesh not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._NavMeshRuntime_hasNavMesh(navMeshID) == 1;
    }
}

pub fn NavMeshRuntime_findPath(navMeshID: u32, startPoint: [*c]const basis.bindings.InteropVec3, endPoint: [*c]const basis.bindings.InteropVec3, filter: [*c]const basis.bindings.InteropNavMeshQueryFilter, pathArray: [*c]basis.bindings.InteropVec3, pathArraySize: u32, pathLength: [*c]u32, searchBoxSize: f32, ignoredSoftObstacles: [*c]const u32, ignoredSoftObstacleCount: u32) i32 {
    if (isWasm) {
        @compileError("NavMeshRuntime_findPath not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._NavMeshRuntime_findPath(navMeshID, startPoint, endPoint, filter, pathArray, pathArraySize, pathLength, searchBoxSize, ignoredSoftObstacles, ignoredSoftObstacleCount);
    }
}

pub fn NavMeshRuntime_findClosestPointOnNavMesh(navMeshID: u32, center: [*c]const basis.bindings.InteropVec3, result: [*c]basis.bindings.InteropVec3, searchBoxSize: f32) i32 {
    if (isWasm) {
        @compileError("NavMeshRuntime_findClosestPointOnNavMesh not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._NavMeshRuntime_findClosestPointOnNavMesh(navMeshID, center, result, searchBoxSize);
    }
}

pub fn NavMeshRuntime_findRandomPointAroundCircle(navMeshID: u32, center: [*c]const basis.bindings.InteropVec3, maxRadius: f32, result: [*c]basis.bindings.InteropVec3, searchBoxSize: f32) i32 {
    if (isWasm) {
        @compileError("NavMeshRuntime_findRandomPointAroundCircle not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._NavMeshRuntime_findRandomPointAroundCircle(navMeshID, center, maxRadius, result, searchBoxSize);
    }
}

pub fn NavMeshRuntime_overlapsNavMesh(navMeshID: u32, center: [*c]const basis.bindings.InteropVec3, filter: [*c]const basis.bindings.InteropNavMeshQueryFilter, searchBoxSize: [*c]const basis.bindings.InteropVec3) c_int {
    if (isWasm) {
        @compileError("NavMeshRuntime_overlapsNavMesh not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._NavMeshRuntime_overlapsNavMesh(navMeshID, center, filter, searchBoxSize);
    }
}

pub fn NavMeshRuntime_addObstacle(navMeshID: u32, radius: f32, obstacleType: u32, initialPosition: [*c]const basis.bindings.InteropVec3, initialLinearVelocity: [*c]const basis.bindings.InteropVec3) u32 {
    if (isWasm) {
        @compileError("NavMeshRuntime_addObstacle not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._NavMeshRuntime_addObstacle(navMeshID, radius, obstacleType, initialPosition, initialLinearVelocity);
    }
}

pub fn NavMeshRuntime_updateObstacle(navMeshID: u32, obstacleID: u32, position: [*c]const basis.bindings.InteropVec3, linearVelocity: [*c]const basis.bindings.InteropVec3) void {
    if (isWasm) {
        @compileError("NavMeshRuntime_updateObstacle not implemented for WASM yet.");
    } else {
        basis.bindings.fp._NavMeshRuntime_updateObstacle(navMeshID, obstacleID, position, linearVelocity);
    }
}

pub fn NavMeshRuntime_removeObstacle(navMeshID: u32, obstacleID: u32) void {
    if (isWasm) {
        @compileError("NavMeshRuntime_removeObstacle not implemented for WASM yet.");
    } else {
        basis.bindings.fp._NavMeshRuntime_removeObstacle(navMeshID, obstacleID);
    }
}

// ===============================

// class StreamingUtils

pub fn StreamingUtils_setStreamingPosition(pos: [*c]const basis.bindings.InteropVec3) void {
    if (isWasm) {
        access.StreamingUtils_setStreamingPosition_WASM(pos.*.x, pos.*.y, pos.*.z);
    } else {
        basis.bindings.fp._StreamingUtils_setStreamingPosition(pos);
    }
}

pub fn StreamingUtils_getStreamingPosition(pos: [*c]basis.bindings.InteropVec3) void {
    if (isWasm) {
        const SIZE = Vec3Size;
        var buffer: [SIZE]u8 = undefined;

        access.StreamingUtils_getStreamingPosition_WASM(&buffer, SIZE);
        var stream = basis.BinaryReadStream.init(&buffer, true);
        const v = stream.get(Vec3);
        pos.* = v.toInterop();
    } else {
        basis.bindings.fp._StreamingUtils_getStreamingPosition(pos);
    }
}

pub fn StreamingUtils_setStreamingPositionUpdateMode(mode: c_int) void {
    if (isWasm) {
        access.StreamingUtils_setStreamingPositionUpdateMode_WASM(mode);
    } else {
        basis.bindings.fp._StreamingUtils_setStreamingPositionUpdateMode(mode);
    }
}

pub fn StreamingUtils_getStreamingPositionUpdateMode() c_int {
    if (isWasm) {
        return access.StreamingUtils_getStreamingPositionUpdateMode_WASM();
    } else {
        return basis.bindings.fp._StreamingUtils_getStreamingPositionUpdateMode();
    }
}

// ===============================

// class ScreenFade

pub fn ScreenFade_isActive() c_int {
    if (isWasm) {
        return access.ScreenFade_isActive_WASM();
    } else {
        return basis.bindings.fp._ScreenFade_isActive();
    }
}

pub fn ScreenFade_fade(from: [*c]const basis.bindings.InteropColor, to: [*c]const basis.bindings.InteropColor, duration: f32) void {
    if (isWasm) {
        access.ScreenFade_fade_WASM(
            from.*.r,
            from.*.g,
            from.*.b,
            from.*.a,
            to.*.r,
            to.*.g,
            to.*.b,
            to.*.a,
            duration,
        );
    } else {
        basis.bindings.fp._ScreenFade_fade(from, to, duration);
    }
}

pub fn ScreenFade_fadeWithCallback(from: [*c]const basis.bindings.InteropColor, to: [*c]const basis.bindings.InteropColor, duration: f32, callback: basis.bindings.FP_void) void {
    if (isWasm) {
        const callbackIntPtr: basis.IntPtr = @intFromPtr(callback);
        access.ScreenFade_fadeWithCallback_WASM(
            from.*.r,
            from.*.g,
            from.*.b,
            from.*.a,
            to.*.r,
            to.*.g,
            to.*.b,
            to.*.a,
            duration,
            callbackIntPtr,
        );
    } else {
        basis.bindings.fp._ScreenFade_fadeWithCallback(from, to, duration, callback);
    }
}

pub fn ScreenFade_setColor(color: [*c]const basis.bindings.InteropColor) void {
    if (isWasm) {
        access.ScreenFade_setColor_WASM(
            color.*.r,
            color.*.g,
            color.*.b,
            color.*.a,
        );
    } else {
        basis.bindings.fp._ScreenFade_setColor(color);
    }
}

pub fn ScreenFade_clear() void {
    if (isWasm) {
        access.ScreenFade_clear_WASM();
    } else {
        basis.bindings.fp._ScreenFade_clear();
    }
}

// ===============================

// class StateMachine

pub fn StateMachine_registerFlowState(
    zigLibCppPtr: basis.bindings.InteropTypedPtr,
    cppPtr: basis.CppPtr,
    name: [*c]const basis.bindings.InteropString,
    flowStateInterfacePtr: basis.IntPtr,
    flags: c_int,
    resultPtr: *basis.bindings.InteropTypedPtr,
) void {
    if (isWasm) {
        const resultBuffer = std.mem.asBytes(resultPtr);

        access.StateMachine_registerFlowState_WASM(
            zigLibCppPtr.ptr,
            zigLibCppPtr.type,
            cppPtr,
            name.*.ptr,
            name.*.len,
            basis.bindings.hostIntPtrFromLib(flowStateInterfacePtr),
            flags,
            resultBuffer,
        );
    } else {
        basis.bindings.fp._StateMachine_registerFlowState(zigLibCppPtr, cppPtr, name, flowStateInterfacePtr, flags, resultPtr);
    }
}

pub fn StateMachine_setCallbacksForGroup(cppPtr: basis.CppPtr, groupName: [*c]const basis.bindings.InteropString, enterCallback: basis.bindings.FP_void, exitCallback: basis.bindings.FP_void) void {
    if (isWasm) {
        const enterCallbackIntPtr: basis.IntPtr = @intFromPtr(enterCallback);
        const exitCallbackIntPtr: basis.IntPtr = @intFromPtr(exitCallback);
        access.StateMachine_setCallbacksForGroup_WASM(
            cppPtr,
            groupName.*.ptr,
            groupName.*.len,
            @intCast(enterCallbackIntPtr),
            @intCast(exitCallbackIntPtr),
        );
    } else {
        basis.bindings.fp._StateMachine_setCallbacksForGroup(cppPtr, groupName, enterCallback, exitCallback);
    }
}

pub fn StateMachine_clearCallbacksForGroup(cppPtr: basis.CppPtr, groupName: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        access.StateMachine_clearCallbacksForGroup_WASM(cppPtr, groupName.*.ptr, groupName.*.len);
    } else {
        basis.bindings.fp._StateMachine_clearCallbacksForGroup(cppPtr, groupName);
    }
}

// ===============================

// class FlowState

pub fn FlowState_startTransition(thisPtr: basis.bindings.InteropTypedPtr, name: [*c]const u8, nameLength: u32) void {
    if (isWasm) {
        access.FlowState_startTransition_WASM(thisPtr.ptr, thisPtr.type, name, nameLength);
    } else {
        basis.bindings.fp._FlowState_startTransition(thisPtr, name, nameLength);
    }
}

pub fn FlowState_subscribeToMessageCategory(thisPtr: basis.bindings.InteropTypedPtr, cat: i32) void {
    if (isWasm) {
        access.FlowState_subscribeToMessageCategory_WASM(thisPtr.ptr, thisPtr.type, cat);
    } else {
        basis.bindings.fp._FlowState_subscribeToMessageCategory(thisPtr, cat);
    }
}

pub fn FlowState_allocMsgParams(thisPtr: basis.bindings.InteropTypedPtr) basis.CppPtr {
    if (isWasm) {
        return access.FlowState_allocMsgParams_WASM(thisPtr.ptr, thisPtr.type);
    } else {
        return basis.bindings.fp._FlowState_allocMsgParams(thisPtr);
    }
}

pub fn FlowState_sendMessage(thisPtr: basis.bindings.InteropTypedPtr, message: i32, parameters: basis.CppPtr) void {
    if (isWasm) {
        access.FlowState_sendMessage_WASM(thisPtr.ptr, thisPtr.type, message, parameters);
    } else {
        basis.bindings.fp._FlowState_sendMessage(thisPtr, message, parameters);
    }
}

pub fn FlowState_getClient(thisPtr: basis.bindings.InteropTypedPtr) basis.CppPtr {
    if (isWasm) {
        return access.FlowState_getClient_WASM(thisPtr.ptr, thisPtr.type);
    } else {
        return basis.bindings.fp._FlowState_getClient(thisPtr);
    }
}

pub fn FlowState_getServer(thisPtr: basis.bindings.InteropTypedPtr) basis.CppPtr {
    if (isWasm) {
        return access.FlowState_getServer_WASM(thisPtr.ptr, thisPtr.type);
    } else {
        return basis.bindings.fp._FlowState_getServer(thisPtr);
    }
}

// ===============================

// class DebugOverlay

pub fn DebugOverlay_isVisible() c_int {
    if (isWasm) {
        return access.DebugOverlay_isVisible_WASM();
    } else {
        return basis.bindings.fp._DebugOverlay_isVisible();
    }
}

pub fn DebugOverlay_setImGuiMenuBarCallbackEnabled(zigLibCppPtr: basis.bindings.InteropTypedPtr, enabled: c_int) void {
    if (isWasm) {
        @compileError("DebugOverlay_setImGuiMenuBarCallbackEnabled not implemented for WASM yet.");
    } else {
        basis.bindings.fp._DebugOverlay_setImGuiMenuBarCallbackEnabled(zigLibCppPtr, enabled);
    }
}

pub fn DebugOverlay_setImGuiCallbackEnabled(zigLibCppPtr: basis.bindings.InteropTypedPtr, enabled: c_int) void {
    if (isWasm) {
        @compileError("DebugOverlay_setImGuiCallbackEnabled not implemented for WASM yet.");
    } else {
        basis.bindings.fp._DebugOverlay_setImGuiCallbackEnabled(zigLibCppPtr, enabled);
    }
}

pub fn DebugOverlay_debugTrace(data: [*c]const u8, dataLength: u32) void {
    if (isWasm) {
        access.DebugOverlay_debugTrace_WASM(data, dataLength);
    } else {
        basis.bindings.fp._DebugOverlay_debugTrace(data, dataLength);
    }
}

pub fn DebugOverlay_debugWarning(data: [*c]const u8, dataLength: u32) void {
    if (isWasm) {
        access.DebugOverlay_debugWarning_WASM(data, dataLength);
    } else {
        basis.bindings.fp._DebugOverlay_debugWarning(data, dataLength);
    }
}

pub fn DebugOverlay_areDebugObjectWindowKeysPressed() c_int {
    if (isWasm) {
        return access.DebugOverlay_areDebugObjectWindowKeysPressed_WASM();
    } else {
        return basis.bindings.fp._DebugOverlay_areDebugObjectWindowKeysPressed();
    }
}

pub fn DebugOverlay_showDebugActionAtPosition(position: [*c]const basis.bindings.InteropVec3, surfaceNormal: [*c]const basis.bindings.InteropVec3) void {
    if (isWasm) {
        @compileError("DebugOverlay_showDebugActionAtPosition not implemented for WASM yet.");
    } else {
        basis.bindings.fp._DebugOverlay_showDebugActionAtPosition(position, surfaceNormal);
    }
}

pub fn DebugOverlay_addDebugSpawnableObjectType(objectType: [*c]const basis.bindings.InteropString, distanceFromSurface: f32) void {
    if (isWasm) {
        access.DebugOverlay_addDebugSpawnableObjectType_WASM(objectType.*.ptr, objectType.*.len, distanceFromSurface);
    } else {
        basis.bindings.fp._DebugOverlay_addDebugSpawnableObjectType(objectType, distanceFromSurface);
    }
}

// ===============================

// class Editor

pub fn Editor_printInfo(data: [*c]const u8, dataLength: u32) void {
    if (isWasm) {
        access.Editor_printInfo_WASM(data, dataLength);
    } else {
        basis.bindings.fp._Editor_printInfo(data, dataLength);
    }
}

pub fn Editor_printWarning(data: [*c]const u8, dataLength: u32) void {
    if (isWasm) {
        access.Editor_printWarning_WASM(data, dataLength);
    } else {
        basis.bindings.fp._Editor_printWarning(data, dataLength);
    }
}

pub fn Editor_printError(data: [*c]const u8, dataLength: u32) void {
    if (isWasm) {
        access.Editor_printError_WASM(data, dataLength);
    } else {
        basis.bindings.fp._Editor_printError(data, dataLength);
    }
}

pub fn Editor_getEditorCamera() basis.CppPtr {
    if (isWasm) {
        return access.Editor_getEditorCamera_WASM();
    } else {
        return basis.bindings.fp._Editor_getEditorCamera();
    }
}

// ===============================

// class ImGui

pub fn ImGui_begin(name: [*c]const basis.bindings.InteropString, flags: i32) c_int {
    if (isWasm) {
        return access.ImGui_begin_WASM(name.*.ptr, name.*.len, flags);
    } else {
        return basis.bindings.fp._ImGui_begin(name, flags);
    }
}

pub fn ImGui_beginEx(name: [*c]const basis.bindings.InteropString, p_open: [*c]bool, flags: i32) c_int {
    if (isWasm) {
        @compileError("ImGui_beginEx() not supported with WASM. Use ImGui_begin() instead, and have a separte button for closing the window.");
    } else {
        return basis.bindings.fp._ImGui_beginEx(name, p_open, flags);
    }
}

pub fn ImGui_end() void {
    if (isWasm) {
        access.ImGui_end_WASM();
    } else {
        basis.bindings.fp._ImGui_end();
    }
}

pub fn ImGui_beginMenu(name: [*c]const basis.bindings.InteropString, enabled: c_int) c_int {
    if (isWasm) {
        return access.ImGui_beginMenu_WASM(name.*.ptr, name.*.len, enabled);
    } else {
        return basis.bindings.fp._ImGui_beginMenu(name, enabled);
    }
}

pub fn ImGui_endMenu() void {
    if (isWasm) {
        access.ImGui_endMenu_WASM();
    } else {
        basis.bindings.fp._ImGui_endMenu();
    }
}

pub fn ImGui_menuItem(label: [*c]const basis.bindings.InteropString, selected: c_int, enabled: c_int) c_int {
    if (isWasm) {
        return access.ImGui_menuItem_WASM(label.*.ptr, label.*.len, selected, enabled);
    } else {
        return basis.bindings.fp._ImGui_menuItem(label, selected, enabled);
    }
}

pub fn ImGui_openPopup(id: [*c]const basis.bindings.InteropString, popupFlags: i32) void {
    if (isWasm) {
        access.ImGui_openPopup_WASM(id.*.ptr, id.*.len, popupFlags);
    } else {
        basis.bindings.fp._ImGui_openPopup(id, popupFlags);
    }
}

pub fn ImGui_beginPopup(id: [*c]const basis.bindings.InteropString, flags: i32) c_int {
    if (isWasm) {
        return access.ImGui_beginPopup_WASM(id.*.ptr, id.*.len, flags);
    } else {
        return basis.bindings.fp._ImGui_beginPopup(id, flags);
    }
}

pub fn ImGui_endPopup() void {
    if (isWasm) {
        access.ImGui_endPopup_WASM();
    } else {
        basis.bindings.fp._ImGui_endPopup();
    }
}

pub fn ImGui_beginPopupModal(name: [*c]const basis.bindings.InteropString, flags: i32) c_int {
    if (isWasm) {
        @compileError("ImGui_beginPopupModal not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._ImGui_beginPopupModal(name, flags);
    }
}

pub fn ImGui_closeCurrentPopup() void {
    if (isWasm) {
        @compileError("ImGui_closeCurrentPopup not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ImGui_closeCurrentPopup();
    }
}

pub fn ImGui_setItemDefaultFocus() void {
    if (isWasm) {
        @compileError("ImGui_setItemDefaultFocus not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ImGui_setItemDefaultFocus();
    }
}

pub fn ImGui_dummy(size: [*c]const basis.bindings.InteropVec2) void {
    if (isWasm) {
        @compileError("ImGui_dummy not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._ImGui_dummy(size);
    }
}

pub fn ImGui_getMainViewportCenter(center: [*c]basis.bindings.InteropVec2) void {
    if (isWasm) {
        @compileError("ImGui_getMainViewportCenter not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ImGui_getMainViewportCenter(center);
    }
}

pub fn ImGui_pushStyleColor(idx: i32, col: [*c]const basis.bindings.InteropColor) void {
    if (isWasm) {
        const r = @as(f32, @floatFromInt(col.r)) / 255.0;
        const g = @as(f32, @floatFromInt(col.g)) / 255.0;
        const b = @as(f32, @floatFromInt(col.b)) / 255.0;
        access.ImGui_pushStyleColor_WASM(idx, r, g, b);
    } else {
        basis.bindings.fp._ImGui_pushStyleColor(idx, col);
    }
}

pub fn ImGui_popStyleColor(count: c_int) void {
    if (isWasm) {
        access.ImGui_popStyleColor_WASM(count);
    } else {
        basis.bindings.fp._ImGui_popStyleColor(count);
    }
}

pub fn ImGui_separator() void {
    if (isWasm) {
        access.ImGui_separator_WASM();
    } else {
        basis.bindings.fp._ImGui_separator();
    }
}

pub fn ImGui_text(text: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        access.ImGui_text_WASM(text.*.ptr, text.*.len);
    } else {
        basis.bindings.fp._ImGui_text(text);
    }
}

pub fn ImGui_textColored(col: [*c]const basis.bindings.InteropColor, text: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        const r = @as(f32, @floatFromInt(col.r)) / 255.0;
        const g = @as(f32, @floatFromInt(col.g)) / 255.0;
        const b = @as(f32, @floatFromInt(col.b)) / 255.0;
        access.ImGui_textColored_WASM(r, g, b, text.*.ptr, text.*.len);
    } else {
        basis.bindings.fp._ImGui_textColored(col, text);
    }
}

pub fn ImGui_sameline(offsetFromStartX: f32, spacingW: f32) void {
    if (isWasm) {
        access.ImGui_sameline_WASM(offsetFromStartX, spacingW);
    } else {
        basis.bindings.fp._ImGui_sameline(offsetFromStartX, spacingW);
    }
}

pub fn ImGui_collapsingHeader(label: [*c]const basis.bindings.InteropString, flags: i32) c_int {
    if (isWasm) {
        return access.ImGui_collapsingHeader_WASM(label.*.ptr, label.*.len, flags);
    } else {
        return basis.bindings.fp._ImGui_collapsingHeader(label, flags);
    }
}

pub fn ImGui_button(label: [*c]const basis.bindings.InteropString, size: [*c]const basis.bindings.InteropVec2) c_int {
    if (isWasm) {
        return access.ImGui_button_WASM(label.*.ptr, label.*.len, size.*.x, size.*.y);
    } else {
        return basis.bindings.fp._ImGui_button(label, size);
    }
}

pub fn ImGui_isItemHovered(flags: i32) c_int {
    if (isWasm) {
        return access.ImGui_isItemHovered_WASM(flags);
    } else {
        return basis.bindings.fp._ImGui_isItemHovered(flags);
    }
}

pub fn ImGui_setTooltip(text: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        access.ImGui_setTooltip_WASM(text.*.ptr, text.*.len);
    } else {
        basis.bindings.fp._ImGui_setTooltip(text);
    }
}

pub fn ImGui_endTooltip() void {
    if (isWasm) {
        access.ImGui_endTooltip_WASM();
    } else {
        basis.bindings.fp._ImGui_endTooltip();
    }
}

pub fn ImGui_setNextWindowPos(pos: [*c]const basis.bindings.InteropVec2, cond: i32, pivot: [*c]const basis.bindings.InteropVec2) void {
    if (isWasm) {
        access.ImGui_setNextWindowPos_WASM(pos.*.x, pos.*.y, cond, pivot.*.x, pivot.*.y);
    } else {
        basis.bindings.fp._ImGui_setNextWindowPos(pos, cond, pivot);
    }
}

pub fn ImGui_setNextWindowSize(size: [*c]const basis.bindings.InteropVec2, cond: i32) void {
    if (isWasm) {
        access.ImGui_setNextWindowSize_WASM(size.*.x, size.*.y, cond);
    } else {
        basis.bindings.fp._ImGui_setNextWindowSize(size, cond);
    }
}

pub fn ImGui_setNextWindowBgAlpha(alpha: f32) void {
    if (isWasm) {
        access.ImGui_setNextWindowBgAlpha_WASM(alpha);
    } else {
        basis.bindings.fp._ImGui_setNextWindowBgAlpha(alpha);
    }
}

pub fn ImGui_beginListBox(label: [*c]const basis.bindings.InteropString, size: [*c]const basis.bindings.InteropVec2) c_int {
    if (isWasm) {
        return access.ImGui_beginListBox_WASM(label.*.ptr, label.*.len, size.*.x, size.*.y);
    } else {
        return basis.bindings.fp._ImGui_beginListBox(label, size);
    }
}

pub fn ImGui_endListBox() void {
    if (isWasm) {
        access.ImGui_endListBox_WASM();
    } else {
        basis.bindings.fp._ImGui_endListBox();
    }
}

pub fn ImGui_radioButton(label: [*c]const basis.bindings.InteropString, v: *i32, v_button: i32) c_int {
    if (isWasm) {
        // What to do about the "v" pointer parameter? Pointers don't directly work with WASM...
        @compileError("ImGui_radioButton not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._ImGui_radioButton(label, v, v_button);
    }
}

pub fn ImGui_getScrollX() f32 {
    if (isWasm) {
        return access.ImGui_getScrollX_WASM();
    } else {
        return basis.bindings.fp._ImGui_getScrollX();
    }
}

pub fn ImGui_getScrollY() f32 {
    if (isWasm) {
        return access.ImGui_getScrollY_WASM();
    } else {
        return basis.bindings.fp._ImGui_getScrollY();
    }
}

pub fn ImGui_setScrollX(scrollX: f32) void {
    if (isWasm) {
        access.ImGui_setScrollX_WASM(scrollX);
    } else {
        basis.bindings.fp._ImGui_setScrollX(scrollX);
    }
}

pub fn ImGui_setScrollY(scrollY: f32) void {
    if (isWasm) {
        access.ImGui_setScrollY_WASM(scrollY);
    } else {
        basis.bindings.fp._ImGui_setScrollY(scrollY);
    }
}

pub fn ImGui_getScrollMaxX() f32 {
    if (isWasm) {
        return access.ImGui_getScrollMaxX_WASM();
    } else {
        return basis.bindings.fp._ImGui_getScrollMaxX();
    }
}

pub fn ImGui_getScrollMaxY() f32 {
    if (isWasm) {
        return access.ImGui_getScrollMaxY_WASM();
    } else {
        return basis.bindings.fp._ImGui_getScrollMaxY();
    }
}

pub fn ImGui_setScrollHereX(centerXRatio: f32) void {
    if (isWasm) {
        access.ImGui_setScrollHereX_WASM(centerXRatio);
    } else {
        basis.bindings.fp._ImGui_setScrollHereX(centerXRatio);
    }
}

pub fn ImGui_setScrollHereY(centerYRatio: f32) void {
    if (isWasm) {
        access.ImGui_setScrollHereY_WASM(centerYRatio);
    } else {
        basis.bindings.fp._ImGui_setScrollHereY(centerYRatio);
    }
}

pub fn ImGui_setScrollFromPosX(localX: f32, centerXRatio: f32) void {
    if (isWasm) {
        access.ImGui_setScrollFromPosX_WASM(localX, centerXRatio);
    } else {
        basis.bindings.fp._ImGui_setScrollFromPosX(localX, centerXRatio);
    }
}

pub fn ImGui_setScrollFromPosY(localY: f32, centerYRatio: f32) void {
    if (isWasm) {
        access.ImGui_setScrollFromPosY_WASM(localY, centerYRatio);
    } else {
        basis.bindings.fp._ImGui_setScrollFromPosY(localY, centerYRatio);
    }
}

pub fn ImGui_dragFloat(label: [*c]const basis.bindings.InteropString, v: *f32, v_speed: f32, v_min: f32, v_max: f32, format: [*c]const basis.bindings.InteropString, flags: i32) c_int {
    if (isWasm) {
        // What to do about the "v" pointer parameter? Pointers don't directly work with WASM...
        @compileError("ImGui_dragFloat not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._ImGui_dragFloat(label, v, v_speed, v_min, v_max, format, flags);
    }
}

pub fn ImGui_dragInt(label: [*c]const basis.bindings.InteropString, v: *i32, v_speed: f32, v_min: i32, v_max: i32, format: [*c]const basis.bindings.InteropString, flags: i32) c_int {
    if (isWasm) {
        // What to do about the "v" pointer parameter? Pointers don't directly work with WASM...
        @compileError("ImGui_dragInt not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._ImGui_dragInt(label, v, v_speed, v_min, v_max, format, flags);
    }
}

pub fn ImGui_sliderFloat(label: [*c]const basis.bindings.InteropString, v: *f32, v_min: f32, v_max: f32, format: [*c]const basis.bindings.InteropString, flags: i32) c_int {
    if (isWasm) {
        // What to do about the "v" pointer parameter? Pointers don't directly work with WASM...
        @compileError("ImGui_sliderFloat not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._ImGui_sliderFloat(label, v, v_min, v_max, format, flags);
    }
}

pub fn ImGui_sliderInt(label: [*c]const basis.bindings.InteropString, v: *i32, v_min: i32, v_max: i32, format: [*c]const basis.bindings.InteropString, flags: i32) c_int {
    if (isWasm) {
        // What to do about the "v" pointer parameter? Pointers don't directly work with WASM...
        @compileError("ImGui_sliderInt not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._ImGui_sliderInt(label, v, v_min, v_max, format, flags);
    }
}

pub fn ImGui_plotMultiLines(data: [*c]const u8, dataLength: u32, getter: basis.bindings.ImguiPlotMultiLinesGetter) void {
    if (isWasm) {
        @compileError("ImGui_plotMultiLines not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ImGui_plotMultiLines(data, dataLength, getter);
    }
}

pub fn ImGui_getContentRegionAvail(region: [*c]basis.bindings.InteropVec2) void {
    if (isWasm) {
        @compileError("ImGui_getContentRegionAvail not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ImGui_getContentRegionAvail(region);
    }
}

pub fn ImGui_pushID(int_id: i32) void {
    if (isWasm) {
        @compileError("ImGui_pushID not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ImGui_pushID(int_id);
    }
}

pub fn ImGui_pushIDPtr(ptr_id: basis.IntPtr64) void {
    if (isWasm) {
        @compileError("ImGui_pushIDPtr not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ImGui_pushIDPtr(ptr_id);
    }
}

pub fn ImGui_popID() void {
    if (isWasm) {
        @compileError("ImGui_popID not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ImGui_popID();
    }
}

// ===============================

// class ImPlot

pub fn ImPlot_beginPlot(title_id: [*c]const basis.bindings.InteropString, size: [*c]const basis.bindings.InteropVec2, flags: i32) c_int {
    if (isWasm) {
        @compileError("ImPlot_beginPlot not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._ImPlot_beginPlot(title_id, size, flags);
    }
}

pub fn ImPlot_endPlot() void {
    if (isWasm) {
        @compileError("ImPlot_endPlot not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ImPlot_endPlot();
    }
}

pub fn ImPlot_setupAxis(axis: i32, label: [*c]const basis.bindings.InteropString, flags: i32) void {
    if (isWasm) {
        @compileError("ImPlot_setupAxis not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ImPlot_setupAxis(axis, label, flags);
    }
}

pub fn ImPlot_setupAxisLimits(axis: i32, v_min: f32, v_max: f32, cond: i32) void {
    if (isWasm) {
        @compileError("ImPlot_setupAxisLimits not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ImPlot_setupAxisLimits(axis, v_min, v_max, cond);
    }
}

pub fn ImPlot_setupLegend(location: i32, flags: i32) void {
    if (isWasm) {
        @compileError("ImPlot_setupLegend not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ImPlot_setupLegend(location, flags);
    }
}

pub fn ImPlot_plotLine(label_id: [*c]const basis.bindings.InteropString, xs: [*c]const f32, ys: [*c]const f32, count: c_int) void {
    if (isWasm) {
        @compileError("ImPlot_plotLine not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ImPlot_plotLine(label_id, xs, ys, count);
    }
}

pub fn ImPlot_plotLineEx(label_id: [*c]const basis.bindings.InteropString, xs: [*c]const f32, ys: [*c]const f32, count: c_int, specData: [*c]const u8, specDataLength: u32) void {
    if (isWasm) {
        @compileError("ImPlot_plotLineEx not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ImPlot_plotLineEx(label_id, xs, ys, count, specData, specDataLength);
    }
}

pub fn ImPlot_plotScatter(label_id: [*c]const basis.bindings.InteropString, xs: [*c]const f32, ys: [*c]const f32, count: c_int) void {
    if (isWasm) {
        @compileError("ImPlot_plotScatter not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ImPlot_plotScatter(label_id, xs, ys, count);
    }
}

pub fn ImPlot_plotScatterEx(label_id: [*c]const basis.bindings.InteropString, xs: [*c]const f32, ys: [*c]const f32, count: c_int, specData: [*c]const u8, specDataLength: u32) void {
    if (isWasm) {
        @compileError("ImPlot_plotScatterEx not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ImPlot_plotScatterEx(label_id, xs, ys, count, specData, specDataLength);
    }
}

pub fn ImPlot_dragPoint(id: c_int, x: [*c]f64, y: [*c]f64, col: [*c]const basis.bindings.InteropColor, size: f32, flags: c_int, out_clicked: [*c]bool, out_hovered: [*c]bool, out_held: [*c]bool) c_int {
    if (isWasm) {
        @compileError("ImPlot_dragPoint not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._ImPlot_dragPoint(id, x, y, col, size, flags, out_clicked, out_hovered, out_held);
    }
}

// ===============================

// class GameObjectCreationParameters

pub fn GameObjectCreationParameters_newParams() basis.CppPtr {
    if (isWasm) {
        return access.GameObjectCreationParameters_newParams_WASM();
    } else {
        return basis.bindings.fp._GameObjectCreationParameters_newParams();
    }
}

pub fn GameObjectCreationParameters_newParamsWithNameAndType(objectName: [*c]const basis.bindings.InteropString, objectType: [*c]const basis.bindings.InteropString) u64 {
    if (isWasm) {
        return access.GameObjectCreationParameters_newParamsWithNameAndType_WASM(objectName.*.ptr, objectName.*.len, objectType.*.ptr, objectType.*.len);
    } else {
        return basis.bindings.fp._GameObjectCreationParameters_newParamsWithNameAndType(objectName, objectType);
    }
}

pub fn GameObjectCreationParameters_deleteParams(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.GameObjectCreationParameters_deleteParams_WASM(cppPtr);
    } else {
        basis.bindings.fp._GameObjectCreationParameters_deleteParams(cppPtr);
    }
}

pub fn GameObjectCreationParameters_setStartTransform(cppPtr: basis.CppPtr, position: [*c]const basis.bindings.InteropVec3, orientation: [*c]const basis.bindings.InteropQuaternion) void {
    if (isWasm) {
        const SIZE = Vec3Size + QuaternionSize;
        var buffer: [SIZE]u8 = undefined;

        var stream = basis.BinaryWriteStream.init(&buffer, true);
        stream.put(Vec3, Vec3.fromInterop(position.*));
        stream.put(Quaternion, Quaternion.fromInterop(orientation.*));

        access.GameObjectCreationParameters_setStartTransform_WASM(cppPtr, &buffer, SIZE);
    } else {
        basis.bindings.fp._GameObjectCreationParameters_setStartTransform(cppPtr, position, orientation);
    }
}

pub fn GameObjectCreationParameters_setPropertyBundlePath(cppPtr: basis.CppPtr, path: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        access.GameObjectCreationParameters_setPropertyBundlePath_WASM(cppPtr, path.*.ptr, path.*.len);
    } else {
        basis.bindings.fp._GameObjectCreationParameters_setPropertyBundlePath(cppPtr, path);
    }
}

// ===============================

// class OSUtility

pub fn OSUtility_writeStringToClipboard(str: [*c]const basis.bindings.InteropString) c_int {
    if (isWasm) {
        @compileError("OSUtility_writeStringToClipboard not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._OSUtility_writeStringToClipboard(str);
    }
}

pub fn OSUtility_readStringFromClipboard(str: [*c]basis.bindings.InteropString) c_int {
    if (isWasm) {
        @compileError("OSUtility_readStringFromClipboard not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._OSUtility_readStringFromClipboard(str);
    }
}

// ===============================

// class ExposedPropertyLayoutReader

pub fn ExposedPropertyLayoutReader_init(cppPtr: basis.CppPtr, version: i32) void {
    if (isWasm) {
        @compileError("ExposedPropertyLayoutReader_init not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ExposedPropertyLayoutReader_init(cppPtr, version);
    }
}

pub fn ExposedPropertyLayoutReader_processProperty(
    cppPtr: basis.CppPtr,
    name: [*c]const basis.bindings.InteropString,
    propertyType: i32,
    serializedDefaultValue: [*c]const u8,
    serializedDefaultValueLength: u32,
    versionAdded: i32,
    options: [*c]const basis.bindings.InteropString,
) void {
    if (isWasm) {
        @compileError("ExposedPropertyLayoutReader_processProperty not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ExposedPropertyLayoutReader_processProperty(cppPtr, name, propertyType, serializedDefaultValue, serializedDefaultValueLength, versionAdded, options);
    }
}

pub fn ExposedPropertyLayoutReader_processString(
    cppPtr: basis.CppPtr,
    name: [*c]const basis.bindings.InteropString,
    defaultValue: [*c]const basis.bindings.InteropString,
    versionAdded: i32,
    options: [*c]const basis.bindings.InteropString,
) void {
    if (isWasm) {
        @compileError("ExposedPropertyLayoutReader_processString not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ExposedPropertyLayoutReader_processString(cppPtr, name, defaultValue, versionAdded, options);
    }
}

pub fn ExposedPropertyLayoutReader_processResourceRef(
    cppPtr: basis.CppPtr,
    name: [*c]const basis.bindings.InteropString,
    resourceTypeID: i32,
    defaultValue: [*c]const basis.bindings.InteropString,
    versionAdded: i32,
    options: [*c]const basis.bindings.InteropString,
) void {
    if (isWasm) {
        @compileError("ExposedPropertyLayoutReader_processResourceRef not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ExposedPropertyLayoutReader_processResourceRef(cppPtr, name, resourceTypeID, defaultValue, versionAdded, options);
    }
}

pub fn ExposedPropertyLayoutReader_processButton(
    cppPtr: basis.CppPtr,
    actionID: [*c]const basis.bindings.InteropString,
    actionName: [*c]const basis.bindings.InteropString,
    buttonText: [*c]const basis.bindings.InteropString,
    options: [*c]const basis.bindings.InteropString,
) void {
    if (isWasm) {
        @compileError("ExposedPropertyLayoutReader_processButton not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ExposedPropertyLayoutReader_processButton(cppPtr, actionID, actionName, buttonText, options);
    }
}

pub fn ExposedPropertyLayoutReader_processCategory(
    cppPtr: basis.CppPtr,
    categoryName: [*c]const basis.bindings.InteropString,
    displayName: [*c]const basis.bindings.InteropString,
    options: [*c]const basis.bindings.InteropString,
) void {
    if (isWasm) {
        @compileError("ExposedPropertyLayoutReader_processCategory not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ExposedPropertyLayoutReader_processCategory(cppPtr, categoryName, displayName, options);
    }
}

pub fn ExposedPropertyLayoutReader_processEnum(
    cppPtr: basis.CppPtr,
    name: [*c]const basis.bindings.InteropString,
    defaultValue: u32,
    enumValueNames: [*c]const basis.bindings.InteropString,
    enumValueIntegrals: [*c]u32,
    valueCount: u32,
    versionAdded: c_int,
    options: [*c]const basis.bindings.InteropString,
) void {
    if (isWasm) {
        @compileError("ExposedPropertyLayoutReader_processEnum not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ExposedPropertyLayoutReader_processEnum(cppPtr, name, defaultValue, enumValueNames, enumValueIntegrals, valueCount, versionAdded, options);
    }
}

pub fn ExposedPropertyLayoutReader_allPropertiesProcessed(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        @compileError("ExposedPropertyLayoutReader_allPropertiesProcessed not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ExposedPropertyLayoutReader_allPropertiesProcessed(cppPtr);
    }
}

// ===============================

// class ZigAngelScriptTypeRegistration

pub fn ZigAngelScriptTypeRegistration_registerEnumType(cppPtr: basis.CppPtr, typeName: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        access.ZigAngelScriptTypeRegistration_registerEnumType_WASM(cppPtr, typeName.*.ptr, typeName.*.len);
    } else {
        basis.bindings.fp._ZigAngelScriptTypeRegistration_registerEnumType(cppPtr, typeName);
    }
}

pub fn ZigAngelScriptTypeRegistration_registerEnumValue(cppPtr: basis.CppPtr, typeName: [*c]const basis.bindings.InteropString, valueName: [*c]const basis.bindings.InteropString, value: c_int) void {
    if (isWasm) {
        access.ZigAngelScriptTypeRegistration_registerEnumValue_WASM(cppPtr, typeName.*.ptr, typeName.*.len, valueName.*.ptr, valueName.*.len, value);
    } else {
        basis.bindings.fp._ZigAngelScriptTypeRegistration_registerEnumValue(cppPtr, typeName, valueName, value);
    }
}

// ===============================

// class ZigAngelScriptComponentRegistration

pub fn ZigAngelScriptComponentRegistration_registerComponentType(cppPtr: basis.CppPtr, typeName: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        access.ZigAngelScriptComponentRegistration_registerComponentType_WASM(cppPtr, typeName.*.ptr, typeName.*.len);
    } else {
        basis.bindings.fp._ZigAngelScriptComponentRegistration_registerComponentType(cppPtr, typeName);
    }
}

pub fn ZigAngelScriptComponentRegistration_registerComponentMethod(cppPtr: basis.CppPtr, declaration: [*c]const basis.bindings.InteropString, functionPtr: u64) void {
    if (isWasm) {
        @compileError("ZigAngelScriptComponentRegistration_registerComponentMethod not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ZigAngelScriptComponentRegistration_registerComponentMethod(cppPtr, declaration, functionPtr);
    }
}

pub fn ZigAngelScriptComponentRegistration_registerComponentEventAutoComplete(cppPtr: basis.CppPtr, declaration: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("ZigAngelScriptComponentRegistration_registerComponentEventAutoComplete not implemented for WASM yet.");
    } else {
        basis.bindings.fp._ZigAngelScriptComponentRegistration_registerComponentEventAutoComplete(cppPtr, declaration);
    }
}

// ===============================

// class AngelScriptUtils

pub fn AngelScriptUtils_getStringRefConstIn(p: u64, value: [*c]basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("AngelScriptUtils_getStringRefConstIn not implemented for WASM yet.");
    } else {
        basis.bindings.fp._AngelScriptUtils_getStringRefConstIn(p, value);
    }
}

pub fn AngelScriptUtils_setStringRefOut(p: u64, value: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("AngelScriptUtils_setStringRefOut not implemented for WASM yet.");
    } else {
        basis.bindings.fp._AngelScriptUtils_setStringRefOut(p, value);
    }
}

pub fn AngelScriptUtils_getGameObjectRefConstIn(p: u64, value: [*c]basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("AngelScriptUtils_getGameObjectRefConstIn not implemented for WASM yet.");
    } else {
        basis.bindings.fp._AngelScriptUtils_getGameObjectRefConstIn(p, value);
    }
}

pub fn AngelScriptUtils_getHashFromGameObjectRefConstIn(p: u64) u32 {
    if (isWasm) {
        @compileError("AngelScriptUtils_getHashFromGameObjectRefConstIn not implemented for WASM yet.");
    } else {
        return basis.bindings.fp._AngelScriptUtils_getHashFromGameObjectRefConstIn(p);
    }
}

pub fn AngelScriptUtils_setGameObjectRefOut(p: u64, value: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("AngelScriptUtils_setGameObjectRefOut not implemented for WASM yet.");
    } else {
        basis.bindings.fp._AngelScriptUtils_setGameObjectRefOut(p, value);
    }
}

pub fn AngelScriptUtils_getColorRefConstIn(p: u64, value: [*c]basis.bindings.InteropColor) void {
    if (isWasm) {
        @compileError("AngelScriptUtils_getColorRefConstIn not implemented for WASM yet.");
    } else {
        basis.bindings.fp._AngelScriptUtils_getColorRefConstIn(p, value);
    }
}

pub fn AngelScriptUtils_setColorRefOut(p: u64, value: [*c]const basis.bindings.InteropColor) void {
    if (isWasm) {
        @compileError("AngelScriptUtils_setColorRefOut not implemented for WASM yet.");
    } else {
        basis.bindings.fp._AngelScriptUtils_setColorRefOut(p, value);
    }
}

pub fn AngelScriptUtils_addRefToASFuncPtr(funcPtr: u64) void {
    if (isWasm) {
        @compileError("AngelScriptUtils_addRefToASFuncPtr not implemented for WASM yet.");
    } else {
        basis.bindings.fp._AngelScriptUtils_addRefToASFuncPtr(funcPtr);
    }
}

pub fn AngelScriptUtils_releaseASFuncPtr(funcPtr: u64) void {
    if (isWasm) {
        @compileError("AngelScriptUtils_releaseASFuncPtr not implemented for WASM yet.");
    } else {
        basis.bindings.fp._AngelScriptUtils_releaseASFuncPtr(funcPtr);
    }
}

// ===============================
