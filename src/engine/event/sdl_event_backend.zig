
const c = @import("../../c.zig").c;
pub const event = @import("./event.zig");

// fn to_sdl_key(key: events.key_code) c.SDL_Keycode {
//     return switch(key) {
//         q => c.SDLK_q,
//         w => c.SDLK_w,
//         a => c.SDLK_a,
//         s => c.SDLK_s,
//         d => c.SDLK_d,
//         left => c.SDLK_LEFT,
//         down => c.SDLK_DOWN,
//         right => c.SDLK_RIGHT,
//         up => c.SDLK_UP,
//         esq => c.SDLK_ESCAPE,
//     };
// }

fn to_event_key(key: c.SDL_Keycode)  event.key_code {
    return switch(key) {
        c.SDLK_q => .q,
        c.SDLK_w => .w,
        c.SDLK_a => .a,
        c.SDLK_s => .s,
        c.SDLK_d => .d,
        c.SDLK_LEFT => .left,
        c.SDLK_DOWN => .down,
        c.SDLK_RIGHT => .right,
        c.SDLK_UP => .up,
        c.SDLK_ESCAPE => .esc,
        else => .esc,
    };
}

pub fn update(handler: *event.KeyboardEvent, time: f32) void {
    var sdl_event: c.SDL_Event = undefined;
    while (c.SDL_PollEvent(&sdl_event) != 0) {
        const _key_event = sdl_event.key.keysym.sym;
        switch (sdl_event.type) {
            c.SDL_KEYDOWN => {
                handler.changeState(to_event_key(_key_event), .pressed, time);
            },
            c.SDL_KEYUP =>{
                handler.changeState(to_event_key(_key_event), .released, time);
            },
            // c.SDL_KEYUP => {
            //     switch (sdl_event.key.keysym.sym) {
            //         's' => {down = false;},
            //         'w' => {up = false;},
            //         'a' => {left = false;},
            //         'd' => {right = false;},
            //         else => {},
            //     }
            // },
            else => {},
        }
    }
    
}
