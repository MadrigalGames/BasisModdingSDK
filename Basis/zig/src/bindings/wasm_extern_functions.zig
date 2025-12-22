// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const basis = @import("../basis.zig");

// Component registration callback:

pub extern "env" fn componentRegistrationCallback_WASM(
    zigLibCppPtr_0: basis.CppPtr,
    zigLibCppPtr_1: u32,
    typeNamePtr: [*]const u8,
    typeNameLength: u32,
    typeNameHash: u32,
    contextTypeNamePtr: [*]const u8,
    contextTypeNameLength: u32,
    updateSortingKey: u32,
    factoryInterfacePtr: basis.IntPtr64,
    flags: u32,
) void;

// ===============================

// Core:

pub extern "env" fn Core_showAssertDialog_WASM(message: [*]const u8, messageLength: u32, caption: [*]const u8, captionLength: u32) i32;
//pub extern "env" fn Core_heapAlloc_WASM(len: u64, alignment: u64) [*c]u8;
//pub extern "env" fn Core_heapFree_WASM(buf: [*c]u8) void;
pub extern "env" fn Core_printOnHost_WASM(ptr: [*]const u8, len: u32) void;
//pub extern "env" fn Core_beginProfilingSample_WASM(name: [*c]const u8) void;
//pub extern "env" fn Core_endProfilingSample_WASM() void;
pub extern "env" fn Core_getRandomSeed_WASM() u64;

// TODO

// ===============================

// App:

pub extern "env" fn App_createApp_WASM(zigLibCppPtr_0: basis.CppPtr, zigLibCppPtr_1: u32, zigAppInterfacePtr: basis.IntPtr64) basis.CppPtr;
pub extern "env" fn App_getAppMode_WASM(cppPtr: basis.CppPtr) i32;
pub extern "env" fn App_getClient_WASM(cppPtr: basis.CppPtr) basis.CppPtr;
pub extern "env" fn App_getServer_WASM(cppPtr: basis.CppPtr) basis.CppPtr;
pub extern "env" fn App_addInput_WASM(cppPtr: basis.CppPtr, inputID: u16, inputType: i32) void;
pub extern "env" fn App_getInputBufferSize_WASM(cppPtr: basis.CppPtr) u32;
pub extern "env" fn App_clearInputMappings_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn App_mapInput_WASM(cppPtr: basis.CppPtr, inputID: u16, source: i32, contextID: u8, valueMultiplier: f32, flags: i32) void;
pub extern "env" fn App_mapKeyboardInput_WASM(cppPtr: basis.CppPtr, inputID: u16, keyCode: i32, contextID: u8, flags: i32) void;
pub extern "env" fn App_mapMouseButtonInput_WASM(cppPtr: basis.CppPtr, inputID: u16, mouseButton: i32, contextID: u8, flags: i32) void;
pub extern "env" fn App_mapGamepadButtonInput_WASM(cppPtr: basis.CppPtr, inputID: u16, gamepadButton: i32, contextID: u8, flags: i32) void;
pub extern "env" fn App_registerMessage_WASM(cppPtr: basis.CppPtr, message: i32, category: i32) void;
pub extern "env" fn App_getClientGameFlowStateMachine_WASM(cppPtr: basis.CppPtr) basis.CppPtr;
pub extern "env" fn App_getServerGameFlowStateMachine_WASM(cppPtr: basis.CppPtr) basis.CppPtr;
//pub extern "env" fn App_createAndLoadSPGame_WASM(cppPtr: basis.CppPtr, gameName: [*c]const basis.bindings.InteropString, levelPath: [*c]const basis.bindings.InteropString, layers: [*c]const basis.bindings.InteropString, layerCount: u32, sessionObjects: [*c]const u64, sessionObjectCount: u32, continuous: c_int, callback: basis.bindings.FP_void_IntPtr64_i32, callbackContext: u64) void;
//pub extern "env" fn App_createSPGame_WASM(cppPtr: basis.CppPtr, gameName: [*c]const basis.bindings.InteropString, continuous: c_int, callback: basis.bindings.FP_void_IntPtr64_i32, callbackContext: u64) void;
//pub extern "env" fn App_loadSPGame_WASM(cppPtr: basis.CppPtr, levelPath: [*c]const basis.bindings.InteropString, layers: [*c]const basis.bindings.InteropString, layerCount: u32, sessionObjects: [*c]const u64, sessionObjectCount: u32) void;
//pub extern "env" fn App_leaveGame_WASM(cppPtr: basis.CppPtr, alsoDisconnectFromServer: c_int, callback: basis.bindings.FP_void_IntPtr64_i32, callbackContext: u64) void;
//pub extern "env" fn App_spGameCallbackWrapper_WASM(resultCode: i32) void;
pub extern "env" fn App_isLocalServerRunning_WASM() i32;
pub extern "env" fn App_isServerThreadRunning_WASM() i32;
pub extern "env" fn App_hasCommandLineParameter_WASM(parameterPtr: [*]const u8, parameterLength: u32) i32;
pub extern "env" fn App_getCommandLineParameter_WASM(parameterPtr: [*]const u8, parameterLength: u32, valueBufferPtr: [*]u8, valueBufferLength: u32) u32;

// ===============================

// ModController:

pub extern "env" fn Mod_createModController_WASM(zigLibCppPtr_0: basis.CppPtr, zigLibCppPtr_1: u32, zigModControllerInterfacePtr: basis.IntPtr64) basis.CppPtr;
pub extern "env" fn Mod_getAppMode_WASM(cppPtr: basis.CppPtr) i32;
pub extern "env" fn Mod_getClient_WASM(cppPtr: basis.CppPtr) basis.CppPtr;
pub extern "env" fn Mod_getServer_WASM(cppPtr: basis.CppPtr) basis.CppPtr;
pub extern "env" fn Mod_registerMessage_WASM(cppPtr: basis.CppPtr, message: i32, category: i32) void;

// ===============================

// Client:

pub extern "env" fn Client_getHostID_WASM(cppPtr: basis.CppPtr) i32;
pub extern "env" fn Client_getRenderer_WASM(cppPtr: basis.CppPtr) basis.CppPtr;
pub extern "env" fn Client_getGameSession_WASM(cppPtr: basis.CppPtr) basis.CppPtr;
pub extern "env" fn Client_getGameState_WASM(cppPtr: basis.CppPtr) basis.CppPtr;
pub extern "env" fn Client_getPhysicsEnginePtr_WASM(cppPtr: basis.CppPtr) basis.CppPtr;
pub extern "env" fn Client_getPrimaryPhysicsScene_WASM(cppPtr: basis.CppPtr) basis.CppPtr;
pub extern "env" fn Client_getInterpolationFactor_WASM(cppPtr: basis.CppPtr) f64;
pub extern "env" fn Client_createMessageNode_WASM(zigLibCppPtr_0: basis.CppPtr, zigLibCppPtr_1: u32, cppPtr: basis.CppPtr, messageNodeNamePtr: [*]const u8, messageNodeNameLength: u32, zigNodePtr: basis.IntPtr64) basis.CppPtr;
//pub extern "env" fn Client_addRPCListener_WASM(cppPtr: basis.CppPtr, onRPCReceivedPtr: u64, userData: u64) basis.CppPtr;
//pub extern "env" fn Client_removeRPCListener_WASM(cppPtr: basis.CppPtr, listenerPtr: basis.CppPtr) void;
pub extern "env" fn Client_sendNetworkMessageToHostID_WASM(cppPtr: basis.CppPtr, data: [*c]const u8, dataLength: u32, reliable: bool, hostID: i32) void;
pub extern "env" fn Client_sendNetworkMessageToPeer_WASM(cppPtr: basis.CppPtr, data: [*c]const u8, dataLength: u32, reliable: bool, peerCppPtr: basis.CppPtr) void;
pub extern "env" fn Client_isConnected_WASM(cppPtr: basis.CppPtr) i32;

// ===============================

// Server:

pub extern "env" fn Server_getGameSession_WASM(cppPtr: basis.CppPtr) basis.CppPtr;
pub extern "env" fn Server_getGameState_WASM(cppPtr: basis.CppPtr) basis.CppPtr;
pub extern "env" fn Server_getPhysicsEnginePtr_WASM(cppPtr: basis.CppPtr) basis.CppPtr;
pub extern "env" fn Server_getPrimaryPhysicsScene_WASM(cppPtr: basis.CppPtr) basis.CppPtr;
pub extern "env" fn Server_createMessageNode_WASM(zigLibCppPtr_0: basis.CppPtr, zigLibCppPtr_1: u32, cppPtr: basis.CppPtr, messageNodeNamePtr: [*]const u8, messageNodeNameLength: u32, zigNodePtr: basis.IntPtr64) basis.CppPtr;
//pub extern "env" fn Server_addRPCListener_WASM(cppPtr: basis.CppPtr, onRPCReceivedPtr: u64, userData: u64) basis.CppPtr;
//pub extern "env" fn Server_removeRPCListener_WASM(cppPtr: basis.CppPtr, listenerPtr: basis.CppPtr) void;
pub extern "env" fn Server_sendNetworkMessageToHostID_WASM(cppPtr: basis.CppPtr, data: [*c]const u8, dataLength: u32, reliable: bool, hostID: i32) void;
pub extern "env" fn Server_sendNetworkMessageToPeer_WASM(cppPtr: basis.CppPtr, data: [*c]const u8, dataLength: u32, reliable: bool, peerCppPtr: basis.CppPtr) void;
pub extern "env" fn Server_endGameSession_WASM(cppPtr: basis.CppPtr) void;

// ===============================

// CommandPrompt:

pub extern "env" fn CommandPrompt_parseCommand_WASM(commandPtr: [*]const u8, commandLength: u32) void;
pub extern "env" fn CommandPrompt_registerIntValue_WASM(
    namespacePtr: [*]const u8,
    namespaceLength: u32,
    namePtr: [*]const u8,
    nameLength: u32,
    setCallback: basis.WasmFuncPtr,
    getCallback: basis.WasmFuncPtr,
    onServer: i32,
    helpTextPtr: [*c]const u8, // Must be [*c] to allow nulls.
    helpTextLength: u32,
) void;
pub extern "env" fn CommandPrompt_registerFloatValue_WASM(
    namespacePtr: [*]const u8,
    namespaceLength: u32,
    namePtr: [*]const u8,
    nameLength: u32,
    setCallback: basis.WasmFuncPtr,
    getCallback: basis.WasmFuncPtr,
    onServer: i32,
    helpTextPtr: [*c]const u8, // Must be [*c] to allow nulls.
    helpTextLength: u32,
) void;
pub extern "env" fn CommandPrompt_registerBoolValue_WASM(
    namespacePtr: [*]const u8,
    namespaceLength: u32,
    namePtr: [*]const u8,
    nameLength: u32,
    setCallback: basis.WasmFuncPtr,
    getCallback: basis.WasmFuncPtr,
    onServer: i32,
    helpTextPtr: [*c]const u8, // Must be [*c] to allow nulls.
    helpTextLength: u32,
) void;
pub extern "env" fn CommandPrompt_registerFunction_WASM(
    namespacePtr: [*]const u8,
    namespaceLength: u32,
    namePtr: [*]const u8,
    nameLength: u32,
    callback: basis.WasmFuncPtr,
    paramTypesBytes: [*]const u8,
    paramCount: u32,
    onServer: i32,
    helpTextPtr: [*c]const u8, // Must be [*c] to allow nulls.
    helpTextLength: u32,
) void;
pub extern "env" fn CommandPrompt_unregister_WASM(namespacePtr: [*]const u8, namespaceLength: u32, namePtr: [*]const u8, nameLength: u32) void;
pub extern "env" fn CommandPrompt_outputLine_WASM(linePtr: [*]const u8, lineLength: u32) void;
pub extern "env" fn CommandPrompt_outputErrorLine_WASM(linePtr: [*]const u8, lineLength: u32) void;
pub extern "env" fn CommandPrompt_getIntParameter_WASM() i32;
pub extern "env" fn CommandPrompt_getFloatParameter_WASM() f32;
pub extern "env" fn CommandPrompt_getBoolParameter_WASM() i32;
pub extern "env" fn CommandPrompt_getStringParameter_WASM(bufferPtr: [*]u8, bufferLength: u32) u32;

// ===============================

// class PlayerController:

//pub extern "env" fn PlayerController_getClient_WASM(thisPtr: basis.bindings.InteropTypedPtr) u64;
//pub extern "env" fn PlayerController_getServer_WASM(thisPtr: basis.bindings.InteropTypedPtr) u64;
//pub extern "env" fn PlayerController_getInputRange_WASM(thisPtr: basis.bindings.InteropTypedPtr, inputID: u16) f32;
//pub extern "env" fn PlayerController_getInputState_WASM(thisPtr: basis.bindings.InteropTypedPtr, inputID: u16) bool;
//pub extern "env" fn PlayerController_getInputAction_WASM(thisPtr: basis.bindings.InteropTypedPtr, inputID: u16) bool;
//pub extern "env" fn PlayerController_subscribeToMessageCategory_WASM(thisPtr: basis.bindings.InteropTypedPtr, cat: i32) void;
//pub extern "env" fn PlayerController_allocMsgParams_WASM(thisPtr: basis.bindings.InteropTypedPtr) u64;
//pub extern "env" fn PlayerController_sendMessage_WASM(thisPtr: basis.bindings.InteropTypedPtr, message: i32, parameters: u64) void;

// ===============================

// class DebugDraw:

pub extern "env" fn DebugDraw_drawLine2D_WASM(parameterBufferPtr: [*]const u8, parameterBufferLength: u32) void;
pub extern "env" fn DebugDraw_drawLine3D_WASM(parameterBufferPtr: [*]const u8, parameterBufferLength: u32) void;
pub extern "env" fn DebugDraw_drawAxisCross_WASM(x: f32, y: f32, z: f32, scale: f32) void;
pub extern "env" fn DebugDraw_drawSphere_WASM(cx: f32, cy: f32, cz: f32, radius: f32, cr: u8, cg: u8, cb: u8, ca: u8, pointCount: c_int) void;
pub extern "env" fn DebugDraw_drawTriangle3D_WASM(parameterBufferPtr: [*]const u8, parameterBufferLength: u32) void;
pub extern "env" fn DebugDraw_drawString_WASM(textBufferPtr: [*]const u8, textBufferLength: u32, parameterBufferPtr: [*]const u8, parameterBufferLength: u32) void;
pub extern "env" fn DebugDraw_drawStringXY_WASM(textBufferPtr: [*]const u8, textBufferLength: u32, parameterBufferPtr: [*]const u8, parameterBufferLength: u32) void;

// ===============================

// class GameObject:

pub extern "env" fn GameObject_getName_WASM(cppPtr: basis.CppPtr, bufferPtr: [*]u8, bufferLength: u32) u32;
pub extern "env" fn GameObject_getType_WASM(cppPtr: basis.CppPtr, bufferPtr: [*]u8, bufferLength: u32) u32;
pub extern "env" fn GameObject_getComponentPtrByShortName_WASM(cppPtr: basis.CppPtr, shortNameBufferPtr: [*]const u8, shortNameBufferLength: u32) basis.IntPtr64;
pub extern "env" fn GameObject_getComponentPtrByTypeName_WASM(cppPtr: basis.CppPtr, typeNameBufferPtr: [*]const u8, typeNameBufferLength: u32) basis.IntPtr64;
pub extern "env" fn GameObject_addGameObjectMeshInstanceMapping_WASM(cppPtr: basis.CppPtr, meshInstancePtr: basis.CppPtr) void;
pub extern "env" fn GameObject_removeGameObjectMeshInstanceMapping_WASM(cppPtr: basis.CppPtr, meshInstancePtr: basis.CppPtr) void;
pub extern "env" fn GameObject_getNameHash_WASM(cppPtr: basis.CppPtr) u32;
pub extern "env" fn GameObject_getWorldTransform_WASM(cppPtr: basis.CppPtr, valueBufferPtr: [*]u8, valueBufferLength: u32) c_int;
pub extern "env" fn GameObject_setWorldTransform_WASM(cppPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) c_int;
pub extern "env" fn GameObject_getMeshComponentData_WASM(cppPtr: basis.CppPtr, componentShortNameBufferPtr: [*]const u8, componentShortNameBufferLength: u32, valueBufferPtr: [*]u8, valueBufferLength: u32) c_int;
pub extern "env" fn GameObject_getPhysicsActor_WASM(cppPtr: basis.CppPtr, valueBufferPtr: [*]u8, valueBufferLength: u32) c_int;
pub extern "env" fn GameObject_setGameTag_WASM(cppPtr: basis.CppPtr, tag: u32) void;
pub extern "env" fn GameObject_getGameTag_WASM(cppPtr: basis.CppPtr) u32;
pub extern "env" fn GameObject_getRenderSceneNode_WASM(cppPtr: basis.CppPtr) basis.CppPtr;

// ===============================

// class ComponentContext:

pub extern "env" fn ComponentContext_getName_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32, bufferPtr: [*]u8, bufferLength: u32) u32;
pub extern "env" fn ComponentContext_onClient_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32) bool;
pub extern "env" fn ComponentContext_inEditor_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32) bool;
pub extern "env" fn ComponentContext_getClient_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32) basis.CppPtr;
pub extern "env" fn ComponentContext_getServer_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32) basis.CppPtr;
pub extern "env" fn ComponentContext_getGameObject_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32) basis.CppPtr;
pub extern "env" fn ComponentContext_subscribeToMessageCategory_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32, cat: i32) void;
pub extern "env" fn ComponentContext_allocMsgParams_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32) basis.CppPtr;
pub extern "env" fn ComponentContext_sendMessage_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32, message: i32, parameters: basis.CppPtr) void;
pub extern "env" fn ComponentContext_getPhysicsEnginePtr_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32) basis.CppPtr;
pub extern "env" fn ComponentContext_getPrimaryPhysicsScene_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32) basis.CppPtr;
pub extern "env" fn ComponentContext_getRenderer_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32) basis.CppPtr;
pub extern "env" fn ComponentContext_getGameSession_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32) basis.CppPtr;
pub extern "env" fn ComponentContext_getGameState_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32) basis.CppPtr;
pub extern "env" fn ComponentContext_getPosition_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32, valueBufferPtr: [*]u8, valueBufferLength: u32) void;
pub extern "env" fn ComponentContext_setPosition_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32, x: f32, y: f32, z: f32) void;
pub extern "env" fn ComponentContext_getOrientation_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32, valueBufferPtr: [*]u8, valueBufferLength: u32) void;
pub extern "env" fn ComponentContext_setOrientation_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32, w: f32, x: f32, y: f32, z: f32) void;
pub extern "env" fn ComponentContext_getLinearVelocity_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32, valueBufferPtr: [*]u8, valueBufferLength: u32) void;
pub extern "env" fn ComponentContext_getAngularVelocity_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32, valueBufferPtr: [*]u8, valueBufferLength: u32) void;
pub extern "env" fn ComponentContext_setTransform_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32, valueBufferPtr: [*]const u8, valueBufferLength: u32) void;
pub extern "env" fn ComponentContext_setTransformWithVelocities_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32, valueBufferPtr: [*]const u8, valueBufferLength: u32) void;
pub extern "env" fn ComponentContext_getWorldMatrix_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32, valueBufferPtr: [*]u8, valueBufferLength: u32) void;
pub extern "env" fn ComponentContext_getRenderSceneNode_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32) basis.CppPtr;
pub extern "env" fn ComponentContext_isClientLocalAvatar_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32) bool;
pub extern "env" fn ComponentContext_getAvatarHostID_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32) i32;
pub extern "env" fn ComponentContext_getInputRange_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32, inputID: u16) f32;
pub extern "env" fn ComponentContext_getInputState_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32, inputID: u16) bool;
pub extern "env" fn ComponentContext_getInputAction_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32, inputID: u16) bool;
pub extern "env" fn ComponentContext_getCharacterController_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32) basis.CppPtr;
pub extern "env" fn ComponentContext_getPhysicsActor_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32, valueBufferPtr: [*]u8, valueBufferLength: u32) c_int;
pub extern "env" fn ComponentContext_flushExposedProperties_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32) void;
pub extern "env" fn ComponentContext_getParentGameObject_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32) basis.CppPtr;
pub extern "env" fn ComponentContext_registerPipe_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32, pipeNameBufferPtr: [*]const u8, pipeNameBufferLength: u32, direction: c_int, reliable: bool) u64;
pub extern "env" fn ComponentContext_writeToPipe_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32, pipe: u64, data: [*c]const u8, dataLength: u32) void;
pub extern "env" fn ComponentContext_callScriptOnTick_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32, tickDeltaTime: f32) void;
pub extern "env" fn ComponentContext_getScriptFunctionByDecl_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32, declBufferPtr: [*c]const u8, declBufferLength: u32) basis.CppPtr;
pub extern "env" fn ComponentContext_getScriptFunctionByASFuncPtr_WASM(thisPtr_0: basis.CppPtr, thisPtr_1: u32, funcPtr: basis.CppPtr) basis.CppPtr;

// ===============================

// AngelScriptFunction:

//pub extern "env" fn AngelScriptFunction_prepareCall_WASM(thisPtr: u64) void;
//pub extern "env" fn AngelScriptFunction_setBoolParam_WASM(thisPtr: u64, i: u32, value: bool) void;
//pub extern "env" fn AngelScriptFunction_setIntParam_WASM(thisPtr: u64, i: u32, value: c_int) void;
//pub extern "env" fn AngelScriptFunction_setUintParam_WASM(thisPtr: u64, i: u32, value: u32) void;
//pub extern "env" fn AngelScriptFunction_setFloatParam_WASM(thisPtr: u64, i: u32, value: f32) void;
//pub extern "env" fn AngelScriptFunction_setStringParam_WASM(thisPtr: u64, i: u32, value: [*c]const basis.bindings.InteropString) void;
//pub extern "env" fn AngelScriptFunction_setGameObjectRefParam_WASM(thisPtr: u64, i: u32, objectNameHash: u32, hostCppPtr: u64, hostIsClient: bool) void;
//pub extern "env" fn AngelScriptFunction_executeCall_WASM(thisPtr: u64) void;

// ===============================

// MessageParameters:

pub extern "env" fn MessageParameters_addInt_WASM(thisPtr: basis.CppPtr, p: i32) void;
pub extern "env" fn MessageParameters_getInt_WASM(thisPtr: basis.CppPtr) i32;
pub extern "env" fn MessageParameters_addUint_WASM(thisPtr: basis.CppPtr, p: u32) void;
pub extern "env" fn MessageParameters_getUint_WASM(thisPtr: basis.CppPtr) u32;
pub extern "env" fn MessageParameters_addUint64_WASM(thisPtr: basis.CppPtr, p: u64) void;
pub extern "env" fn MessageParameters_getUint64_WASM(thisPtr: basis.CppPtr) u64;
pub extern "env" fn MessageParameters_addFloat_WASM(thisPtr: basis.CppPtr, p: f32) void;
pub extern "env" fn MessageParameters_getFloat_WASM(thisPtr: basis.CppPtr) f32;
pub extern "env" fn MessageParameters_addVec3_WASM(thisPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) void;
pub extern "env" fn MessageParameters_getVec3_WASM(thisPtr: basis.CppPtr, valueBufferPtr: [*]u8, valueBufferLength: u32) void;
pub extern "env" fn MessageParameters_addVec4_WASM(thisPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) void;
pub extern "env" fn MessageParameters_getVec4_WASM(thisPtr: basis.CppPtr, valueBufferPtr: [*]u8, valueBufferLength: u32) void;
pub extern "env" fn MessageParameters_addQuaternion_WASM(thisPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) void;
pub extern "env" fn MessageParameters_getQuaternion_WASM(thisPtr: basis.CppPtr, valueBufferPtr: [*]u8, valueBufferLength: u32) void;
pub extern "env" fn MessageParameters_addString_WASM(thisPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) void;
pub extern "env" fn MessageParameters_getString_WASM(thisPtr: basis.CppPtr, valueBufferPtr: [*]u8, valueBufferLength: u32) u32;

// ===============================

// MessageNode:

pub extern "env" fn MessageNode_destroy_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn MessageNode_subscribeToMessageCategory_WASM(cppPtr: basis.CppPtr, cat: i32) void;
pub extern "env" fn MessageNode_allocMsgParams_WASM(cppPtr: basis.CppPtr) basis.CppPtr;
pub extern "env" fn MessageNode_sendMessage_WASM(cppPtr: basis.CppPtr, message: i32, parameters: basis.CppPtr) void;

// ===============================

// InputManager:

pub extern "env" fn InputManager_addGameInputContextToFront_WASM(context: u8) void;
pub extern "env" fn InputManager_addGameInputContextToBack_WASM(context: u8) void;
pub extern "env" fn InputManager_isGameInputContextEnabled_WASM(context: u8) bool;
pub extern "env" fn InputManager_removeGameInputContext_WASM(context: u8) void;
pub extern "env" fn InputManager_isCursorLocked_WASM() bool;
pub extern "env" fn InputManager_lockCursor_WASM() void;
pub extern "env" fn InputManager_releaseCursor_WASM() void;
pub extern "env" fn InputManager_getGameInputMode_WASM() i32;
pub extern "env" fn InputManager_isKeyPressed_WASM(keyCode: u32) bool;
pub extern "env" fn InputManager_isMouseButtonPressed_WASM(id: u32) bool;
pub extern "env" fn InputManager_getMappedKeyCode_WASM(inputID: u16, context: u8, flags: i32) i32;
pub extern "env" fn InputManager_getMappedMouseButton_WASM(inputID: u16, context: u8, flags: i32) i32;
pub extern "env" fn InputManager_getMappedGamepadButton_WASM(inputID: u16, context: u8, flags: i32) i32;

// ===============================

// PropagatedValue:

pub extern "env" fn PropagatedValue_create_WASM(
    thisPtr_0: basis.CppPtr,
    thisPtr_1: u32,
    zigPVPtr: u64,
    namePtr: [*c]const u8,
    nameLength: u32,
    valueBufferPtr: [*]const u8,
    valueBufferLength: u32,
) basis.CppPtr;

pub extern "env" fn PropagatedValue_set_WASM(cppPVPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) void;

pub extern "env" fn PropagatedValue_createAction_WASM(
    thisPtr_0: basis.CppPtr,
    thisPtr_1: u32,
    zigPAPtr: u64,
    namePtr: [*c]const u8,
    nameLength: u32,
    reliablePropagation: bool,
    immediatePropagation: bool,
) basis.CppPtr;

pub extern "env" fn PropagatedValue_fireAction_WASM(cppPAPtr: basis.CppPtr) void;

// ===============================

// SceneNode:

pub extern "env" fn SceneNode_newNode_WASM() basis.CppPtr;
pub extern "env" fn SceneNode_deleteNode_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn SceneNode_createChildNode_WASM(cppPtr: basis.CppPtr) basis.CppPtr;
pub extern "env" fn SceneNode_destroyChildNode_WASM(cppPtr: basis.CppPtr, cppChildPtr: basis.CppPtr) void;
pub extern "env" fn SceneNode_detachAll_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn SceneNode_destroyAllChildNodes_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn SceneNode_setPosition_WASM(cppPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) void;
pub extern "env" fn SceneNode_getPosition_WASM(cppPtr: basis.CppPtr, space: c_int, valueBufferPtr: [*]u8, valueBufferLength: u32) void;
pub extern "env" fn SceneNode_setOrientation_WASM(cppPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) void;
pub extern "env" fn SceneNode_getOrientation_WASM(cppPtr: basis.CppPtr, space: c_int, valueBufferPtr: [*]u8, valueBufferLength: u32) void;
pub extern "env" fn SceneNode_setScale_WASM(cppPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) void;
pub extern "env" fn SceneNode_getScale_WASM(cppPtr: basis.CppPtr, valueBufferPtr: [*]u8, valueBufferLength: u32) void;
pub extern "env" fn SceneNode_translate_WASM(cppPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) void;
pub extern "env" fn SceneNode_yaw_WASM(cppPtr: basis.CppPtr, angle: f32, space: c_int, immediateUpdate: bool) void;
pub extern "env" fn SceneNode_pitch_WASM(cppPtr: basis.CppPtr, angle: f32, space: c_int, immediateUpdate: bool) void;
pub extern "env" fn SceneNode_roll_WASM(cppPtr: basis.CppPtr, angle: f32, space: c_int, immediateUpdate: bool) void;
pub extern "env" fn SceneNode_lookAtSceneNode_WASM(cppPtr: basis.CppPtr, targetCppPtr: basis.CppPtr, immediateUpdate: bool) void;
pub extern "env" fn SceneNode_attachMeshInstance_WASM(cppPtr: basis.CppPtr, meshInstanceCppPtr: basis.CppPtr) void;
pub extern "env" fn SceneNode_detachMeshInstance_WASM(cppPtr: basis.CppPtr, meshInstanceCppPtr: basis.CppPtr) void;
pub extern "env" fn SceneNode_isMeshInstanceAttached_WASM(cppPtr: basis.CppPtr, meshInstanceCppPtr: basis.CppPtr) i32;
pub extern "env" fn SceneNode_attachCamera_WASM(cppPtr: basis.CppPtr, cameraCppPtr: basis.CppPtr) void;
pub extern "env" fn SceneNode_detachCamera_WASM(cppPtr: basis.CppPtr, cameraCppPtr: basis.CppPtr) void;
pub extern "env" fn SceneNode_isCameraAttached_WASM(cppPtr: basis.CppPtr, cameraCppPtr: basis.CppPtr) i32;
pub extern "env" fn SceneNode_getLocalToParentTransform_WASM(cppPtr: basis.CppPtr, valueBufferPtr: [*]u8, valueBufferLength: u32) void;
pub extern "env" fn SceneNode_getLocalToWorldTransform_WASM(cppPtr: basis.CppPtr, valueBufferPtr: [*]u8, valueBufferLength: u32) void;
pub extern "env" fn SceneNode_getLocalToAncestorTransform_WASM(cppPtr: basis.CppPtr, ancestorCppPtr: basis.CppPtr, valueBufferPtr: [*]u8, valueBufferLength: u32) void;

// ===============================

// PhysicsScene:

pub extern "env" fn PhysicsScene_addActor_WASM(sceneCppPtr: basis.CppPtr, actorCppPtr: basis.CppPtr) void;
pub extern "env" fn PhysicsScene_removeActor_WASM(sceneCppPtr: basis.CppPtr, actorCppPtr: basis.CppPtr) void;
pub extern "env" fn PhysicsScene_addVehicleController_WASM(sceneCppPtr: basis.CppPtr, vehicleControllerCppPtr: basis.CppPtr) void;
pub extern "env" fn PhysicsScene_removeVehicleController_WASM(sceneCppPtr: basis.CppPtr, vehicleControllerCppPtr: basis.CppPtr) void;
pub extern "env" fn PhysicsScene_addJoint_WASM(sceneCppPtr: basis.CppPtr, jointCppPtr: basis.CppPtr, jointType: u32) void;
pub extern "env" fn PhysicsScene_removeJoint_WASM(sceneCppPtr: basis.CppPtr, jointCppPtr: basis.CppPtr, jointType: u32) void;
pub extern "env" fn PhysicsScene_applyRadialForce_WASM(sceneCppPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) void;
pub extern "env" fn PhysicsScene_applyRadialImpulse_WASM(sceneCppPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) void;
pub extern "env" fn PhysicsScene_sphereSweep_WASM(sceneCppPtr: basis.CppPtr, parameterBufferPtr: [*]u8, parameterBufferLength: u32) c_int;
//pub extern "env" fn PhysicsScene_sphereSweepEx_WASM(sceneCppPtr: basis.CppPtr, sphereRadius: f32, origin: [*c]const basis.bindings.InteropVec3, direction: [*c]const basis.bindings.InteropVec3, maxDistance: f32, resultArray: [*c]basis.bindings.PhysicsInteropRayCastResult, resultArraySize: u32, blockingActorTypes: u32) u32;
//pub extern "env" fn PhysicsScene_getSphereOverlapping_WASM(sceneCppPtr: basis.CppPtr, center: [*c]const basis.bindings.InteropVec3, radius: f32) u32;
pub extern "env" fn PhysicsScene_castRay_WASM(sceneCppPtr: basis.CppPtr, parameterBufferPtr: [*]u8, parameterBufferLength: u32) c_int;
pub extern "env" fn PhysicsScene_castRayEx_WASM(sceneCppPtr: basis.CppPtr, parameterBufferPtr: [*]u8, parameterBufferLength: u32) c_int;
//pub extern "env" fn PhysicsScene_castRayWithCallback_WASM(sceneCppPtr: basis.CppPtr, origin: [*c]const basis.bindings.InteropVec3, direction: [*c]const basis.bindings.InteropVec3, maxDistance: f32, result: [*c]basis.bindings.PhysicsInteropRayCastResult, blockingActorTypes: u32, callbackPtr: u64, needsPostFilter: bool, shouldReportHit: basis.bindings.FP_i32_IntPtr_IntPtr64_u32, shouldReportHitPostFilter: basis.bindings.FP_i32_IntPtr_IntPtr64_u32_Vec3_Vec3) c_int;
//pub extern "env" fn PhysicsScene_setCollisionCallbacksEnabled_WASM(sceneCppPtr: basis.CppPtr, enabled: c_int) void;

// ===============================

// PhysicsMaterial:

pub extern "env" fn PhysicsMaterial_getDefaultMaterial_WASM(physicsEngineCppPtr: basis.CppPtr) basis.CppPtr;
pub extern "env" fn PhysicsMaterial_getBaseMaterial_WASM(physicsEngineCppPtr: basis.CppPtr, materialIndex: u32) basis.CppPtr;
pub extern "env" fn PhysicsMaterial_createMaterial_WASM(physicsEngineCppPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) basis.CppPtr;
pub extern "env" fn PhysicsMaterial_getBasePhysicsMaterialName_WASM(cppPtr: basis.CppPtr) u32;
pub extern "env" fn PhysicsMaterial_addRef_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn PhysicsMaterial_release_WASM(cppPtr: basis.CppPtr) void;

// ===============================

// PhysicsShape:

pub extern "env" fn PhysicsShape_createBox_WASM(physicsEngineCppPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) basis.CppPtr;
pub extern "env" fn PhysicsShape_createSphere_WASM(physicsEngineCppPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) basis.CppPtr;
pub extern "env" fn PhysicsShape_createCapsule_WASM(physicsEngineCppPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) basis.CppPtr;
pub extern "env" fn PhysicsShape_createCylinder_WASM(physicsEngineCppPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) basis.CppPtr;
pub extern "env" fn PhysicsShape_createCylinderX_WASM(physicsEngineCppPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) basis.CppPtr;
pub extern "env" fn PhysicsShape_createCylinderZ_WASM(physicsEngineCppPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) basis.CppPtr;
pub extern "env" fn PhysicsShape_addRef_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn PhysicsShape_release_WASM(cppPtr: basis.CppPtr) void;

// ===============================

// PhysicsActor:

pub extern "env" fn PhysicsActor_createRigidBodyDynamic_WASM(physicsEngineCppPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) basis.CppPtr;
pub extern "env" fn PhysicsActor_createRigidBodyStatic_WASM(physicsEngineCppPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) basis.CppPtr;
pub extern "env" fn PhysicsActor_createBoxTrigger_WASM(zigLibCppPtr_0: basis.CppPtr, zigLibCppPtr_1: u32, physicsEngineCppPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) basis.CppPtr;
pub extern "env" fn PhysicsActor_createSphereTrigger_WASM(zigLibCppPtr_0: basis.CppPtr, zigLibCppPtr_1: u32, physicsEngineCppPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) basis.CppPtr;
pub extern "env" fn PhysicsActor_setWorldTransform_WASM(cppPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) void;
pub extern "env" fn PhysicsActor_getWorldTransform_WASM(cppPtr: basis.CppPtr, valueBufferPtr: [*]u8, valueBufferLength: u32) void;
pub extern "env" fn PhysicsActor_setKinematicTarget_WASM(cppPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) void;
pub extern "env" fn PhysicsActor_setMassData_WASM(cppPtr: basis.CppPtr, mass: f32, comX: f32, comY: f32, comZ: f32) void;
pub extern "env" fn PhysicsActor_getWorldBounds_WASM(cppPtr: basis.CppPtr, valueBufferPtr: [*]u8, valueBufferLength: u32) void;
pub extern "env" fn PhysicsActor_associateWithGameObject_WASM(cppPtr: basis.CppPtr, gameObjectCppPtr: basis.CppPtr) void;
pub extern "env" fn PhysicsActor_getAssociatedGameObject_WASM(cppPtr: basis.CppPtr) basis.CppPtr;
pub extern "env" fn PhysicsActor_isSleeping_WASM(cppPtr: basis.CppPtr) c_int;
pub extern "env" fn PhysicsActor_wakeUp_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn PhysicsActor_putToSleep_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn PhysicsActor_setLinearVelocity_WASM(cppPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) void;
pub extern "env" fn PhysicsActor_getLinearVelocity_WASM(cppPtr: basis.CppPtr, valueBufferPtr: [*]u8, valueBufferLength: u32) void;
pub extern "env" fn PhysicsActor_setAngularVelocity_WASM(cppPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) void;
pub extern "env" fn PhysicsActor_getAngularVelocity_WASM(cppPtr: basis.CppPtr, valueBufferPtr: [*]u8, valueBufferLength: u32) void;
pub extern "env" fn PhysicsActor_addForce_WASM(cppPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) void;
pub extern "env" fn PhysicsActor_addImpulse_WASM(cppPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) void;
pub extern "env" fn PhysicsActor_addRef_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn PhysicsActor_release_WASM(cppPtr: basis.CppPtr) void;

// ===============================

// PhysicsJoint:

//pub extern "env" fn PhysicsJoint_createFixedJoint_WASM(physicsEngineCppPtr: u64, actorACppPtr: u64, actorAPosition: [*c]const basis.bindings.InteropVec3, actorAOrientation: [*c]const basis.bindings.InteropQuaternion, actorBCppPtr: u64, actorBPosition: [*c]const basis.bindings.InteropVec3, actorBOrientation: [*c]const basis.bindings.InteropQuaternion) u64;
//pub extern "env" fn PhysicsJoint_createSphericalJoint_WASM(physicsEngineCppPtr: u64, actorACppPtr: u64, actorAPosition: [*c]const basis.bindings.InteropVec3, actorAOrientation: [*c]const basis.bindings.InteropQuaternion, actorBCppPtr: u64, actorBPosition: [*c]const basis.bindings.InteropVec3, actorBOrientation: [*c]const basis.bindings.InteropQuaternion) u64;
//pub extern "env" fn PhysicsJoint_createDistanceJoint_WASM(physicsEngineCppPtr: u64, actorACppPtr: u64, actorAPosition: [*c]const basis.bindings.InteropVec3, actorAOrientation: [*c]const basis.bindings.InteropQuaternion, actorBCppPtr: u64, actorBPosition: [*c]const basis.bindings.InteropVec3, actorBOrientation: [*c]const basis.bindings.InteropQuaternion) u64;
//pub extern "env" fn PhysicsJoint_createDof6Joint_WASM(physicsEngineCppPtr: u64, actorACppPtr: u64, actorAPosition: [*c]const basis.bindings.InteropVec3, actorAOrientation: [*c]const basis.bindings.InteropQuaternion, actorBCppPtr: u64, actorBPosition: [*c]const basis.bindings.InteropVec3, actorBOrientation: [*c]const basis.bindings.InteropQuaternion) u64;
//pub extern "env" fn PhysicsJoint_createSphericalSpringJoint_WASM(physicsEngineCppPtr: u64, actorACppPtr: u64, actorAPosition: [*c]const basis.bindings.InteropVec3, actorAOrientation: [*c]const basis.bindings.InteropQuaternion, actorBCppPtr: u64, actorBPosition: [*c]const basis.bindings.InteropVec3, actorBOrientation: [*c]const basis.bindings.InteropQuaternion, stiffness: f32, damping: f32, forceLimit: f32) u64;
//pub extern "env" fn PhysicsJoint_enableProjection_WASM(cppPtr: basis.CppPtr, jointType: u32, projectToActor0: bool, linearTolerance: f32, angularTolerance: f32) void;
//pub extern "env" fn PhysicsJoint_setBreakForce_WASM(cppPtr: basis.CppPtr, jointType: u32, force: f32, torque: f32) void;
//pub extern "env" fn PhysicsJoint_setDof6Motion_WASM(cppPtr: basis.CppPtr, axis: u32, motion: u32) void;
//pub extern "env" fn PhysicsJoint_setDof6Drive_WASM(cppPtr: basis.CppPtr, drive: u32, driveStiffness: f32, driveDamping: f32, driveForceLimit: f32, isAcceleration: bool) void;
//pub extern "env" fn PhysicsJoint_setDof6TwistLimit_WASM(cppPtr: basis.CppPtr, lower: f32, upper: f32) void;
//pub extern "env" fn PhysicsJoint_setDriveGoalPose_WASM(cppPtr: basis.CppPtr, jointType: u32, posePosition: [*c]const basis.bindings.InteropVec3, poseOrientation: [*c]const basis.bindings.InteropQuaternion) void;
//pub extern "env" fn PhysicsJoint_getConstraintForce_WASM(cppPtr: basis.CppPtr, jointType: u32, linear: [*c]basis.bindings.InteropVec3, angular: [*c]basis.bindings.InteropVec3) void;
//pub extern "env" fn PhysicsJoint_setInvMassScale0_WASM(cppPtr: basis.CppPtr, jointType: u32, invMassScale: f32) void;
//pub extern "env" fn PhysicsJoint_setInvInertiaScale0_WASM(cppPtr: basis.CppPtr, jointType: u32, invInertiaScale: f32) void;
//pub extern "env" fn PhysicsJoint_setInvMassScale1_WASM(cppPtr: basis.CppPtr, jointType: u32, invMassScale: f32) void;
//pub extern "env" fn PhysicsJoint_setInvInertiaScale1_WASM(cppPtr: basis.CppPtr, jointType: u32, invInertiaScale: f32) void;
//pub extern "env" fn PhysicsJoint_getInvMassScale0_WASM(cppPtr: basis.CppPtr, jointType: u32) f32;
//pub extern "env" fn PhysicsJoint_getInvInertiaScale0_WASM(cppPtr: basis.CppPtr, jointType: u32) f32;
//pub extern "env" fn PhysicsJoint_getInvMassScale1_WASM(cppPtr: basis.CppPtr, jointType: u32) f32;
//pub extern "env" fn PhysicsJoint_getInvInertiaScale1_WASM(cppPtr: basis.CppPtr, jointType: u32) f32;
//pub extern "env" fn PhysicsJoint_addRef_WASM(cppPtr: basis.CppPtr, jointType: u32) void;
//pub extern "env" fn PhysicsJoint_release_WASM(cppPtr: basis.CppPtr, jointType: u32) void;

// ===============================

// PhysicsTriMesh:

//pub extern "env" fn PhysicsTriMesh_createTriMesh_WASM(physicsEngineCppPtr: u64, data: [*c]const basis.bindings.InteropString) u64;
//pub extern "env" fn PhysicsTriMesh_getTriangleCount_WASM(cppPtr: basis.CppPtr) u32;
//pub extern "env" fn PhysicsTriMesh_getTriangleVertices_WASM(cppPtr: basis.CppPtr, triangle: u32, p0: [*c]basis.bindings.InteropVec3, p1: [*c]basis.bindings.InteropVec3, p2: [*c]basis.bindings.InteropVec3) void;
//pub extern "env" fn PhysicsTriMesh_pointDistance_WASM(cppPtr: basis.CppPtr, point: [*c]const basis.bindings.InteropVec3, meshPosition: [*c]const basis.bindings.InteropVec3, meshOrientation: [*c]const basis.bindings.InteropQuaternion, closestPoint: [*c]basis.bindings.InteropVec3, closestIndex: [*c]u32) f32;
//pub extern "env" fn PhysicsTriMesh_addRef_WASM(cppPtr: basis.CppPtr) void;
//pub extern "env" fn PhysicsTriMesh_release_WASM(cppPtr: basis.CppPtr) void;

// ===============================

// CharacterController:

//pub extern "env" fn CharacterController_setMovementVector_WASM(cppPtr: basis.CppPtr, movementVector: [*c]const basis.bindings.InteropVec2) void;
//pub extern "env" fn CharacterController_getMovementVector_WASM(cppPtr: basis.CppPtr, movementVector: [*c]basis.bindings.InteropVec2) void;
//pub extern "env" fn CharacterController_getLinearVelocity_WASM(cppPtr: basis.CppPtr, linearVelocity: [*c]basis.bindings.InteropVec3) void;
//pub extern "env" fn CharacterController_addRef_WASM(cppPtr: basis.CppPtr) void;
//pub extern "env" fn CharacterController_release_WASM(cppPtr: basis.CppPtr) void;

// ===============================

// VehicleController:

//pub extern "env" fn VehicleController_createVehicleController_WASM(physicsEngineCppPtr: u64, desc: [*c]const basis.bindings.InteropVehCtrlDesc, controllerType: i32) u64;
//pub extern "env" fn VehicleController_reinit_WASM(cppPtr: basis.CppPtr, desc: [*c]const basis.bindings.InteropVehCtrlDesc) void;
//pub extern "env" fn VehicleController_setInputData_WASM(cppPtr: basis.CppPtr, inputData: [*c]const basis.bindings.InteropVehInputData) void;
//pub extern "env" fn VehicleController_getInputData_WASM(cppPtr: basis.CppPtr, inputData: [*c]basis.bindings.InteropVehInputData) void;
//pub extern "env" fn VehicleController_startGearChange_WASM(cppPtr: basis.CppPtr, targetGear: i32) void;
//pub extern "env" fn VehicleController_forceGearChange_WASM(cppPtr: basis.CppPtr, targetGear: i32) void;
//pub extern "env" fn VehicleController_freezeInputData_WASM(cppPtr: basis.CppPtr, forceBrakes: c_int) void;
//pub extern "env" fn VehicleController_unfreezeInputData_WASM(cppPtr: basis.CppPtr) void;
//pub extern "env" fn VehicleController_getWheelCount_WASM(cppPtr: basis.CppPtr) u32;
//pub extern "env" fn VehicleController_getWheelStateInfo_WASM(cppPtr: basis.CppPtr, wheelIndex: u32, stateInfo: [*c]basis.bindings.InteropVehWheelStateInfo) void;
//pub extern "env" fn VehicleController_getStateInfo_WASM(cppPtr: basis.CppPtr, stateInfo: [*c]basis.bindings.InteropVehStateInfo) void;
//pub extern "env" fn VehicleController_addRef_WASM(cppPtr: basis.CppPtr) void;
//pub extern "env" fn VehicleController_release_WASM(cppPtr: basis.CppPtr) void;

// ===============================

// ResourceManager:

pub extern "env" fn ResourceManager_init_WASM() basis.CppPtr;
pub extern "env" fn ResourceManager_deinit_WASM() void;
pub extern "env" fn ResourceManager_acquireResource_WASM(cppPtr: basis.CppPtr, resourcePathPtr: [*]const u8, resourcePathLength: u32, resourceType: i32) basis.CppPtr;
pub extern "env" fn ResourceManager_lock_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn ResourceManager_unlock_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn ResourceManager_registerResourceReloadedCallback_WASM(resourceCppPtr: basis.CppPtr, callbackID: u32) void;
pub extern "env" fn ResourceManager_unregisterResourceReloadedCallback_WASM(resourceCppPtr: basis.CppPtr, callbackID: u32) void;
//pub extern "env" fn ResourceManager_beginGetResourcesWithFileExtension_WASM(cppPtr: basis.CppPtr, fileExtension: [*c]const basis.bindings.InteropString, resourceCount: [*c]u32) [*c]const basis.bindings.InteropString;
//pub extern "env" fn ResourceManager_endGetResourcesWithFileExtension_WASM() void;
//pub extern "env" fn ResourceManager_addLooseFileResourcePack_WASM(cppPtr: basis.CppPtr, resourcePackName: [*c]const basis.bindings.InteropString, mappings: [*c]const basis.bindings.InteropLooseFileMapping, mappingCount: u32) void;

// ===============================

// Resource:

pub extern "env" fn Resource_getSharedMesh_WASM(cppPtr: basis.CppPtr) basis.CppPtr;
pub extern "env" fn Resource_hasPhysicsMesh_WASM(cppPtr: basis.CppPtr) c_int;
//pub extern "env" fn Resource_getPhysicsMeshData_WASM(cppPtr: basis.CppPtr, data: [*c]basis.bindings.InteropString) void;
pub extern "env" fn Resource_getSharedMaterial_WASM(cppPtr: basis.CppPtr) basis.CppPtr;
//pub extern "env" fn Resource_getRawData_WASM(cppPtr: basis.CppPtr, data: [*c]basis.bindings.InteropString) void;
pub extern "env" fn Resource_addRef_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn Resource_release_WASM(cppPtr: basis.CppPtr) void;

// ===============================

// Renderer:

pub extern "env" fn Renderer_getPrimaryScene_WASM(cppPtr: basis.CppPtr) basis.CppPtr;
pub extern "env" fn Renderer_addCameraToBackOfQueue_WASM(cppPtr: basis.CppPtr, cameraCppPtr: basis.CppPtr) void;
pub extern "env" fn Renderer_addCameraToFrontOfQueue_WASM(cppPtr: basis.CppPtr, cameraCppPtr: basis.CppPtr) void;
pub extern "env" fn Renderer_removeCameraFromQueue_WASM(cppPtr: basis.CppPtr, cameraCppPtr: basis.CppPtr) void;
pub extern "env" fn Renderer_getMainCamera_WASM(cppPtr: basis.CppPtr) basis.CppPtr;
pub extern "env" fn Renderer_getScreenWidth_WASM(cppPtr: basis.CppPtr) u32;
pub extern "env" fn Renderer_getScreenHeight_WASM(cppPtr: basis.CppPtr) u32;
pub extern "env" fn Renderer_setVignetteEnabled_WASM(cppPtr: basis.CppPtr, enabled: c_int) void;
pub extern "env" fn Renderer_createMesh_WASM(cppPtr: basis.CppPtr, geomCppPtr: basis.CppPtr, createImmutableGPUBuffers: bool, debugNamePtr: [*]const u8, debugNameLength: u32) basis.CppPtr;
pub extern "env" fn Renderer_createMeshManual_WASM(cppPtr: basis.CppPtr, vertexFormatType: c_int, vertexCount: u32, indexCount: u32, debugNamePtr: [*]const u8, debugNameLength: u32) basis.CppPtr;
//pub extern "env" fn Renderer_captureSinglePre2DFrame_WASM(cppPtr: basis.CppPtr, outputFolderPath: [*c]const basis.bindings.InteropString) void;
//pub extern "env" fn Renderer_captureSingleFullEndUserFrame_WASM(cppPtr: basis.CppPtr, outputFolderPath: [*c]const basis.bindings.InteropString) void;
//pub extern "env" fn Renderer_captureSingleFullFrame_WASM(cppPtr: basis.CppPtr, outputFolderPath: [*c]const basis.bindings.InteropString) void;
//pub extern "env" fn Renderer_startCapturingPre2DFrames_WASM(cppPtr: basis.CppPtr, outputFolderPath: [*c]const basis.bindings.InteropString, debugDrawInfo: c_int, interval: u32) void;
//pub extern "env" fn Renderer_startCapturingFullEndUserFrames_WASM(cppPtr: basis.CppPtr, outputFolderPath: [*c]const basis.bindings.InteropString, debugDrawInfo: c_int, interval: u32) void;
//pub extern "env" fn Renderer_startCapturingFullFrames_WASM(cppPtr: basis.CppPtr, outputFolderPath: [*c]const basis.bindings.InteropString, debugDrawInfo: c_int, interval: u32) void;
//pub extern "env" fn Renderer_stopCapturingFrames_WASM(cppPtr: basis.CppPtr) void;

// ===============================

// RenderScene:

pub extern "env" fn RenderScene_getRootSceneNode_WASM(cppPtr: basis.CppPtr) basis.CppPtr;
pub extern "env" fn RenderScene_destroySceneNode_WASM(cppPtr: basis.CppPtr, sceneNodeCppPtr: basis.CppPtr) void;
pub extern "env" fn RenderScene_createCamera_WASM(cppPtr: basis.CppPtr) basis.CppPtr;
pub extern "env" fn RenderScene_destroyCamera_WASM(cppPtr: basis.CppPtr, cameraCppPtr: basis.CppPtr) void;
pub extern "env" fn RenderScene_createDynamicMeshInstance_WASM(cppPtr: basis.CppPtr, parameterBufferPtr: [*]const u8, parameterBufferLength: u32) basis.CppPtr;
pub extern "env" fn RenderScene_createStaticMeshInstance_WASM(cppPtr: basis.CppPtr, parameterBufferPtr: [*]const u8, parameterBufferLength: u32, addToBVH: bool) basis.CppPtr;
pub extern "env" fn RenderScene_destroyMeshInstance_WASM(cppPtr: basis.CppPtr, meshInstanceCppPtr: basis.CppPtr) void;
pub extern "env" fn RenderScene_castRay_WASM(cppPtr: basis.CppPtr, parameterBufferPtr: [*]u8, parameterBufferLength: u32) c_int;
pub extern "env" fn RenderScene_getTireTrackRenderer_WASM(cppPtr: basis.CppPtr) basis.CppPtr;

// ===============================

// TireTrackRenderer:

//pub extern "env" fn TireTrackRenderer_clear_WASM(cppPtr: basis.CppPtr) void;
//pub extern "env" fn TireTrackRenderer_registerTire_WASM(cppPtr: basis.CppPtr, width: f32, isRightSideTire: bool, tireType: u32) u32;
//pub extern "env" fn TireTrackRenderer_unregisterTire_WASM(cppPtr: basis.CppPtr, id: u32) void;
//pub extern "env" fn TireTrackRenderer_beginTireTrack_WASM(cppPtr: basis.CppPtr, id: u32) void;
//pub extern "env" fn TireTrackRenderer_endTireTrack_WASM(cppPtr: basis.CppPtr, id: u32) void;
//pub extern "env" fn TireTrackRenderer_updateTireTrack_WASM(cppPtr: basis.CppPtr, id: u32, contactPosition: [*c]const basis.bindings.InteropVec3, movementDirection: [*c]const basis.bindings.InteropVec3, longitudinalSlip: f32, lateralSlip: f32, groundNormal: [*c]const basis.bindings.InteropVec3) void;
//pub extern "env" fn TireTrackRenderer_beginStaticTireTrack_WASM(cppPtr: basis.CppPtr, width: f32, isRightSideTire: bool, tireType: u32) u32;
//pub extern "env" fn TireTrackRenderer_addPointToStaticTireTrack_WASM(cppPtr: basis.CppPtr, id: u32, contactPosition: [*c]const basis.bindings.InteropVec3, movementDirection: [*c]const basis.bindings.InteropVec3, longitudinalSlip: f32, lateralSlip: f32, groundNormal: [*c]const basis.bindings.InteropVec3, alpha: f32) void;
//pub extern "env" fn TireTrackRenderer_endStaticTireTrack_WASM(cppPtr: basis.CppPtr, id: u32) void;
//pub extern "env" fn TireTrackRenderer_removeStaticTireTrack_WASM(cppPtr: basis.CppPtr, id: u32) void;

// ===============================

// MeshGeometry:

//pub extern "env" fn MeshGeometry_newGeometry_WASM() u64;
//pub extern "env" fn MeshGeometry_deleteGeometry_WASM(cppPtr: basis.CppPtr) void;
//pub extern "env" fn MeshGeometry_clear_WASM(cppPtr: basis.CppPtr) void;
//pub extern "env" fn MeshGeometry_addLodLevel_WASM(cppPtr: basis.CppPtr) u64;
//pub extern "env" fn MeshGeometry_getLodLevel_WASM(cppPtr: basis.CppPtr, lodLevelIndex: u8) u64;
//pub extern "env" fn MeshGeometry_getLodLevelCount_WASM(cppPtr: basis.CppPtr) u8;

// ===============================

// MeshGeometryLodLevel:

//pub extern "env" fn MeshGeometryLodLevel_clear_WASM(cppPtr: basis.CppPtr) void;
//pub extern "env" fn MeshGeometryLodLevel_addSubMesh_WASM(cppPtr: basis.CppPtr, vertexFormatType: c_int) u64;
//pub extern "env" fn MeshGeometryLodLevel_getSubMesh_WASM(cppPtr: basis.CppPtr, subMeshIndex: u8) u64;
//pub extern "env" fn MeshGeometryLodLevel_getSubMeshCount_WASM(cppPtr: basis.CppPtr) u8;

// ===============================

// MeshGeometrySubMesh:

//pub extern "env" fn MeshGeometrySubMesh_clear_WASM(cppPtr: basis.CppPtr) void;
//pub extern "env" fn MeshGeometrySubMesh_addIndex_WASM(cppPtr: basis.CppPtr, index: u16) void;
//pub extern "env" fn MeshGeometrySubMesh_addFace_WASM(cppPtr: basis.CppPtr, index0: u16, index1: u16, index2: u16) void;
//pub extern "env" fn MeshGeometrySubMesh_addVertex_WASM(cppPtr: basis.CppPtr, vertex: [*c]const u8, vertexSize: u32) void;
//pub extern "env" fn MeshGeometrySubMesh_getVertexFormatType_WASM(cppPtr: basis.CppPtr) c_int;
//pub extern "env" fn MeshGeometrySubMesh_getVertexCount_WASM(cppPtr: basis.CppPtr) u32;
//pub extern "env" fn MeshGeometrySubMesh_getIndexCount_WASM(cppPtr: basis.CppPtr) u32;

// ===============================

// Mesh:

pub extern "env" fn Mesh_getLodLevelCount_WASM(cppPtr: basis.CppPtr) u8;
pub extern "env" fn Mesh_getLodLevel_WASM(cppPtr: basis.CppPtr, lodLevelIndex: u8) basis.CppPtr;
pub extern "env" fn Mesh_addRef_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn Mesh_release_WASM(cppPtr: basis.CppPtr) void;

// ===============================

// MeshLodLevel:

//pub extern "env" fn MeshLodLevel_getSubMeshCount_WASM(cppPtr: basis.CppPtr) u8;
//pub extern "env" fn MeshLodLevel_setSubMeshCount_WASM(cppPtr: basis.CppPtr, count: u8) void;
//pub extern "env" fn MeshLodLevel_getSubMesh_WASM(cppPtr: basis.CppPtr, subMeshIndex: u8) u64;
//pub extern "env" fn MeshLodLevel_getBounds_WASM(cppPtr: basis.CppPtr, min: [*c]basis.bindings.InteropVec3, max: [*c]basis.bindings.InteropVec3) void;
//pub extern "env" fn MeshLodLevel_setBounds_WASM(cppPtr: basis.CppPtr, min: [*c]const basis.bindings.InteropVec3, max: [*c]const basis.bindings.InteropVec3) void;

// ===============================

// MeshSubMesh:

//pub extern "env" fn MeshSubMesh_getVertexFormatType_WASM(cppPtr: basis.CppPtr) c_int;
//pub extern "env" fn MeshSubMesh_getVertexCount_WASM(cppPtr: basis.CppPtr) u32;
//pub extern "env" fn MeshSubMesh_setVertexCount_WASM(cppPtr: basis.CppPtr, count: u32) void;
//pub extern "env" fn MeshSubMesh_getIndexCount_WASM(cppPtr: basis.CppPtr) u32;
//pub extern "env" fn MeshSubMesh_setIndexCount_WASM(cppPtr: basis.CppPtr, count: u32) void;
//pub extern "env" fn MeshSubMesh_getVertices_WASM(cppPtr: basis.CppPtr, bufferSize: [*c]u32) [*c]u8;
//pub extern "env" fn MeshSubMesh_getIndices_WASM(cppPtr: basis.CppPtr, bufferSize: [*c]u32) [*c]u16;

// ===============================

// Material:

pub extern "env" fn Material_addRef_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn Material_release_WASM(cppPtr: basis.CppPtr) void;

// ===============================

// MeshInstance:

pub extern "env" fn MeshInstance_setVisible_WASM(cppPtr: basis.CppPtr, visible: bool) void;
pub extern "env" fn MeshInstance_isVisible_WASM(cppPtr: basis.CppPtr) bool;
pub extern "env" fn MeshInstance_getMaterial_WASM(cppPtr: basis.CppPtr, subMeshIndex: u32) basis.CppPtr;
pub extern "env" fn MeshInstance_setMaterial_WASM(cppPtr: basis.CppPtr, materialCppPtr: basis.CppPtr, subMeshIndex: u32) void;
pub extern "env" fn MeshInstance_getFlags_WASM(cppPtr: basis.CppPtr) c_int;
pub extern "env" fn MeshInstance_isFlagSet_WASM(cppPtr: basis.CppPtr, flag: c_int) c_int;
pub extern "env" fn MeshInstance_setFlagValue_WASM(cppPtr: basis.CppPtr, flag: c_int, value: c_int) void;
pub extern "env" fn MeshInstance_updateLightProbeData_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn MeshInstance_getParentSceneNode_WASM(cppPtr: basis.CppPtr) basis.CppPtr;

// ===============================

// Camera:

pub extern "env" fn Camera_setPerspective_WASM(cppPtr: basis.CppPtr, fovY: f32, aspectRatio: f32, nearClip: f32, farClip: f32) void;
pub extern "env" fn Camera_setOrthographic_WASM(cppPtr: basis.CppPtr, width: f32, height: f32, nearClip: f32, farClip: f32) void;
pub extern "env" fn Camera_getWorldPosition_WASM(cppPtr: basis.CppPtr, valueBufferPtr: [*]u8, valueBufferLength: u32) void;
pub extern "env" fn Camera_getForwardDirection_WASM(cppPtr: basis.CppPtr, valueBufferPtr: [*]u8, valueBufferLength: u32) void;
pub extern "env" fn Camera_getFovY_WASM(cppPtr: basis.CppPtr) f32;
pub extern "env" fn Camera_getFovX_WASM(cppPtr: basis.CppPtr) f32;
pub extern "env" fn Camera_getNearClip_WASM(cppPtr: basis.CppPtr) f32;
pub extern "env" fn Camera_getFarClip_WASM(cppPtr: basis.CppPtr) f32;
pub extern "env" fn Camera_getPickRay_WASM(cppPtr: basis.CppPtr, screenX: c_int, screenY: c_int, space: c_int, valueBufferPtr: [*]u8, valueBufferLength: u32) void;
pub extern "env" fn Camera_worldToScreen_WASM(cppPtr: basis.CppPtr, worldPosX: f32, worldPosY: f32, worldPosZ: f32, valueBufferPtr: [*]u8, valueBufferLength: u32) bool;
pub extern "env" fn Camera_worldToScreenUnbounded_WASM(cppPtr: basis.CppPtr, worldPosX: f32, worldPosY: f32, worldPosZ: f32, valueBufferPtr: [*]u8, valueBufferLength: u32) void;
pub extern "env" fn Camera_getViewMatrix_WASM(cppPtr: basis.CppPtr, valueBufferPtr: [*]u8, valueBufferLength: u32) void;
pub extern "env" fn Camera_getProjectionMatrix_WASM(cppPtr: basis.CppPtr, valueBufferPtr: [*]u8, valueBufferLength: u32) void;
pub extern "env" fn Camera_getParentSceneNode_WASM(cppPtr: basis.CppPtr) basis.CppPtr;

// ===============================

// GameSession:

pub extern "env" fn GameSession_getSessionType_WASM(cppPtr: basis.CppPtr) i32;
pub extern "env" fn GameSession_getClientCount_WASM(cppPtr: basis.CppPtr) u32;
pub extern "env" fn GameSession_getClient_WASM(cppPtr: basis.CppPtr, clientIndex: u32, valueBufferPtr: [*]u8, valueBufferLength: u32) void;
pub extern "env" fn GameSession_isPaused_WASM(cppPtr: basis.CppPtr) i32;
pub extern "env" fn GameSession_requestPause_WASM(cppPtr: basis.CppPtr, paused: i32) void;
pub extern "env" fn GameSession_getLevelData_WASM(cppPtr: basis.CppPtr) u64;
pub extern "env" fn GameSession_isContinuousSession_WASM(cppPtr: basis.CppPtr) i32;

// ===============================

// GameState:

pub extern "env" fn GameState_getGameObject_WASM(cppPtr: basis.CppPtr, objectNameHash: u32) basis.CppPtr;
pub extern "env" fn GameState_getGameObjectFromRenderable_WASM(cppPtr: basis.CppPtr, renderableCppPtr: basis.CppPtr) basis.CppPtr;
pub extern "env" fn GameState_createGameObject_WASM(cppPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) void;
pub extern "env" fn GameState_createGameObjectWithStartTransform_WASM(cppPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) void;
pub extern "env" fn GameState_createGameObjectWithSpawnPointIndex_WASM(cppPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) void;
pub extern "env" fn GameState_createGameObjectWithSpawnPointName_WASM(cppPtr: basis.CppPtr, valueBufferPtr: [*]const u8, valueBufferLength: u32) void;
pub extern "env" fn GameState_createGameObjectWithParameters_WASM(cppPtr: basis.CppPtr, paramsCppPtr: basis.CppPtr, propagate: bool) void;
pub extern "env" fn GameState_destroyGameObject_WASM(cppPtr: basis.CppPtr, objectNameHash: u32, propagate: bool, destroyImmediately: bool) void;
pub extern "env" fn GameState_hasGameObject_WASM(cppPtr: basis.CppPtr, objectNameHash: u32) bool;
pub extern "env" fn GameState_setAvatarObject_WASM(cppPtr: basis.CppPtr, objectNameHash: u32, hostID: i32) void;
pub extern "env" fn GameState_clearAvatarObject_WASM(cppPtr: basis.CppPtr, hostID: i32) void;
pub extern "env" fn GameState_getAvatarObjectByHostID_WASM(cppPtr: basis.CppPtr, hostID: c_int) u32;
pub extern "env" fn GameState_getHostIDByAvatarObject_WASM(cppPtr: basis.CppPtr, avatarNameHash: u32) c_int;
pub extern "env" fn GameState_broadcastScriptMessage_WASM(cppPtr: basis.CppPtr, senderCppPtr: basis.CppPtr, msgBufferPtr: [*]u8, msgBufferLength: u32) void;
pub extern "env" fn GameState_generateGameObjectName_WASM(cppPtr: basis.CppPtr, prefixBufferPtr: [*]const u8, prefixBufferLength: u32, randomPartLength: c_int, resultBufferPtr: [*]const u8, resultBufferLength: u32) u32;

// ===============================

// LevelData:

//pub extern "env" fn LevelData_getDataBlockManager_WASM(cppPtr: basis.CppPtr) u64;

// ===============================

// LevelDataBlockManager:

//pub extern "env" fn LevelDataBlockManager_getDataBlock_WASM(cppPtr: basis.CppPtr, namePtr: [*c]const u8, nameLength: u32) u64;
//pub extern "env" fn LevelDataBlockManager_addDataBlock_WASM(cppPtr: basis.CppPtr, namePtr: [*c]const u8, nameLength: u32, bufferSize: u32) u64;
//pub extern "env" fn LevelDataBlockManager_addDataBlockIfDoesNotExist_WASM(cppPtr: basis.CppPtr, namePtr: [*c]const u8, nameLength: u32, bufferSize: u32) u64;
//pub extern "env" fn LevelDataBlockManager_getMutableDataBlock_WASM(cppPtr: basis.CppPtr, namePtr: [*c]const u8, nameLength: u32) u64;
//pub extern "env" fn LevelDataBlockManager_hasDataBlock_WASM(cppPtr: basis.CppPtr, namePtr: [*c]const u8, nameLength: u32) c_int;

// ===============================

// LevelDataBlock:

//pub extern "env" fn LevelDataBlock_getReadBuffer_WASM(cppPtr: basis.CppPtr, bufferSize: [*c]u32) [*c]const u8;
//pub extern "env" fn LevelDataBlock_getChunkStartReadBufferPosition_WASM(cppPtr: basis.CppPtr, chunkIndex: u32) u32;
//pub extern "env" fn LevelDataBlock_setReadBufferPosition_WASM(cppPtr: basis.CppPtr, position: u32) void;
//pub extern "env" fn LevelDataBlock_getWriteBuffer_WASM(cppPtr: basis.CppPtr, bufferSize: [*c]u32) [*c]u8;
//pub extern "env" fn LevelDataBlock_beginWritingChunk_WASM(cppPtr: basis.CppPtr) u32;
//pub extern "env" fn LevelDataBlock_finishWritingChunk_WASM(cppPtr: basis.CppPtr, position: u32) void;
//pub extern "env" fn LevelDataBlock_getChunkCount_WASM(cppPtr: basis.CppPtr) u32;

// ===============================

// NavMeshRuntime:

//pub extern "env" fn NavMeshRuntime_hasNavMesh_WASM(navMeshID: u32) bool;
//pub extern "env" fn NavMeshRuntime_findPath_WASM(navMeshID: u32, startPoint: [*c]const basis.bindings.InteropVec3, endPoint: [*c]const basis.bindings.InteropVec3, filter: [*c]const basis.bindings.InteropNavMeshQueryFilter, pathArray: [*c]basis.bindings.InteropVec3, pathArraySize: u32, pathLength: [*c]u32, searchBoxSize: f32) i32;
//pub extern "env" fn NavMeshRuntime_findClosestPointOnNavMesh_WASM(navMeshID: u32, center: [*c]const basis.bindings.InteropVec3, result: [*c]basis.bindings.InteropVec3, searchBoxSize: f32) i32;
//pub extern "env" fn NavMeshRuntime_findRandomPointAroundCircle_WASM(navMeshID: u32, center: [*c]const basis.bindings.InteropVec3, maxRadius: f32, result: [*c]basis.bindings.InteropVec3, searchBoxSize: f32) i32;
//pub extern "env" fn NavMeshRuntime_overlapsNavMesh_WASM(navMeshID: u32, center: [*c]const basis.bindings.InteropVec3, filter: [*c]const basis.bindings.InteropNavMeshQueryFilter, searchBoxSize: [*c]const basis.bindings.InteropVec3) c_int;
//pub extern "env" fn NavMeshRuntime_addObstacle_WASM(navMeshID: u32, radius: f32, obstacleType: u32, initialPosition: [*c]const basis.bindings.InteropVec3, initialLinearVelocity: [*c]const basis.bindings.InteropVec3) u32;
//pub extern "env" fn NavMeshRuntime_updateObstacle_WASM(navMeshID: u32, obstacleID: u32, position: [*c]const basis.bindings.InteropVec3, linearVelocity: [*c]const basis.bindings.InteropVec3) void;
//pub extern "env" fn NavMeshRuntime_removeObstacle_WASM(navMeshID: u32, obstacleID: u32) void;

// ===============================

// StreamingUtils:

pub extern "env" fn StreamingUtils_setStreamingPosition_WASM(posX: f32, posY: f32, posZ: f32) void;
pub extern "env" fn StreamingUtils_getStreamingPosition_WASM(valueBufferPtr: [*]u8, valueBufferLength: u32) void;
pub extern "env" fn StreamingUtils_setStreamingPositionUpdateMode_WASM(mode: c_int) void;
pub extern "env" fn StreamingUtils_getStreamingPositionUpdateMode_WASM() c_int;

// ===============================

// ScreenFade:

pub extern "env" fn ScreenFade_isActive_WASM() c_int;
pub extern "env" fn ScreenFade_fade_WASM(fromR: u8, fromG: u8, fromB: u8, fromA: u8, toR: u8, toG: u8, toB: u8, toA: u8, duration: f32) void;
pub extern "env" fn ScreenFade_fadeWithCallback_WASM(fromR: u8, fromG: u8, fromB: u8, fromA: u8, toR: u8, toG: u8, toB: u8, toA: u8, duration: f32, callback: basis.WasmFuncPtr) void;
pub extern "env" fn ScreenFade_setColor_WASM(r: u8, g: u8, b: u8, a: u8) void;
pub extern "env" fn ScreenFade_clear_WASM() void;

// ===============================

// StateMachine:

pub extern "env" fn StateMachine_registerFlowState_WASM(zigLibCppPtr_0: basis.IntPtr64, zigLibCppPtr_1: u32, cppPtr: basis.CppPtr, namePtr: [*]const u8, nameLength: u32, flowStateInterfacePtr: basis.IntPtr64, flags: i32, resultPtr: [*]u8) void;
pub extern "env" fn StateMachine_setCallbacksForGroup_WASM(cppPtr: basis.CppPtr, groupNamePtr: [*]const u8, groupNameLength: u32, enterCallback: basis.WasmFuncPtr, exitCallback: basis.WasmFuncPtr) void;
pub extern "env" fn StateMachine_clearCallbacksForGroup_WASM(cppPtr: basis.CppPtr, groupNamePtr: [*]const u8, groupNameLength: u32) void;

// ===============================

// FlowState:

pub extern "env" fn FlowState_startTransition_WASM(thisPtr_0: basis.IntPtr64, thisPtr_1: u32, name: [*]const u8, nameLength: u32) void;
pub extern "env" fn FlowState_subscribeToMessageCategory_WASM(thisPtr_0: basis.IntPtr64, thisPtr_1: u32, cat: i32) void;
pub extern "env" fn FlowState_allocMsgParams_WASM(thisPtr_0: basis.IntPtr64, thisPtr_1: u32) basis.CppPtr;
pub extern "env" fn FlowState_sendMessage_WASM(thisPtr_0: basis.IntPtr64, thisPtr_1: u32, message: i32, parameters: basis.CppPtr) void;
pub extern "env" fn FlowState_getClient_WASM(thisPtr_0: basis.IntPtr64, thisPtr_1: u32) basis.CppPtr;
pub extern "env" fn FlowState_getServer_WASM(thisPtr_0: basis.IntPtr64, thisPtr_1: u32) basis.CppPtr;

// ===============================

// DebugOverlay:

pub extern "env" fn DebugOverlay_isVisible_WASM() c_int;
//pub extern "env" fn DebugOverlay_setImGuiMenuBarCallbackEnabled_WASM(enabled: c_int) void;
//pub extern "env" fn DebugOverlay_setImGuiCallbackEnabled_WASM(enabled: c_int) void;
pub extern "env" fn DebugOverlay_debugTrace_WASM(data: [*c]const u8, dataLength: u32) void;
pub extern "env" fn DebugOverlay_debugWarning_WASM(data: [*c]const u8, dataLength: u32) void;
pub extern "env" fn DebugOverlay_areDebugObjectWindowKeysPressed_WASM() c_int;
//pub extern "env" fn DebugOverlay_showDebugActionAtPosition_WASM(position: [*c]const basis.bindings.InteropVec3, surfaceNormal: [*c]const basis.bindings.InteropVec3) void;
pub extern "env" fn DebugOverlay_addDebugSpawnableObjectType_WASM(objectTypePtr: [*]const u8, objectTypeLength: u32, distanceFromSurface: f32) void;

// ===============================

// Editor:

pub extern "env" fn Editor_printInfo_WASM(data: [*c]const u8, dataLength: u32) void;
pub extern "env" fn Editor_printWarning_WASM(data: [*c]const u8, dataLength: u32) void;
pub extern "env" fn Editor_printError_WASM(data: [*c]const u8, dataLength: u32) void;
pub extern "env" fn Editor_getEditorCamera_WASM() basis.CppPtr;

// ===============================

// ImGui:

pub extern "env" fn ImGui_begin_WASM(namePtr: [*c]const u8, nameLength: u32, flags: i32) c_int;
//pub extern "env" fn ImGui_beginEx_WASM(name: [*c]const basis.bindings.InteropString, p_open: [*c]bool, flags: i32) c_int;
pub extern "env" fn ImGui_end_WASM() void;
pub extern "env" fn ImGui_beginMenu_WASM(namePtr: [*c]const u8, nameLength: u32, enabled: c_int) c_int;
pub extern "env" fn ImGui_endMenu_WASM() void;
pub extern "env" fn ImGui_menuItem_WASM(label: [*c]const u8, labelLength: u32, selected: c_int, enabled: c_int) c_int;
pub extern "env" fn ImGui_openPopup_WASM(idPtr: [*c]const u8, idLength: u32, popupFlags: i32) void;
pub extern "env" fn ImGui_beginPopup_WASM(idPtr: [*c]const u8, idLength: u32, flags: i32) c_int;
pub extern "env" fn ImGui_endPopup_WASM() void;
pub extern "env" fn ImGui_pushStyleColor_WASM(idx: i32, r: f32, g: f32, b: f32) void;
pub extern "env" fn ImGui_popStyleColor_WASM(count: c_int) void;
pub extern "env" fn ImGui_separator_WASM() void;
pub extern "env" fn ImGui_text_WASM(textPtr: [*c]const u8, textLength: u32) void;
pub extern "env" fn ImGui_textColored_WASM(r: f32, g: f32, b: f32, textPtr: [*c]const u8, textLength: u32) void;
pub extern "env" fn ImGui_sameline_WASM(offsetFromStartX: f32, spacingW: f32) void;
pub extern "env" fn ImGui_collapsingHeader_WASM(labelPtr: [*c]const u8, labelLength: u32, flags: i32) c_int;
pub extern "env" fn ImGui_button_WASM(labelPtr: [*c]const u8, labelLength: u32, sizeX: f32, sizeY: f32) c_int;
pub extern "env" fn ImGui_isItemHovered_WASM(flags: i32) c_int;
pub extern "env" fn ImGui_setTooltip_WASM(textPtr: [*c]const u8, textLength: u32) void;
pub extern "env" fn ImGui_endTooltip_WASM() void;
pub extern "env" fn ImGui_setNextWindowPos_WASM(posX: f32, posY: f32, cond: i32, pivotX: f32, pivotY: f32) void;
pub extern "env" fn ImGui_setNextWindowSize_WASM(sizeX: f32, sizeY: f32, cond: i32) void;
pub extern "env" fn ImGui_setNextWindowBgAlpha_WASM(alpha: f32) void;
pub extern "env" fn ImGui_beginListBox_WASM(labelPtr: [*c]const u8, labelLength: u32, sizeX: f32, sizeY: f32) c_int;
pub extern "env" fn ImGui_endListBox_WASM() void;
pub extern "env" fn ImGui_getScrollX_WASM() f32;
pub extern "env" fn ImGui_getScrollY_WASM() f32;
pub extern "env" fn ImGui_setScrollX_WASM(scrollX: f32) void;
pub extern "env" fn ImGui_setScrollY_WASM(scrollY: f32) void;
pub extern "env" fn ImGui_getScrollMaxX_WASM() f32;
pub extern "env" fn ImGui_getScrollMaxY_WASM() f32;
pub extern "env" fn ImGui_setScrollHereX_WASM(centerXRatio: f32) void;
pub extern "env" fn ImGui_setScrollHereY_WASM(centerYRatio: f32) void;
pub extern "env" fn ImGui_setScrollFromPosX_WASM(localX: f32, centerXRatio: f32) void;
pub extern "env" fn ImGui_setScrollFromPosY_WASM(localY: f32, centerYRatio: f32) void;

// ===============================

// GameObjectCreationParameters:

pub extern "env" fn GameObjectCreationParameters_newParams_WASM() basis.CppPtr;
pub extern "env" fn GameObjectCreationParameters_newParamsWithNameAndType_WASM(namePtr: [*c]const u8, nameLength: u32, typePtr: [*c]const u8, typeLength: u32) u64;
pub extern "env" fn GameObjectCreationParameters_deleteParams_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn GameObjectCreationParameters_setStartTransform_WASM(cppPtr: basis.CppPtr, valueBufferPtr: [*c]const u8, valueBufferLength: u32) void;
pub extern "env" fn GameObjectCreationParameters_setPropertyBundlePath_WASM(cppPtr: basis.CppPtr, pathPtr: [*c]const u8, pathLength: u32) void;

// ===============================

// OSUtility:

//pub extern "env" fn OSUtility_writeStringToClipboard_WASM(str: [*c]const basis.bindings.InteropString) c_int;

// ===============================

// ExposedPropertyLayoutReader:

//pub extern "env" fn ExposedPropertyLayoutReader_init_WASM(cppPtr: basis.CppPtr, version: i32) void;
//pub extern "env" fn ExposedPropertyLayoutReader_processProperty_WASM(cppPtr: basis.CppPtr, namePtr: [*c]const u8, nameLength: u32, propertyType: i32, serializedDefaultValue: [*c]const u8, serializedDefaultValueLength: u32, versionAdded: i32, options: [*c]const basis.bindings.InteropString) void;
//pub extern "env" fn ExposedPropertyLayoutReader_processString_WASM(cppPtr: basis.CppPtr, namePtr: [*c]const u8, nameLength: u32, defaultValue: [*c]const basis.bindings.InteropString, versionAdded: i32, options: [*c]const basis.bindings.InteropString) void;
//pub extern "env" fn ExposedPropertyLayoutReader_processResourceRef_WASM(cppPtr: basis.CppPtr, namePtr: [*c]const u8, nameLength: u32, resourceTypeID: i32, defaultValue: [*c]const basis.bindings.InteropString, versionAdded: i32, options: [*c]const basis.bindings.InteropString) void;
//pub extern "env" fn ExposedPropertyLayoutReader_processButton_WASM(cppPtr: basis.CppPtr, actionID: [*c]const basis.bindings.InteropString, actionName: [*c]const basis.bindings.InteropString, buttonText: [*c]const basis.bindings.InteropString, options: [*c]const basis.bindings.InteropString) void;
//pub extern "env" fn ExposedPropertyLayoutReader_processCategory_WASM(cppPtr: basis.CppPtr, categoryName: [*c]const basis.bindings.InteropString, displayName: [*c]const basis.bindings.InteropString, options: [*c]const basis.bindings.InteropString) void;
//pub extern "env" fn ExposedPropertyLayoutReader_processEnum_WASM(cppPtr: basis.CppPtr, namePtr: [*c]const u8, nameLength: u32, defaultValue: u32, enumValueNames: [*c]basis.bindings.InteropString, enumValueIntegrals: [*c]u32, valueCount: u32, versionAdded: c_int, options: [*c]const basis.bindings.InteropString) void;
//pub extern "env" fn ExposedPropertyLayoutReader_allPropertiesProcessed_WASM(cppPtr: basis.CppPtr) void;

// ===============================

// ZigAngelScriptTypeRegistration:

pub extern "env" fn ZigAngelScriptTypeRegistration_registerEnumType_WASM(cppPtr: basis.CppPtr, typeNamePtr: [*]const u8, typeNameLength: u32) void;
pub extern "env" fn ZigAngelScriptTypeRegistration_registerEnumValue_WASM(cppPtr: basis.CppPtr, typeNamePtr: [*]const u8, typeNameLength: u32, valueNamePtr: [*]const u8, valueNameLength: u32, value: i32) void;

// ===============================

// ZigAngelScriptComponentRegistration:

pub extern "env" fn ZigAngelScriptComponentRegistration_registerComponentType_WASM(cppPtr: basis.CppPtr, typeNamePtr: [*]const u8, typeNameLength: u32) void;
//pub extern "env" fn ZigAngelScriptComponentRegistration_registerComponentMethod_WASM(cppPtr: basis.CppPtr, declaration: [*c]const basis.bindings.InteropString, functionPtr: u64) void;
//pub extern "env" fn ZigAngelScriptComponentRegistration_registerComponentEventAutoComplete_WASM(cppPtr: basis.CppPtr, declaration: [*c]const basis.bindings.InteropString) void;

// ===============================

// AngelScriptUtils:

//pub extern "env" fn AngelScriptUtils_getStringRefConstIn_WASM(p: u64, value: [*c]basis.bindings.InteropString) void;
//pub extern "env" fn AngelScriptUtils_setStringRefOut_WASM(p: u64, value: [*c]const basis.bindings.InteropString) void;
//pub extern "env" fn AngelScriptUtils_getGameObjectRefConstIn_WASM(p: u64, value: [*c]basis.bindings.InteropString) void;
//pub extern "env" fn AngelScriptUtils_getHashFromGameObjectRefConstIn_WASM(p: u64) u32;
//pub extern "env" fn AngelScriptUtils_setGameObjectRefOut_WASM(p: u64, value: [*c]const basis.bindings.InteropString) void;
//pub extern "env" fn AngelScriptUtils_getColorRefConstIn_WASM(p: u64, value: [*c]basis.bindings.InteropColor) void;
//pub extern "env" fn AngelScriptUtils_setColorRefOut_WASM(p: u64, value: [*c]const basis.bindings.InteropColor) void;
//pub extern "env" fn AngelScriptUtils_addRefToASFuncPtr_WASM(funcPtr: u64) void;
//pub extern "env" fn AngelScriptUtils_releaseASFuncPtr_WASM(funcPtr: u64) void;

// ===============================
