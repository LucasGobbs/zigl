const c = @import("../c.zig").c;
const Hash = @import("std").AutoHashMap;
const test_allocator = @import("std").testing.allocator;
const event_backend = @import("./sdl_event_backend.zig");

pub const key_code = enum {
    q,
    w,
    a,
    s,
    d,
    left,
    up,
    right,
    down,
    esc,
};
pub const key_state = enum {
    empty,
    pressed,
    holded,
    released,
    double_pressed,
};

pub const Key = struct {
    current_state: key_state = .empty,
    last_state: key_state = .empty,

    current_time: f32 = 0.0,
    last_time: f32 = 0.0,
    pub fn changeState(self: *Key, new_state: key_state, new_time: f32) void {
        self.save();
        self.current_state = new_state;
        self.current_time = new_time;
    }
    fn save(self: *Key) void {
        self.last_state = self.current_state;
        self.last_time = self.current_time;
    }
};
pub const KeyboardEvent = struct {
    keys: Hash(key_code, Key),
    pub fn create() !KeyboardEvent {
        var keys_hash = Hash(key_code, Key).init(
            test_allocator,
        );

        var index = @enumToInt(key_code.q);
        const last_key_code = @enumToInt(key_code.esc); 
        while (index <= last_key_code){
            try keys_hash.put(@intToEnum(key_code, index), Key{});
            index += 1;
        }
        
        return KeyboardEvent {
            .keys = keys_hash
        };
    }
    pub fn isPressed(self: *KeyboardEvent, code: key_code) bool {
        var key = self.keys.get(code);
        return key.?.state == key_state.pressed;
    }

    pub fn changeState(self: *KeyboardEvent, code: key_code, new_state: key_state) void {
        var old_key = self.keys.get(code);
        const old_state = old_key.?.state;
        switch(new_state){
            .pressed => {

            },
        }
        self.keys.put(code, old_key.?) catch |err|{
            @panic("aa");
        };

    }
    pub fn update(self: *KeyboardEvent, ) !void {
        event_backend.update(self);
        // var sdl_event: c.SDL_Event = undefined;
        // while (c.SDL_PollEvent(&sdl_event) != 0) {
        //     switch (sdl_event.type) {
        //         c.SDL_QUIT => break :mainloop,
        //         c.SDL_KEYDOWN => {
        //             switch (sdl_event.key.keysym.sym) {
        //                 c.SDLK_ESCAPE => break :mainloop,
        //                 'f' => app.window.toggleFullScreen(),
        //                 'z' => c.glPolygonMode(c.GL_FRONT_AND_BACK, c.GL_LINE),
        //                 'x' => c.glPolygonMode(c.GL_FRONT_AND_BACK, c.GL_FILL),

        //                 's' => {down = true;},
        //                 'w' => {up = true;},
        //                 'a' => {left = true;},
        //                 'd' => {right = true;},
        //                 else => {},
        //             }
        //         },
        //         c.SDL_KEYUP => {
        //             switch (sdl_event.key.keysym.sym) {
        //                 's' => {down = false;},
        //                 'w' => {up = false;},
        //                 'a' => {left = false;},
        //                 'd' => {right = false;},
        //                 else => {},
        //             }
        //         },
        //         c.SDL_MOUSEMOTION => {
        //             mouseX += sdl_event.motion.xrel;
        //             mouseY += sdl_event.motion.yrel;
        //         },
        //         //c.SDL_MOUSEMOTION => { _ = c.SDL_GetGlobalMouseState(&mouseX,&mouseY);},
        //         else => {},
        //     }
        // }
    } 
    pub fn destroy(self: *KeyboardEvent) void {
        self.keys.deinit();
    }

};

