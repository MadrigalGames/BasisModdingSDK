// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

const ObjectMap = std.json.ObjectMap;

pub fn getFloatMember(object: *const ObjectMap, name: []const u8) f32 {
    basis.assertf(@src(), object.contains(name), "The float member '{s}' is missing.", .{name});
    return @as(f32, @floatCast(object.get(name).?.float));
}

pub fn getUint32Member(object: *const ObjectMap, name: []const u8) u32 {
    basis.assertf(@src(), object.contains(name), "The uint32 member '{s}' is missing.", .{name});
    return @as(u32, @intCast(object.get(name).?.integer));
}

pub fn getInt32Member(object: *const ObjectMap, name: []const u8) i32 {
    basis.assertf(@src(), object.contains(name), "The int32 member '{s}' is missing.", .{name});
    return @as(i32, @intCast(object.get(name).?.integer));
}

pub fn getBoolMember(object: *const ObjectMap, name: []const u8) bool {
    basis.assertf(@src(), object.contains(name), "The bool member '{s}' is missing.", .{name});
    return object.get(name).?.bool;
}

pub fn getStringMember(object: *const ObjectMap, name: []const u8) []const u8 {
    basis.assertf(@src(), object.contains(name), "The string member '{s}' is missing.", .{name});
    return object.get(name).?.string;
}

pub fn getArrayMember(object: *const ObjectMap, name: []const u8) std.json.Array {
    basis.assertf(@src(), object.contains(name), "The array member '{s}' is missing.", .{name});
    return object.get(name).?.array;
}

pub fn getVec2Member(object: *const ObjectMap, name: []const u8) basis.math.Vec2 {
    basis.assertf(@src(), object.contains(name), "The vec2 member '{s}' is missing.", .{name});
    return basis.math.Vec2.initFromJsonArray(object.get(name).?.array);
}

pub fn getVec3Member(object: *const ObjectMap, name: []const u8) basis.math.Vec3 {
    basis.assertf(@src(), object.contains(name), "The vec3 member '{s}' is missing.", .{name});
    return basis.math.Vec3.initFromJsonArray(object.get(name).?.array);
}

pub fn getVec4Member(object: *const ObjectMap, name: []const u8) basis.math.Vec4 {
    basis.assertf(@src(), object.contains(name), "The vec4 member '{s}' is missing.", .{name});
    return basis.math.Vec4.initFromJsonArray(object.get(name).?.array);
}

pub fn getEnumMember(comptime T: type, object: *const ObjectMap, name: []const u8) !T {
    basis.assertf(@src(), object.contains(name), "The enum member '{s}' is missing.", .{name});
    const strValue = object.get(name).?.string;
    if (std.meta.stringToEnum(T, strValue)) |e| {
        return e;
    }

    return error.NotPartOfEnum;
}
