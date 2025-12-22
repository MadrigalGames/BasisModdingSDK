// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

pub const ScriptCode = struct {
    const Self = @This();

    pub const FunctionMetadata = struct {
        index: u32,
        label: basis.String,
        flags: i32,
    };

    pub const Template = enum {
        Script,
        Trigger,
    };

    const StringList = basis.ArrayList(basis.String);
    const FunctionMetadataList = basis.ArrayList(FunctionMetadata);

    //----------------------------------------------------

    allocator: std.mem.Allocator,

    sourceCode: StringList,

    byteCodeData: []u8,
    byteCodeSize: usize,

    functionMetadata: FunctionMetadataList,

    //----------------------------------------------------

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .allocator = allocator,
            .sourceCode = StringList.init(allocator),
            .byteCodeData = &[_]u8{},
            .byteCodeSize = 0,
            .functionMetadata = FunctionMetadataList.init(allocator),
        };
    }

    pub fn initTemplate(
        allocator: std.mem.Allocator,
        template: Template,
    ) Self {
        var self = Self{
            .allocator = allocator,
            .sourceCode = StringList.init(allocator),
            .byteCodeData = &[_]u8{},
            .byteCodeSize = 0,
            .functionMetadata = FunctionMetadataList.init(allocator),
        };

        self.setupTemplate(template);
        return self;
    }

    pub fn deinit(self: *Self) void {
        self.clear();
        self.sourceCode.deinit();
        self.functionMetadata.deinit();
    }

    pub fn clear(self: *Self) void {
        for (self.sourceCode.items) |*e| {
            e.deinit();
        }
        self.sourceCode.clearAndFree();

        if (self.byteCodeSize > 0) {
            self.allocator.free(self.byteCodeData);
        }
        self.byteCodeData = &[_]u8{};
        self.byteCodeSize = 0;

        for (self.functionMetadata.items) |*e| {
            e.label.deinit();
        }
        self.functionMetadata.clearAndFree();
    }

    //----------------------------------------------------

    pub fn tryDeserialize(self: *Self, stream: *basis.BinaryReadStream) !void {
        self.clear();

        try stream.deserializeStringArrayList(&self.sourceCode);

        const byteCodeSize = stream.getInt(u64);
        self.byteCodeSize = @intCast(byteCodeSize);

        if (self.byteCodeSize > 0) {
            self.byteCodeData = try self.allocator.alloc(u8, self.byteCodeSize);
            stream.read(self.byteCodeData, self.byteCodeSize);
        } else {
            self.byteCodeData = &[_]u8{};
        }

        const functionMetadataCount: usize = @intCast(stream.getInt(u32));

        try self.functionMetadata.ensureTotalCapacity(functionMetadataCount);

        {
            var i: usize = 0;
            while (i < functionMetadataCount) : (i += 1) {
                const index = stream.getInt(u32);
                var label = basis.String.init(self.allocator);
                try stream.deserializeString(&label);
                const flags = stream.getInt(i32);

                self.functionMetadata.appendAssumeCapacity(.{
                    .index = index,
                    .label = label,
                    .flags = flags,
                });
            }
        }
    }

    pub fn serialize(self: Self, stream: *basis.BinaryWriteStream) void {
        stream.putStringArrayList(self.sourceCode);

        stream.putInt(u64, @intCast(self.byteCodeSize));
        if (self.byteCodeSize > 0) {
            stream.write(self.byteCodeData[0..self.byteCodeSize]);
        }

        stream.putInt(u32, @intCast(self.functionMetadata.items.len));

        for (self.functionMetadata.items) |e| {
            stream.putInt(u32, e.index);
            stream.putString(e.label.str());
            stream.putInt(i32, e.flags);
        }
    }

    //----------------------------------------------------

    fn setupTemplate(self: *Self, template: Template) void {
        self.clear();

        switch (template) {
            Template.Script => {
                const lines = [_][]const u8{
                    "void onCreate()",
                    "{",
                    "    // Will get called when the object is created.",
                    "}",
                    "",
                    "void onMessage(const gameobject &in sender, const string &in message, const messageparameters &in params)",
                    "{",
                    "    // Will get called when a script message arrives.",
                    "}",
                    "",
                    "void onDestroy()",
                    "{",
                    "    // Will get called when the object is destroyed.",
                    "}",
                    "",
                };

                self.sourceCode.ensureTotalCapacity(lines.len) catch unreachable;

                for (lines) |line| {
                    const s = basis.string.init(self.allocator, line);
                    self.sourceCode.appendAssumeCapacity(s);
                }
            },
            Template.Trigger => {
                const lines = [_][]const u8{
                    "void onCreate()",
                    "{",
                    "    // Will get called when the object is created.",
                    "}",
                    "",
                    "void onObjectEntered(const gameobject &in object)",
                    "{",
                    "    // Will get called when a game object enters the trigger volume.",
                    "}",
                    "",
                    "void onObjectExited(const gameobject &in object)",
                    "{",
                    "    // Will get called when a game object exits the trigger volume.",
                    "}",
                    "",
                };

                self.sourceCode.ensureTotalCapacity(lines.len) catch unreachable;

                for (lines) |line| {
                    const s = basis.string.init(self.allocator, line);
                    self.sourceCode.appendAssumeCapacity(s);
                }
            },
        }
    }
};
