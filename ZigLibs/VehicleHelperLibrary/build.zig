// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");

// NOTE! This build file is here solely to help zls find the source files
// of the used packages, eg. basis. You shouldn't build this library on its own.

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    var lib = b.addLibrary(.{
        .name = "VHL",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/vhl.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    // These paths are relative to the build file (ie. this file):

    const basisModule = b.createModule(.{
        .root_source_file = b.path("../../Basis/zig/src/basis.zig"),
    });

    lib.root_module.addImport("basis", basisModule);

    b.installArtifact(lib);
}
