// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const basis = @import("basis");

const RendererPtr = basis.renderer.RendererPtr;
const MeshPtr = basis.renderer.MeshPtr;
const MeshGeometryPtr = basis.renderer.mesh_geometry.MeshGeometryPtr;

const Vec3 = basis.math.Vec3;
const Color = basis.Color;

const BinaryReadStream = basis.BinaryReadStream;
const BinaryWriteStream = basis.BinaryWriteStream;

//----------------------------------------------------

pub const VertexFormatType = basis.renderer.vertex_formats.VertexFormatType.PositionNormalColor;
pub const VertexFormat = basis.renderer.vertex_formats.VertexPositionNormalColor;

const VertexSerializedSize = blk: {
    var buffer: [128]u8 = undefined;
    var stream = basis.BinaryWriteStream.init(&buffer, true);
    const v = VertexFormat{ .position = Vec3.Zero, .normal = Vec3.UnitX, .color = basis.math.Vec4.Zero };
    stream.put(VertexFormat, v);
    break :blk stream.cursorPosition;
};

pub const TriangleLinePoint = struct {
    const Self = @This();

    position: Vec3 = Vec3.Zero,
    normal: Vec3 = Vec3.UnitY,
    width: f32 = 1.0,
    color: Color = Color.White,

    // If [hasTwoColors] is false, only [color] is used. If it is true, [color] is
    // used for the left side and [color2] for the right side of the quad.
    hasTwoColors: bool = false,
    color2: Color = Color.Black,

    //----------------------------------------------------

    pub fn deserialize(
        self: *Self,
        stream: *BinaryReadStream,
    ) void {
        self.position = stream.get(Vec3);
        self.normal = stream.get(Vec3);
        self.width = stream.getFloat();
        self.color = stream.get(Color);
        self.hasTwoColors = stream.getBool();
        self.color2 = stream.get(Color);
    }

    pub fn serialize(
        self: *const Self,
        stream: *BinaryWriteStream,
    ) void {
        stream.put(Vec3, self.position);
        stream.put(Vec3, self.normal);
        stream.putFloat(self.width);
        stream.put(Color, self.color);
        stream.putBool(self.hasTwoColors);
        stream.put(Color, self.color2);
    }
};

//----------------------------------------------------

pub fn addLine(mesh: MeshPtr, p0: TriangleLinePoint, p1: TriangleLinePoint) void {
    const lodLevel = mesh.getLodLevel(0);
    const subMesh = lodLevel.getSubMesh(0);

    const vertices = subMesh.getVertices();
    var stream = basis.BinaryWriteStream.init(vertices, true);
    stream.cursorPosition = VertexSerializedSize * subMesh.getVertexCount();

    // The direction the line is going in this quad.
    const lineVector = p1.position.sub(p0.position).normalized();

    const startEdgeVector = lineVector.cross(p0.normal).normalized();
    const endEdgeVector = lineVector.cross(p1.normal).normalized();

    var v0: VertexFormat = undefined;
    v0.color = p0.color.toLinearVec4();
    v0.position = p0.position.add(startEdgeVector.multiplyFloat(p0.width * 0.5));
    v0.normal = p0.normal;

    var v1: VertexFormat = undefined;
    v1.color = p1.color.toLinearVec4();
    v1.position = p1.position.add(endEdgeVector.multiplyFloat(p1.width * 0.5));
    v1.normal = p1.normal;

    var v2: VertexFormat = undefined;
    v2.color = if (p0.hasTwoColors) p0.color2.toLinearVec4() else v0.color;
    v2.position = p0.position.sub(startEdgeVector.multiplyFloat(p0.width * 0.5));
    v2.normal = p0.normal;

    var v3: VertexFormat = undefined;
    v3.color = if (p1.hasTwoColors) p1.color2.toLinearVec4() else v1.color;
    v3.position = p1.position.sub(endEdgeVector.multiplyFloat(p1.width * 0.5));
    v3.normal = p1.normal;

    var bounds = basis.math.AABB.initEmpty();
    bounds.addAABB(lodLevel.getBounds());
    bounds.addPoint(v0.position);
    bounds.addPoint(v1.position);
    bounds.addPoint(v2.position);
    bounds.addPoint(v3.position);
    lodLevel.setBounds(bounds);

    stream.put(VertexFormat, v0);
    stream.put(VertexFormat, v1);
    stream.put(VertexFormat, v2);

    stream.put(VertexFormat, v2);
    stream.put(VertexFormat, v1);
    stream.put(VertexFormat, v3);

    subMesh.setVertexCount(subMesh.getVertexCount() + 6);
}

pub fn addMultiPointLine(mesh: MeshPtr, points: []const TriangleLinePoint, closedLoop: bool) void {
    if (points.len == 2) {
        addLine(mesh, points[0], points[1]);
        return;
    }

    const lodLevel = mesh.getLodLevel(0);
    const subMesh = lodLevel.getSubMesh(0);

    const vertices = subMesh.getVertices();
    var stream = basis.BinaryWriteStream.init(vertices, true);

    const newQuadCount = points.len - 1;

    var firstEdgeVector = Vec3.Zero;
    var prevEdgeVector = Vec3.Zero;

    for (0..newQuadCount) |i| {
        const p0 = points[i];
        const p1 = points[i + 1];

        basis.assert(@src(), basis.math.floatsAlmostEqual(p0.normal.squaredLength(), 1.0));
        basis.assert(@src(), basis.math.floatsAlmostEqual(p1.normal.squaredLength(), 1.0));

        // The direction the line is going in this quad.
        const lineVector = p1.position.sub(p0.position).normalized();

        // Two vectors to hold the directions of the start and end edges of the quad.
        // For the first quad, start edge is perpendicular to the line vector. The same goes
        // for the end edge of the last quad (unless closedLoop is true, in which
        // case the first and last edge are made parallel). For all edges in between, they
        // are averaged between the adjacent quads (ie. made parallel).
        var startEdgeVector = Vec3.Zero;
        var endEdgeVector = Vec3.Zero;

        if (i == 0) {
            // First quad.

            startEdgeVector = lineVector.cross(p0.normal).normalized();

            if (closedLoop) {
                const lastPoint = points[points.len - 1];
                const nextToLastPoint = points[points.len - 2];

                const lastLineVector = lastPoint.position.sub(nextToLastPoint.position).normalized();
                const lastEdgeVector = lastLineVector.cross(lastPoint.normal).normalized();

                startEdgeVector = (startEdgeVector.add(lastEdgeVector)).multiplyFloat(0.5);
                firstEdgeVector = startEdgeVector;
            }

            // Look ahead to the next point.
            const p2 = points[i + 2];

            const nextLineVector = p2.position.sub(p1.position).normalized();
            const unaveragedEndEdgeVector = lineVector.cross(p1.normal).normalized();
            const nextStartEdgeVector = nextLineVector.cross(p2.normal).normalized();

            endEdgeVector = (unaveragedEndEdgeVector.add(nextStartEdgeVector)).multiplyFloat(0.5);
            prevEdgeVector = endEdgeVector;
        } else if (i == newQuadCount - 1) {
            // Last quad.

            startEdgeVector = prevEdgeVector;

            if (closedLoop) {
                endEdgeVector = firstEdgeVector;
            } else {
                endEdgeVector = lineVector.cross(p1.normal).normalized();
            }
        } else {
            startEdgeVector = prevEdgeVector;

            // Look ahead to the next point.
            const p2 = points[i + 2];

            const nextLineVector = p2.position.sub(p1.position).normalized();
            const unaveragedEndEdgeVector = lineVector.cross(p1.normal).normalized();
            const nextStartEdgeVector = nextLineVector.cross(p2.normal).normalized();

            endEdgeVector = (unaveragedEndEdgeVector.add(nextStartEdgeVector)).multiplyFloat(0.5);
            prevEdgeVector = endEdgeVector;
        }

        var v0: VertexFormat = undefined;
        v0.color = p0.color.toLinearVec4();
        v0.position = p0.position.add(startEdgeVector.multiplyFloat(p0.width * 0.5));
        v0.normal = p0.normal;

        var v1: VertexFormat = undefined;
        v1.color = p1.color.toLinearVec4();
        v1.position = p1.position.add(endEdgeVector.multiplyFloat(p1.width * 0.5));
        v1.normal = p1.normal;

        var v2: VertexFormat = undefined;
        v2.color = if (p0.hasTwoColors) p0.color2.toLinearVec4() else v0.color;
        v2.position = p0.position.sub(startEdgeVector.multiplyFloat(p0.width * 0.5));
        v2.normal = p0.normal;

        var v3: VertexFormat = undefined;
        v3.color = if (p1.hasTwoColors) p1.color2.toLinearVec4() else v1.color;
        v3.position = p1.position.sub(endEdgeVector.multiplyFloat(p1.width * 0.5));
        v3.normal = p1.normal;

        var bounds = basis.math.AABB.initEmpty();
        bounds.addAABB(lodLevel.getBounds());
        bounds.addPoint(v0.position);
        bounds.addPoint(v1.position);
        bounds.addPoint(v2.position);
        bounds.addPoint(v3.position);
        lodLevel.setBounds(bounds);

        stream.put(VertexFormat, v0);
        stream.put(VertexFormat, v1);
        stream.put(VertexFormat, v2);

        stream.put(VertexFormat, v2);
        stream.put(VertexFormat, v1);
        stream.put(VertexFormat, v3);

        subMesh.setVertexCount(subMesh.getVertexCount() + 6);
    }
}
