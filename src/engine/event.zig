const c = @import("../c.zig").c;
const Hash = @import("std").ArrayHashMap;
const test_allocator = std.testing.allocator;
// handle keys

// onPress
// onHold
// onDoublePress
pub const key_state = enum {
    empty,
    pressed,
    holded,
    released,
    double_pressed,
};
pub const Key = struct {
    state: key_state = .empty,
    time: f32 = 0.0,
};
pub const EventHandler = struct {
    keys: Hash(Key),
    pub fn create() EventHandler {
        var keys_hash = Hash(Key).init(test_allocator);

        keys_hash.put(c.SDLK_ESCAPE, Key{});
        keys_hash.put('f', Key{});
        keys_hash.put('z', Key{});

        keys_hash.put('w', Key{});
        keys_hash.put('a', Key{});
        keys_hash.put('s', Key{});
        keys_hash.put('d', Key{});
        return EventHandler {
            .keys = keys_hash
        };
    }
    pub fn update(self: *EventHandler) void {
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
                c.SDL_MOUSEMOTION => {
                    mouseX += sdl_event.motion.xrel;
                    mouseY += sdl_event.motion.yrel;
                },
                //c.SDL_MOUSEMOTION => { _ = c.SDL_GetGlobalMouseState(&mouseX,&mouseY);},
                else => {},
            }
        }
    } 

};
