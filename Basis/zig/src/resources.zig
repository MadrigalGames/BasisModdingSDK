// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

pub const resource_types = @import("resources/resource_types.zig");
pub const resource_manager = @import("resources/resource_manager.zig");

pub const RawDataFilePtr = resource_types.RawDataFilePtr;
pub const JsonResourcePtr = resource_types.JsonResourcePtr;
pub const MaterialResourcePtr = resource_types.MaterialResourcePtr;
pub const TextureResourcePtr = resource_types.TextureResourcePtr;
pub const MeshResourcePtr = resource_types.MeshResourcePtr;
