// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const ClientPtr = basis.host.ClientPtr;

const SceneNodePtr = basis.math.SceneNodePtr;
const Vec3 = basis.math.Vec3;
const Quaternion = basis.math.Quaternion;
const TransformInterpolator = basis.math.TransformInterpolator;

var gFOVMultiplier: f32 = 1.0;

pub const FreeCameraController = struct {
    const Self = @This();

    client: ClientPtr,

    inputNode: SceneNodePtr = SceneNodePtr.initNull(),

    cameraPosition: Vec3 = Vec3.Zero,
    cameraOrientation: Quaternion = Quaternion.Identity,
    baseCameraFov: f32 = basis.math.Pi * 0.25,

    forwardBackward: f32 = 0.0,
    leftRight: f32 = 0.0,
    upDown: f32 = 0.0,

    enabled: bool = false,

    transformInterpolator: TransformInterpolator = .{},

    //----------------------------------------------------

    pub fn init(client: ClientPtr) Self {
        return Self{
            .client = client,
            .inputNode = SceneNodePtr.initNew(),
        };
    }

    pub fn deinit(self: *Self) void {
        if (self.enabled) {
            self.disable();
        }

        self.inputNode.deinit();
        self.inputNode = SceneNodePtr.Null;
    }

    pub fn registerCmdPrompt() void {
        basis.command_prompt.registerFloatValue("camera", "freecamfov", setFOVMultiplier, getFOVMultiplier, false, "");
    }

    pub fn unregisterCmdPrompt() void {
        basis.command_prompt.unregister("camera", "freecamfov");
    }

    //----------------------------------------------------

    pub fn getCameraFov(self: *const Self) f32 {
        return self.baseCameraFov * gFOVMultiplier;
    }

    pub fn enable(self: *Self, position: Vec3, orientation: Quaternion) void {
        self.inputNode.setPosition(position);
        self.inputNode.setOrientation(orientation);
        self.transformInterpolator.clear();

        self.enabled = true;
    }

    pub fn disable(self: *Self) void {
        self.enabled = false;
    }

    pub fn tick(self: *Self, tickDeltaTime: f32) void {
        if (self.enabled) {
            var cameraTranslation = Vec3.init(self.leftRight, self.upDown, self.forwardBackward);
            cameraTranslation = cameraTranslation.multiplyFloat(tickDeltaTime * 20.0);

            if (cameraTranslation.length() > 0) {
                self.inputNode.translate(cameraTranslation);
            }

            self.transformInterpolator.pushTransform(
                self.inputNode.getPosition(),
                self.inputNode.getOrientation(),
            );
        }
    }

    pub fn update(self: *Self, deltaTime: f32) void {
        _ = deltaTime;

        if (self.enabled) {
            if (self.transformInterpolator.hasTransforms) {
                var pos = Vec3.Zero;
                var ori = Quaternion.Identity;

                const if32 = @as(f32, @floatCast(self.client.getInterpolationFactor()));
                self.transformInterpolator.getInterpolatedTransform(if32, &pos, &ori);

                self.cameraPosition = pos;
                self.cameraOrientation = ori;
            } else {
                self.cameraPosition = self.inputNode.getPosition();
                self.cameraOrientation = self.inputNode.getOrientation();
            }
        }
    }

    pub fn setCameraTransform(self: *Self, position: Vec3, orientation: Quaternion) void {
        self.inputNode.setPosition(position);
        self.inputNode.setOrientation(orientation);
        self.cameraPosition = position;
        self.cameraOrientation = orientation;
        self.transformInterpolator.clear();
    }

    pub fn updateCameraMovement(self: *Self, forwardBackward: f32, leftRight: f32, upDown: f32) void {
        self.forwardBackward = forwardBackward;
        self.leftRight = leftRight;
        self.upDown = upDown;
    }

    pub fn updateCameraPitch(self: *Self, delta: f32) void {
        self.inputNode.pitchInSpace(delta * 0.02, basis.math.CoordinateSpace.Local, false);
    }

    pub fn updateCameraYaw(self: *Self, delta: f32) void {
        self.inputNode.yawInSpace(-delta * 0.02, basis.math.CoordinateSpace.World, false);
    }

    //----------------------------------------------------

    fn setFOVMultiplier(multiplier: f32) callconv(.c) void {
        gFOVMultiplier = multiplier;
    }

    fn getFOVMultiplier() callconv(.c) f32 {
        return gFOVMultiplier;
    }
};
