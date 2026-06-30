// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

// The null IO implementation is there just to have something we can pass to the engine on
// platforms that don't have readily available IO implementations, such as WASM freestanding.
// Using any of the functionality results in an assert failure.

pub const NullIo = struct {
    pub fn io(self: *NullIo) std.Io {
        return .{
            .userdata = self,
            .vtable = &.{
                .async = async,
                .concurrent = concurrent,
                .await = await,
                .cancel = cancel,
                .select = select,

                .groupAsync = groupAsync,
                .groupConcurrent = groupConcurrent,
                .groupAwait = groupAwait,
                .groupCancel = groupCancel,

                .recancel = recancel,
                .swapCancelProtection = swapCancelProtection,
                .checkCancel = checkCancel,

                .futexWait = futexWait,
                .futexWaitUncancelable = futexWaitUncancelable,
                .futexWake = futexWake,

                .operate = operate,
                .batchAwaitAsync = batchAwaitAsync,
                .batchAwaitConcurrent = batchAwaitConcurrent,
                .batchCancel = batchCancel,

                .dirCreateDir = dirCreateDir,
                .dirCreateDirPath = dirCreateDirPath,
                .dirCreateDirPathOpen = dirCreateDirPathOpen,
                .dirStat = dirStat,
                .dirStatFile = dirStatFile,
                .dirAccess = dirAccess,
                .dirCreateFile = dirCreateFile,
                .dirCreateFileAtomic = dirCreateFileAtomic,
                .dirOpenFile = dirOpenFile,
                .dirOpenDir = dirOpenDir,
                .dirClose = dirClose,
                .dirRead = dirRead,
                .dirRealPath = dirRealPath,
                .dirRealPathFile = dirRealPathFile,
                .dirDeleteFile = dirDeleteFile,
                .dirDeleteDir = dirDeleteDir,
                .dirRename = dirRename,
                .dirRenamePreserve = dirRenamePreserve,
                .dirSymLink = dirSymLink,
                .dirReadLink = dirReadLink,
                .dirSetOwner = dirSetOwner,
                .dirSetFileOwner = dirSetFileOwner,
                .dirSetPermissions = dirSetPermissions,
                .dirSetFilePermissions = dirSetFilePermissions,
                .dirSetTimestamps = dirSetTimestamps,
                .dirHardLink = dirHardLink,

                .fileStat = fileStat,
                .fileLength = fileLength,
                .fileClose = fileClose,
                .fileWritePositional = fileWritePositional,
                .fileWriteFileStreaming = fileWriteFileStreaming,
                .fileWriteFilePositional = fileWriteFilePositional,
                .fileReadPositional = fileReadPositional,
                .fileSeekBy = fileSeekBy,
                .fileSeekTo = fileSeekTo,
                .fileSync = fileSync,
                .fileIsTty = fileIsTty,
                .fileEnableAnsiEscapeCodes = fileEnableAnsiEscapeCodes,
                .fileSupportsAnsiEscapeCodes = fileSupportsAnsiEscapeCodes,
                .fileSetLength = fileSetLength,
                .fileSetOwner = fileSetOwner,
                .fileSetPermissions = fileSetPermissions,
                .fileSetTimestamps = fileSetTimestamps,
                .fileLock = fileLock,
                .fileTryLock = fileTryLock,
                .fileUnlock = fileUnlock,
                .fileDowngradeLock = fileDowngradeLock,
                .fileRealPath = fileRealPath,
                .fileHardLink = fileHardLink,

                .fileMemoryMapCreate = fileMemoryMapCreate,
                .fileMemoryMapDestroy = fileMemoryMapDestroy,
                .fileMemoryMapSetLength = fileMemoryMapSetLength,
                .fileMemoryMapRead = fileMemoryMapRead,
                .fileMemoryMapWrite = fileMemoryMapWrite,

                .processExecutableOpen = processExecutableOpen,
                .processExecutablePath = processExecutablePath,
                .lockStderr = lockStderr,
                .tryLockStderr = tryLockStderr,
                .unlockStderr = unlockStderr,
                .processCurrentPath = processCurrentPath,
                .processSetCurrentDir = processSetCurrentDir,
                .processReplace = processReplace,
                .processReplacePath = processReplacePath,
                .processSpawn = processSpawn,
                .processSpawnPath = processSpawnPath,
                .childWait = childWait,
                .childKill = childKill,

                .progressParentFile = progressParentFile,

                .now = now,
                .clockResolution = clockResolution,
                .sleep = sleep,

                .random = random,
                .randomSecure = randomSecure,

                .netListenIp = netListenIp,
                .netListenUnix = netListenUnix,
                .netAccept = netAccept,
                .netBindIp = netBindIp,
                .netConnectIp = netConnectIp,
                .netSocketCreatePair = netSocketCreatePair,
                .netConnectUnix = netConnectUnix,
                .netClose = netClose,
                .netShutdown = netShutdown,
                .netRead = netRead,
                .netWrite = netWrite,
                .netWriteFile = netWriteFile,
                .netSend = netSend,
                .netReceive = netReceive,
                .netInterfaceNameResolve = netInterfaceNameResolve,
                .netInterfaceName = netInterfaceName,
                .netLookup = netLookup,
            },
        };
    }

    pub fn deinit(self: *NullIo) void {
        _ = self;
    }
};

//----------------------------------------------------

fn async(
    userdata: ?*anyopaque,
    result: []u8,
    result_alignment: std.mem.Alignment,
    context: []const u8,
    context_alignment: std.mem.Alignment,
    start: *const fn (context: *const anyopaque, result: *anyopaque) void,
) ?*std.Io.AnyFuture {
    _ = userdata;
    _ = result;
    _ = result_alignment;
    _ = context;
    _ = context_alignment;
    _ = start;
    basis.assertd(@src(), false, "Basis null IO: concurrent() called");
    unreachable;
}

fn concurrent(
    userdata: ?*anyopaque,
    result_len: usize,
    result_alignment: std.mem.Alignment,
    context: []const u8,
    context_alignment: std.mem.Alignment,
    start: *const fn (context: *const anyopaque, result: *anyopaque) void,
) std.Io.ConcurrentError!*std.Io.AnyFuture {
    _ = userdata;
    _ = result_len;
    _ = result_alignment;
    _ = context;
    _ = context_alignment;
    _ = start;
    basis.assertd(@src(), false, "Basis null IO: concurrent() called");
    unreachable;
}

fn await(
    userdata: ?*anyopaque,
    any_future: *std.Io.AnyFuture,
    result: []u8,
    result_alignment: std.mem.Alignment,
) void {
    _ = userdata;
    _ = any_future;
    _ = result;
    _ = result_alignment;
    basis.assertd(@src(), false, "Basis null IO: await() called");
    unreachable;
}

fn cancel(
    userdata: ?*anyopaque,
    any_future: *std.Io.AnyFuture,
    result: []u8,
    result_alignment: std.mem.Alignment,
) void {
    _ = userdata;
    _ = any_future;
    _ = result;
    _ = result_alignment;
    basis.assertd(@src(), false, "Basis null IO: cancel() called");
    unreachable;
}

fn select(userdata: ?*anyopaque, futures: []const *std.Io.AnyFuture) std.Io.Cancelable!usize {
    _ = userdata;
    _ = futures;
    basis.assertd(@src(), false, "Basis null IO: select() called");
    unreachable;
}

fn groupAsync(
    userdata: ?*anyopaque,
    type_erased: *std.Io.Group,
    context: []const u8,
    context_alignment: std.mem.Alignment,
    start: *const fn (context: *const anyopaque) std.Io.Cancelable!void,
) void {
    _ = userdata;
    _ = type_erased;
    _ = context;
    _ = context_alignment;
    _ = start;
    basis.assertd(@src(), false, "Basis null IO: groupAsync() called");
    unreachable;
}

fn groupConcurrent(
    userdata: ?*anyopaque,
    type_erased: *std.Io.Group,
    context: []const u8,
    context_alignment: std.mem.Alignment,
    start: *const fn (context: *const anyopaque) std.Io.Cancelable!void,
) std.Io.ConcurrentError!void {
    _ = userdata;
    _ = type_erased;
    _ = context;
    _ = context_alignment;
    _ = start;
    basis.assertd(@src(), false, "Basis null IO: groupConcurrent() called");
    unreachable;
}

fn groupAwait(userdata: ?*anyopaque, type_erased: *std.Io.Group, initial_token: *anyopaque) std.Io.Cancelable!void {
    _ = userdata;
    _ = type_erased;
    _ = initial_token;
    basis.assertd(@src(), false, "Basis null IO: groupAwait() called");
    unreachable;
}

fn groupCancel(userdata: ?*anyopaque, type_erased: *std.Io.Group, initial_token: *anyopaque) void {
    _ = userdata;
    _ = type_erased;
    _ = initial_token;
    basis.assertd(@src(), false, "Basis null IO: groupCancel() called");
    unreachable;
}

fn recancel(userdata: ?*anyopaque) void {
    _ = userdata;
    basis.assertd(@src(), false, "Basis null IO: recancel() called");
    unreachable;
}

fn recancelInner() void {
    basis.assertd(@src(), false, "Basis null IO: recancelInner() called");
    unreachable;
}

fn swapCancelProtection(userdata: ?*anyopaque, new: std.Io.CancelProtection) std.Io.CancelProtection {
    _ = userdata;
    _ = new;
    basis.assertd(@src(), false, "Basis null IO: swapCancelProtection() called");
    unreachable;
}

fn checkCancel(userdata: ?*anyopaque) std.Io.Cancelable!void {
    _ = userdata;
    basis.assertd(@src(), false, "Basis null IO: checkCancel() called");
    unreachable;
}

fn futexWait(userdata: ?*anyopaque, ptr: *const u32, expected: u32, timeout: std.Io.Timeout) std.Io.Cancelable!void {
    _ = userdata;
    _ = ptr;
    _ = expected;
    _ = timeout;
    basis.assertd(@src(), false, "Basis null IO: futexWait() called");
    unreachable;
}

fn futexWaitUncancelable(userdata: ?*anyopaque, ptr: *const u32, expected: u32) void {
    _ = userdata;
    _ = ptr;
    _ = expected;
    basis.assertd(@src(), false, "Basis null IO: futexWaitUncancelable() called");
    unreachable;
}

fn futexWake(userdata: ?*anyopaque, ptr: *const u32, max_waiters: u32) void {
    _ = userdata;
    _ = ptr;
    _ = max_waiters;
    basis.assertd(@src(), false, "Basis null IO: futexWake() called");
    unreachable;
}

fn operate(userdata: ?*anyopaque, operation: std.Io.Operation) std.Io.Cancelable!std.Io.Operation.Result {
    _ = userdata;
    _ = operation;
    basis.assertd(@src(), false, "Basis null IO: operate() called");
    unreachable;
}

fn batchAwaitAsync(userdata: ?*anyopaque, b: *std.Io.Batch) std.Io.Cancelable!void {
    _ = userdata;
    _ = b;
    basis.assertd(@src(), false, "Basis null IO: batchAwaitAsync() called");
    unreachable;
}

fn batchAwaitConcurrent(userdata: ?*anyopaque, b: *std.Io.Batch, timeout: std.Io.Timeout) std.Io.Batch.AwaitConcurrentError!void {
    _ = userdata;
    _ = b;
    _ = timeout;
    basis.assertd(@src(), false, "Basis null IO: batchAwaitConcurrent() called");
    unreachable;
}

fn batchCancel(userdata: ?*anyopaque, b: *std.Io.Batch) void {
    _ = userdata;
    _ = b;
    basis.assertd(@src(), false, "Basis null IO: batchCancel() called");
    unreachable;
}

fn dirCreateDir(userdata: ?*anyopaque, dir: std.Io.Dir, sub_path: []const u8, permissions: std.Io.Dir.Permissions) std.Io.Dir.CreateDirError!void {
    _ = userdata;
    _ = dir;
    _ = sub_path;
    _ = permissions;
    basis.assertd(@src(), false, "Basis null IO: dirCreateDir() called");
    unreachable;
}

fn dirCreateDirPath(
    userdata: ?*anyopaque,
    dir: std.Io.Dir,
    sub_path: []const u8,
    permissions: std.Io.Dir.Permissions,
) std.Io.Dir.CreateDirPathError!std.Io.Dir.CreatePathStatus {
    _ = userdata;
    _ = dir;
    _ = sub_path;
    _ = permissions;
    basis.assertd(@src(), false, "Basis null IO: dirCreateDirPath() called");
    unreachable;
}

fn dirCreateDirPathOpen(
    userdata: ?*anyopaque,
    dir: std.Io.Dir,
    sub_path: []const u8,
    permissions: std.Io.Dir.Permissions,
    options: std.Io.Dir.OpenOptions,
) std.Io.Dir.CreateDirPathOpenError!std.Io.Dir {
    _ = userdata;
    _ = dir;
    _ = sub_path;
    _ = permissions;
    _ = options;
    basis.assertd(@src(), false, "Basis null IO: dirCreateDirPathOpen() called");
    unreachable;
}

fn dirStat(userdata: ?*anyopaque, dir: std.Io.Dir) std.Io.Dir.StatError!std.Io.Dir.Stat {
    _ = userdata;
    _ = dir;
    basis.assertd(@src(), false, "Basis null IO: dirStat() called");
    unreachable;
}

fn dirStatFile(
    userdata: ?*anyopaque,
    dir: std.Io.Dir,
    sub_path: []const u8,
    options: std.Io.Dir.StatFileOptions,
) std.Io.Dir.StatFileError!std.Io.File.Stat {
    _ = userdata;
    _ = dir;
    _ = sub_path;
    _ = options;
    basis.assertd(@src(), false, "Basis null IO: dirStatFile() called");
    unreachable;
}

fn dirAccess(
    userdata: ?*anyopaque,
    dir: std.Io.Dir,
    sub_path: []const u8,
    options: std.Io.Dir.AccessOptions,
) std.Io.Dir.AccessError!void {
    _ = userdata;
    _ = dir;
    _ = sub_path;
    _ = options;
    basis.assertd(@src(), false, "Basis null IO: dirAccess() called");
    unreachable;
}

fn dirCreateFile(
    userdata: ?*anyopaque,
    dir: std.Io.Dir,
    sub_path: []const u8,
    flags: std.Io.File.CreateFlags,
) std.Io.File.OpenError!std.Io.File {
    _ = userdata;
    _ = dir;
    _ = sub_path;
    _ = flags;
    basis.assertd(@src(), false, "Basis null IO: dirCreateFile() called");
    unreachable;
}

fn dirCreateFileAtomic(
    userdata: ?*anyopaque,
    dir: std.Io.Dir,
    dest_path: []const u8,
    options: std.Io.Dir.CreateFileAtomicOptions,
) std.Io.Dir.CreateFileAtomicError!std.Io.File.Atomic {
    _ = userdata;
    _ = dir;
    _ = dest_path;
    _ = options;
    basis.assertd(@src(), false, "Basis null IO: dirCreateFileAtomic() called");
    unreachable;
}

fn dirOpenFile(
    userdata: ?*anyopaque,
    dir: std.Io.Dir,
    sub_path: []const u8,
    flags: std.Io.File.OpenFlags,
) std.Io.File.OpenError!std.Io.File {
    _ = userdata;
    _ = dir;
    _ = sub_path;
    _ = flags;
    basis.assertd(@src(), false, "Basis null IO: dirOpenFile() called");
    unreachable;
}

fn dirOpenDir(
    userdata: ?*anyopaque,
    dir: std.Io.Dir,
    sub_path: []const u8,
    options: std.Io.Dir.OpenOptions,
) std.Io.Dir.OpenError!std.Io.Dir {
    _ = userdata;
    _ = dir;
    _ = sub_path;
    _ = options;
    basis.assertd(@src(), false, "Basis null IO: dirOpenDir() called");
    unreachable;
}

fn dirClose(userdata: ?*anyopaque, dirs: []const std.Io.Dir) void {
    _ = userdata;
    _ = dirs;
    basis.assertd(@src(), false, "Basis null IO: dirClose() called");
    unreachable;
}

fn dirRead(userdata: ?*anyopaque, dr: *std.Io.Dir.Reader, buffer: []std.Io.Dir.Entry) std.Io.Dir.Reader.Error!usize {
    _ = userdata;
    _ = dr;
    _ = buffer;
    basis.assertd(@src(), false, "Basis null IO: dirRead() called");
    unreachable;
}

fn dirRealPath(userdata: ?*anyopaque, dir: std.Io.Dir, out_buffer: []u8) std.Io.Dir.RealPathError!usize {
    _ = userdata;
    _ = dir;
    _ = out_buffer;
    basis.assertd(@src(), false, "Basis null IO: dirRealPathFile() called");
    unreachable;
}

fn dirRealPathFile(userdata: ?*anyopaque, dir: std.Io.Dir, sub_path: []const u8, out_buffer: []u8) std.Io.Dir.RealPathFileError!usize {
    _ = userdata;
    _ = dir;
    _ = sub_path;
    _ = out_buffer;
    basis.assertd(@src(), false, "Basis null IO: dirRealPathFile() called");
    unreachable;
}

fn dirDeleteFile(userdata: ?*anyopaque, dir: std.Io.Dir, sub_path: []const u8) std.Io.Dir.DeleteFileError!void {
    _ = userdata;
    _ = dir;
    _ = sub_path;
    basis.assertd(@src(), false, "Basis null IO: dirDeleteFile() called");
    unreachable;
}

fn dirDeleteDir(userdata: ?*anyopaque, dir: std.Io.Dir, sub_path: []const u8) std.Io.Dir.DeleteDirError!void {
    _ = userdata;
    _ = dir;
    _ = sub_path;
    basis.assertd(@src(), false, "Basis null IO: dirDeleteDir() called");
    unreachable;
}

fn dirRename(
    userdata: ?*anyopaque,
    old_dir: std.Io.Dir,
    old_sub_path: []const u8,
    new_dir: std.Io.Dir,
    new_sub_path: []const u8,
) std.Io.Dir.RenameError!void {
    _ = userdata;
    _ = old_dir;
    _ = old_sub_path;
    _ = new_dir;
    _ = new_sub_path;
    basis.assertd(@src(), false, "Basis null IO: dirRename() called");
    unreachable;
}

fn dirRenamePreserve(
    userdata: ?*anyopaque,
    old_dir: std.Io.Dir,
    old_sub_path: []const u8,
    new_dir: std.Io.Dir,
    new_sub_path: []const u8,
) std.Io.Dir.RenamePreserveError!void {
    _ = userdata;
    _ = old_dir;
    _ = old_sub_path;
    _ = new_dir;
    _ = new_sub_path;
    basis.assertd(@src(), false, "Basis null IO: dirRenamePreserve() called");
    unreachable;
}

fn dirSymLink(
    userdata: ?*anyopaque,
    dir: std.Io.Dir,
    target_path: []const u8,
    sym_link_path: []const u8,
    flags: std.Io.Dir.SymLinkFlags,
) std.Io.Dir.SymLinkError!void {
    _ = userdata;
    _ = dir;
    _ = target_path;
    _ = sym_link_path;
    _ = flags;
    basis.assertd(@src(), false, "Basis null IO: dirSymLink() called");
    unreachable;
}

fn dirReadLink(userdata: ?*anyopaque, dir: std.Io.Dir, sub_path: []const u8, buffer: []u8) std.Io.Dir.ReadLinkError!usize {
    _ = userdata;
    _ = dir;
    _ = sub_path;
    _ = buffer;
    basis.assertd(@src(), false, "Basis null IO: dirReadLink() called");
    unreachable;
}

fn dirSetOwner(userdata: ?*anyopaque, dir: std.Io.Dir, owner: ?std.Io.File.Uid, group: ?std.Io.File.Gid) std.Io.Dir.SetOwnerError!void {
    _ = userdata;
    _ = dir;
    _ = owner;
    _ = group;
    basis.assertd(@src(), false, "Basis null IO: dirSetOwner() called");
    unreachable;
}

fn dirSetFileOwner(
    userdata: ?*anyopaque,
    dir: std.Io.Dir,
    sub_path: []const u8,
    owner: ?std.Io.File.Uid,
    group: ?std.Io.File.Gid,
    options: std.Io.Dir.SetFileOwnerOptions,
) std.Io.Dir.SetFileOwnerError!void {
    _ = userdata;
    _ = dir;
    _ = sub_path;
    _ = owner;
    _ = group;
    _ = options;
    basis.assertd(@src(), false, "Basis null IO: dirSetFileOwner() called");
    unreachable;
}

fn dirSetPermissions(userdata: ?*anyopaque, dir: std.Io.Dir, permissions: std.Io.Dir.Permissions) std.Io.Dir.SetPermissionsError!void {
    _ = userdata;
    _ = dir;
    _ = permissions;
    basis.assertd(@src(), false, "Basis null IO: dirSetPermissions() called");
    unreachable;
}

fn dirSetFilePermissions(
    userdata: ?*anyopaque,
    dir: std.Io.Dir,
    sub_path: []const u8,
    permissions: std.Io.Dir.Permissions,
    options: std.Io.Dir.SetFilePermissionsOptions,
) std.Io.Dir.SetFilePermissionsError!void {
    _ = userdata;
    _ = dir;
    _ = sub_path;
    _ = permissions;
    _ = options;
    basis.assertd(@src(), false, "Basis null IO: dirSetFilePermissions() called");
    unreachable;
}

fn dirSetTimestamps(
    userdata: ?*anyopaque,
    dir: std.Io.Dir,
    sub_path: []const u8,
    options: std.Io.Dir.SetTimestampsOptions,
) std.Io.Dir.SetTimestampsError!void {
    _ = userdata;
    _ = dir;
    _ = sub_path;
    _ = options;
    basis.assertd(@src(), false, "Basis null IO: dirSetTimestamps() called");
    unreachable;
}

fn dirHardLink(
    userdata: ?*anyopaque,
    old_dir: std.Io.Dir,
    old_sub_path: []const u8,
    new_dir: std.Io.Dir,
    new_sub_path: []const u8,
    options: std.Io.Dir.HardLinkOptions,
) std.Io.Dir.HardLinkError!void {
    _ = userdata;
    _ = old_dir;
    _ = old_sub_path;
    _ = new_dir;
    _ = new_sub_path;
    _ = options;
    basis.assertd(@src(), false, "Basis null IO: dirHardLink() called");
    unreachable;
}

fn fileStat(userdata: ?*anyopaque, file: std.Io.File) std.Io.File.StatError!std.Io.File.Stat {
    _ = userdata;
    _ = file;
    basis.assertd(@src(), false, "Basis null IO: fileStat() called");
    unreachable;
}

fn fileLength(userdata: ?*anyopaque, file: std.Io.File) std.Io.File.LengthError!u64 {
    _ = userdata;
    _ = file;
    basis.assertd(@src(), false, "Basis null IO: fileLength() called");
    unreachable;
}

fn fileClose(userdata: ?*anyopaque, files: []const std.Io.File) void {
    _ = userdata;
    _ = files;
    basis.assertd(@src(), false, "Basis null IO: fileClose() called");
    unreachable;
}

fn fileWritePositional(
    userdata: ?*anyopaque,
    file: std.Io.File,
    header: []const u8,
    data: []const []const u8,
    splat: usize,
    offset: u64,
) std.Io.File.WritePositionalError!usize {
    _ = userdata;
    _ = file;
    _ = header;
    _ = data;
    _ = splat;
    _ = offset;
    basis.assertd(@src(), false, "Basis null IO: fileWritePositional() called");
    unreachable;
}

fn fileWriteFileStreaming(
    userdata: ?*anyopaque,
    file: std.Io.File,
    header: []const u8,
    file_reader: *std.Io.File.Reader,
    limit: std.Io.Limit,
) std.Io.File.Writer.WriteFileError!usize {
    _ = userdata;
    _ = file;
    _ = header;
    _ = file_reader;
    _ = limit;
    basis.assertd(@src(), false, "Basis null IO: fileWriteFileStreaming() called");
    unreachable;
}

fn fileWriteFilePositional(
    userdata: ?*anyopaque,
    file: std.Io.File,
    header: []const u8,
    file_reader: *std.Io.File.Reader,
    limit: std.Io.Limit,
    offset: u64,
) std.Io.File.WriteFilePositionalError!usize {
    _ = userdata;
    _ = file;
    _ = header;
    _ = file_reader;
    _ = limit;
    _ = offset;
    basis.assertd(@src(), false, "Basis null IO: fileWriteFilePositional() called");
    unreachable;
}

fn fileReadPositional(userdata: ?*anyopaque, file: std.Io.File, data: []const []u8, offset: u64) std.Io.File.ReadPositionalError!usize {
    _ = userdata;
    _ = file;
    _ = data;
    _ = offset;
    basis.assertd(@src(), false, "Basis null IO: fileReadPositional() called");
    unreachable;
}

fn fileSeekBy(userdata: ?*anyopaque, file: std.Io.File, offset: i64) std.Io.File.SeekError!void {
    _ = userdata;
    _ = file;
    _ = offset;
    basis.assertd(@src(), false, "Basis null IO: fileSeekBy() called");
    unreachable;
}

fn fileSeekTo(userdata: ?*anyopaque, file: std.Io.File, offset: u64) std.Io.File.SeekError!void {
    _ = userdata;
    _ = file;
    _ = offset;
    basis.assertd(@src(), false, "Basis null IO: fileSeekTo() called");
    unreachable;
}

fn fileSync(userdata: ?*anyopaque, file: std.Io.File) std.Io.File.SyncError!void {
    _ = userdata;
    _ = file;
    basis.assertd(@src(), false, "Basis null IO: fileSync() called");
    unreachable;
}

fn fileIsTty(userdata: ?*anyopaque, file: std.Io.File) std.Io.Cancelable!bool {
    _ = userdata;
    _ = file;
    basis.assertd(@src(), false, "Basis null IO: fileIsTty() called");
    unreachable;
}

fn fileEnableAnsiEscapeCodes(userdata: ?*anyopaque, file: std.Io.File) std.Io.File.EnableAnsiEscapeCodesError!void {
    _ = userdata;
    _ = file;
    basis.assertd(@src(), false, "Basis null IO: fileEnableAnsiEscapeCodes() called");
    unreachable;
}

fn fileSupportsAnsiEscapeCodes(userdata: ?*anyopaque, file: std.Io.File) std.Io.Cancelable!bool {
    _ = userdata;
    _ = file;
    basis.assertd(@src(), false, "Basis null IO: fileSupportsAnsiEscapeCodes() called");
    unreachable;
}

fn fileSetLength(userdata: ?*anyopaque, file: std.Io.File, length: u64) std.Io.File.SetLengthError!void {
    _ = userdata;
    _ = file;
    _ = length;
    basis.assertd(@src(), false, "Basis null IO: fileSetLength() called");
    unreachable;
}

fn fileSetOwner(userdata: ?*anyopaque, file: std.Io.File, owner: ?std.Io.File.Uid, group: ?std.Io.File.Gid) std.Io.File.SetOwnerError!void {
    _ = userdata;
    _ = file;
    _ = owner;
    _ = group;
    basis.assertd(@src(), false, "Basis null IO: fileSetOwner() called");
    unreachable;
}

fn fileSetPermissions(userdata: ?*anyopaque, file: std.Io.File, permissions: std.Io.File.Permissions) std.Io.File.SetPermissionsError!void {
    _ = userdata;
    _ = file;
    _ = permissions;
    basis.assertd(@src(), false, "Basis null IO: fileSetPermissions() called");
    unreachable;
}

fn fileSetTimestamps(
    userdata: ?*anyopaque,
    file: std.Io.File,
    options: std.Io.File.SetTimestampsOptions,
) std.Io.File.SetTimestampsError!void {
    _ = userdata;
    _ = file;
    _ = options;
    basis.assertd(@src(), false, "Basis null IO: fileSetTimestamps() called");
    unreachable;
}

fn fileLock(userdata: ?*anyopaque, file: std.Io.File, lock: std.Io.File.Lock) std.Io.File.LockError!void {
    _ = userdata;
    _ = file;
    _ = lock;
    basis.assertd(@src(), false, "Basis null IO: fileLock() called");
    unreachable;
}

fn fileTryLock(userdata: ?*anyopaque, file: std.Io.File, lock: std.Io.File.Lock) std.Io.File.LockError!bool {
    _ = userdata;
    _ = file;
    _ = lock;
    basis.assertd(@src(), false, "Basis null IO: fileTryLock() called");
    unreachable;
}

fn fileUnlock(userdata: ?*anyopaque, file: std.Io.File) void {
    _ = userdata;
    _ = file;
    basis.assertd(@src(), false, "Basis null IO: fileUnlock() called");
    unreachable;
}

fn fileDowngradeLock(userdata: ?*anyopaque, file: std.Io.File) std.Io.File.DowngradeLockError!void {
    _ = userdata;
    _ = file;
    basis.assertd(@src(), false, "Basis null IO: fileDowngradeLock() called");
    unreachable;
}

fn fileRealPath(userdata: ?*anyopaque, file: std.Io.File, out_buffer: []u8) std.Io.File.RealPathError!usize {
    _ = userdata;
    _ = file;
    _ = out_buffer;
    basis.assertd(@src(), false, "Basis null IO: fileRealPath() called");
    unreachable;
}

fn fileHardLink(
    userdata: ?*anyopaque,
    file: std.Io.File,
    new_dir: std.Io.Dir,
    new_sub_path: []const u8,
    options: std.Io.File.HardLinkOptions,
) std.Io.File.HardLinkError!void {
    _ = userdata;
    _ = file;
    _ = new_dir;
    _ = new_sub_path;
    _ = options;
    basis.assertd(@src(), false, "Basis null IO: fileHardLink() called");
    unreachable;
}

fn fileMemoryMapCreate(
    userdata: ?*anyopaque,
    file: std.Io.File,
    options: std.Io.File.MemoryMap.CreateOptions,
) std.Io.File.MemoryMap.CreateError!std.Io.File.MemoryMap {
    _ = userdata;
    _ = file;
    _ = options;
    basis.assertd(@src(), false, "Basis null IO: fileMemoryMapCreate() called");
    unreachable;
}

fn fileMemoryMapDestroy(userdata: ?*anyopaque, mm: *std.Io.File.MemoryMap) void {
    _ = userdata;
    _ = mm;
    basis.assertd(@src(), false, "Basis null IO: fileMemoryMapDestroy() called");
    unreachable;
}

fn fileMemoryMapSetLength(
    userdata: ?*anyopaque,
    mm: *std.Io.File.MemoryMap,
    new_len: usize,
) std.Io.File.MemoryMap.SetLengthError!void {
    _ = userdata;
    _ = mm;
    _ = new_len;
    basis.assertd(@src(), false, "Basis null IO: fileMemoryMapSetLength() called");
    unreachable;
}

fn fileMemoryMapRead(userdata: ?*anyopaque, mm: *std.Io.File.MemoryMap) std.Io.File.ReadPositionalError!void {
    _ = userdata;
    _ = mm;
    basis.assertd(@src(), false, "Basis null IO: fileMemoryMapRead() called");
    unreachable;
}

fn fileMemoryMapWrite(userdata: ?*anyopaque, mm: *std.Io.File.MemoryMap) std.Io.File.WritePositionalError!void {
    _ = userdata;
    _ = mm;
    basis.assertd(@src(), false, "Basis null IO: fileMemoryMapWrite() called");
    unreachable;
}

fn processExecutableOpen(userdata: ?*anyopaque, flags: std.Io.File.OpenFlags) std.process.OpenExecutableError!std.Io.File {
    _ = userdata;
    _ = flags;
    basis.assertd(@src(), false, "Basis null IO: processExecutableOpen() called");
    unreachable;
}

fn processExecutablePath(userdata: ?*anyopaque, out_buffer: []u8) std.process.ExecutablePathError!usize {
    _ = userdata;
    _ = out_buffer;
    basis.assertd(@src(), false, "Basis null IO: processExecutablePath() called");
    unreachable;
}

fn lockStderr(userdata: ?*anyopaque, terminal_mode: ?std.Io.Terminal.Mode) std.Io.Cancelable!std.Io.LockedStderr {
    _ = userdata;
    _ = terminal_mode;
    basis.assertd(@src(), false, "Basis null IO: lockStderr() called");
    unreachable;
}

fn tryLockStderr(userdata: ?*anyopaque, terminal_mode: ?std.Io.Terminal.Mode) std.Io.Cancelable!?std.Io.LockedStderr {
    _ = userdata;
    _ = terminal_mode;
    basis.assertd(@src(), false, "Basis null IO: tryLockStderr() called");
    unreachable;
}

fn unlockStderr(userdata: ?*anyopaque) void {
    _ = userdata;
    basis.assertd(@src(), false, "Basis null IO: unlockStderr() called");
    unreachable;
}

fn processCurrentPath(userdata: ?*anyopaque, buffer: []u8) std.process.CurrentPathError!usize {
    _ = userdata;
    _ = buffer;
    basis.assertd(@src(), false, "Basis null IO: processCurrentPath() called");
    unreachable;
}

fn processSetCurrentDir(userdata: ?*anyopaque, dir: std.Io.Dir) std.process.SetCurrentDirError!void {
    _ = userdata;
    _ = dir;
    basis.assertd(@src(), false, "Basis null IO: processSetCurrentDir() called");
    unreachable;
}

fn processReplace(userdata: ?*anyopaque, options: std.process.ReplaceOptions) std.process.ReplaceError {
    _ = userdata;
    _ = options;
    basis.assertd(@src(), false, "Basis null IO: processReplace() called");
    unreachable;
}

fn processReplacePath(userdata: ?*anyopaque, dir: std.Io.Dir, options: std.process.ReplaceOptions) std.process.ReplaceError {
    _ = userdata;
    _ = dir;
    _ = options;
    basis.assertd(@src(), false, "Basis null IO: processReplacePath() called");
    unreachable;
}

fn processSpawn(userdata: ?*anyopaque, options: std.process.SpawnOptions) std.process.SpawnError!std.process.Child {
    _ = userdata;
    _ = options;
    basis.assertd(@src(), false, "Basis null IO: processSpawn() called");
    unreachable;
}

fn processSpawnPath(userdata: ?*anyopaque, dir: std.Io.Dir, options: std.process.SpawnOptions) std.process.SpawnError!std.process.Child {
    _ = userdata;
    _ = dir;
    _ = options;
    basis.assertd(@src(), false, "Basis null IO: processSpawnPath() called");
    unreachable;
}

fn childWait(userdata: ?*anyopaque, child: *std.process.Child) std.process.Child.WaitError!std.process.Child.Term {
    _ = userdata;
    _ = child;
    basis.assertd(@src(), false, "Basis null IO: childWait() called");
    unreachable;
}

fn childKill(userdata: ?*anyopaque, child: *std.process.Child) void {
    _ = userdata;
    _ = child;
    basis.assertd(@src(), false, "Basis null IO: childKill() called");
    unreachable;
}

fn progressParentFile(userdata: ?*anyopaque) std.Progress.ParentFileError!std.Io.File {
    _ = userdata;
    basis.assertd(@src(), false, "Basis null IO: progressParentFile() called");
    unreachable;
}

fn now(userdata: ?*anyopaque, clock: std.Io.Clock) std.Io.Timestamp {
    _ = userdata;
    _ = clock;
    basis.assertd(@src(), false, "Basis null IO: now() called");
    unreachable;
}

fn clockResolution(userdata: ?*anyopaque, clock: std.Io.Clock) std.Io.Clock.ResolutionError!std.Io.Duration {
    _ = userdata;
    _ = clock;
    basis.assertd(@src(), false, "Basis null IO: clockResolution() called");
    unreachable;
}

fn sleep(userdata: ?*anyopaque, timeout: std.Io.Timeout) std.Io.Cancelable!void {
    _ = userdata;
    _ = timeout;
    basis.assertd(@src(), false, "Basis null IO: sleep() called");
    unreachable;
}

fn random(userdata: ?*anyopaque, buffer: []u8) void {
    _ = userdata;
    _ = buffer;
    basis.assertd(@src(), false, "Basis null IO: random() called");
    unreachable;
}

fn randomSecure(userdata: ?*anyopaque, buffer: []u8) std.Io.RandomSecureError!void {
    _ = userdata;
    _ = buffer;
    basis.assertd(@src(), false, "Basis null IO: randomSecure() called");
    unreachable;
}

fn netListenIp(
    userdata: ?*anyopaque,
    address: std.Io.net.IpAddress,
    options: std.Io.net.IpAddress.ListenOptions,
) std.Io.net.IpAddress.ListenError!std.Io.net.Server {
    _ = userdata;
    _ = address;
    _ = options;
    basis.assertd(@src(), false, "Basis null IO: netListenIp() called");
    unreachable;
}

fn netListenUnix(
    userdata: ?*anyopaque,
    address: *const std.Io.net.UnixAddress,
    options: std.Io.net.UnixAddress.ListenOptions,
) std.Io.net.UnixAddress.ListenError!std.Io.net.Socket.Handle {
    _ = userdata;
    _ = address;
    _ = options;
    basis.assertd(@src(), false, "Basis null IO: netListenUnix() called");
    unreachable;
}

fn netAccept(userdata: ?*anyopaque, listen_handle: std.Io.net.Socket.Handle) std.Io.net.Server.AcceptError!std.Io.net.Stream {
    _ = userdata;
    _ = listen_handle;
    basis.assertd(@src(), false, "Basis null IO: netAccept() called");
    unreachable;
}

fn netBindIp(
    userdata: ?*anyopaque,
    address: *const std.Io.net.IpAddress,
    options: std.Io.net.IpAddress.BindOptions,
) std.Io.net.IpAddress.BindError!std.Io.net.Socket {
    _ = userdata;
    _ = address;
    _ = options;
    basis.assertd(@src(), false, "Basis null IO: netBindIp() called");
    unreachable;
}

fn netConnectIp(
    userdata: ?*anyopaque,
    address: *const std.Io.net.IpAddress,
    options: std.Io.net.IpAddress.ConnectOptions,
) std.Io.net.IpAddress.ConnectError!std.Io.net.Stream {
    _ = userdata;
    _ = address;
    _ = options;
    basis.assertd(@src(), false, "Basis null IO: netConnectIp() called");
    unreachable;
}

fn netSocketCreatePair(
    userdata: ?*anyopaque,
    options: std.Io.net.Socket.CreatePairOptions,
) std.Io.net.Socket.CreatePairError![2]std.Io.net.Socket {
    _ = userdata;
    _ = options;
    basis.assertd(@src(), false, "Basis null IO: netSocketCreatePair() called");
    unreachable;
}

fn netConnectUnix(
    userdata: ?*anyopaque,
    address: *const std.Io.net.UnixAddress,
) std.Io.net.UnixAddress.ConnectError!std.Io.net.Socket.Handle {
    _ = userdata;
    _ = address;
    basis.assertd(@src(), false, "Basis null IO: netConnectUnix() called");
    unreachable;
}

fn netClose(userdata: ?*anyopaque, handles: []const std.Io.net.Socket.Handle) void {
    _ = userdata;
    _ = handles;
    basis.assertd(@src(), false, "Basis null IO: netClose() called");
    unreachable;
}

fn netShutdown(_: ?*anyopaque, _: std.Io.net.Socket.Handle, _: std.Io.net.ShutdownHow) std.Io.net.ShutdownError!void {
    basis.assertd(@src(), false, "Basis null IO: netShutdown() called");
    unreachable;
}

fn netRead(userdata: ?*anyopaque, fd: std.Io.net.Socket.Handle, data: [][]u8) std.Io.net.Stream.Reader.Error!usize {
    _ = userdata;
    _ = fd;
    _ = data;
    basis.assertd(@src(), false, "Basis null IO: netRead() called");
    unreachable;
}

fn netWrite(
    userdata: ?*anyopaque,
    handle: std.Io.net.Socket.Handle,
    header: []const u8,
    data: []const []const u8,
    splat: usize,
) std.Io.net.Stream.Writer.Error!usize {
    _ = userdata;
    _ = handle;
    _ = header;
    _ = data;
    _ = splat;
    basis.assertd(@src(), false, "Basis null IO: netWrite() called");
    unreachable;
}

fn netWriteFile(
    userdata: ?*anyopaque,
    socket_handle: std.Io.net.Socket.Handle,
    header: []const u8,
    file_reader: *std.Io.File.Reader,
    limit: std.Io.Limit,
) std.Io.net.Stream.Writer.WriteFileError!usize {
    _ = userdata;
    _ = socket_handle;
    _ = header;
    _ = file_reader;
    _ = limit;
    basis.assertd(@src(), false, "Basis null IO: netWriteFile() called");
    unreachable;
}

fn netSend(
    userdata: ?*anyopaque,
    handle: std.Io.net.Socket.Handle,
    messages: []std.Io.net.OutgoingMessage,
    flags: std.Io.net.SendFlags,
) struct { ?std.Io.net.Socket.SendError, usize } {
    _ = userdata;
    _ = handle;
    _ = messages;
    _ = flags;
    basis.assertd(@src(), false, "Basis null IO: netSend() called");
    unreachable;
}

fn netReceive(
    userdata: ?*anyopaque,
    handle: std.Io.net.Socket.Handle,
    message_buffer: []std.Io.net.IncomingMessage,
    data_buffer: []u8,
    flags: std.Io.net.ReceiveFlags,
    timeout: std.Io.Timeout,
) struct { ?std.Io.net.Socket.ReceiveTimeoutError, usize } {
    _ = userdata;
    _ = handle;
    _ = message_buffer;
    _ = data_buffer;
    _ = flags;
    _ = timeout;
    basis.assertd(@src(), false, "Basis null IO: netReceive() called");
    unreachable;
}

fn netInterfaceNameResolve(
    userdata: ?*anyopaque,
    name: *const std.Io.net.Interface.Name,
) std.Io.net.Interface.Name.ResolveError!std.Io.net.Interface {
    _ = userdata;
    _ = name;
    basis.assertd(@src(), false, "Basis null IO: netInterfaceNameResolve() called");
    unreachable;
}

fn netInterfaceName(userdata: ?*anyopaque, interface: std.Io.net.Interface) std.Io.net.Interface.NameError!std.Io.net.Interface.Name {
    _ = userdata;
    _ = interface;
    basis.assertd(@src(), false, "Basis null IO: netInterfaceName() called");
    unreachable;
}

fn netLookup(
    userdata: ?*anyopaque,
    host_name: std.Io.net.HostName,
    resolved: *std.Io.Queue(std.Io.net.HostName.LookupResult),
    options: std.Io.net.HostName.LookupOptions,
) std.Io.net.HostName.LookupError!void {
    _ = userdata;
    _ = resolved;
    _ = host_name;
    _ = options;
    basis.assertd(@src(), false, "Basis null IO: netLookup() called");
    unreachable;
}
