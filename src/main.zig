const std = @import("std");
const App = @import("engine/app.zig").App;
const ShaderProgram = @import("engine/shader.zig").ShaderProgram;
const c = @import("c.zig").c;

const f32Vertex = @import("engine/buffers/vertex.zig").f32Vertex;
const Index = @import("engine/buffers/index.zig").Index;

const math = @import("zlm");
pub fn main() anyerror!void {
    var app = try App.create("Tesasdst", 640, 480);
    defer app.destroy();

    const identity = math.Mat4.createScale(1.0,1.5,1.0);
  

    var default = try ShaderProgram.create("../shaders/default");
    defer default.destroy();

    var vertex_data = [_]f32{
        0.5,  0.5, 0.0,  // top right
        0.5, -0.5, 0.0,  // bottom right
        -0.5, -0.5, 0.0,  // bottom let
        -0.5,  0.5, 0.0
    };
    var index_data = [_]u32{
        0, 1, 3,
        1, 2, 3
    };

    var triangle_vb = f32Vertex.create(&vertex_data);
    defer triangle_vb.destroy();

    var triangle_ib = Index.create(&index_data);
    defer triangle_ib.destroy();
    c.glVertexAttribPointer(
            0,                 
            3,                 
            c.GL_FLOAT,         
            c.GL_FALSE,          
            0,
            null        
        );
    c.glEnableVertexAttribArray(0);
    
    
    c.glUseProgram(default.id);
    const identity_id = c.glGetUniformLocation(default.id, "transform");
    c.glUniformMatrix4fv(identity_id, 1, c.GL_FALSE, @ptrCast([*c]const f32, &identity.fields));

    mainloop: while (true) {

        var sdl_event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&sdl_event) != 0) {
            switch (sdl_event.type) {
                c.SDL_QUIT => break :mainloop,
                c.SDL_KEYDOWN => {
                    switch (sdl_event.key.keysym.sym) {
                        c.SDLK_ESCAPE => break :mainloop,
                        'f' => app.window.toggleFullScreen(),
                        'z' => c.glPolygonMode(c.GL_FRONT_AND_BACK, c.GL_LINE),
                        'x' => c.glPolygonMode(c.GL_FRONT_AND_BACK, c.GL_FILL),
                        else => {},
                    }
                },
                else => {},
            }
        }

        c.glViewport(0, 0, @intCast(c_int, app.window.width), @intCast(c_int, app.window.height));
        c.glClearColor(0.5, 0.5, 1.0, 0.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT);


        
        triangle_ib.bind();
        triangle_vb.bind();
        c.glDrawElements(c.GL_TRIANGLES, 6, c.GL_UNSIGNED_INT, null);
        f32Vertex.unbind();
        // 

        // c.glDrawArrays(c.GL_TRIANGLES, 0, 3);
        // 


        app.window.swap();

    }
}