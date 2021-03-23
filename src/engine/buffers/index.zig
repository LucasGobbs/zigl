const c = @import("../../c.zig").c;

pub const Index = struct {
    id: c.GLuint,
    data: []c.GLuint,
    


    pub fn create(data: []c.GLuint) Index {
        var _id: c.GLuint = undefined;
    
        c.glGenBuffers(1, &_id);
        c.glBindBuffer(c.GL_ELEMENT_ARRAY_BUFFER, _id);
        c.glBufferData(c.GL_ELEMENT_ARRAY_BUFFER, @intCast(c_longlong, data.len * @sizeOf(c_uint)), @ptrCast(*const c_void, data) , c.GL_STATIC_DRAW );

        return Index {
            .id = _id,
            .data = data,
        };
    } 
    pub fn bind(self: Index) void {
        c.glBindBuffer(c.GL_ELEMENT_ARRAY_BUFFER, self.id);
    }
    pub fn destroy(self: Index) void {
        c.glDeleteBuffers(1, &self.id);
    }
};
