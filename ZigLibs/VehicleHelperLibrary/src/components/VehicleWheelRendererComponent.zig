// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const vhl = @import("../vhl.zig");

const vehicles = basis.physics.vehicles;

const GameObjectComponent = basis.component_contexts.GameObjectComponent;

//const VehicleControllerDescription = basis.physics.vehicle_controller.VehicleControllerDescription;
const VehicleControllerPtr = basis.physics.vehicle_controller.VehicleControllerPtr;

const VehicleControllerComponent = vhl.components.VehicleControllerComponent;

const MeshPtr = basis.renderer.MeshPtr;
const MaterialPtr = basis.renderer.MaterialPtr;
const MeshInstancePtr = basis.renderer.MeshInstancePtr;

const MaterialResourcePtr = basis.resources.MaterialResourcePtr;
const MeshResourcePtr = basis.resources.MeshResourcePtr;

const SceneNodePtr = basis.math.SceneNodePtr;

const Allocator = std.mem.Allocator;

pub const VehicleWheelRendererComponent = struct {
    const Self = @This();

    pub const RegistrationName = "vhl.VehicleWheelRendererComponent";

    pub const WheelVisuals = struct {
        mesh: MeshPtr,
        material: MaterialPtr,
        meshInstance: MeshInstancePtr,
        sceneNode: SceneNodePtr,
    };

    pub const WheelVisualsList = basis.BoundedArray(WheelVisuals, vehicles.MaxWheelCount);

    //----------------------------------------------------

    context: GameObjectComponent,

    vehicleControllerComponent: *VehicleControllerComponent = undefined,
    vehicleController: VehicleControllerPtr = VehicleControllerPtr.Null,
    wheelVisuals: WheelVisualsList,
    wheelVisualsCreated: bool = false,

    //----------------------------------------------------

    pub fn init(context: GameObjectComponent) !Self {
        return Self{
            .context = context,
            .wheelVisuals = try WheelVisualsList.init(0),
        };
    }

    //pub fn create(_: *Self) !void {}

    pub fn destroy(self: *Self) !void {
        if (self.wheelVisualsCreated) {
            self.destroyWheelVisuals();
        }
    }

    pub fn onObjectCreated(self: *Self) !void {
        var gameObject = self.context.getGameObject();

        {
            const comp = gameObject.getComponent(VehicleControllerComponent);
            basis.assertd(@src(), comp != null, "Vehicle controller component not found.");
            self.vehicleControllerComponent = comp.?;
        }

        self.vehicleController = self.vehicleControllerComponent.controller;
    }

    pub fn tick(self: *Self, tickDeltaTime: f32) !void {
        _ = tickDeltaTime;

        for (self.wheelVisuals.slice(), 0..) |*wheel, i| {
            const wheelInfo = self.vehicleController.getWheelStateInfo(i);

            const pos = wheelInfo.localTransform.position;
            var ori = wheelInfo.localTransform.orientation;

            if (i % 2 != 0) // if side-right wheel
            {
                var rightWheelFlip: basis.math.Quaternion = basis.math.Quaternion.Identity;
                rightWheelFlip.setRotationY(basis.math.Pi);
                ori = rightWheelFlip.concatenate(ori);
            }

            wheel.sceneNode.setPosition(pos);
            wheel.sceneNode.setOrientation(ori);
        }
    }

    pub fn createWheels(
        self: *Self,
        wheelMaterialPaths: []const basis.String,
        wheelMeshPaths: []const basis.String,
    ) void {
        if (self.wheelVisualsCreated) {
            self.destroyWheelVisuals();
        }

        self.createWheelVisuals(wheelMaterialPaths, wheelMeshPaths);
    }

    pub fn setWheelVisible(self: *Self, wheelIndex: u32, visible: bool) void {
        basis.assert(@src(), wheelIndex < self.wheelVisuals.len);
        var wheel: *WheelVisuals = &self.wheelVisuals.slice()[wheelIndex];
        wheel.meshInstance.setVisible(visible);
    }

    //----------------------------------------------------

    fn createWheelVisuals(
        self: *Self,
        wheelMaterialPaths: []const basis.String,
        wheelMeshPaths: []const basis.String,
    ) void {
        basis.assert(@src(), wheelMaterialPaths.len == wheelMeshPaths.len);

        const renderScene = self.context.getRenderer().getPrimaryScene();

        var matResources: [vehicles.MaxWheelCount]MaterialResourcePtr = undefined;
        var meshResources: [vehicles.MaxWheelCount]MeshResourcePtr = undefined;

        const go = self.context.getGameObject();

        for (0..wheelMaterialPaths.len) |i| {
            matResources[i] = basis.resources.resource_manager.acquireResourceOrError(MaterialResourcePtr, wheelMaterialPaths[i].str());
            meshResources[i] = basis.resources.resource_manager.acquireResourceOrError(MeshResourcePtr, wheelMeshPaths[i].str());

            const material = matResources[i].getSharedMaterial();
            const mesh = meshResources[i].getSharedMesh();
            const m = [_]MaterialPtr{material};
            const meshInstance = renderScene.createDynamicMeshInstance(mesh, &m);
            const sceneNode = self.context.transform.getRenderSceneNode().createChildNode();
            sceneNode.attachMeshInstance(meshInstance);

            meshInstance.setFlagValue(.RenderedUsingLightProbeGI, true);

            self.wheelVisuals.append(WheelVisuals{
                .mesh = mesh,
                .material = material,
                .meshInstance = meshInstance,
                .sceneNode = sceneNode,
            }) catch unreachable;

            go.addGameObjectMeshInstanceMapping(meshInstance);
        }

        // Remove references in a separate loop to keep the resources alive during the creation
        // of all wheels even if they all use the same resources.

        for (0..wheelMaterialPaths.len) |i| {
            matResources[i].release();
            meshResources[i].release();
        }

        self.wheelVisualsCreated = true;
    }

    fn destroyWheelVisuals(self: *Self) void {
        basis.assert(@src(), self.wheelVisualsCreated);

        const renderScene = self.context.getRenderer().getPrimaryScene();
        const go = self.context.getGameObject();

        for (self.wheelVisuals.slice()) |*wheel| {
            wheel.sceneNode.detachAll();

            go.removeGameObjectMeshInstanceMapping(wheel.meshInstance);

            renderScene.destroyMeshInstance(wheel.meshInstance);
            renderScene.destroySceneNode(wheel.sceneNode);

            wheel.mesh.release();
            wheel.material.release();
        }

        self.wheelVisuals.len = 0;
        self.wheelVisualsCreated = false;
    }
};
