const std = @import("std");
const App = @import("engine/app.zig").App;
const ShaderProgram = @import("engine/shader.zig").ShaderProgram;
const c = @import("c.zig").c;


pub fn main() anyerror!void {
    std.debug.print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",.{});
    var app = try App.create("Tesasdst", 640, 480);
    defer app.destroy();

    
    var default = try ShaderProgram.create("../shaders/default");
    defer default.destroy();

    const vertex_data = [_]f32{
        -1.0, -1.0, 0.0,
        1.0, -1.0, 0.0,
        0.0, 1.0, 0.0,
    };
    var vb_id: c.GLuint = undefined;
    c.glGenBuffers(1, &vb_id);
    c.glBindBuffer(c.GL_ARRAY_BUFFER, vb_id);
    c.glBufferData(c.GL_ARRAY_BUFFER, vertex_data.len * @sizeOf(f32), @ptrCast(*const c_void, &vertex_data) , c.GL_STATIC_DRAW );
    

    c.glUseProgram(default.id);
    mainloop: while (true) {

        var sdl_event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&sdl_event) != 0) {
            switch (sdl_event.type) {
                c.SDL_QUIT => break :mainloop,
                c.SDL_KEYDOWN => {
                    switch (sdl_event.key.keysym.sym) {
                        c.SDLK_ESCAPE => break :mainloop,
                        'f' => app.window.toggleFullScreen(),
                        else => {},
                    }
                },
                else => {},
            }
        }

        c.glViewport(0, 0, @intCast(c_int, app.window.width), @intCast(c_int, app.window.height));
        c.glClearColor(0.5, 0.5, 1.0, 0.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT);
        c.glEnableVertexAttribArray(0);
        c.glBindBuffer(c.GL_ARRAY_BUFFER, vb_id);
        c.glVertexAttribPointer(
            0,                 
            3,                 
            c.GL_FLOAT,         
            c.GL_FALSE,          
            0,
            null        
        );

        c.glDrawArrays(c.GL_TRIANGLES, 0, 3);
        c.glDisableVertexAttribArray(0);


        app.window.swap();

    }
}