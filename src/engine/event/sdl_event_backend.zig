
const c = @import("../../c.zig").c;
pub const event = @import("./event.zig");

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
    var sdl_events: [10]c.SDL_Event = undefined;
    
    c.SDL_PumpEvents();
    const count = c.SDL_PeepEvents(&sdl_events, 10, @intToEnum(c.SDL_eventaction, c.SDL_PEEKEVENT), c.SDL_FIRSTEVENT, c.SDL_LASTEVENT );
  
    for(sdl_events)|sdl_event|{
        const _key_event = sdl_event.key.keysym.sym;
        switch (sdl_event.type) {
            c.SDL_KEYDOWN => {
                handler.changeState(to_event_key(_key_event), .pressed, time);
            },
            c.SDL_KEYUP =>{
                handler.changeState(to_event_key(_key_event), .released, time);
            },
            c.SDL_MOUSEBUTTONDOWN=>{
               // c.SDL_LogInfo(c.SDL_LOG_CATEGORY_APPLICATION, "[SDL]Mouse Down: %d x %d", sdl_event.button.x, sdl_event.button.y);
            },
        
            
            else => {},
        }
    }
}
