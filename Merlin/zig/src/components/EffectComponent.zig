// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const merlin = @import("../merlin.zig");

const GameObjectComponent = basis.component_contexts.GameObjectComponent;

const Message = basis.messaging.Message;
const MessageParametersPtr = basis.messaging.MessageParametersPtr;

pub const EffectComponent = struct {
    const Self = @This();
    pub const RegistrationName = "merlin.EffectComponent";
    pub const UpdateOrder = 50;

    context: GameObjectComponent,

    effectDesc: merlin.EffectDescriptionPtr = merlin.EffectDescriptionPtr.Null,
    effectInstance: merlin.EffectInstancePtr = merlin.EffectInstancePtr.Null,

    // Exposed properties:
    effectPath: basis.String,
    autoStart: bool = true,
    letFinishOnParentDeath: bool = false,

    pub const ExposedPropertyMap = .{
        basis.exposed_properties.ResourceRefProperty(Self, "effectPath", basis.typeinfo.ResourceTypeID.RawDataFile, "", 1, ""),
        basis.exposed_properties.Property(Self, bool, "autoStart", true, 1, ""),
        basis.exposed_properties.Property(Self, bool, "letFinishOnParentDeath", false, 1, ""),
        basis.exposed_properties.Button("start", "Start", "Start", ""),
        basis.exposed_properties.Button("stop", "Stop", "Stop", ""),
        basis.exposed_properties.Button("stopAndLetFinish", "Stop and let finish", "Stop", ""),
    };

    //----------------------------------------------------

    pub fn init(context: GameObjectComponent) !Self {
        return Self{
            .context = context,
            .effectPath = basis.String.init(context.allocator),
        };
    }

    //----------------------------------------------------

    pub fn destroy(self: *Self) !void {
        if (self.letFinishOnParentDeath) {
            self.stopAndLetFinish();
        } else {
            self.stop();
        }

        self.effectPath.deinit();
    }

    pub fn onObjectCreated(self: *Self) !void {
        if (!self.context.inEditor() and self.autoStart) {
            self.start();
        }
    }

    pub fn update(self: *Self, deltaTime: f32) !void {
        _ = deltaTime; // autofix
        if (!self.effectInstance.isNull()) {
            const sceneNode = self.context.transform.getRenderSceneNode();
            const worldMatrix = basis.math.Mat43.fromOrientationPosition(
                sceneNode.getOrientation(),
                sceneNode.getPosition(),
            );
            self.effectInstance.setTransform(worldMatrix);
        }
    }

    // pub fn onMessageReceived(self: *Self, message: Message, senderNameHash: basis.string.StringHash, parameters: MessageParametersPtr) !void {
    //     _ = self;
    //     _ = message;
    //     _ = senderNameHash;
    //     _ = parameters;
    // }

    pub fn editorButtonActionExecuted(self: *Self, buttonActionID: []const u8) !void {
        if (basis.string.eql(buttonActionID, "start")) {
            self.start();
        } else if (basis.string.eql(buttonActionID, "stop")) {
            self.stop();
        } else if (basis.string.eql(buttonActionID, "stopAndLetFinish")) {
            self.stopAndLetFinish();
        }
    }

    //----------------------------------------------------

    pub fn start(self: *Self) void {
        if (!self.effectInstance.isNull()) {
            self.effectInstance.stop();
            self.effectInstance.releaseAndZero();
        }

        self.effectDesc = merlin.loadEffect(self.effectPath.str());

        if (self.effectDesc.isNull()) return;

        const worldMatrix = self.context.transform.getWorldMatrix();
        self.effectInstance = self.effectDesc.createInstance(worldMatrix, true);
    }

    pub fn stop(self: *Self) void {
        if (!self.effectInstance.isNull()) {
            self.effectInstance.stop();
            self.effectInstance.releaseAndZero();
        }
    }

    pub fn stopAndLetFinish(self: *Self) void {
        if (!self.effectInstance.isNull()) {
            self.effectInstance.stopEmitting();
            self.effectInstance.releaseWhenFinishedAndZero();
        }
    }
};
