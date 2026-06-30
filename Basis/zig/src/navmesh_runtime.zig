// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

const Vec3 = basis.math.Vec3;

pub const NavMeshQueryResult = enum(i32) {
    OK = 0,
    OKIgnoringSoftObstacles,
    InProgress,
    CouldNotFindPolygon,
    CouldNotFindPath,
    Error,
    InvalidNavMesh,
};

pub const NavMeshID = enum(u32) {
    Main = 0,
    Aux1 = 1,
    Aux2 = 2,
    Aux3 = 3,
    Aux4 = 4,
};

pub const NavMeshAreaType = enum(u32) {
    Null = 0, // Must match RC_NULL_AREA in Recast.h
    Ground = 1,
    Water = 2,
    Road = 3,
    Door = 4,
    Grass = 5,
    Jump = 6,
    RoadMinor = 7,
    Walkable = 63, // Must match RC_WALKABLE_AREA in Recast.h. This is the maximum allowed area ID.
};

pub const MaxNavMeshCount = std.enums.values(NavMeshID).len;

pub const NavMeshObstacleID = u32;
pub const InvalidNavMeshObstacleID = 0xFFFFFFFF;

pub const NavMeshObstacleType = enum(u32) {
    Hard = 0, // An obstacle which cannot be ignored, such as a door, blocking the way.
    Soft, // An obstacle which can be ignored, if it is the only way to find a path.
};

//----------------------------------------------------

pub const NavMeshQueryFilter = struct {
    pub const MaxAreaCount = 64; // Must be the same as DT_MAX_AREAS in DetourNavMesh.h
    //----------------------------------------------------
    areaCost: [MaxAreaCount]f32 = @splat(1.0), // Cost per area type.
    includeFlags: u16 = 0xFFFF, // Flags for polygons that can be visited.
    excludeFlags: u16 = 0, // Flags for polygons that should not be visited.

    pub fn toInterop(
        self: *const NavMeshQueryFilter,
        interopFilter: *basis.bindings.InteropNavMeshQueryFilter,
    ) void {
        for (0..NavMeshQueryFilter.MaxAreaCount) |i| {
            interopFilter.areaCost[i] = self.areaCost[i];
        }
        interopFilter.includeFlags = self.includeFlags;
        interopFilter.excludeFlags = self.excludeFlags;
    }
};

//----------------------------------------------------

// Temp storage used by findPath() & co below.
const FINDPATH_MAX_ARRAY_SIZE: u32 = 128;
threadlocal var findPath_tempStorage: [FINDPATH_MAX_ARRAY_SIZE]basis.bindings.InteropVec3 = undefined;

//----------------------------------------------------

// Queries.

pub fn hasNavMesh(navMeshID: NavMeshID) bool {
    return basis.bindings.api.NavMeshRuntime_hasNavMesh(@intFromEnum(navMeshID));
}

/// Finds a path from the start point to the end point, using the given parameters, and stores the result in [pathArray].
pub fn findPath(navMeshID: NavMeshID, startPoint: Vec3, endPoint: Vec3, pathArray: []Vec3, pathLength: *u32, searchBoxSize: f32) NavMeshQueryResult {
    const filter = NavMeshQueryFilter{};
    return findPathWithFilter(navMeshID, startPoint, endPoint, filter, pathArray, pathLength, searchBoxSize, &.{});
}

/// Finds a path from the start point to the end point, using the given parameters, and stores the result in [pathArray].
pub fn findPathWithFilter(
    navMeshID: NavMeshID,
    startPoint: Vec3,
    endPoint: Vec3,
    filter: NavMeshQueryFilter,
    pathArray: []Vec3,
    pathLength: *u32,
    searchBoxSize: f32,
    ignoredSoftObstacles: []const NavMeshObstacleID,
) NavMeshQueryResult {
    if (!hasNavMesh(navMeshID)) {
        return NavMeshQueryResult.InvalidNavMesh;
    }

    const safePathArraySize: u32 = @min(pathArray.len, FINDPATH_MAX_ARRAY_SIZE);

    const sp = startPoint.toInterop();
    const ep = endPoint.toInterop();

    var interopFilter: basis.bindings.InteropNavMeshQueryFilter = undefined;
    filter.toInterop(&interopFilter);

    const ignoredSoftObstaclesPtr: [*c]const u32 = if (ignoredSoftObstacles.len > 0) ignoredSoftObstacles.ptr else null;

    const result: NavMeshQueryResult = @enumFromInt(basis.bindings.api.NavMeshRuntime_findPath(
        @intFromEnum(navMeshID),
        &sp,
        &ep,
        &interopFilter,
        &findPath_tempStorage,
        safePathArraySize,
        pathLength,
        searchBoxSize,
        ignoredSoftObstaclesPtr,
        @intCast(ignoredSoftObstacles.len),
    ));

    if (result == .OK or result == .OKIgnoringSoftObstacles) {
        for (0..pathLength.*) |i| {
            pathArray[i] = Vec3.fromInterop(findPath_tempStorage[i]);
        }
    }

    return result;
}

/// Same as findPath() but only checks if a path exists and returns its length.
pub fn checkPath(navMeshID: NavMeshID, startPoint: Vec3, endPoint: Vec3, pathLength: *u32, searchBoxSize: f32) NavMeshQueryResult {
    const filter = NavMeshQueryFilter{};
    return checkPathWithFilter(navMeshID, startPoint, endPoint, filter, pathLength, searchBoxSize, &.{});
}

/// Same as findPathWithFilter() but only checks if a path exists and returns its length.
pub fn checkPathWithFilter(
    navMeshID: NavMeshID,
    startPoint: Vec3,
    endPoint: Vec3,
    filter: NavMeshQueryFilter,
    pathLength: *u32,
    searchBoxSize: f32,
    ignoredSoftObstacles: []const NavMeshObstacleID,
) NavMeshQueryResult {
    if (!hasNavMesh(navMeshID)) {
        return NavMeshQueryResult.InvalidNavMesh;
    }

    const safePathArraySize: u32 = FINDPATH_MAX_ARRAY_SIZE;

    const sp = startPoint.toInterop();
    const ep = endPoint.toInterop();

    var interopFilter: basis.bindings.InteropNavMeshQueryFilter = undefined;
    filter.toInterop(&interopFilter);

    const ignoredSoftObstaclesPtr: [*c]const u32 = if (ignoredSoftObstacles.len > 0) ignoredSoftObstacles.ptr else null;

    const result: NavMeshQueryResult = @enumFromInt(basis.bindings.api.NavMeshRuntime_findPath(
        @intFromEnum(navMeshID),
        &sp,
        &ep,
        &interopFilter,
        &findPath_tempStorage,
        safePathArraySize,
        pathLength,
        searchBoxSize,
        ignoredSoftObstaclesPtr,
        @intCast(ignoredSoftObstacles.len),
    ));

    return result;
}

pub fn findClosestPointOnNavMesh(navMeshID: NavMeshID, center: Vec3, result: *Vec3, searchBoxSize: f32) NavMeshQueryResult {
    if (!hasNavMesh(navMeshID)) {
        return NavMeshQueryResult.InvalidNavMesh;
    }

    const c = center.toInterop();

    var interopResult: basis.bindings.InteropVec3 = undefined;

    const queryResult: NavMeshQueryResult = @enumFromInt(basis.bindings.api.NavMeshRuntime_findClosestPointOnNavMesh(
        @intFromEnum(navMeshID),
        &c,
        &interopResult,
        searchBoxSize,
    ));

    if (queryResult == .OK or queryResult == .OKIgnoringSoftObstacles) {
        result.* = Vec3.fromInterop(interopResult);
    }

    return queryResult;
}

pub fn findRandomPointAroundCircle(navMeshID: NavMeshID, center: Vec3, maxRadius: f32, result: *Vec3, searchBoxSize: f32) NavMeshQueryResult {
    if (!hasNavMesh(navMeshID)) {
        return NavMeshQueryResult.InvalidNavMesh;
    }

    const c = center.toInterop();

    var interopResult: basis.bindings.InteropVec3 = undefined;

    const queryResult: NavMeshQueryResult = @enumFromInt(basis.bindings.api.NavMeshRuntime_findRandomPointAroundCircle(
        @intFromEnum(navMeshID),
        &c,
        maxRadius,
        &interopResult,
        searchBoxSize,
    ));

    if (queryResult == .OK or queryResult == .OKIgnoringSoftObstacles) {
        result.* = Vec3.fromInterop(interopResult);
    }

    return queryResult;
}

pub fn overlapsNavMesh(navMeshID: NavMeshID, center: Vec3, searchBoxSize: Vec3) bool {
    const filter = NavMeshQueryFilter{};
    return overlapsNavMeshWithFilter(navMeshID, center, filter, searchBoxSize);
}

pub fn overlapsNavMeshWithFilter(navMeshID: NavMeshID, center: Vec3, filter: NavMeshQueryFilter, searchBoxSize: Vec3) bool {
    if (!hasNavMesh(navMeshID)) {
        return false;
    }

    const c = center.toInterop();
    const sbs = searchBoxSize.toInterop();

    var interopFilter: basis.bindings.InteropNavMeshQueryFilter = undefined;
    filter.toInterop(&interopFilter);

    const res = basis.bindings.api.NavMeshRuntime_overlapsNavMesh(@intFromEnum(navMeshID), &c, &interopFilter, &sbs);
    return res == 1;
}

//----------------------------------------------------

// Obstacles.

pub fn addObstacle(navMeshID: NavMeshID, radius: f32, obstacleType: NavMeshObstacleType, initialPosition: Vec3, initialLinearVelocity: Vec3) NavMeshObstacleID {
    const ip = initialPosition.toInterop();
    const ilv = initialLinearVelocity.toInterop();
    return basis.bindings.api.NavMeshRuntime_addObstacle(@intFromEnum(navMeshID), radius, @intFromEnum(obstacleType), &ip, &ilv);
}

pub fn updateObstacle(navMeshID: NavMeshID, obstacleID: NavMeshObstacleID, position: Vec3, linearVelocity: Vec3) void {
    const p = position.toInterop();
    const lv = linearVelocity.toInterop();
    basis.bindings.api.NavMeshRuntime_updateObstacle(@intFromEnum(navMeshID), obstacleID, &p, &lv);
}

pub fn removeObstacle(navMeshID: NavMeshID, obstacleID: NavMeshObstacleID) void {
    basis.bindings.api.NavMeshRuntime_removeObstacle(@intFromEnum(navMeshID), obstacleID);
}
