// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

pub const host = @import("host/host.zig");
pub const client = @import("host/client.zig");
pub const server = @import("host/server.zig");

pub const HostPtr = host.HostPtr;
pub const ClientPtr = client.ClientPtr;
pub const ServerPtr = server.ServerPtr;
