// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const basis = @import("basis");
const nemo = @import("nemo.zig");

const StringRefConstIn = basis.angelscript.StringRefConstIn;
const StringRefOut = basis.angelscript.StringRefOut;

// This type wraps the scripting API for Nemo global variables, missions, etc.
// Can be used as a field in a game object component to easily add the API
// to that component.
pub const NemoScriptAPI = struct {
    database: nemo.DatabasePtr = .Null,

    fn readFloat(self: *const NemoScriptAPI, setPath: []const u8, variableName: []const u8) f32 {
        const set = self.database.getGlobalVariableSetByPath(setPath);
        basis.assertf(@src(), !set.isNull(), "Invalid GVS path: \"{s}\".", .{setPath});
        return set.readFloat(variableName);
    }

    fn writeFloat(self: *const NemoScriptAPI, setPath: []const u8, variableName: []const u8, value: f32) void {
        const set = self.database.getGlobalVariableSetByPath(setPath);
        basis.assertf(@src(), !set.isNull(), "Invalid GVS path: \"{s}\".", .{setPath});
        set.writeFloat(variableName, value);
    }

    fn readInt(self: *const NemoScriptAPI, setPath: []const u8, variableName: []const u8) i32 {
        const set = self.database.getGlobalVariableSetByPath(setPath);
        basis.assertf(@src(), !set.isNull(), "Invalid GVS path: \"{s}\".", .{setPath});
        return set.readInt(variableName);
    }

    fn writeInt(self: *const NemoScriptAPI, setPath: []const u8, variableName: []const u8, value: i32) void {
        const set = self.database.getGlobalVariableSetByPath(setPath);
        basis.assertf(@src(), !set.isNull(), "Invalid GVS path: \"{s}\".", .{setPath});
        set.writeInt(variableName, value);
    }

    fn readBool(self: *const NemoScriptAPI, setPath: []const u8, variableName: []const u8) bool {
        const set = self.database.getGlobalVariableSetByPath(setPath);
        basis.assertf(@src(), !set.isNull(), "Invalid GVS path: \"{s}\".", .{setPath});
        return set.readBool(variableName);
    }

    fn writeBool(self: *const NemoScriptAPI, setPath: []const u8, variableName: []const u8, value: bool) void {
        const set = self.database.getGlobalVariableSetByPath(setPath);
        basis.assertf(@src(), !set.isNull(), "Invalid GVS path: \"{s}\".", .{setPath});
        set.writeBool(variableName, value);
    }

    pub fn registerAngelScript(comptime Container: type, reg: basis.angelscript.ComponentRegistration) void {
        reg.registerComponentMethod(
            "float readFloat(const string &in setPath, const string &in variableName)",
            &WrapRead(Container, f32, readFloat).call,
        );
        reg.registerComponentMethod(
            "void writeFloat(const string &in setPath, const string &in variableName, float value)",
            &WrapWrite(Container, f32, writeFloat).call,
        );
        reg.registerComponentMethod(
            "int readInt(const string &in setPath, const string &in variableName)",
            &WrapRead(Container, i32, readInt).call,
        );
        reg.registerComponentMethod(
            "void writeInt(const string &in setPath, const string &in variableName, int value)",
            &WrapWrite(Container, i32, writeInt).call,
        );
        reg.registerComponentMethod(
            "bool readBool(const string &in setPath, const string &in variableName)",
            &WrapRead(Container, bool, readBool).call,
        );
        reg.registerComponentMethod(
            "void writeBool(const string &in setPath, const string &in variableName, bool value)",
            &WrapWrite(Container, bool, writeBool).call,
        );
        reg.registerComponentMethod(
            "void readString(const string &in setPath, const string &in variableName, string &out value)",
            &ReadString(Container).call,
        );
        reg.registerComponentMethod(
            "void writeString(const string &in setPath, const string &in variableName, const string &in value)",
            &WriteString(Container).call,
        );
        reg.registerComponentMethod("void startMission(const string &in missionPath)", &StartMission(Container).call);
        reg.registerComponentMethod("void abortMission(const string &in missionPath)", &AbortMission(Container).call);
        reg.registerComponentMethod("void sendMissionSignal(const string &in missionPath, const string &in signalName)", &SendMissionSignal(Container).call);
    }
};

fn WrapRead(comptime Container: type, comptime T: type, comptime readFn: anytype) type {
    return struct {
        pub fn call(_self: usize, _setPath: StringRefConstIn, _variableName: StringRefConstIn) callconv(.c) T {
            const self = basis.angelscript.getComponentSelf(Container, _self);
            const setPath = basis.angelscript.getStringRefConstIn(_setPath);
            const variableName = basis.angelscript.getStringRefConstIn(_variableName);
            return readFn(&self.nemoAPI, setPath, variableName);
        }
    };
}

fn WrapWrite(comptime Container: type, comptime T: type, comptime writeFn: anytype) type {
    return struct {
        pub fn call(_self: usize, _setPath: StringRefConstIn, _variableName: StringRefConstIn, value: T) callconv(.c) void {
            const self = basis.angelscript.getComponentSelf(Container, _self);
            const setPath = basis.angelscript.getStringRefConstIn(_setPath);
            const variableName = basis.angelscript.getStringRefConstIn(_variableName);
            writeFn(&self.nemoAPI, setPath, variableName, value);
        }
    };
}

fn ReadString(comptime Container: type) type {
    return struct {
        pub fn call(_self: usize, _setPath: StringRefConstIn, _variableName: StringRefConstIn, _value: StringRefOut) callconv(.c) void {
            const self = basis.angelscript.getComponentSelf(Container, _self);
            const setPath = basis.angelscript.getStringRefConstIn(_setPath);
            const variableName = basis.angelscript.getStringRefConstIn(_variableName);
            const set = self.nemoAPI.database.getGlobalVariableSetByPath(setPath);
            basis.assertf(@src(), !set.isNull(), "Invalid GVS path: \"{s}\".", .{setPath});
            const result = set.readString(variableName);
            basis.angelscript.setStringRefOut(_value, result);
        }
    };
}

fn WriteString(comptime Container: type) type {
    return struct {
        pub fn call(_self: usize, _setPath: StringRefConstIn, _variableName: StringRefConstIn, _value: StringRefConstIn) callconv(.c) void {
            const self = basis.angelscript.getComponentSelf(Container, _self);
            const setPath = basis.angelscript.getStringRefConstIn(_setPath);
            const variableName = basis.angelscript.getStringRefConstIn(_variableName);
            const value = basis.angelscript.getStringRefConstIn(_value);
            const set = self.nemoAPI.database.getGlobalVariableSetByPath(setPath);
            basis.assertf(@src(), !set.isNull(), "Invalid GVS path: \"{s}\".", .{setPath});
            set.writeString(variableName, value);
        }
    };
}

fn StartMission(comptime Container: type) type {
    return struct {
        pub fn call(_self: usize, _missionPath: StringRefConstIn) callconv(.c) void {
            const self = basis.angelscript.getComponentSelf(Container, _self);
            const missionPath = basis.angelscript.getStringRefConstIn(_missionPath);
            const mission = self.nemoAPI.database.getMissionByPath(missionPath);
            basis.assertf(@src(), !mission.isNull(), "Invalid mission path: \"{s}\".", .{missionPath});
            mission.start();
        }
    };
}

fn AbortMission(comptime Container: type) type {
    return struct {
        pub fn call(_self: usize, _missionPath: StringRefConstIn) callconv(.c) void {
            const self = basis.angelscript.getComponentSelf(Container, _self);
            const missionPath = basis.angelscript.getStringRefConstIn(_missionPath);
            const mission = self.nemoAPI.database.getMissionByPath(missionPath);
            basis.assertf(@src(), !mission.isNull(), "Invalid mission path: \"{s}\".", .{missionPath});
            mission.abort();
        }
    };
}

fn SendMissionSignal(comptime Container: type) type {
    return struct {
        pub fn call(_self: usize, _missionPath: StringRefConstIn, _signalName: StringRefConstIn) callconv(.c) void {
            const self = basis.angelscript.getComponentSelf(Container, _self);
            const missionPath = basis.angelscript.getStringRefConstIn(_missionPath);
            const signalName = basis.angelscript.getStringRefConstIn(_signalName);
            const mission = self.nemoAPI.database.getMissionByPath(missionPath);
            basis.assertf(@src(), !mission.isNull(), "Invalid mission path: \"{s}\".", .{missionPath});
            mission.sendSignal(signalName);
        }
    };
}
