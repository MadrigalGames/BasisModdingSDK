// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");

pub const bindings = @import("bindings.zig");

pub const timbre_utils = @import("timbre_utils.zig");

// This forces the namespaces/modules to be loaded and the exports to be processed.
comptime {
    _ = bindings.generated_bind_functions;
}

pub fn forceAnalysis() void {
    const modules = .{
        bindings,
        timbre_utils,
    };

    inline for (modules) |module| {
        std.testing.refAllDeclsRecursive(module);
    }
}
