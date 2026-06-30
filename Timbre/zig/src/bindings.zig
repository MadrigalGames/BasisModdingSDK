// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");

pub const api = @import("bindings/api.zig");

pub const generated_types = @import("bindings/generated_types.zig");
pub const generated_bind_functions = @import("bindings/generated_bind_functions.zig");
pub const generated_function_pointers = @import("bindings/generated_function_pointers.zig");

// Shorthand form to make using the generated function pointers a bit less cumbersome.
pub const fp = generated_function_pointers;
