// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const TransformAnimation = basis.animation.TransformAnimation;

const Vec3 = basis.math.Vec3;
const Quaternion = basis.math.Quaternion;

pub const TransformAnimationPlayer = struct {
    const Self = @This();

    const State = enum(i32) {
        Stopped = 0,
        Paused,
        Playing,
        PlayedToTheEnd,
    };

    //----------------------------------------------------

    // The animation, use init() to set.
    animation: ?*const TransformAnimation,

    // The current state of the player. Use play(), pause() etc. to set.
    state: State,

    // The current time. Use setPlaybackPosition() to set.
    currentTime: f32,

    // The current output values of the animation player.
    currentPosition: Vec3,
    currentOrientation: Quaternion,

    // These can be set directly.
    playbackSpeed: f32,
    looping: bool,

    // Internal bokkeeping.
    searchFrameIndex: u32,
    animationFrameDuration: f32,

    //----------------------------------------------------

    pub fn init(animation: ?*const TransformAnimation) Self {
        var frameDuration: f32 = 0.0;
        if (animation) |anim| {
            frameDuration = 1.0 / @as(f32, @floatFromInt(anim.framerate));
        }

        return Self{
            .animation = animation,
            .state = .Stopped,
            .currentTime = 0.0,
            .currentPosition = .Zero,
            .currentOrientation = .Identity,
            .playbackSpeed = 1.0,
            .looping = false,
            .searchFrameIndex = 0,
            .animationFrameDuration = frameDuration,
        };
    }

    //----------------------------------------------------

    pub fn play(self: *Self) void {
        if (self.animation) |anim| {
            if (self.state == .Stopped or self.state == .PlayedToTheEnd) {
                if (self.playbackSpeed >= 0.0) {
                    self.searchFrameIndex = 0;
                    self.jumpToFirstFrame();
                } else {
                    const frameCount = anim.frames.items.len;
                    basis.assert(@src(), frameCount > 0);
                    self.searchFrameIndex = @intCast(frameCount - 1);
                    self.jumpToLastFrame();
                }
            }

            self.state = .Playing;
        }
    }

    pub fn pause(self: *Self) void {
        self.state = .Paused;
    }

    pub fn stop(self: *Self) void {
        if (self.animation) |anim| {
            if (self.state != .Stopped) {
                if (self.playbackSpeed >= 0.0) {
                    self.searchFrameIndex = 0;
                    self.jumpToFirstFrame();
                } else {
                    const frameCount = anim.frames.items.len;
                    basis.assert(@src(), frameCount > 0);
                    self.searchFrameIndex = @intCast(frameCount - 1);
                    self.jumpToLastFrame();
                }
            }

            self.state = .Stopped;
        }
    }

    pub fn setPlaybackPosition(self: *Self, time: f32) void {
        if (self.animation != null) {
            self.currentTime = time;
            self.updateAtCurrentTime();
        }
    }

    pub fn jumpToFirstFrame(self: *Self) void {
        if (self.animation) |anim| {
            self.currentTime = 0.0;
            self.currentPosition = anim.frames.items[0].position;
            self.currentOrientation = anim.frames.items[0].orientation;
        }
    }

    pub fn jumpToLastFrame(self: *Self) void {
        if (self.animation) |anim| {
            self.currentTime = anim.length;
            const frameCount = anim.frames.items.len;
            basis.assert(@src(), frameCount > 0);
            self.currentPosition = anim.frames.items[frameCount - 1].position;
            self.currentOrientation = anim.frames.items[frameCount - 1].orientation;
        }
    }

    //----------------------------------------------------

    // Updates the animation. Returns true if the result was updated (ie. the transform
    // was changed somehow), otherwise false.
    pub fn update(self: *Self, deltaTime: f32) bool {
        if (self.animation) |anim| {
            if (self.state == .Playing) {
                self.currentTime += deltaTime * self.playbackSpeed;

                if (self.currentTime >= anim.length and self.playbackSpeed >= 0.0) {
                    if (self.looping) {
                        self.currentTime -= anim.length;
                        self.searchFrameIndex = 0;
                    } else {
                        self.currentTime = anim.length;
                        self.state = .PlayedToTheEnd;

                        const frameCount = anim.frames.items.len;
                        basis.assert(@src(), frameCount > 0);
                        self.currentPosition = anim.frames.items[frameCount - 1].position;
                        self.currentOrientation = anim.frames.items[frameCount - 1].orientation;
                        return true;
                    }
                } else if (self.currentTime < 0.0 and self.playbackSpeed < 0.0) {
                    if (self.looping) {
                        self.currentTime += anim.length;
                        const frameCount = anim.frames.items.len;
                        self.searchFrameIndex = @intCast(frameCount - 1);
                    } else {
                        self.currentTime = 0.0;
                        self.state = .PlayedToTheEnd;

                        self.currentPosition = anim.frames.items[0].position;
                        self.currentOrientation = anim.frames.items[0].orientation;
                        return true;
                    }
                }

                self.updateAtCurrentTime();
                return true;
            }
        }

        return false;
    }

    //----------------------------------------------------

    fn updateAtCurrentTime(self: *Self) void {
        if (self.animation) |anim| {
            var f0: usize = 0;
            var f1: usize = 0;
            var factor: f32 = 0.0;
            self.getCurrentFrames(&f0, &f1, &factor);

            const p0 = anim.frames.items[f0].position;
            const p1 = anim.frames.items[f1].position;

            const o0 = anim.frames.items[f0].orientation;
            const o1 = anim.frames.items[f1].orientation;

            self.currentPosition = basis.math.Vec3.lerp(factor, p0, p1);
            self.currentOrientation = basis.math.Quaternion.slerp(factor, o0, o1);
        }
    }

    fn getCurrentFrames(self: *Self, f0: *usize, f1: *usize, factor: *f32) void {
        if (self.animation) |anim| {
            if (self.currentTime <= 0.0) {
                f0.* = 0;
                f1.* = 1;
                factor.* = 0.0;
            } else if (self.currentTime >= anim.length) {
                const frameCount = anim.frames.items.len;
                f0.* = frameCount - 2;
                f1.* = frameCount - 1;
                factor.* = 1.0;
            } else {
                var searchFrameTime: f32 = 0.0;
                var nextFrameTime: f32 = 0.0;

                while (true) {
                    searchFrameTime = self.animationFrameDuration * @as(f32, @floatFromInt(self.searchFrameIndex));
                    nextFrameTime = self.animationFrameDuration * @as(f32, @floatFromInt(self.searchFrameIndex + 1));

                    if (searchFrameTime <= self.currentTime and nextFrameTime >= self.currentTime) {
                        break;
                    }

                    if (self.currentTime < searchFrameTime) {
                        self.searchFrameIndex -= 1;
                    } else {
                        self.searchFrameIndex += 1;
                    }
                }

                f0.* = self.searchFrameIndex;
                f1.* = self.searchFrameIndex + 1;
                factor.* = basis.math.remapFloat(self.currentTime, searchFrameTime, nextFrameTime, 0.0, 1.0);
            }
        }
    }
};
