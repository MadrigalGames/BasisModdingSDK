// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
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

pub const AttachedEffectComponent = struct {
    const Self = @This();
    pub const RegistrationName = "merlin.AttachedEffectComponent";
    pub const UpdateOrder = 50;

    context: GameObjectComponent,
    blueprintProperties: ?*const BPProps = null,

    effectDesc: merlin.EffectDescriptionPtr = merlin.EffectDescriptionPtr.Null,
    effectInstance: merlin.EffectInstancePtr = merlin.EffectInstancePtr.Null,

    //----------------------------------------------------

    pub fn init(context: GameObjectComponent) !Self {
        return Self{
            .context = context,
        };
    }

    //----------------------------------------------------

    pub fn create(self: *Self) !void {
        _ = self;
    }

    pub fn destroy(self: *Self) !void {
        if (!self.effectInstance.isNull()) {
            if (self.blueprintProperties.?.letFinish) {
                self.effectInstance.stopEmitting();
                self.effectInstance.releaseWhenFinishedAndZero();
            } else {
                self.effectInstance.stop();
                self.effectInstance.releaseAndZero();
            }
        }
    }

    pub fn onObjectCreated(self: *Self) !void {
        basis.assert(@src(), self.blueprintProperties != null);
        const bpProps = self.blueprintProperties.?;

        if (bpProps.effectPath.isEmpty()) return;

        self.effectDesc = merlin.loadEffect(bpProps.effectPath.str());

        if (self.effectDesc.isNull()) return;

        const worldMatrix = self.context.transform.getWorldMatrix();
        self.effectInstance = self.effectDesc.createInstance(worldMatrix, bpProps.autoStart);
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

    //----------------------------------------------------

    fn start(self: *Self) void {
        if (!self.effectInstance.isNull()) {
            self.effectInstance.start();
        }
    }

    fn stop(self: *Self) void {
        if (!self.effectInstance.isNull()) {
            self.effectInstance.stop();
        }
    }
};

//----------------------------------------------------

const BPProps = struct {
    const Self = @This();

    allocator: std.mem.Allocator,

    effectPath: basis.String,
    autoStart: bool = false,
    letFinish: bool = false,

    pub fn init(allocator: std.mem.Allocator) !Self {
        return Self{
            .allocator = allocator,
            .effectPath = basis.String.init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.effectPath.deinit();
    }

    pub fn loadJSON(self: *Self, json: []const u8) !void {
        const Props = struct {
            effectPath: []const u8,
            autoStart: bool,
            letFinish: bool,
        };

        var arena = std.heap.ArenaAllocator.init(self.allocator);
        defer arena.deinit();

        const props = try std.json.parseFromSliceLeaky(Props, arena.allocator(), json, .{});

        try self.effectPath.set(props.effectPath);
        self.autoStart = props.autoStart;
        self.letFinish = props.letFinish;
    }
};
