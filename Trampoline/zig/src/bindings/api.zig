// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const builtin = @import("builtin");
const basis = @import("basis");
const trampoline = @import("../trampoline.zig");

const isWasm = (builtin.cpu.arch == .wasm32 or builtin.cpu.arch == .wasm64);

const access = if (isWasm)
    @import("wasm_extern_functions.zig")
else
    .{}; // TODO: Replace this with some module that contains the DLL interface.

// class Localization

pub fn Localization_isValidLocalizationKey(keyName: [*c]const basis.bindings.InteropString) bool {
    if (isWasm) {
        @compileError("Localization_isValidLocalizationKey not implemented for WASM yet.");
    } else {
        return trampoline.bindings.fp._Localization_isValidLocalizationKey(keyName);
    }
}

pub fn Localization_getLocalizedStringByName(keyName: [*c]const basis.bindings.InteropString, value: [*c]basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("Localization_getLocalizedStringByName not implemented for WASM yet.");
    } else {
        trampoline.bindings.fp._Localization_getLocalizedStringByName(keyName, value);
    }
}

pub fn Localization_getLocalizedStringByNameWithParams1(keyName: [*c]const basis.bindings.InteropString, param0: [*c]const basis.bindings.InteropString, value: [*c]basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("Localization_getLocalizedStringByNameWithParams1 not implemented for WASM yet.");
    } else {
        trampoline.bindings.fp._Localization_getLocalizedStringByNameWithParams1(keyName, param0, value);
    }
}

pub fn Localization_getLocalizedStringByNameWithParams2(keyName: [*c]const basis.bindings.InteropString, param0: [*c]const basis.bindings.InteropString, param1: [*c]const basis.bindings.InteropString, value: [*c]basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("Localization_getLocalizedStringByNameWithParams2 not implemented for WASM yet.");
    } else {
        trampoline.bindings.fp._Localization_getLocalizedStringByNameWithParams2(keyName, param0, param1, value);
    }
}

pub fn Localization_getLocalizedStringByNameWithParams3(keyName: [*c]const basis.bindings.InteropString, param0: [*c]const basis.bindings.InteropString, param1: [*c]const basis.bindings.InteropString, param2: [*c]const basis.bindings.InteropString, value: [*c]basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("Localization_getLocalizedStringByNameWithParams3 not implemented for WASM yet.");
    } else {
        trampoline.bindings.fp._Localization_getLocalizedStringByNameWithParams3(keyName, param0, param1, param2, value);
    }
}

pub fn Localization_getLocalizedVec2ByName(keyName: [*c]const basis.bindings.InteropString, value: [*c]basis.bindings.InteropVec2) void {
    if (isWasm) {
        @compileError("Localization_getLocalizedVec2ByName not implemented for WASM yet.");
    } else {
        trampoline.bindings.fp._Localization_getLocalizedVec2ByName(keyName, value);
    }
}

pub fn Localization_setUILanguage(id: i32) void {
    if (isWasm) {
        @compileError("Localization_setUILanguage not implemented for WASM yet.");
    } else {
        trampoline.bindings.fp._Localization_setUILanguage(id);
    }
}

// ===============================

// class MainLib

pub fn MainLib_callU64(callID: u64, param: u64) u64 {
    if (isWasm) {
        return access.MainLib_callU64_WASM(callID, param);
    } else {
        return trampoline.bindings.fp._MainLib_MainLib_callU64(callID, param);
    }
}

// ===============================

// class TimbreUtils

pub fn TimbreUtils_loadAdditiveProject(data: [*c]const u8, dataLength: u32) void {
    if (isWasm) {
        access.TimbreUtils_loadAdditiveProject_WASM(data, dataLength);
    } else {
        trampoline.bindings.fp._TimbreUtils_loadAdditiveProject(data, dataLength);
    }
}

// ===============================
