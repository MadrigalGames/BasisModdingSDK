// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const builtin = @import("builtin");
const basis = @import("basis");
const merlin = @import("../merlin.zig");

const isWasm = basis.build_options.buildAsWASM;

const access = if (isWasm)
    @import("wasm_extern_functions.zig")
else
    .{}; // TODO: Replace this with some module that contains the DLL interface.

// class MerlinManager

pub fn MerlinManager_loadEffect(resourcePath: [*c]const basis.bindings.InteropString) basis.CppPtr {
    if (isWasm) {
        return access.MerlinManager_loadEffect_WASM(resourcePath.*.ptr, resourcePath.*.len);
    } else {
        return merlin.bindings.fp._MerlinManager_loadEffect(resourcePath);
    }
}

// ===============================

// class EffectDescription

pub fn EffectDescription_createInstance(cppPtr: basis.CppPtr, worldTransform: [*c]const basis.bindings.InteropMat43, autoStart: c_int) basis.CppPtr {
    if (isWasm) {
        @compileError("EffectDescription_createInstance not implemented for WASM yet.");
    } else {
        return merlin.bindings.fp._EffectDescription_createInstance(cppPtr, worldTransform, autoStart);
    }
}

pub fn EffectDescription_getParameterIndex(cppPtr: basis.CppPtr, parameterName: [*c]const basis.bindings.InteropString) u8 {
    if (isWasm) {
        return access.EffectDescription_getParameterIndex_WASM(cppPtr, parameterName.*.ptr, parameterName.*.len);
    } else {
        return merlin.bindings.fp._EffectDescription_getParameterIndex(cppPtr, parameterName);
    }
}

// ===============================

// class EffectInstance

pub fn EffectInstance_release(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        @compileError("EffectInstance_release not implemented for WASM yet.");
    } else {
        merlin.bindings.fp._EffectInstance_release(cppPtr);
    }
}

pub fn EffectInstance_releaseWhenFinished(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        @compileError("EffectInstance_releaseWhenFinished not implemented for WASM yet.");
    } else {
        merlin.bindings.fp._EffectInstance_releaseWhenFinished(cppPtr);
    }
}

pub fn EffectInstance_setTransform(cppPtr: basis.CppPtr, worldTransform: [*c]const basis.bindings.InteropMat43) void {
    if (isWasm) {
        @compileError("EffectInstance_setTransform not implemented for WASM yet.");
    } else {
        merlin.bindings.fp._EffectInstance_setTransform(cppPtr, worldTransform);
    }
}

pub fn EffectInstance_getState(cppPtr: basis.CppPtr) u32 {
    if (isWasm) {
        @compileError("EffectInstance_getState not implemented for WASM yet.");
    } else {
        return merlin.bindings.fp._EffectInstance_getState(cppPtr);
    }
}

pub fn EffectInstance_start(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        @compileError("EffectInstance_start not implemented for WASM yet.");
    } else {
        merlin.bindings.fp._EffectInstance_start(cppPtr);
    }
}

pub fn EffectInstance_pause(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        @compileError("EffectInstance_pause not implemented for WASM yet.");
    } else {
        merlin.bindings.fp._EffectInstance_pause(cppPtr);
    }
}

pub fn EffectInstance_stop(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        @compileError("EffectInstance_stop not implemented for WASM yet.");
    } else {
        merlin.bindings.fp._EffectInstance_stop(cppPtr);
    }
}

pub fn EffectInstance_stopEmitting(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        @compileError("EffectInstance_stopEmitting not implemented for WASM yet.");
    } else {
        merlin.bindings.fp._EffectInstance_stopEmitting(cppPtr);
    }
}

pub fn EffectInstance_setIntParameter(cppPtr: basis.CppPtr, index: u8, parameter: c_int) void {
    if (isWasm) {
        @compileError("EffectInstance_setIntParameter not implemented for WASM yet.");
    } else {
        merlin.bindings.fp._EffectInstance_setIntParameter(cppPtr, index, parameter);
    }
}

pub fn EffectInstance_setFloatParameter(cppPtr: basis.CppPtr, index: u8, parameter: f32) void {
    if (isWasm) {
        @compileError("EffectInstance_setFloatParameter not implemented for WASM yet.");
    } else {
        merlin.bindings.fp._EffectInstance_setFloatParameter(cppPtr, index, parameter);
    }
}

pub fn EffectInstance_setVectorParameter(cppPtr: basis.CppPtr, index: u8, parameter: [*c]const basis.bindings.InteropVec4) void {
    if (isWasm) {
        @compileError("EffectInstance_setVectorParameter not implemented for WASM yet.");
    } else {
        merlin.bindings.fp._EffectInstance_setVectorParameter(cppPtr, index, parameter);
    }
}

// ===============================
