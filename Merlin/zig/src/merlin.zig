// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");

pub const bindings = @import("bindings.zig");
pub const effect_description = @import("effect_description.zig");
pub const effect_instance = @import("effect_instance.zig");
pub const components = @import("components/components.zig");

pub const ParameterIndex = u8;

pub const InvalidParameterIndexID: ParameterIndex = 0xFF;

pub const EffectDescriptionPtr = effect_description.EffectDescriptionPtr;
pub const EffectInstancePtr = effect_instance.EffectInstancePtr;

//----------------------------------------------------

pub const EffectInstanceState = enum(u32) {
    Invalid = 0,
    Stopped,
    Playing,
    Paused,
    Finished,
};

//----------------------------------------------------

pub fn loadEffect(resourcePath: []const u8) EffectDescriptionPtr {
    const interopPath = basis.string.toInteropString(resourcePath);
    const cppPtr = bindings.api.MerlinManager_loadEffect(&interopPath);
    return EffectDescriptionPtr.initFromCppPtr(cppPtr);
}

//----------------------------------------------------

// Misc:

// This forces the namespaces/modules to be loaded and the exports to be processed.
comptime {
    _ = bindings.generated_bind_functions;
}

pub fn forceAnalysis() void {
    const modules = .{
        @This(),
        bindings,
        effect_description,
        effect_instance,
        components,
    };

    inline for (modules) |module| {
        std.testing.refAllDeclsRecursive(module);
    }
}
