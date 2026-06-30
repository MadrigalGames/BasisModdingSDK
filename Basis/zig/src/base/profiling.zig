// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const builtin = @import("builtin");
const basis = @import("../basis.zig");

// TODO: Move this somewhere it can be controlled per build type, eg. remove from final builds.
const ProfilingEnabled = false;

pub fn beginSample(name: [*:0]const u8) void {
    if (ProfilingEnabled) {
        basis.bindings.api.Core_beginProfilingSample(name);
    }
}

pub fn endSample() void {
    if (ProfilingEnabled) {
        basis.bindings.api.Core_endProfilingSample();
    }
}
