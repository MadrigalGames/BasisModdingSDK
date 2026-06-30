// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const basis = @import("basis");

// MerlinManager:

pub extern "env" fn MerlinManager_loadEffect_WASM(resourcePathPtr: [*]const u8, resourcePathLength: u32) basis.CppPtr;

// EffectDescription:

pub extern "env" fn EffectDescription_getParameterIndex_WASM(cppPtr: basis.CppPtr, parameterNamePtr: [*]const u8, parameterNameLength: u32) u8;
