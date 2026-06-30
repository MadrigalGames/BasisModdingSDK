// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

pub fn RingBuffer(comptime T: type, comptime Size: usize) type {
    return struct {
        const Self = @This();

        //----------------------------------------------------

        _buffer: [Size]T,
        _currentFrontIndex: i32,
        _currentBackIndex: i32,
        _elementCount: i32,

        //----------------------------------------------------

        pub fn init() Self {
            return Self{
                ._buffer = undefined,
                ._currentFrontIndex = 0,
                ._currentBackIndex = 0,
                ._elementCount = 0,
            };
        }

        //----------------------------------------------------

        pub fn clear(self: *Self) void {
            self._currentFrontIndex = 0;
            self._currentBackIndex = 0;
            self._elementCount = 0;
        }

        pub fn pushBack(self: *Self, item: T) void {
            if (self._elementCount == 0) {
                // The first element is added.
                self._currentFrontIndex = 0;
                self._currentBackIndex = 0;
                self._elementCount = 1;
            } else if (self._elementCount < Size) {
                // An element is added while there is still empty space in the buffer.
                self._currentFrontIndex = 0;
                self._currentBackIndex += 1;
                self._elementCount += 1;
            } else {
                // An element is added while there is no empty space in the buffer.
                self._currentFrontIndex += 1;
                if (self._currentFrontIndex >= Size) {
                    self._currentFrontIndex = 0;
                }

                self._currentBackIndex += 1;
                if (self._currentBackIndex >= Size) {
                    self._currentBackIndex = 0;
                }
            }

            self._buffer[@intCast(self._currentBackIndex)] = item;
        }

        pub fn popBack(self: *Self) void {
            if (self._elementCount == 0) {
                return;
            }

            // Reset the buffer positions. If the buffer isn't full, which it won't be if we
            // pop the last element, we assume that the front sits at index 0.
            self.resetBufferPositions();
            self._currentBackIndex -= 1;
            self._elementCount -= 1;
        }

        //----------------------------------------------------

        /// Get the front element of the list, ie. the oldest element added to the list.
        pub fn getFront(self: *const Self) T {
            basis.assert(@src(), self._elementCount > 0);
            return self._buffer[@intCast(self._currentFrontIndex)];
        }

        /// Get a pointer the front element of the list, ie. the oldest element added to the list.
        pub fn getFrontPtr(self: *const Self) *T {
            basis.assert(@src(), self._elementCount > 0);
            return &self._buffer[@intCast(self._currentFrontIndex)];
        }

        /// Get an element offset elements from the front element. The offset is towards the back.
        pub fn getFrontOffset(self: *const Self, offset: usize) T {
            var index: i32 = (self._currentFrontIndex + @as(i32, @intCast(offset)));

            while (index >= self._elementCount)
                index -= self._elementCount;

            return self._buffer[@intCast(index)];
        }

        /// Get a pointer to an element offset elements from the front element. The offset is towards the back.
        pub fn getFrontOffsetPtr(self: *Self, offset: usize) *T {
            var index: i32 = (self._currentFrontIndex + @as(i32, @intCast(offset)));

            while (index >= self._elementCount)
                index -= self._elementCount;

            return &self._buffer[@intCast(index)];
        }

        //----------------------------------------------------

        /// Get the back element of the list, ie. the newest element added to the list.
        pub fn getBack(self: *const Self) T {
            basis.assert(@src(), self._elementCount > 0);
            return self._buffer[@intCast(self._currentBackIndex)];
        }

        /// Get a pointer the back element of the list, ie. the newest element added to the list.
        pub fn getBackPtr(self: *const Self) *T {
            basis.assert(@src(), self._elementCount > 0);
            return &self._buffer[@intCast(self._currentBackIndex)];
        }

        /// Get an element offset elements from the back element. The offset is towards the front.
        pub fn getBackOffset(self: *const Self, offset: usize) T {
            var index: i32 = (self._currentBackIndex - @as(i32, @intCast(offset)));

            while (index < 0)
                index += self._elementCount;

            return self._buffer[@intCast(index)];
        }

        /// Get a pointer to an element offset elements from the back element. The offset is towards the front.
        pub fn getBackOffsetPtr(self: *Self, offset: usize) *T {
            var index: i32 = (self._currentBackIndex - @as(i32, @intCast(offset)));

            while (index < 0)
                index += self._elementCount;

            return &self._buffer[@intCast(index)];
        }

        //----------------------------------------------------

        pub fn getCount(self: *const Self) usize {
            return @intCast(self._elementCount);
        }

        pub fn isFull(self: *const Self) bool {
            return self._elementCount == Size;
        }

        //----------------------------------------------------

        fn resetBufferPositions(self: *Self) void {
            // We shift the elements left so that the front sits at index 0.
            while (self._currentFrontIndex > 0) {
                const temp = self._buffer[0];
                for (0..(Size - 1)) |i| {
                    self._buffer[i] = self._buffer[i + 1];
                }
                self._buffer[Size - 1] = temp;

                self._currentFrontIndex -= 1;
                self._currentBackIndex -= 1;
                if (self._currentBackIndex < 0) {
                    self._currentBackIndex = Size - 1;
                }
            }
        }
    };
}
