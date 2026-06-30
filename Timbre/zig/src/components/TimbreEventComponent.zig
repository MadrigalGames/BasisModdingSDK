// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const timbre = @import("../timbre.zig");

const GameObjectComponent = basis.component_contexts.GameObjectComponent;

const Message = basis.messaging.Message;
const MessageParametersPtr = basis.messaging.MessageParametersPtr;

const TickLevel = basis.game_session.TickLevel;

pub const TimbreEventComponent = struct {
    const Self = @This();
    pub const RegistrationName = "timbre.TimbreEventComponent";
    pub const UpdateOrder = 50;

    context: GameObjectComponent,

    eventDesc: timbre.EventDescriptionPtr = timbre.EventDescriptionPtr.Null,
    eventInstance: timbre.EventInstancePtr = timbre.EventInstancePtr.Null,

    // Exposed properties:
    eventPath: basis.String,
    autoPlay: bool = false,
    autoPause: bool = true,
    autoPauseTickLevel: TickLevel = .Partial,

    pub const ExposedPropertyMap = .{
        basis.exposed_properties.StringProperty(Self, "eventPath", "", 1, ""),
        basis.exposed_properties.Button("play", "Play", "Play", ""),
        basis.exposed_properties.Button("stop", "Stop", "Stop", ""),
        basis.exposed_properties.Property(Self, bool, "autoPlay", false, 1, ""),
        basis.exposed_properties.Property(Self, bool, "autoPause", true, 1, ""),
        basis.exposed_properties.Property(Self, TickLevel, "autoPauseTickLevel", .Partial, 1, ""),
    };

    //----------------------------------------------------

    pub fn init(context: GameObjectComponent) !Self {
        return Self{
            .context = context,
            .eventPath = basis.String.init(context.allocator),
        };
    }

    //----------------------------------------------------

    // pub fn create(self: *Self) !void {
    //     _ = self;
    // }

    pub fn destroy(self: *Self) !void {
        if (!self.eventInstance.isNull()) {
            self.eventInstance.stop();
            self.eventInstance.releaseAndZero();
        }

        self.eventPath.deinit();
    }

    pub fn onObjectCreated(self: *Self) !void {
        if (!self.context.inEditor() and self.autoPlay) {
            self.play();
        }
    }

    pub fn update(self: *Self, deltaTime: f32) !void {
        _ = deltaTime;

        if (!self.eventInstance.isNull() and self.eventInstance.getState() == timbre.PlaybackState.Playing) {
            self.eventInstance.set3DParameters(self.context.transform.getPosition(), basis.math.Vec3.Zero);
        }
    }

    // pub fn tick(self: *Self, tickDeltaTime: f32) !void {
    //     _ = self;
    //     _ = tickDeltaTime;
    // }

    // pub fn onMessageReceived(self: *Self, message: Message, senderNameHash: basis.string.StringHash, parameters: MessageParametersPtr) !void {
    //     _ = self;
    //     _ = message;
    //     _ = senderNameHash;
    //     _ = parameters;
    // }

    pub fn editorButtonActionExecuted(self: *Self, buttonActionID: []const u8) !void {
        if (basis.string.eql(buttonActionID, "play")) {
            self.play();
        } else if (basis.string.eql(buttonActionID, "stop")) {
            self.stop();
        }
    }

    pub fn isExposedPropertyVisible(self: *Self, propertyName: []const u8) bool {
        if (basis.string.eql(propertyName, "autoPauseTickLevel")) return self.autoPause;

        return true;
    }

    //----------------------------------------------------

    pub fn play(self: *Self) void {
        if (!self.eventInstance.isNull()) {
            self.eventInstance.stop();
            self.eventInstance.releaseAndZero();
        }

        self.eventDesc = timbre.sound_manager.getEventDesc(self.eventPath.str());

        if (self.eventDesc.isNull()) {
            basis.debug_overlay.debugWarning("Cannot play. No Timbre event with path \"{s}\".", .{self.eventPath.str()});
            return;
        }

        self.eventInstance = if (self.autoPause)
            self.eventDesc.createInstanceWithAutoPauseTickLevel(self.autoPauseTickLevel)
        else
            self.eventDesc.createInstance(false);

        self.eventInstance.set3DParameters(self.context.transform.getPosition(), basis.math.Vec3.Zero);
        self.eventInstance.start();
    }

    pub fn stop(self: *Self) void {
        if (!self.eventInstance.isNull() and self.eventInstance.getState() == timbre.PlaybackState.Playing) {
            self.eventInstance.stop();
        }
    }
};
