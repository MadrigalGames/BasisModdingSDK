// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Vec3 = basis.math.Vec3;
const Quaternion = basis.math.Quaternion;

pub const TransformAnimation = struct {
    const Self = @This();

    pub const Frame = struct {
        position: Vec3,
        orientation: Quaternion,
    };

    //----------------------------------------------------

    length: f32 = 0,
    framerate: u32 = 0,
    frames: basis.ArrayList(Frame),

    //----------------------------------------------------

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .frames = .init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.frames.deinit();
    }

    //----------------------------------------------------

    pub fn tryDeserialize(self: *Self, stream: *basis.BinaryReadStream) !void {
        self.frames.clearRetainingCapacity();

        self.length = stream.getFloat();
        self.framerate = stream.getInt(u32);

        const frameCount = stream.getInt(u32);
        try self.frames.resize(@intCast(frameCount));

        for (self.frames.items) |*f| {
            f.position = stream.get(Vec3);
            f.orientation = stream.get(Quaternion);
        }
    }
};
