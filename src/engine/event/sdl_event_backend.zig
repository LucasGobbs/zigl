
const c = @import("../../c.zig").c;
pub const events = @import("./event.zig");

pub fn to_sdl_key(key: events.key_code) c.SDL_Keycode {
    return switch(key) {
        q => c.SDLK_q,
        w => c.SDLK_w,
        a => c.SDLK_a,
        s => c.SDLK_s,
        d => c.SDLK_d,
        left => c.SDLK_LEFT,
        down => c.SDLK_DOWN,
        right => c.SDLK_RIGHT,
        up => c.SDLK_UP,
        esq => c.SDLK_ESCAPE,
    };
}

pub fn to_event_key(key: c.SDL_Keycode)  events.key_code {
    return switch(key) {
        c.SDLK_q => q,
        c.SDLK_w => w,
        c.SDLK_a => a,
        c.SDLK_s => s,
        c.SDLK_d => d,
        c.SDLK_LEFT => left,
        c.SDLK_DOWN => down,
        c.SDLK_RIGHT => right,
        c.SDLK_UP => up,
        c.SDLK_ESCAPE => esc
    };
}

pub fn update(handler: *EventHandler) void {
    switch (sdl_event.type) {
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
        else => {},
    }
}
