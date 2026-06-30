// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const MeshGeometrySubMeshPtr = basis.renderer.mesh_geometry.MeshGeometrySubMeshPtr;

const Vec2 = basis.math.Vec2;
const Vec3 = basis.math.Vec3;
const Vec4 = basis.math.Vec4;

pub fn createBox(
    width: f32,
    height: f32,
    depth: f32,
    color: basis.Color,
    target: MeshGeometrySubMeshPtr,
) void {
    target.clear();

    const linearColor = color.toLinearVec4();

    const w2 = 0.5 * width;
    const h2 = 0.5 * height;
    const d2 = 0.5 * depth;

    // Fill in the front face vertex data.
    addVertexInternal(Vec3.init(-w2, -h2, -d2), Vec3.init(0.0, 0.0, -1.0), Vec3.init(1.0, 0.0, 0.0), Vec2.init(0.0, 1.0), linearColor, target);
    addVertexInternal(Vec3.init(-w2, h2, -d2), Vec3.init(0.0, 0.0, -1.0), Vec3.init(1.0, 0.0, 0.0), Vec2.init(0.0, 0.0), linearColor, target);
    addVertexInternal(Vec3.init(w2, h2, -d2), Vec3.init(0.0, 0.0, -1.0), Vec3.init(1.0, 0.0, 0.0), Vec2.init(1.0, 0.0), linearColor, target);
    addVertexInternal(Vec3.init(w2, -h2, -d2), Vec3.init(0.0, 0.0, -1.0), Vec3.init(1.0, 0.0, 0.0), Vec2.init(1.0, 1.0), linearColor, target);

    // Fill in the back face vertex data.
    addVertexInternal(Vec3.init(-w2, -h2, d2), Vec3.init(0.0, 0.0, 1.0), Vec3.init(-1.0, 0.0, 0.0), Vec2.init(1.0, 1.0), linearColor, target);
    addVertexInternal(Vec3.init(w2, -h2, d2), Vec3.init(0.0, 0.0, 1.0), Vec3.init(-1.0, 0.0, 0.0), Vec2.init(0.0, 1.0), linearColor, target);
    addVertexInternal(Vec3.init(w2, h2, d2), Vec3.init(0.0, 0.0, 1.0), Vec3.init(-1.0, 0.0, 0.0), Vec2.init(0.0, 0.0), linearColor, target);
    addVertexInternal(Vec3.init(-w2, h2, d2), Vec3.init(0.0, 0.0, 1.0), Vec3.init(-1.0, 0.0, 0.0), Vec2.init(1.0, 0.0), linearColor, target);

    // Fill in the top face vertex data.
    addVertexInternal(Vec3.init(-w2, h2, -d2), Vec3.init(0.0, 1.0, 0.0), Vec3.init(1.0, 0.0, 0.0), Vec2.init(0.0, 1.0), linearColor, target);
    addVertexInternal(Vec3.init(-w2, h2, d2), Vec3.init(0.0, 1.0, 0.0), Vec3.init(1.0, 0.0, 0.0), Vec2.init(0.0, 0.0), linearColor, target);
    addVertexInternal(Vec3.init(w2, h2, d2), Vec3.init(0.0, 1.0, 0.0), Vec3.init(1.0, 0.0, 0.0), Vec2.init(1.0, 0.0), linearColor, target);
    addVertexInternal(Vec3.init(w2, h2, -d2), Vec3.init(0.0, 1.0, 0.0), Vec3.init(1.0, 0.0, 0.0), Vec2.init(1.0, 1.0), linearColor, target);

    // Fill in the bottom face vertex data.
    addVertexInternal(Vec3.init(-w2, -h2, -d2), Vec3.init(0.0, -1.0, 0.0), Vec3.init(-1.0, 0.0, 0.0), Vec2.init(1.0, 1.0), linearColor, target);
    addVertexInternal(Vec3.init(w2, -h2, -d2), Vec3.init(0.0, -1.0, 0.0), Vec3.init(-1.0, 0.0, 0.0), Vec2.init(0.0, 1.0), linearColor, target);
    addVertexInternal(Vec3.init(w2, -h2, d2), Vec3.init(0.0, -1.0, 0.0), Vec3.init(-1.0, 0.0, 0.0), Vec2.init(0.0, 0.0), linearColor, target);
    addVertexInternal(Vec3.init(-w2, -h2, d2), Vec3.init(0.0, -1.0, 0.0), Vec3.init(-1.0, 0.0, 0.0), Vec2.init(1.0, 0.0), linearColor, target);

    // Fill in the left face vertex data.
    addVertexInternal(Vec3.init(-w2, -h2, d2), Vec3.init(-1.0, 0.0, 0.0), Vec3.init(0.0, 0.0, -1.0), Vec2.init(0.0, 1.0), linearColor, target);
    addVertexInternal(Vec3.init(-w2, h2, d2), Vec3.init(-1.0, 0.0, 0.0), Vec3.init(0.0, 0.0, -1.0), Vec2.init(0.0, 0.0), linearColor, target);
    addVertexInternal(Vec3.init(-w2, h2, -d2), Vec3.init(-1.0, 0.0, 0.0), Vec3.init(0.0, 0.0, -1.0), Vec2.init(1.0, 0.0), linearColor, target);
    addVertexInternal(Vec3.init(-w2, -h2, -d2), Vec3.init(-1.0, 0.0, 0.0), Vec3.init(0.0, 0.0, -1.0), Vec2.init(1.0, 1.0), linearColor, target);

    // Fill in the right face vertex data.
    addVertexInternal(Vec3.init(w2, -h2, -d2), Vec3.init(1.0, 0.0, 0.0), Vec3.init(0.0, 0.0, 1.0), Vec2.init(0.0, 1.0), linearColor, target);
    addVertexInternal(Vec3.init(w2, h2, -d2), Vec3.init(1.0, 0.0, 0.0), Vec3.init(0.0, 0.0, 1.0), Vec2.init(0.0, 0.0), linearColor, target);
    addVertexInternal(Vec3.init(w2, h2, d2), Vec3.init(1.0, 0.0, 0.0), Vec3.init(0.0, 0.0, 1.0), Vec2.init(1.0, 0.0), linearColor, target);
    addVertexInternal(Vec3.init(w2, -h2, d2), Vec3.init(1.0, 0.0, 0.0), Vec3.init(0.0, 0.0, 1.0), Vec2.init(1.0, 1.0), linearColor, target);

    // Create the indices.

    // Fill in the front face index data
    target.addIndex(0);
    target.addIndex(1);
    target.addIndex(2);
    target.addIndex(0);
    target.addIndex(2);
    target.addIndex(3);

    // Fill in the back face index data
    target.addIndex(4);
    target.addIndex(5);
    target.addIndex(6);
    target.addIndex(4);
    target.addIndex(6);
    target.addIndex(7);

    // Fill in the top face index data
    target.addIndex(8);
    target.addIndex(9);
    target.addIndex(10);
    target.addIndex(8);
    target.addIndex(10);
    target.addIndex(11);

    // Fill in the bottom face index data
    target.addIndex(12);
    target.addIndex(13);
    target.addIndex(14);
    target.addIndex(12);
    target.addIndex(14);
    target.addIndex(15);

    // Fill in the left face index data
    target.addIndex(16);
    target.addIndex(17);
    target.addIndex(18);
    target.addIndex(16);
    target.addIndex(18);
    target.addIndex(19);

    // Fill in the right face index data
    target.addIndex(20);
    target.addIndex(21);
    target.addIndex(22);
    target.addIndex(20);
    target.addIndex(22);
    target.addIndex(23);
}

pub fn createSphere(
    radius: f32,
    sliceCount: u32,
    stackCount: u32,
    color: basis.Color,
    target: MeshGeometrySubMeshPtr,
) void {
    target.clear();

    // Compute the vertices stating at the top pole and moving down the stacks.

    // Poles: note that there will be texture coordinate distortion as there is
    // not a unique point on the texture map to assign to the pole when mapping
    // a rectangular texture onto a sphere.

    const linearColor = color.toLinearVec4();

    addVertexInternal(Vec3.init(0.0, radius, 0.0), Vec3.init(0.0, 1.0, 0.0), Vec3.init(1.0, 0.0, 0.0), Vec2.init(0.0, 0.0), linearColor, target);

    const phiStep = basis.math.Pi / @as(f32, @floatFromInt(stackCount));
    const thetaStep = basis.math.TwoPi / @as(f32, @floatFromInt(sliceCount));

    {
        var i: u32 = 1;
        while (i <= stackCount - 1) : (i += 1) {
            const phi = @as(f32, @floatFromInt(i)) * phiStep;

            var j: u32 = 0;
            while (j <= sliceCount) : (j += 1) {
                const theta = @as(f32, @floatFromInt(j)) * thetaStep;

                // Spherical to cartesian.
                const position = Vec3.init(
                    radius * std.math.sin(phi) * std.math.cos(theta),
                    radius * std.math.cos(phi),
                    radius * std.math.sin(phi) * std.math.sin(theta),
                );

                // Partial derivative of P with respect to theta.
                const tangent = Vec3.init(
                    -radius * std.math.sin(phi) * std.math.sin(theta),
                    0.0,
                    radius * std.math.sin(phi) * std.math.cos(theta),
                ).normalized();

                const normal = position.normalized();

                const texcoord = Vec2.init(
                    theta / basis.math.TwoPi,
                    phi / basis.math.Pi,
                );

                addVertexInternal(position, normal, tangent, texcoord, linearColor, target);
            }
        }
    }

    addVertexInternal(Vec3.init(0.0, -radius, 0.0), Vec3.init(0.0, -1.0, 0.0), Vec3.init(1.0, 0.0, 0.0), Vec2.init(0.0, 1.0), linearColor, target);

    // Compute indices for top stack. The top stack was written first to the
    // vertex buffer and connects the top pole to the first ring.

    {
        var i: u32 = 1;
        while (i <= sliceCount) : (i += 1) {
            target.addIndex(0);
            target.addIndex(@intCast(i + 1));
            target.addIndex(@intCast(i));
        }
    }

    // Compute indices for inner stacks (not connected to poles).

    // Offset the indices to the index of the first vertex in the first ring.
    // This is just skipping the top pole vertex.

    var baseIndex: u32 = 1;
    const ringVertexCount: u32 = sliceCount + 1;

    {
        var i: u32 = 0;
        while (i < stackCount - 2) : (i += 1) {
            var j: u32 = 0;
            while (j < sliceCount) : (j += 1) {
                target.addIndexAny(baseIndex + i * ringVertexCount + j);
                target.addIndexAny(baseIndex + i * ringVertexCount + j + 1);
                target.addIndexAny(baseIndex + (i + 1) * ringVertexCount + j);

                target.addIndexAny(baseIndex + (i + 1) * ringVertexCount + j);
                target.addIndexAny(baseIndex + i * ringVertexCount + j + 1);
                target.addIndexAny(baseIndex + (i + 1) * ringVertexCount + j + 1);
            }
        }
    }

    // Compute indices for bottom stack. The bottom stack was written last to the vertex buffer
    // and connects the bottom pole to the bottom ring.

    // South pole vertex was added last.
    const southPoleIndex = target.getVertexCount() - 1;

    // Offset the indices to the index of the first vertex in the last ring.
    baseIndex = southPoleIndex - ringVertexCount;

    {
        var i: u32 = 0;
        while (i < sliceCount) : (i += 1) {
            target.addIndexAny(southPoleIndex);
            target.addIndexAny(baseIndex + i);
            target.addIndexAny(baseIndex + i + 1);
        }
    }
}

//----------------------------------------------------

fn addVertexInternal(
    pos: Vec3,
    normal: Vec3,
    tangent: Vec3,
    uv: Vec2,
    color: Vec4,
    target: MeshGeometrySubMeshPtr,
) void {
    const vertexType = target.getVertexFormatType();
    switch (vertexType) {
        basis.renderer.vertex_formats.VertexFormatType.PositionNormalColor => {
            target.addVertex(basis.renderer.vertex_formats.VertexPositionNormalColor{
                .position = pos,
                .normal = normal,
                .color = color,
            });
        },
        basis.renderer.vertex_formats.VertexFormatType.PositionTangentBinormalNormalTexcoord => {
            target.addVertex(basis.renderer.vertex_formats.VertexPositionTangentBinormalNormalTexcoord{
                .position = pos,
                .tangent = tangent,
                .binormal = normal.cross(tangent).normalized(),
                .normal = normal,
                .texcoord = uv,
            });
        },
        else => basis.assertd(@src(), false, "Vertex type unsupported by the geometry generator."),
    }
}
