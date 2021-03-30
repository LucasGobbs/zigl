
const math = @import("zlm");

pub const Vertex = packed struct {
    pos: math.Vec3,
    normal: ?math.Vec3,
    uv: ?math.Vec2,
    color: ?math.Vec3,
};

pub const Mesh = struct {
    // vertices
    // normals
    // uv
    vertices: []Vertex,
    indices: []u32,
};