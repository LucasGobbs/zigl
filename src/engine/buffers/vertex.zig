const c = @import("../../c.zig").c;
const VertexArray = @import ("./vertex_array.zig").VertexArray;
pub const f16Vertex = GenericVertex(f16);
pub const f32Vertex = GenericVertex(f32);
pub const f64Vertex = GenericVertex(f64);

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

        pub fn layout(buffer: f32Vertex, layout: anytype) !*VertexArray {
        var va_instance = VertexArray.create();
        var vl_instance = VertexBufferLayout.create();
        inline for(layout) |element| {
            comptime const kind = element[0];
            comptime const count = element[1];
            switch(kind){
                .float => {try vl_instance.addFloat(count);},
                .uint  => {try vl_instance.addUnsignedInt(count);},
                .ubyte => {try vl_instance.addUnsignedByte(count);},
                else => {@panic("Error");},
            }
   
        }
        va_instance.addBuffer(buffer, vl_instance);
        return &va_instance;
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