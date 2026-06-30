// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

// Property layouts are only ever read from the main thread, so we can use a global temp buffer.
const TEMP_BUFFER_SIZE = 256 * 1024;
var tempBuffer: [TEMP_BUFFER_SIZE]u8 = undefined;

pub const ExposedPropertyLayoutReaderPtr = struct {
    const Self = @This();

    cppPtr: basis.CppPtr,
    allocator: std.mem.Allocator,

    pub fn init(self: *const Self, version: i32) void {
        basis.bindings.api.ExposedPropertyLayoutReader_init(self.cppPtr, version);
    }

    pub fn processProperty(self: *const Self, comptime T: type, name: []const u8, defaultValue: T, versionAdded: i32, options: []const u8) void {
        var stream = basis.binary_stream.BinaryWriteStream.init(&tempBuffer, true);

        switch (T) {
            f32 => {
                stream.putFloat(defaultValue);
            },
            f64 => @compileError("Exposed properties of type f64 not currently supported."),
            i8, u8, i16, u16, i32, u32, i64, u64 => {
                stream.putInt(T, defaultValue);
            },
            bool => {
                stream.putBool(defaultValue);
            },
            else => {
                stream.put(T, defaultValue);
            },
        }

        const defaultValueSerializedLength = @as(u32, @intCast(stream.cursorPosition));

        const interopName = basis.string.toInteropString(name);
        const interopOptions = basis.string.toInteropString(options);

        const typeID = basis.typeinfo.getTypeID(T);

        basis.bindings.api.ExposedPropertyLayoutReader_processProperty(self.cppPtr, &interopName, typeID.asInt(), &tempBuffer[0], defaultValueSerializedLength, versionAdded, &interopOptions);
    }

    pub fn processString(self: *const Self, name: []const u8, defaultValue: []const u8, versionAdded: i32, options: []const u8) void {
        const interopName = basis.string.toInteropString(name);
        const interopDefaultValue = basis.string.toInteropString(defaultValue);
        const interopOptions = basis.string.toInteropString(options);

        basis.bindings.api.ExposedPropertyLayoutReader_processString(self.cppPtr, &interopName, &interopDefaultValue, versionAdded, &interopOptions);
    }

    pub fn processResourceRef(self: *const Self, name: []const u8, resourceTypeID: basis.typeinfo.ResourceTypeID, defaultValue: []const u8, versionAdded: i32, options: []const u8) void {
        const interopName = basis.string.toInteropString(name);
        const interopDefaultValue = basis.string.toInteropString(defaultValue);
        const interopOptions = basis.string.toInteropString(options);

        basis.bindings.api.ExposedPropertyLayoutReader_processResourceRef(self.cppPtr, &interopName, resourceTypeID.asInt(), &interopDefaultValue, versionAdded, &interopOptions);
    }

    pub fn processGameObjectRef(self: *const Self, name: []const u8, defaultValue: []const u8, versionAdded: i32, options: []const u8) void {
        var stream = basis.binary_stream.BinaryWriteStream.init(&tempBuffer, true);

        // We "fake" writing a GameObjectRef here in order to not have to provide an allocator just to create a temp GameObjectRef.
        basis.game_object.GameObjectRef.serializeStatic(
            defaultValue,
            basis.string.makeStringHash(defaultValue),
            &stream,
        );

        const defaultValueSerializedLength = @as(u32, @intCast(stream.cursorPosition));

        const interopName = basis.string.toInteropString(name);
        const interopOptions = basis.string.toInteropString(options);

        const typeID = basis.typeinfo.TypeID.BASIS_TYPE_GAME_OBJECT_REF;

        basis.bindings.api.ExposedPropertyLayoutReader_processProperty(self.cppPtr, &interopName, typeID.asInt(), &tempBuffer[0], defaultValueSerializedLength, versionAdded, &interopOptions);
    }

    pub fn processScriptCode(self: *const Self, name: []const u8, template: basis.angelscript.ScriptCode.Template, versionAdded: i32, options: []const u8) void {
        var stream = basis.binary_stream.BinaryWriteStream.init(&tempBuffer, true);

        var sc = basis.angelscript.ScriptCode.initTemplate(self.allocator, template);
        sc.serialize(&stream);
        sc.deinit();

        const defaultValueSerializedLength = @as(u32, @intCast(stream.cursorPosition));

        const interopName = basis.string.toInteropString(name);
        const interopOptions = basis.string.toInteropString(options);

        const typeID = basis.typeinfo.TypeID.BASIS_TYPE_SCRIPT_CODE;

        basis.bindings.api.ExposedPropertyLayoutReader_processProperty(self.cppPtr, &interopName, typeID.asInt(), &tempBuffer[0], defaultValueSerializedLength, versionAdded, &interopOptions);
    }

    pub fn processEnum(self: *const Self, comptime T: type, name: []const u8, defaultValue: T, versionAdded: i32, options: []const u8) void {
        const valueCount = @as(u32, @intCast(@typeInfo(T).@"enum".fields.len));

        const defaultInt = @intFromEnum(defaultValue);
        if (@TypeOf(defaultInt) != u32) {
            @compileError("Enums used as exposed properties must be backed by the u32 data type.");
        }

        var names: [valueCount]basis.bindings.InteropString = undefined;
        var integrals: [valueCount]u32 = undefined;

        inline for (@typeInfo(T).@"enum".fields, 0..) |enumField, i| {
            names[i] = basis.string.toInteropString(enumField.name);
            integrals[i] = @as(u32, @intCast(enumField.value));
        }

        const interopName = basis.string.toInteropString(name);
        const interopOptions = basis.string.toInteropString(options);

        basis.bindings.api.ExposedPropertyLayoutReader_processEnum(self.cppPtr, &interopName, defaultInt, &names[0], &integrals[0], valueCount, versionAdded, &interopOptions);
    }

    pub fn processButton(self: *const Self, actionID: []const u8, actionName: []const u8, buttonText: []const u8, options: []const u8) void {
        const interopActionID = basis.string.toInteropString(actionID);
        const interopActionName = basis.string.toInteropString(actionName);
        const interopButtonText = basis.string.toInteropString(buttonText);
        const interopOptions = basis.string.toInteropString(options);

        basis.bindings.api.ExposedPropertyLayoutReader_processButton(self.cppPtr, &interopActionID, &interopActionName, &interopButtonText, &interopOptions);
    }

    pub fn processCategory(self: *const Self, categoryName: []const u8, displayName: []const u8, options: []const u8) void {
        const interopCategoryName = basis.string.toInteropString(categoryName);
        const interopDisplayName = basis.string.toInteropString(displayName);
        const interopOptions = basis.string.toInteropString(options);

        basis.bindings.api.ExposedPropertyLayoutReader_processCategory(self.cppPtr, &interopCategoryName, &interopDisplayName, &interopOptions);
    }

    pub fn allPropertiesProcessed(self: *const Self) void {
        basis.bindings.api.ExposedPropertyLayoutReader_allPropertiesProcessed(self.cppPtr);
    }

    //----------------------------------------------------
};
