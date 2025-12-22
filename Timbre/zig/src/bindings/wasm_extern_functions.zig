// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const basis = @import("basis");

// TimbreSoundManager:

pub extern "env" fn TimbreSoundManager_getMasterGroupBus_WASM() basis.CppPtr;
pub extern "env" fn TimbreSoundManager_getGroupBus_WASM(pathPtr: [*]const u8, pathLength: u32) basis.CppPtr;
pub extern "env" fn TimbreSoundManager_getEventDesc_WASM(pathPtr: [*]const u8, pathLength: u32) basis.CppPtr;
pub extern "env" fn TimbreSoundManager_playAndForget2D_WASM(eventDescCppPtr: basis.CppPtr, autoPause: bool) void;
pub extern "env" fn TimbreSoundManager_playAndForget3D_WASM(eventDescCppPtr: basis.CppPtr, positionX: f32, positionY: f32, positionZ: f32, autoPause: bool) void;
pub extern "env" fn TimbreSoundManager_playByPathAndForget2D_WASM(eventPathPtr: [*]const u8, eventPathLength: u32, autoPause: bool) void;
pub extern "env" fn TimbreSoundManager_playByPathAndForget3D_WASM(eventPathPtr: [*]const u8, eventPathLength: u32, positionX: f32, positionY: f32, positionZ: f32, autoPause: bool) void;

// GroupBus:

pub extern "env" fn GroupBus_getVolume_WASM(cppPtr: basis.CppPtr) f32;
pub extern "env" fn GroupBus_setVolume_WASM(cppPtr: basis.CppPtr, volume: f32) void;

// EventDescription:

pub extern "env" fn EventDescription_createInstance_WASM(cppPtr: basis.CppPtr, autoPause: bool) basis.CppPtr;
pub extern "env" fn EventDescription_getParameterIndex_WASM(cppPtr: basis.CppPtr, namePtr: [*]const u8, nameLength: u32) u32;
pub extern "env" fn EventDescription_getLength_WASM(cppPtr: basis.CppPtr) f32;

// EventInstance:

pub extern "env" fn EventInstance_release_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn EventInstance_releaseWhenFinished_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn EventInstance_releaseAfterFadeOut_WASM(cppPtr: basis.CppPtr, fadeOutDuration: f32) void;
pub extern "env" fn EventInstance_getState_WASM(cppPtr: basis.CppPtr) u32;
pub extern "env" fn EventInstance_start_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn EventInstance_pause_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn EventInstance_stop_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn EventInstance_setParameterByName_WASM(cppPtr: basis.CppPtr, namePtr: [*]const u8, nameLength: u32, value: f32) void;
pub extern "env" fn EventInstance_setParameterByIndex_WASM(cppPtr: basis.CppPtr, index: u32, value: f32) void;
pub extern "env" fn EventInstance_set3DParameters_WASM(cppPtr: basis.CppPtr, posX: f32, posY: f32, posZ: f32, linVelX: f32, linVelY: f32, linVelZ: f32) void;
pub extern "env" fn EventInstance_sendSignal_WASM(cppPtr: basis.CppPtr, signalPtr: [*]const u8, signalLength: u32) void;
pub extern "env" fn EventInstance_fadeIn_WASM(cppPtr: basis.CppPtr, fadeInDuration: f32) void;
