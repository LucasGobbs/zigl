const std = @import("std");
const math = @import("zlm");
const c = @import("c.zig").c;

const App = @import("engine/app.zig").App;
const ShaderProgram = @import("engine/shader.zig").ShaderProgram;
const f32Vertex = @import("engine/buffers/vertex.zig").f32Vertex;
const Index = @import("engine/buffers/index.zig").Index;
const Camera = @import("engine/camera.zig").Camera;

const VertexBufferLayout = @import("engine/buffers/vertex_array.zig").VertexBufferLayout;
const VertexArray = @import("engine/buffers/vertex_array.zig").VertexArray;
pub fn main() anyerror!void {
    var app = try App.create("Tesasdst", 640, 480);
    defer app.destroy();

   
    var default = try ShaderProgram.create("../shaders/default");
    defer default.destroy();
    var cube_vertex_data = [_] f32 {
        -1, -1, -1, 1.0, 0.0, 0.0, 
        1, -1, -1, 1.0, 0.0, 0.0, 

        1, 1, -1, 0.0, 1.0, 0.0, 
        -1, 1, -1, 1.0, 0.0, 0.0, 

        -1, -1, 1, 0.0, 1.0, 0.0, 
        1, -1, 1, 0.0, 1.0, 0.0, 

        1, 1, 1, 0.0, 1.0, 0.0, 
        -1, 1, 1, 0.0, 1.0, 0.0
    };
    var cube_index_data = [_] u32 {
        0, 1, 3, 3, 1, 2,
        1, 5, 2, 2, 5, 6,
        5, 4, 6, 6, 4, 7,
        4, 0, 7, 7, 0, 3,
        3, 2, 7, 7, 2, 6,
        4, 5, 0, 0, 5, 1  
    };

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

    var triangle_vb = f32Vertex.create(&cube_vertex_data);
    defer triangle_vb.destroy();

    var triangle_ib = Index.create(&cube_index_data);
    defer triangle_ib.destroy();

    
    

    
    c.glUseProgram(default.id);
    
    

    var model = math.Mat4.createAngleAxis(math.vec3(0.0,0.0,1.0), 0.78);
    const projection = math.Mat4.createPerspective(0.785375, 640.0 / 480.0, 0.1, 1000);
    var view = math.Mat4.createLookAt(math.vec3(0.0,0.0,3.0), math.vec3(0.0,0.0,0.0), math.vec3(0.0,-1.0,0.0));//math.Mat4.createTranslationXYZ(0.0, 0.0, 3.0);

    
    var camera = Camera.create(math.vec3(0.0,0.0,-3.0), math.vec3(0.0,0.0,1.0), math.vec3(0.0,-1.0,0.0));
    var frame: f32 = 0.0;
    var mouseX: i32 = 0;
    var mouseY: i32 = 0;
    var lastMouseX: i32 = 0;
    var lastMouseY: i32 = 0;
    var up: bool = false;
    var down: bool = false;
    var right: bool = false;
    var left: bool = false;
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

                        's' => {down = true;},
                        'w' => {up = true;},
                        'a' => {left = true;},
                        'd' => {right = true;},
                        else => {},
                    }
                },
                c.SDL_KEYUP => {
                    switch (sdl_event.key.keysym.sym) {
                        's' => {down = false;},
                        'w' => {up = false;},
                        'a' => {left = false;},
                        'd' => {right = false;},
                        else => {},
                    }
                },
                c.SDL_MOUSEMOTION => { _ = c.SDL_GetGlobalMouseState(&mouseX,&mouseY);},
                else => {},
            }
        }
        if(up){
            camera.move_straight(0.005);
        } else if(down){
            camera.move_straight(-0.005);
        }

        if(right){
            camera.move_side(-0.005);
        }else if(left){
            camera.move_side(0.005);
        }

        c.glViewport(0, 0, @intCast(c_int, app.window.width), @intCast(c_int, app.window.height));
        c.glClearColor(0.5, 0.5, 1.0, 0.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT | c.GL_DEPTH_BUFFER_BIT);
        camera.pan(math.vec2(@intToFloat(f32, mouseX - lastMouseX) * 0.01, @intToFloat(f32, mouseY - lastMouseY) * 0.01));
        view = camera.getMatrix();
        model = math.Mat4.createAngleAxis(math.vec3(0.0,0.0,1.0), @sin(frame)*2);
        default.setUniformMat4f("model", model);
        default.setUniformMat4f("projection", projection);
        default.setUniformMat4f("view", view);

        var layout = VertexBufferLayout.create();
        try layout.addFloat(3);
        try layout.addFloat(3);
        defer layout.destroy();
        var vertex_array = VertexArray.create();
        vertex_array.addBuffer(triangle_vb, layout);

        vertex_array.bind();
        triangle_ib.bind();
        //triangle_vb.bind();
        c.glDrawElements(c.GL_TRIANGLES, 36, c.GL_UNSIGNED_INT, null);
        f32Vertex.unbind();
        // 

        // c.glDrawArrays(c.GL_TRIANGLES, 0, 3);
        // 
        frame += 0.0005;

        app.window.swap();
        lastMouseX = mouseX;
        lastMouseY = mouseY;
    }
}