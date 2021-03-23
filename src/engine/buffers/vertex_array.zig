const c = @import("../../c.zig").c;
const std = @import("std");
const ArrayList = std.ArrayList;
const f32Vertex = @import("./vertex.zig").f32Vertex;
const test_allocator = std.testing.allocator;

pub const VertexArray = struct {
    id: c_uint,
    pub fn create() VertexArray {
        var instance = VertexArray {
            .id = 0,
        };
        c.glGenVertexArrays(1, &instance.id);
        return instance;
    }
    pub fn addBuffer(self: VertexArray, vb: f32Vertex, layout: VertexBufferLayout) void {
        self.bind();
        vb.bind();
        var offset: u32 = 0;
        for (layout.elements.items) |element, index| {
            c.glEnableVertexAttribArray(@intCast(c_uint, index));
            c.glVertexAttribPointer(
                @intCast(c_uint, index), 
                @intCast(c_int, element.count), 
                element.gltype, 
                element.normalized, 
                @intCast(c_int, layout.stride), 
                @intToPtr(?*const c_void, offset)
            );
            offset += element.count * VertexBufferElement.sizeOf(element.gltype);
        }
    }
    pub fn bind(self: VertexArray) void {
        c.glBindVertexArray(self.id);
    }
    pub fn unbind(self: VertexArray) void {
        c.glBindVertexArray(0);
    }
    pub fn destroy(self: VertexArray) void {
        c.glDeleteVertexArray(self.id);
    }
};


pub const VertexBufferLayout = struct {
    stride: u32,
    elements: ArrayList(VertexBufferElement),
    pub fn create() VertexBufferLayout {
        return VertexBufferLayout{
            .stride = 0,
            .elements = ArrayList(VertexBufferElement).init(test_allocator),
        };
    }

    pub fn addFloat(self: *VertexBufferLayout, count: u32) !void {
        try self.push(c.GL_FLOAT, count, c.GL_FALSE);
    }
    pub fn addUnsignedInt(self: *VertexBufferLayout, count: u32) void {
        try self.push(c.GL_UNSIGNED_INT, count, c.GL_FALSE);
    }
    pub fn addUnsignedByte(self: VertexBufferLayout, count: u32) void {
        try self.push(c.GL_UNSIGNED_BYTE, count, c.GL_TRUE);
    }

    pub fn push(self: *VertexBufferLayout,  gltype: u32, count: u32, normalized: u8) !void {
        var new_element = VertexBufferElement{.gltype = gltype, .count = count, .normalized = normalized};
        try self.elements.append(new_element);
        self.stride += count * VertexBufferElement.sizeOf(gltype);
    }

    pub fn destroy(self: VertexBufferLayout) void {
        self.elements.deinit();
    }
};

pub const VertexBufferElement = struct {
    gltype: u32,
    count: u32,
    normalized: u8,
    pub fn sizeOf( gltype: c_uint) c_uint{
        return switch(gltype){
            c.GL_FLOAT => @sizeOf(c.GLfloat),
            c.GL_UNSIGNED_INT => @sizeOf(c.GLuint),
            c.GL_UNSIGNED_BYTE => @sizeOf(c.GLbyte), 
            else => 0,
        };
    }
};