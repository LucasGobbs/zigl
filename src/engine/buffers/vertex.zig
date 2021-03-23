const c = @import("../../c.zig").c;


pub const f32Vertex = GenericVertex(f32);


pub fn GenericVertex(comptime T: type) type {
    return struct {
        id: c.GLuint,
        data: []T,
      
        const Self = @This();

        pub fn create(data: []T) Self {
            var _id: c.GLuint = undefined;
        
            c.glGenBuffers(1, &_id);
            c.glBindBuffer(c.GL_ARRAY_BUFFER, _id);
            c.glBufferData(c.GL_ARRAY_BUFFER, @intCast(c_longlong, data.len * @sizeOf(T)), @ptrCast(*const c_void, data) , c.GL_STATIC_DRAW );

            return Self {
                .id = _id,
                .data = data,
            };
        } 
        pub fn bind(self: Self) void {
            c.glBindBuffer(c.GL_ARRAY_BUFFER, self.id);
        }
        pub fn unbind() void {
            c.glBindBuffer(c.GL_ARRAY_BUFFER, 0);
        }
        pub fn destroy(self: Self) void {
            c.glDeleteBuffers(1, &self.id);
        }
    };
}