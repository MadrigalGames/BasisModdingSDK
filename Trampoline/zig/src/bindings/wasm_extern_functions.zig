// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const basis = @import("basis");

// MainLib:

pub extern "env" fn MainLib_callU64_WASM(callID: u64, param: u64) u64;

// TimbreUtils:
pub extern "env" fn TimbreUtils_loadAdditiveProject_WASM(data: [*c]const u8, dataLength: u32) void;
