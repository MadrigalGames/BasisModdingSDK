// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const basis = @import("basis");

// Database:

pub extern "env" fn Database_newDatabase_WASM() basis.CppPtr;
pub extern "env" fn Database_deleteDatabase_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn Database_loadOnClient_WASM(cppPtr: basis.CppPtr, clientCppPtr: basis.CppPtr, fileResourcePathPtr: [*]const u8, fileResourcePathLength: u32) void;
pub extern "env" fn Database_loadOnServer_WASM(cppPtr: basis.CppPtr, serverCppPtr: basis.CppPtr, fileResourcePathPtr: [*]const u8, fileResourcePathLength: u32) void;
pub extern "env" fn Database_unload_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn Database_generateScriptApi_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn Database_tick_WASM(cppPtr: basis.CppPtr, tickDeltaTime: f32, flags: u32) void;
pub extern "env" fn Database_serialize_WASM(cppPtr: basis.CppPtr, buffer: [*]u8, bufferLength: u32) u32;
pub extern "env" fn Database_deserialize_WASM(cppPtr: basis.CppPtr, buffer: [*]const u8, bufferLength: u32) u32;
pub extern "env" fn Database_getMissionByPath_WASM(cppPtr: basis.CppPtr, pathPtr: [*]const u8, pathLength: u32) basis.CppPtr;
pub extern "env" fn Database_getMissionByPathHash_WASM(cppPtr: basis.CppPtr, pathHash: u32) basis.CppPtr;
pub extern "env" fn Database_getGlobalVariableSetByPath_WASM(cppPtr: basis.CppPtr, pathPtr: [*]const u8, pathLength: u32) basis.CppPtr;
pub extern "env" fn Database_getGlobalVariableSetByPathHash_WASM(cppPtr: basis.CppPtr, pathHash: u32) basis.CppPtr;
pub extern "env" fn Database_getCharacterDataByPath_WASM(cppPtr: basis.CppPtr, pathPtr: [*]const u8, pathLength: u32) basis.CppPtr;
pub extern "env" fn Database_getCharacterDataByPathHash_WASM(cppPtr: basis.CppPtr, pathHash: u32) basis.CppPtr;
pub extern "env" fn Database_getConversationByPath_WASM(cppPtr: basis.CppPtr, pathPtr: [*]const u8, pathLength: u32) basis.CppPtr;
pub extern "env" fn Database_getConversationByPathHash_WASM(cppPtr: basis.CppPtr, pathHash: u32) basis.CppPtr;
