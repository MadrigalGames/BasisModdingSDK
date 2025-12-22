// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const builtin = @import("builtin");
const basis = @import("basis");
const nemo = @import("../nemo.zig");

const isWasm = basis.build_options.buildAsWASM;

const access = if (isWasm)
    @import("wasm_extern_functions.zig")
else
    .{}; // TODO: Replace this with some module that contains the DLL interface.

// class Database

pub fn Database_newDatabase() basis.CppPtr {
    if (isWasm) {
        return access.Database_newDatabase_WASM();
    } else {
        return nemo.bindings.fp._Database_newDatabase();
    }
}

pub fn Database_deleteDatabase(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.Database_deleteDatabase_WASM(cppPtr);
    } else {
        nemo.bindings.fp._Database_deleteDatabase(cppPtr);
    }
}

pub fn Database_loadOnClient(cppPtr: basis.CppPtr, clientCppPtr: basis.CppPtr, fileResourcePath: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        access.Database_loadOnClient_WASM(cppPtr, clientCppPtr, fileResourcePath.*.ptr, fileResourcePath.*.len);
    } else {
        nemo.bindings.fp._Database_loadOnClient(cppPtr, clientCppPtr, fileResourcePath);
    }
}

pub fn Database_loadOnServer(cppPtr: basis.CppPtr, serverCppPtr: basis.CppPtr, fileResourcePath: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        access.Database_loadOnServer_WASM(cppPtr, serverCppPtr, fileResourcePath.*.ptr, fileResourcePath.*.len);
    } else {
        nemo.bindings.fp._Database_loadOnServer(cppPtr, serverCppPtr, fileResourcePath);
    }
}

pub fn Database_unload(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.Database_unload_WASM(cppPtr);
    } else {
        nemo.bindings.fp._Database_unload(cppPtr);
    }
}

pub fn Database_tick(cppPtr: basis.CppPtr, tickDeltaTime: f32) void {
    if (isWasm) {
        access.Database_tick_WASM(cppPtr, tickDeltaTime);
    } else {
        nemo.bindings.fp._Database_tick(cppPtr, tickDeltaTime);
    }
}

pub fn Database_serialize(cppPtr: basis.CppPtr, buffer: [*c]u8, bufferLength: u32) u32 {
    if (isWasm) {
        return access.Database_serialize_WASM(cppPtr, buffer, bufferLength);
    } else {
        return nemo.bindings.fp._Database_serialize(cppPtr, buffer, bufferLength);
    }
}

pub fn Database_deserialize(cppPtr: basis.CppPtr, buffer: [*c]const u8, bufferLength: u32) u32 {
    if (isWasm) {
        return access.Database_deserialize_WASM(cppPtr, buffer, bufferLength);
    } else {
        return nemo.bindings.fp._Database_deserialize(cppPtr, buffer, bufferLength);
    }
}

pub fn Database_getMissionByPath(cppPtr: basis.CppPtr, path: [*c]const basis.bindings.InteropString) basis.CppPtr {
    if (isWasm) {
        return access.Database_getMissionByPath_WASM(cppPtr, path.*.ptr, path.*.len);
    } else {
        return nemo.bindings.fp._Database_getMissionByPath(cppPtr, path);
    }
}

pub fn Database_getMissionByPathHash(cppPtr: basis.CppPtr, pathHash: u32) basis.CppPtr {
    if (isWasm) {
        return access.Database_getMissionByPathHash_WASM(cppPtr, pathHash);
    } else {
        return nemo.bindings.fp._Database_getMissionByPathHash(cppPtr, pathHash);
    }
}

pub fn Database_getGlobalVariableSetByPath(cppPtr: basis.CppPtr, path: [*c]const basis.bindings.InteropString) basis.CppPtr {
    if (isWasm) {
        return access.Database_getGlobalVariableSetByPath_WASM(cppPtr, path.*.ptr, path.*.len);
    } else {
        return nemo.bindings.fp._Database_getGlobalVariableSetByPath(cppPtr, path);
    }
}

pub fn Database_getGlobalVariableSetByPathHash(cppPtr: basis.CppPtr, pathHash: u32) basis.CppPtr {
    if (isWasm) {
        return access.Database_getGlobalVariableSetByPathHash_WASM(cppPtr, pathHash);
    } else {
        return nemo.bindings.fp._Database_getGlobalVariableSetByPathHash(cppPtr, pathHash);
    }
}

pub fn Database_getCharacterDataByPath(cppPtr: basis.CppPtr, path: [*c]const basis.bindings.InteropString) basis.CppPtr {
    if (isWasm) {
        return access.Database_getCharacterDataByPath_WASM(cppPtr, path.*.ptr, path.*.len);
    } else {
        return nemo.bindings.fp._Database_getCharacterDataByPath(cppPtr, path);
    }
}

pub fn Database_getCharacterDataByPathHash(cppPtr: basis.CppPtr, pathHash: u32) basis.CppPtr {
    if (isWasm) {
        return access.Database_getCharacterDataByPathHash_WASM(cppPtr, pathHash);
    } else {
        return nemo.bindings.fp._Database_getCharacterDataByPathHash(cppPtr, pathHash);
    }
}

// ===============================

// class Mission

pub fn Mission_getPath(cppPtr: basis.CppPtr, path: [*c]basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("Mission_getPath not implemented for WASM yet.");
    } else {
        nemo.bindings.fp._Mission_getPath(cppPtr, path);
    }
}

pub fn Mission_getState(cppPtr: basis.CppPtr) u32 {
    if (isWasm) {
        @compileError("Mission_getState not implemented for WASM yet.");
    } else {
        return nemo.bindings.fp._Mission_getState(cppPtr);
    }
}

pub fn Mission_start(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        @compileError("Mission_start not implemented for WASM yet.");
    } else {
        nemo.bindings.fp._Mission_start(cppPtr);
    }
}

pub fn Mission_abort(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        @compileError("Mission_abort not implemented for WASM yet.");
    } else {
        nemo.bindings.fp._Mission_abort(cppPtr);
    }
}

// ===============================

// class GlobalVariableSet

pub fn GlobalVariableSet_getPath(cppPtr: basis.CppPtr, path: [*c]basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("GlobalVariableSet_getPath not implemented for WASM yet.");
    } else {
        nemo.bindings.fp._GlobalVariableSet_getPath(cppPtr, path);
    }
}

pub fn GlobalVariableSet_readFloat(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString) f32 {
    if (isWasm) {
        @compileError("GlobalVariableSet_readFloat not implemented for WASM yet.");
    } else {
        return nemo.bindings.fp._GlobalVariableSet_readFloat(cppPtr, name);
    }
}

pub fn GlobalVariableSet_writeFloat(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString, value: f32) void {
    if (isWasm) {
        @compileError("GlobalVariableSet_writeFloat not implemented for WASM yet.");
    } else {
        nemo.bindings.fp._GlobalVariableSet_writeFloat(cppPtr, name, value);
    }
}

pub fn GlobalVariableSet_readInt(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString) c_int {
    if (isWasm) {
        @compileError("GlobalVariableSet_readInt not implemented for WASM yet.");
    } else {
        return nemo.bindings.fp._GlobalVariableSet_readInt(cppPtr, name);
    }
}

pub fn GlobalVariableSet_writeInt(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString, value: c_int) void {
    if (isWasm) {
        @compileError("GlobalVariableSet_writeInt not implemented for WASM yet.");
    } else {
        nemo.bindings.fp._GlobalVariableSet_writeInt(cppPtr, name, value);
    }
}

pub fn GlobalVariableSet_readBool(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString) c_int {
    if (isWasm) {
        @compileError("GlobalVariableSet_readBool not implemented for WASM yet.");
    } else {
        return nemo.bindings.fp._GlobalVariableSet_readBool(cppPtr, name);
    }
}

pub fn GlobalVariableSet_writeBool(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString, value: bool) void {
    if (isWasm) {
        @compileError("GlobalVariableSet_writeBool not implemented for WASM yet.");
    } else {
        nemo.bindings.fp._GlobalVariableSet_writeBool(cppPtr, name, value);
    }
}

pub fn GlobalVariableSet_readString(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString, value: [*c]basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("GlobalVariableSet_readString not implemented for WASM yet.");
    } else {
        nemo.bindings.fp._GlobalVariableSet_readString(cppPtr, name, value);
    }
}

pub fn GlobalVariableSet_writeString(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString, value: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("GlobalVariableSet_writeString not implemented for WASM yet.");
    } else {
        nemo.bindings.fp._GlobalVariableSet_writeString(cppPtr, name, value);
    }
}

// ===============================

// class CharacterData

pub fn CharacterData_getPath(cppPtr: basis.CppPtr, path: [*c]basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("CharacterData_getPath not implemented for WASM yet.");
    } else {
        nemo.bindings.fp._CharacterData_getPath(cppPtr, path);
    }
}

pub fn CharacterData_getFirstName(cppPtr: basis.CppPtr, value: [*c]basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("CharacterData_getFirstName not implemented for WASM yet.");
    } else {
        nemo.bindings.fp._CharacterData_getFirstName(cppPtr, value);
    }
}

pub fn CharacterData_getLastName(cppPtr: basis.CppPtr, value: [*c]basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("CharacterData_getLastName not implemented for WASM yet.");
    } else {
        nemo.bindings.fp._CharacterData_getLastName(cppPtr, value);
    }
}

pub fn CharacterData_getUIColor(cppPtr: basis.CppPtr, value: [*c]basis.bindings.InteropColor) void {
    if (isWasm) {
        @compileError("CharacterData_getUIColor not implemented for WASM yet.");
    } else {
        nemo.bindings.fp._CharacterData_getUIColor(cppPtr, value);
    }
}

// ===============================
