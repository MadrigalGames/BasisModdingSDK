// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const trampoline = @import("trampoline.zig");

pub const SoundBankData = struct {
    soundBankName: []const u8,
    soundBankResourcePath: []const u8,
};

pub fn loadAdditiveProject(
    client: basis.host.ClientPtr,
    projectResourcePath: []const u8,
    soundBanks: []const SoundBankData,
) !void {
    const tempBuffer = try client.allocator.alloc(u8, 2 * 1024);
    defer client.allocator.free(tempBuffer);

    var stream = basis.binary_stream.BinaryWriteStream.init(tempBuffer, true);

    stream.putString(projectResourcePath);

    stream.putInt(u32, @intCast(soundBanks.len));

    for (soundBanks) |sb| {
        stream.putString(sb.soundBankName);
        stream.putString(sb.soundBankResourcePath);
    }

    const serializedLength: u32 = @intCast(stream.cursorPosition);

    trampoline.bindings.api.TimbreUtils_loadAdditiveProject(&tempBuffer[0], serializedLength);
}
