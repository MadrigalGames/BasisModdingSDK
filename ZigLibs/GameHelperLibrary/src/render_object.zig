// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const basis = @import("basis");

const RendererPtr = basis.renderer.RendererPtr;
const RenderScenePtr = basis.renderer.RenderScenePtr;
const MeshPtr = basis.renderer.MeshPtr;
const MaterialPtr = basis.renderer.MaterialPtr;
const MeshInstancePtr = basis.renderer.MeshInstancePtr;
const MeshGeometryPtr = basis.renderer.mesh_geometry.MeshGeometryPtr;

const SceneNodePtr = basis.math.SceneNodePtr;

const MeshResourcePtr = basis.resources.MeshResourcePtr;
const MaterialResourcePtr = basis.resources.MaterialResourcePtr;

const GameObjectPtr = basis.game_object.GameObjectPtr;

// A helper struct for encapsulating the data needed to put a mesh instance into a render scene.
pub const RenderObject = struct {
    const Self = @This();

    pub const MeshInstanceType = enum {
        Movable, // Dynamic mesh instance (ie. it can be moved around).
        Immovable, // Static mesh instance (ie. it can be moved around (esp. in the editors) but it is supposed to be stationary in the game.
        ImmovableBVH, // Static mesh instance placed into the BVH (ie. it shouldn't be moved around without rebuilding the BVH).
    };

    pub const ManualMeshData = struct {
        vertexFormatType: basis.renderer.vertex_formats.VertexFormatType,
        vertexCount: u32,
        indexCount: u32,
    };

    // The mesh data can come from any of the following:
    pub const MeshSourceTag = enum {
        meshResourcePath,
        meshGeometryMutable,
        meshGeometryImmutable,
        manualMesh,
    };
    pub const MeshSource = union(MeshSourceTag) {
        meshResourcePath: []const u8,
        meshGeometryMutable: MeshGeometryPtr,
        meshGeometryImmutable: MeshGeometryPtr,
        manualMesh: ManualMeshData,
    };

    //----------------------------------------------------

    renderer: RendererPtr = .Null,
    renderScene: RenderScenePtr = .Null,

    mesh: MeshPtr = .Null,
    material: MaterialPtr = .Null,
    materialResource: MaterialResourcePtr = .Null,

    sceneNode: SceneNodePtr = .Null,
    hasDedicatedNode: bool = false,

    meshInstance: MeshInstancePtr = .Null,
    meshInstanceType: MeshInstanceType = .Movable,

    gameObject: ?GameObjectPtr = null,

    //----------------------------------------------------

    /// Create a new Render Object. If parentNode is not null, the mesh instance is
    /// attached to that node, otherwise it is attached to the scene root node. If
    /// createDedicatedNode is true, a new scene node is created under the parentNode
    /// (or root if parentNode is null) and the mesh is attached to the new scene
    /// node, which is also automatically destroyed in deinit().
    pub fn init(
        renderer: RendererPtr,
        meshInstanceType: MeshInstanceType,
        meshSource: MeshSource,
        materialResourcePath: []const u8,
        parentNode: ?SceneNodePtr,
        createDedicatedNode: bool,
        gameObject: ?GameObjectPtr,
    ) Self {
        var self = Self{
            .renderer = renderer,
            .renderScene = renderer.getPrimaryScene(),
            .hasDedicatedNode = createDedicatedNode,
            .gameObject = gameObject,
        };

        if (parentNode != null) {
            self.sceneNode = if (createDedicatedNode)
                parentNode.?.createChildNode()
            else
                parentNode.?;
        } else {
            self.sceneNode = if (createDedicatedNode)
                self.renderScene.getRootSceneNode().createChildNode()
            else
                self.renderScene.getRootSceneNode();
        }

        self.initInternal(meshInstanceType, meshSource, materialResourcePath);

        return self;
    }

    // Call this if the resources have been updated, to update the render object.
    pub fn reloadResources(self: *Self) void {
        self.deinitMeshInstance();
        self.material.releaseAndZero();

        self.material = self.materialResource.getSharedMaterial();
        self.initMeshInstance();

        // TODO: If the mesh source is a mesh resource, refresh the mesh here too.
    }

    pub fn deinit(self: *Self) void {
        if (!self.isInitialized()) return;
        self.deinitInternal();
    }

    pub fn isInitialized(self: *const Self) bool {
        // If the mesh instance is null we assume the object never got initialized.
        return !self.meshInstance.isNull();
    }

    //----------------------------------------------------

    fn initInternal(self: *Self, meshInstanceType: MeshInstanceType, meshSource: MeshSource, materialResourcePath: []const u8) void {
        switch (meshSource) {
            MeshSourceTag.meshResourcePath => |val| {
                const meshRes = basis.resources.resource_manager.acquireResourceOrError(
                    MeshResourcePtr,
                    val,
                );
                self.mesh = meshRes.getSharedMesh();
                meshRes.release();
            },
            MeshSourceTag.meshGeometryMutable => |val| {
                self.mesh = self.renderer.createMesh(
                    val,
                    false,
                    "Mutable RenderObject mesh",
                );
            },
            MeshSourceTag.meshGeometryImmutable => |val| {
                self.mesh = self.renderer.createMesh(
                    val,
                    true,
                    "Immutable RenderObject mesh",
                );
            },
            MeshSourceTag.manualMesh => |val| {
                self.mesh = self.renderer.createMeshManual(
                    val.vertexFormatType,
                    val.vertexCount,
                    val.indexCount,
                    "Manual RenderObject mesh",
                );
            },
        }

        self.materialResource = basis.resources.resource_manager.acquireResourceOrError(
            MaterialResourcePtr,
            materialResourcePath,
        );
        self.material = self.materialResource.getSharedMaterial();

        self.meshInstanceType = meshInstanceType;
        self.initMeshInstance();
    }

    fn deinitInternal(self: *Self) void {
        self.deinitMeshInstance();

        if (self.hasDedicatedNode) {
            self.renderScene.destroySceneNode(self.sceneNode);
        }

        self.mesh.releaseAndZero();
        self.material.releaseAndZero();

        self.renderer = .Null;
        self.renderScene = .Null;
        self.sceneNode = .Null;
        self.hasDedicatedNode = false;
        self.meshInstance = .Null;

        self.materialResource.releaseAndZero();
    }

    //----------------------------------------------------

    fn initMeshInstance(self: *Self) void {
        const m = [_]MaterialPtr{self.material};

        self.meshInstance = if (self.meshInstanceType == .Movable)
            self.renderScene.createDynamicMeshInstance(self.mesh, &m)
        else
            self.renderScene.createStaticMeshInstance(self.mesh, &m, self.meshInstanceType == .ImmovableBVH);

        if (self.gameObject) |go| {
            go.addGameObjectMeshInstanceMapping(self.meshInstance);
        }

        self.sceneNode.attachMeshInstance(self.meshInstance);
    }

    fn deinitMeshInstance(self: *Self) void {
        self.sceneNode.detachMeshInstance(self.meshInstance);

        if (self.gameObject) |go| {
            go.removeGameObjectMeshInstanceMapping(self.meshInstance);
        }

        self.renderScene.destroyMeshInstance(self.meshInstance);
    }
};
