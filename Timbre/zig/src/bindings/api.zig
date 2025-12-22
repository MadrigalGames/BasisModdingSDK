// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const builtin = @import("builtin");
const basis = @import("basis");
const timbre = @import("../timbre.zig");

const isWasm = basis.build_options.buildAsWASM;

const access = if (isWasm)
    @import("wasm_extern_functions.zig")
else
    .{}; // TODO: Replace this with some module that contains the DLL interface.

// class TimbreSoundManager

pub fn TimbreSoundManager_getMasterGroupBus() basis.CppPtr {
    if (isWasm) {
        return access.TimbreSoundManager_getMasterGroupBus_WASM();
    } else {
        return timbre.bindings.fp._TimbreSoundManager_getMasterGroupBus();
    }
}

pub fn TimbreSoundManager_getGroupBus(path: [*c]const basis.bindings.InteropString) basis.CppPtr {
    if (isWasm) {
        return access.TimbreSoundManager_getGroupBus_WASM(path.*.ptr, path.*.len);
    } else {
        return timbre.bindings.fp._TimbreSoundManager_getGroupBus(path);
    }
}

pub fn TimbreSoundManager_getEventDesc(path: [*c]const basis.bindings.InteropString) basis.CppPtr {
    if (isWasm) {
        return access.TimbreSoundManager_getEventDesc_WASM(path.*.ptr, path.*.len);
    } else {
        return timbre.bindings.fp._TimbreSoundManager_getEventDesc(path);
    }
}

pub fn TimbreSoundManager_playAndForget2D(eventDescCppPtr: basis.CppPtr, autoPause: bool) void {
    if (isWasm) {
        access.TimbreSoundManager_playAndForget2D_WASM(eventDescCppPtr, autoPause);
    } else {
        timbre.bindings.fp._TimbreSoundManager_playAndForget2D(eventDescCppPtr, autoPause);
    }
}

pub fn TimbreSoundManager_playAndForget3D(eventDescCppPtr: basis.CppPtr, position: [*c]const basis.bindings.InteropVec3, autoPause: bool) void {
    if (isWasm) {
        access.TimbreSoundManager_playAndForget3D_WASM(eventDescCppPtr, position.*.x, position.*.y, position.*.z, autoPause);
    } else {
        timbre.bindings.fp._TimbreSoundManager_playAndForget3D(eventDescCppPtr, position, autoPause);
    }
}

pub fn TimbreSoundManager_playByPathAndForget2D(eventPath: [*c]const basis.bindings.InteropString, autoPause: bool) void {
    if (isWasm) {
        access.TimbreSoundManager_playByPathAndForget2D_WASM(eventPath.*.ptr, eventPath.*.len, autoPause);
    } else {
        timbre.bindings.fp._TimbreSoundManager_playByPathAndForget2D(eventPath, autoPause);
    }
}

pub fn TimbreSoundManager_playByPathAndForget3D(eventPath: [*c]const basis.bindings.InteropString, position: [*c]const basis.bindings.InteropVec3, autoPause: bool) void {
    if (isWasm) {
        access.TimbreSoundManager_playByPathAndForget3D_WASM(eventPath.*.ptr, eventPath.*.len, position.*.x, position.*.y, position.*.z, autoPause);
    } else {
        timbre.bindings.fp._TimbreSoundManager_playByPathAndForget3D(eventPath, position, autoPause);
    }
}

// ===============================

// class GroupBus

pub fn GroupBus_getVolume(cppPtr: basis.CppPtr) f32 {
    if (isWasm) {
        return access.GroupBus_getVolume_WASM(cppPtr);
    } else {
        return timbre.bindings.fp._GroupBus_getVolume(cppPtr);
    }
}

pub fn GroupBus_setVolume(cppPtr: basis.CppPtr, volume: f32) void {
    if (isWasm) {
        access.GroupBus_setVolume_WASM(cppPtr, volume);
    } else {
        timbre.bindings.fp._GroupBus_setVolume(cppPtr, volume);
    }
}

// ===============================

// class EventDescription

pub fn EventDescription_createInstance(cppPtr: basis.CppPtr, autoPause: c_int) basis.CppPtr {
    if (isWasm) {
        return access.EventDescription_createInstance_WASM(cppPtr, (autoPause == 1));
    } else {
        return timbre.bindings.fp._EventDescription_createInstance(cppPtr, autoPause);
    }
}

pub fn EventDescription_getParameterIndex(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString) u32 {
    if (isWasm) {
        return access.EventDescription_getParameterIndex_WASM(cppPtr, name.*.ptr, name.*.len);
    } else {
        return timbre.bindings.fp._EventDescription_getParameterIndex(cppPtr, name);
    }
}

pub fn EventDescription_getLength(cppPtr: basis.CppPtr) f32 {
    if (isWasm) {
        return access.EventDescription_getLength_WASM(cppPtr);
    } else {
        return timbre.bindings.fp._EventDescription_getLength(cppPtr);
    }
}

// ===============================

// class EventInstance

pub fn EventInstance_release(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.EventInstance_release_WASM(cppPtr);
    } else {
        timbre.bindings.fp._EventInstance_release(cppPtr);
    }
}

pub fn EventInstance_releaseWhenFinished(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.EventInstance_releaseWhenFinished_WASM(cppPtr);
    } else {
        timbre.bindings.fp._EventInstance_releaseWhenFinished(cppPtr);
    }
}

pub fn EventInstance_releaseAfterFadeOut(cppPtr: basis.CppPtr, fadeOutDuration: f32) void {
    if (isWasm) {
        access.EventInstance_releaseAfterFadeOut_WASM(cppPtr, fadeOutDuration);
    } else {
        timbre.bindings.fp._EventInstance_releaseAfterFadeOut(cppPtr, fadeOutDuration);
    }
}

pub fn EventInstance_getState(cppPtr: basis.CppPtr) u32 {
    if (isWasm) {
        return access.EventInstance_getState_WASM(cppPtr);
    } else {
        return timbre.bindings.fp._EventInstance_getState(cppPtr);
    }
}

pub fn EventInstance_start(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.EventInstance_start_WASM(cppPtr);
    } else {
        timbre.bindings.fp._EventInstance_start(cppPtr);
    }
}

pub fn EventInstance_pause(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.EventInstance_pause_WASM(cppPtr);
    } else {
        timbre.bindings.fp._EventInstance_pause(cppPtr);
    }
}

pub fn EventInstance_stop(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.EventInstance_stop_WASM(cppPtr);
    } else {
        timbre.bindings.fp._EventInstance_stop(cppPtr);
    }
}

pub fn EventInstance_setParameterByName(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString, value: f32) void {
    if (isWasm) {
        access.EventInstance_setParameterByName_WASM(cppPtr, name.*.ptr, name.*.len, value);
    } else {
        timbre.bindings.fp._EventInstance_setParameterByName(cppPtr, name, value);
    }
}

pub fn EventInstance_setParameterByIndex(cppPtr: basis.CppPtr, index: u32, value: f32) void {
    if (isWasm) {
        access.EventInstance_setParameterByIndex_WASM(cppPtr, index, value);
    } else {
        timbre.bindings.fp._EventInstance_setParameterByIndex(cppPtr, index, value);
    }
}

pub fn EventInstance_set3DParameters(cppPtr: basis.CppPtr, position: [*c]const basis.bindings.InteropVec3, linVel: [*c]const basis.bindings.InteropVec3) void {
    if (isWasm) {
        access.EventInstance_set3DParameters_WASM(cppPtr, position.*.x, position.*.y, position.*.z, linVel.*.x, linVel.*.y, linVel.*.z);
    } else {
        timbre.bindings.fp._EventInstance_set3DParameters(cppPtr, position, linVel);
    }
}

pub fn EventInstance_sendSignal(cppPtr: basis.CppPtr, signal: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        access.EventInstance_sendSignal_WASM(cppPtr, signal.*.ptr, signal.*.len);
    } else {
        timbre.bindings.fp._EventInstance_sendSignal(cppPtr, signal);
    }
}

pub fn EventInstance_fadeIn(cppPtr: basis.CppPtr, fadeInDuration: f32) void {
    if (isWasm) {
        access.EventInstance_fadeIn_WASM(cppPtr, fadeInDuration);
    } else {
        timbre.bindings.fp._EventInstance_fadeIn(cppPtr, fadeInDuration);
    }
}

// ===============================
