const c = @import("../c.zig").c;
const std = @import("std");
pub const Error = error{SdlError};
const log = std.log.scoped(.sdl2);
pub fn makeError() error{SdlError} {
    if (c.SDL_GetError()) |ptr| {
        log.debug("{s}\n", .{
            std.mem.span(ptr),
        });
    }
    return error.SdlError;
}

pub const Window  = struct {
    ptr: *c.SDL_Window,
    width: usize,
    height: usize,
    isFullScreen: bool,
    pub fn create(title: [:0]const u8, width: usize, height: usize) !Window{
        return Window{
            .ptr = c.SDL_CreateWindow(
                title, 
                c.SDL_WINDOWPOS_CENTERED, 
                c.SDL_WINDOWPOS_CENTERED, 
                @intCast(c_int, width), 
                @intCast(c_int, height), 
                c.SDL_WINDOW_OPENGL //| c.SDL_WINDOW_FULLSCREEN_DESKTOP
            ) orelse return makeError(),
            .width = width,
            .height = height,
            .isFullScreen = false
        };
    }
    pub fn clear(self: Window) void {
        c.glViewport(0, 0, @intCast(c_int, self.width), @intCast(c_int, self.height));
        c.glClearColor(0.5, 0.5, 1.0, 0.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT | c.GL_DEPTH_BUFFER_BIT);
    }
    pub fn swap(self: Window) void {
        c.SDL_GL_SwapWindow(self.ptr);
    }
    pub fn toggleFullScreen(self: Window) void {
        if (self.isFullScreen) {
            _ = c.SDL_SetWindowFullscreen(self.ptr, c.SDL_WINDOW_OPENGL | c.SDL_WINDOW_FULLSCREEN_DESKTOP);
        } else {
            _ = c.SDL_SetWindowFullscreen(self.ptr, c.SDL_WINDOW_OPENGL);
        }
        
    }
    pub fn destroy(self: Window) void {
        c.SDL_DestroyWindow(self.ptr);
    }
};
