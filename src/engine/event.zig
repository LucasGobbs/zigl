

// handle keys

// onPress
// onHold
// onDoublePress
pub const EventType = enum {
    pressed,
    holded,
    released,
    double_pressed,
};
pub const Action = struct {

};

pub const Event = struct {
    event_type: EventType

};

pub const EventHandler = struct {

};
