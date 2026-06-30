// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const vhl = @import("vhl.zig");

const Vec2 = basis.math.Vec2;
const Vec2Int = basis.math.Vec2Int;

const VehicleControllerPtr = basis.physics.vehicle_controller.VehicleControllerPtr;
const VehicleGear = basis.physics.vehicles.VehicleGear;
const VehicleInputData = basis.physics.vehicles.VehicleInputData;
const VehicleStateInfo = basis.physics.vehicles.VehicleStateInfo;

const gForwardReverseSwitchTime = 0.2;
const gForwardToReverseStationaryTime = 0.6;
const gReverseToForwardStationaryTime = 0.5;
const gForwardReverseSwitchMaxSpeed = 2.0;

pub const AutoGearBoxParams = struct {
    const Self = @This();

    pub const MaxGearCount = 6;
    pub const MaxCurvePointCount = 8;

    pub const ShiftCurve = basis.BoundedArray(Vec2, MaxCurvePointCount);

    // Note the -1. For eg. 6 gears we only need 5 curves.
    // The shift-up curves are, 1-2, 2-3, 3-4, 4-5, and 5-6.
    // The shift-down curves are, 6-5, 5-4, 4-3, 3-2, and 2-1.
    pub const ShiftCurveList = basis.BoundedArray(ShiftCurve, MaxGearCount - 1);

    //----------------------------------------------------

    shiftUpCurves: ShiftCurveList = .{},
    shiftDownCurves: ShiftCurveList = .{},
    gearCount: u32 = 0,
    minTimeBetweenGearChanges: f32 = 0.4,

    //----------------------------------------------------

    pub fn deserialize(self: *Self, stream: *basis.BinaryReadStream) void {
        self.gearCount = stream.getInt(u32);
        self.minTimeBetweenGearChanges = stream.getFloat();

        // Reset back to zero.
        self.shiftUpCurves = .{};
        self.shiftDownCurves = .{};

        for (0..self.gearCount - 1) |_| {
            const pointCount = stream.getInt(u32);
            var c: *ShiftCurve = self.shiftUpCurves.addOneAssumeCapacity();

            for (0..pointCount) |_| {
                const point: *Vec2 = c.addOneAssumeCapacity();
                point.* = stream.get(Vec2);
            }
        }

        for (0..self.gearCount - 1) |_| {
            const pointCount = stream.getInt(u32);
            var c: *ShiftCurve = self.shiftDownCurves.addOneAssumeCapacity();

            for (0..pointCount) |_| {
                const point: *Vec2 = c.addOneAssumeCapacity();
                point.* = stream.get(Vec2);
            }
        }
    }

    pub fn serialize(self: *const Self, stream: *basis.BinaryWriteStream) void {
        stream.putInt(u32, self.gearCount);
        stream.putFloat(self.minTimeBetweenGearChanges);

        for (0..self.gearCount - 1) |i| {
            const curve = self.shiftUpCurves.constSlice()[i];
            const pointCount = curve.len;
            stream.putInt(u32, @intCast(pointCount));

            for (0..pointCount) |p| {
                stream.put(Vec2, curve.constSlice()[p]);
            }
        }

        for (0..self.gearCount - 1) |i| {
            const curve = self.shiftDownCurves.constSlice()[i];
            const pointCount = curve.len;
            stream.putInt(u32, @intCast(pointCount));

            for (0..pointCount) |p| {
                stream.put(Vec2, curve.constSlice()[p]);
            }
        }
    }
};

//----------------------------------------------------

pub const AutoGearBox = struct {
    const Self = @This();

    controller: VehicleControllerPtr,
    params: AutoGearBoxParams,

    timeSinceLastGearShift: f32,
    timeSpentAccelerating: f32,
    timeSpentBraking: f32,
    timeSpentStationary: f32,

    // When this is enabled pressing long enough on the brake will eventually shift into reverse gear.
    _brakeIntoReverseEnabled: bool,

    pub fn init(controller: VehicleControllerPtr, params: AutoGearBoxParams) Self {
        var autoBox = Self{
            .controller = controller,
            .params = params,
            .timeSinceLastGearShift = 100000.0,
            .timeSpentAccelerating = 0.0,
            .timeSpentBraking = 0.0,
            .timeSpentStationary = 0.0,
            ._brakeIntoReverseEnabled = true,
        };

        autoBox.reset();
        return autoBox;
    }

    pub fn reset(self: *Self) void {
        self.timeSinceLastGearShift = 100000.0;
        self.timeSpentAccelerating = 0.0;
        self.timeSpentBraking = 0.0;
        self.timeSpentStationary = 0.0;

        self.shiftGear(VehicleGear.Gear1);
    }

    pub fn update(
        self: *Self,
        deltaTime: f32,
        inputAcceleration: f32,
        inputBrake: f32,
        inputHandBrake: f32,
        vehicleInputData: *VehicleInputData,
    ) void {
        const stateInfo = self.controller.getStateInfo();
        self.updateWithStateInfo(deltaTime, stateInfo, inputAcceleration, inputBrake, inputHandBrake, vehicleInputData);
    }

    pub fn updateWithStateInfo(
        self: *Self,
        stateInfo: *const basis.physics.vehicles.VehicleStateInfo,
        deltaTime: f32,
        inputAcceleration: f32,
        inputBrake: f32,
        inputHandBrake: f32,
        vehicleInputData: *VehicleInputData,
    ) void {
        const cg = stateInfo.currentGear;
        const speed = stateInfo.currentSpeedForward;

        // Switch gears:

        const isInForwardGear = cg.asInt() >= VehicleGear.Gear1.asInt();
        const isInReverseGear = cg == VehicleGear.GearR;

        if (isInForwardGear and self.shouldSwitchToReverse()) {
            self.shiftGear(VehicleGear.GearR);
        } else if (isInReverseGear and self.shouldSwitchToForward()) {
            self.shiftGear(VehicleGear.Gear1);
        } else if (isInForwardGear and self.canShiftGear()) {
            const targetGear = self.updateTargetGear(cg, inputAcceleration, speed);

            if (targetGear != cg) {
                self.shiftGear(targetGear);
            }
        }

        // Apply input:

        if (cg.asInt() >= VehicleGear.Gear1.asInt()) {
            vehicleInputData.acceleration = inputAcceleration;
            vehicleInputData.brake = inputBrake;
        } else if (cg == VehicleGear.GearR) {
            // In reverse gear we flip the acceleration and brake input.
            vehicleInputData.brake = inputAcceleration;
            vehicleInputData.acceleration = inputBrake;
        }

        vehicleInputData.handbrake = inputHandBrake; // Handbrake is piped straight through.

        self.timeSinceLastGearShift += deltaTime;

        if (inputAcceleration > 0.0 and inputBrake == 0.0) {
            self.timeSpentAccelerating += deltaTime;
        } else {
            self.timeSpentAccelerating = 0.0;
        }

        if (inputBrake > 0.0 and inputAcceleration == 0.0) {
            self.timeSpentBraking += deltaTime;
        } else {
            self.timeSpentBraking = 0.0;
        }

        if (basis.math.floatsAlmostEqualEpsilon(speed, 0.0, gForwardReverseSwitchMaxSpeed)) {
            self.timeSpentStationary += deltaTime;
        } else {
            self.timeSpentStationary = 0.0;
        }

        //basis.printf("Time spent (a/b) {d}, {d}\n", .{ self.timeSpentAccelerating, self.timeSpentBraking });
    }

    pub fn setBrakeIntoReverseEnabled(self: *Self, enabled: bool) void {
        self._brakeIntoReverseEnabled = enabled;
        if (!enabled) {
            const stateInfo = self.controller.getStateInfo();
            if (stateInfo.currentGear == .GearR) {
                //basis.print("*** Force-resetting 1st gear\n");
                self.shiftGear(.Gear1);
            }
        }
    }

    //----------------------------------------------------

    const VizWidth = 400;
    const VizHeight = 300;
    const Margin = 20;
    const BorderColor = basis.Color.Yellow;
    const CurrentPositionColor = basis.Color.White;
    const CurveMin = Vec2.Zero;
    const CurveMax = Vec2.init(100, 100);

    const DebugDrawColors = [_]basis.Color{
        basis.Color.init(242, 129, 0),
        basis.Color.init(163, 191, 217),
        basis.Color.init(134, 179, 158),
        basis.Color.init(255, 128, 246),
        basis.Color.init(64, 255, 191),
        basis.Color.init(229, 214, 0),
        basis.Color.init(0, 226, 242),
        basis.Color.init(255, 128, 128),
        basis.Color.init(170, 204, 102),
        basis.Color.init(229, 0, 92),
        basis.Color.init(242, 198, 182),
        basis.Color.init(54, 217, 54),
        basis.Color.init(184, 163, 217),
        basis.Color.init(242, 121, 170),
        basis.Color.init(61, 157, 242),
        basis.Color.init(166, 64, 255),
    };

    fn drawDebugRect(x: i32, y: i32, size: i32, c: basis.Color) void {
        const halfSize = @divExact(size, 2);
        basis.debug_draw.drawLine2D(x - halfSize, y - halfSize, x - halfSize, y + halfSize, c);
        basis.debug_draw.drawLine2D(x + halfSize, y - halfSize, x + halfSize, y + halfSize, c);
        basis.debug_draw.drawLine2D(x - halfSize, y - halfSize, x + halfSize, y - halfSize, c);
        basis.debug_draw.drawLine2D(x - halfSize, y + halfSize, x + halfSize, y + halfSize, c);
    }

    fn toScreen(p: Vec2, curveMin: Vec2, curveMax: Vec2) Vec2Int {
        const screenAtMaxX = Margin + VizWidth;
        const screenAtMaxY = Margin;

        const screenAtMinX = Margin;
        const screenAtMinY = Margin + VizHeight;

        const x = basis.math.remapFloat(p.x, curveMin.x, curveMax.x, @as(f32, @floatFromInt(screenAtMinX)), @as(f32, @floatFromInt(screenAtMaxX)));
        const y = basis.math.remapFloat(p.y, curveMin.y, curveMax.y, @as(f32, @floatFromInt(screenAtMinY)), @as(f32, @floatFromInt(screenAtMaxY)));

        return Vec2Int.init(@as(i32, @intFromFloat(x)), @as(i32, @intFromFloat(y)));
    }

    pub fn debugDrawImgui(
        self: *const Self,
        objectName: []const u8,
        stateInfo: *VehicleStateInfo,
        vehicleTopSpeed: f32,
    ) void {
        _ = objectName; // autofix
        var tempBuffer: [1024]u8 = undefined;

        const avail = basis.imgui.getContentRegionAvail();
        const size = Vec2.init(avail.x, avail.x * 0.75);

        const throttle = self.controller.getInputData().acceleration;
        const speed = stateInfo.currentSpeedForward;

        {
            const line = std.fmt.bufPrint(&tempBuffer, "Current gear: {s}", .{stateInfo.currentGear.asString()}) catch unreachable;
            basis.imgui.text(line);
        }

        {
            const line = std.fmt.bufPrint(&tempBuffer, "Gear count: {}", .{self.params.gearCount}) catch unreachable;
            basis.imgui.text(line);
        }

        if (basis.implot.beginPlot("Shift curves", size, 0)) {
            var xs: [AutoGearBoxParams.MaxCurvePointCount]f32 = undefined;
            var ys: [AutoGearBoxParams.MaxCurvePointCount]f32 = undefined;

            basis.implot.setupAxis(.X1, "Speed (km/h)", basis.implot.ImPlotAxisFlags.None.asInt());
            basis.implot.setupAxis(.Y1, "Throttle (%)", basis.implot.ImPlotAxisFlags.None.asInt());

            basis.implot.setupAxisLimits(.X1, -10.0, vehicleTopSpeed + 10.0, .Always);
            basis.implot.setupAxisLimits(.Y1, -5.0, 105.0, .Always);

            basis.implot.setupLegend(.East, basis.implot.ImPlotLegendFlags.Outside.asInt());

            // Shift-up curves.
            for (self.params.shiftUpCurves.constSlice(), 0..) |c, curveIndex| {
                const points = c.constSlice();
                for (points, 0..) |p, i| {
                    xs[i] = p.x;
                    ys[i] = p.y;
                }

                const label = std.fmt.bufPrint(&tempBuffer, "{} -> {}##shiftUp_{}", .{ curveIndex + 1, curveIndex + 2, curveIndex }) catch unreachable;

                var spec = basis.implot.ImPlotSpec{};
                spec.lineWeight = 3.0;
                basis.implot.plotLineEx(label, xs[0..c.len], ys[0..c.len], spec);
            }

            // Shift-down curves.
            for (self.params.shiftDownCurves.constSlice(), 0..) |c, curveIndex| {
                const points = c.constSlice();
                for (points, 0..) |p, i| {
                    xs[i] = p.x;
                    ys[i] = p.y;
                }

                const label = std.fmt.bufPrint(&tempBuffer, "{} -> {}##shiftDown_{}", .{ curveIndex + 2, curveIndex + 1, curveIndex }) catch unreachable;

                basis.implot.plotLine(label, xs[0..c.len], ys[0..c.len]);
            }

            // Current position.

            const currentPosition = Vec2.init(speed * 3.6, throttle * 100.0);

            {
                const x = [_]f32{ -1000.0, 1000.0 };
                const y = [_]f32{ currentPosition.y, currentPosition.y };

                var spec = basis.implot.ImPlotSpec{};
                spec.lineColor = .White;
                basis.implot.plotLineEx("##currentShiftH", &x, &y, spec);
            }

            {
                const x = [_]f32{ currentPosition.x, currentPosition.x };
                const y = [_]f32{ -1000.0, 1000.0 };

                var spec = basis.implot.ImPlotSpec{};
                spec.lineColor = .White;
                basis.implot.plotLineEx("##currentShiftV", &x, &y, spec);
            }

            {
                const x = [_]f32{currentPosition.x};
                const y = [_]f32{currentPosition.y};
                var spec = basis.implot.ImPlotSpec{};
                spec.markerFillColor = .White;
                spec.markerLineColor = .White;
                basis.implot.plotScatterEx("##currentShift", &x, &y, spec);
            }

            basis.implot.endPlot();
        }
    }

    //----------------------------------------------------

    fn shiftGear(self: *Self, targetGear: VehicleGear) void {
        self.controller.forceGearChange(targetGear);
        self.timeSinceLastGearShift = 0.0;
    }

    fn canShiftGear(self: *const Self) bool {
        if (self.timeSinceLastGearShift < self.params.minTimeBetweenGearChanges) return false;

        return true;
    }

    fn shouldSwitchToForward(self: *const Self) bool {
        return self.timeSpentAccelerating >= gForwardReverseSwitchTime and
            self.timeSpentStationary >= gReverseToForwardStationaryTime;
    }

    fn shouldSwitchToReverse(self: *const Self) bool {
        return self._brakeIntoReverseEnabled and
            self.timeSpentBraking >= gForwardReverseSwitchTime and
            self.timeSpentStationary >= gForwardToReverseStationaryTime;
    }

    fn updateTargetGear(self: *const Self, currentGear: VehicleGear, throttle: f32, speed: f32) VehicleGear {
        // We need to be in a "forward gear", ie. not in R or N.
        basis.assert(@src(), currentGear.asInt() >= VehicleGear.Gear1.asInt() and currentGear.asInt() <= VehicleGear.Gear10.asInt());

        // The first forward gear has numeric value 2, the second 3 etc. so subtract two to get the index of the forward gear.
        var gearIndex: i32 = currentGear.asInt() - 2;

        // Convert speed from m/s to km/h, and throttle from [0, 1] to [0, 100].
        const point = Vec2.init(speed * 3.6, throttle * 100.0);

        if (gearIndex == 0) {
            if (!self.shiftUp(point, &gearIndex)) {
                return currentGear;
            }
        } else if (gearIndex == self.params.gearCount - 1) {
            if (!self.shiftDown(point, &gearIndex)) {
                return currentGear;
            }
        } else {
            if (!self.shiftUp(point, &gearIndex)) {
                if (!self.shiftDown(point, &gearIndex)) {
                    return currentGear;
                }
            }
        }

        // Convert from forward gear index back to the numeric value of the gear.
        return @as(VehicleGear, @enumFromInt(gearIndex + 2));
    }

    fn shiftUp(self: *const Self, input: Vec2, gear: *i32) bool {
        if (gear.* == self.params.gearCount - 1) {
            return false;
        }

        basis.assert(@src(), gear.* < self.params.gearCount - 1);

        const originalGear: i32 = gear.*;
        const firstCurveIndex: i32 = gear.*;
        const lastCurveIndex: i32 = @as(i32, @intCast(self.params.gearCount)) - 2;

        var i: i32 = firstCurveIndex;
        while (i <= lastCurveIndex) : (i += 1) {
            if (isPointToRightOfShiftCurve(input, self.params.shiftUpCurves.constSlice()[@as(usize, @intCast(i))])) {
                gear.* = gear.* + 1;
            }
        }

        basis.assert(@src(), gear.* <= self.params.gearCount - 1);

        // if (originalGear != gear.*) {
        //     basis.printf("Shift up {d} -> {d}\n", .{ originalGear + 1, gear.* + 1 });
        // }

        return (originalGear != gear.*);
    }

    fn shiftDown(self: *const Self, input: Vec2, gear: *i32) bool {
        basis.assert(@src(), gear.* > 0);

        const originalGear: i32 = @as(i32, @intCast(gear.*));
        const firstCurveIndex: i32 = @as(i32, @intCast(gear.*)) - 1;

        var i: i32 = firstCurveIndex;
        while (i >= 0) : (i -= 1) {
            if (!isPointToRightOfShiftCurve(input, self.params.shiftDownCurves.constSlice()[@as(usize, @intCast(i))])) {
                gear.* = gear.* - 1;
            }
        }

        basis.assert(@src(), gear.* >= 0);

        // if (originalGear != gear.*) {
        //     basis.printf("Shift down {d} -> {d}\n", .{ originalGear + 1, gear.* + 1 });
        // }

        return (originalGear != gear.*);
    }
};

//----------------------------------------------------

fn isPointToRightOfShiftCurve(point: Vec2, shiftCurve: AutoGearBoxParams.ShiftCurve) bool {
    var i: usize = 0;
    while (i < shiftCurve.len - 1) : (i += 1) {
        const p0 = shiftCurve.get(i);
        const p1 = shiftCurve.get(i + 1);

        if (point.x >= p1.x) {
            // The point is to the right of the whole segment, so skip to the next one.
            continue;
        }

        if (point.x < p0.x and point.y >= p0.y) {
            // The point is to the left of the whole segment, return false.
            return false;
        }

        const segmentDir = p1.sub(p0).normalized();
        const p0ToPoint = point.sub(p0).normalized();

        const segmentAngle = segmentDir.dot(Vec2.UnitY);
        const p0ToPointAngle = p0ToPoint.dot(Vec2.UnitY);

        if (p0ToPointAngle > segmentAngle) {
            return false;
        }
    }

    return true;
}
