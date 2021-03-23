const c = @import("../c.zig").c;
const std = @import("std");
// Error handling copy of https://github.com/MasterQ32/SDL.zig/blob/master/src/lib.zig
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

pub const App = struct {
    
    window: Window,
    renderer: Renderer,
    gl_ctx: c.SDL_GLContext,

    pub fn create(title: [:0]const u8, width: usize, height: usize) !App {
        _ = c.SDL_Init(c.SDL_INIT_VIDEO);
        // c.SDL_GL_SetAttribute( c.SDL_GL_CONTEXT_MAJOR_VERSION, 4 );
        // c.SDL_GL_SetAttribute( c.SDL_GL_CONTEXT_MINOR_VERSION, 4 );
        // c.SDL_GL_SetAttribute( c.SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE );
        // if (c.SDL_GL_SetAttribute(.SDL_GL_CONTEXT_MAJOR_VERSION, 4) != 0 or
        // c.SDL_GL_SetAttribute(.SDL_GL_CONTEXT_MINOR_VERSION, 4) != 0 or
        // c.SDL_GL_SetAttribute(.SDL_GL_CONTEXT_PROFILE_MASK, c.SDL_GL_CONTEXT_PROFILE_CORE) != 0 or
        // c.SDL_GL_SetAttribute(.SDL_GL_CONTEXT_FLAGS, c.SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG) != 0){
        //     std.debug.print("BBBBBBBBBBBBBBBBBBBBBBBB",.{});
        //     @panic("erro");
        // }
   
        
        var _window = try Window.create(title, width, height);
        var _gl_ctx = c.SDL_GL_CreateContext(_window.ptr);
        const  _renderer = try Renderer.create(_window);
        
        if(c.gladLoadGLLoader(c.SDL_GL_GetProcAddress) == 0){
            @panic("do something with a");
        }
        _ = c.SDL_ShowCursor(0);
        c.glEnable(c.GL_DEPTH_TEST); 
        return App {
            .window = _window,
            .renderer = _renderer,
            .gl_ctx = _gl_ctx 
        };
    }

    pub fn destroy(self: App) void {
        c.SDL_Quit();
        c.SDL_GL_DeleteContext( self.gl_ctx );
        self.window.destroy();
        self.renderer.destroy();
    }
};

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
                c.SDL_WINDOW_OPENGL | c.SDL_WINDOW_FULLSCREEN_DESKTOP
            ) orelse return makeError(),
            .width = 1920,
            .height = 1080,
            .isFullScreen = false
        };
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

pub const Renderer = struct {
    ptr: *c.SDL_Renderer,
    pub fn create(window: Window) !Renderer {
        return Renderer{
            .ptr = c.SDL_CreateRenderer(window.ptr, 0, c.SDL_RENDERER_PRESENTVSYNC) orelse return makeError()
        };
    }
    pub fn destroy(self: Renderer) void {
        c.SDL_DestroyRenderer(self.ptr);
    }
};


// Pool events

// init window