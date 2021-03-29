const c = @import("../c.zig").c;
const Hash = @import("std").AutoHashMap;
const test_allocator = @import("std").testing.allocator;
const event_backend = @import("./sdl_event_backend.zig");
const std = @import("std");
pub const key_code = enum {
    start_enum,

    esc,       f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, printscreen, 
    quote,         d1, d2, d3, d4, d5, d6, d7, d8, d9, d0, underline, plus,
    tab,              q, w, e, r, t, y, u, i, o, p, enter,
    capslock,          a, s, d, f, g, h, j,  k,  l, 
    lshift, back_slash, z, x, c, v, b, n, m, comma, less_than, plus_than, dot, rshift,
    lctrl, lalt,                space,           ralt,                          rctrl,

    left, right, up, down,

    end_enum
};

pub const key_state = enum {
    empty,
    pressed,
    holded,
    released,
    double_pressed,
};

pub const StateTracker = struct{
    state: key_state = .empty,
    time: f32 = 0.0,
};

pub const Key = struct {
    current: StateTracker = StateTracker{},
    last: StateTracker = StateTracker{},

    pub fn consume(self: *Key) key_state {
        const old_state = self.current.state;
        switch(self.current.state){
            .holded => {}, // Because hold events cannot be consumed
            else => {self.changeState(.empty, 0.0);}
        }
        return old_state;
    }
    pub fn changeState(self: *Key, new_state: key_state, new_time: f32) void {
        self.save();
        switch(new_state){
            .pressed => {
                if(self.current.state == .pressed){
                    self.current.state = .holded;
                } else if(self.current.state != .holded){
                     self.current.state = .pressed;
                } 
            },
            else => {
                self.current.state = new_state;
            },
        }
        
        self.current.time = new_time;
    }
    
    fn save(self: *Key) void {
        self.last.state = self.current.state;
        self.last.time = self.current.time;
    }
};
pub const KeyHash = struct {
    keys: Hash(key_code, Key),
    pub fn create() !KeyHash {

        var keys_hash = Hash(key_code, Key).init(
            test_allocator,
        );

        var index = @enumToInt(key_code.start_enum);
        const last_key_code = @enumToInt(key_code.end_enum); 
        while (index <= last_key_code){
            try keys_hash.put(@intToEnum(key_code, index), Key{});
            index += 1;
        }

        return KeyHash {
            .keys = keys_hash
        };
    }
    // get
    // add 
    // remove
    
};
pub const KeyboardEvent = struct {
    keys: Hash(key_code, Key),
    pub fn create() !KeyboardEvent {
        var keys_hash = try KeyHash.create();
        
        return KeyboardEvent {
            .keys = keys_hash
        };
    }
    pub fn debug(self: KeyboardEvent, code: key_code) !void {
        const stdout = std.io.getStdOut().writer();
        const key = self.keys.get(code);
        try stdout.print("Key {}: ", .{code});
        try stdout.print("\n  Current  -> State: {}\t| Time: {d:.2}", .{key.?.current.state, key.?.current.time});
        try stdout.print("\n  Last     -> State: {}\t| Time: {d:.2}\n\n", .{key.?.last.state, key.?.last.time});
        
    }
    pub fn getKeyState(self: *KeyboardEvent, code: key_code) key_state{
        var key = self.keys.get(code);
        var state = key.?.consume();
        return state;
    } 
    pub fn isPressed(self: *KeyboardEvent, code: key_code) bool {
        var state = self.getKeyState(code);
        return state == key_state.pressed;
    }
    pub fn isHolded(self: *KeyboardEvent, code: key_code) bool {
        var state = self.getKeyState(code);
        return state == key_state.holded;
    }
    //Pressed or holded
    pub fn isActive(self: *KeyboardEvent, code: key_code) bool {
        var state = self.getKeyState(code);
        return state == key_state.pressed or state == key_state.holded;
    }

    pub fn changeState(self: *KeyboardEvent, code: key_code, new_state: key_state, time: f32) void {
        var old_key = self.keys.get(code);
        old_key.?.changeState(new_state, time);
        self.keys.put(code, old_key.?) catch |err|{
            @panic("aa");
        };

    }
    pub fn update(self: *KeyboardEvent, time: f32 ) !void {
        event_backend.update(self, time);
    } 
    pub fn destroy(self: *KeyboardEvent) void {
        self.keys.deinit();
    }

};

pub const Mouse = struct {
    x: f32,
    y: f32,
};


