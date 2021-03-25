const c = @import("../c.zig").c;
const Window = @import("./window.zig").Window;
const std = @import("std");
// Error handling copy of https://github.com/MasterQ32/SDL.zig/blob/master/src/lib.zig

pub const App = struct {
    
    window: Window,

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

        if(c.gladLoadGLLoader(c.SDL_GL_GetProcAddress) == 0){
            @panic("do something with a");
        }
        _ = c.SDL_ShowCursor(0);
        //c.SDL_SetWindowGrab(_window.ptr, @intToEnum(c.SDL_bool, c.SDL_TRUE));
        _ = c.SDL_SetRelativeMouseMode(@intToEnum(c.SDL_bool, c.SDL_TRUE));
        
        c.glEnable(c.GL_DEPTH_TEST); 
        return App {
            .window = _window, 
            .gl_ctx = _gl_ctx 
        };
    }

    pub fn destroy(self: App) void {
        c.SDL_Quit();
        c.SDL_GL_DeleteContext( self.gl_ctx );
        self.window.destroy();
    }
};


// Pool events

// init window