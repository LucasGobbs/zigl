const c = @import("../c.zig").c;
const Hash = @import("std").AutoHashMap;
const test_allocator = @import("std").testing.allocator;
const event_backend = @import("./sdl_event_backend.zig");
const std = @import("std");
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
    current_time: f32 = 0.0,


    last_state: key_state = .empty,
    last_time: f32 = 0.0,

    pub fn consume(self: *Key) key_state {
        const old_state = self.current_state;
        switch(self.current_state){
            .holded => {}, // Because hold events cannot be consumed
            else => {self.changeState(.empty, 0.0);}
        }
        return old_state;
    }
    pub fn changeState(self: *Key, new_state: key_state, new_time: f32) void {
        self.save();
        switch(new_state){
            .pressed => {
                if(self.current_state == .pressed){
                    self.current_state = .holded;
                } else if(self.current_state != .holded){
                     self.current_state = .pressed;
                } 
            },
            else => {
                self.current_state = new_state;
            },
        }
        
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
    pub fn debug(self: KeyboardEvent, code: key_code) !void {
        const stdout = std.io.getStdOut().writer();
        const key = self.keys.get(code);
        try stdout.print("Key {}: ", .{code});
        try stdout.print("\n  Current  -> State: {}\t| Time: {d:.2}", .{key.?.current_state, key.?.current_time});
        try stdout.print("\n  Last     -> State: {}\t| Time: {d:.2}\n\n", .{key.?.last_state, key.?.last_time});
        
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

