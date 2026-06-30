// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

pub const ResultCode = enum(i32) {
    None = -1,
    Default = 0,
    Success = 1,
    ErrorNetwork = 2,
    ErrorCreatingHost = 3,
    ErrorConnecting = 4,
    ErrorThreading = 5,
    ErrorNotFound = 6,
    ErrorGeneric = 7,
    ErrorPassword = 8,
    ErrorAlreadyExists = 9,
    ErrorNatPunchThrough = 10,
    ErrorServerFull = 11,
    ErrorScriptCompilation = 12,
    ErrorIORead = 13,
    ErrorIOWrite = 14,
    UserCancelled = 15,
};

pub const CompletionCallback = basis.delegate.VoidDelegate1(ResultCode);
