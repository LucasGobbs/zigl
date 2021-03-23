const c = @import("../c.zig").c;
const std = @import("std");
const math = @import("zlm");
pub const Shader_type = enum {
    frag,
    vert
};

pub const ShaderProgram = struct {
    path: []const u8,
    id: c_uint,
    vertex: Shader,
    fragment: Shader,
    pub fn create(comptime path: [:0]const u8) !ShaderProgram {
        const _id = c.glCreateProgram();
        const _vertex = try Shader.create(path ++ ".vert", .vert);
        c.glAttachShader(_id, _vertex.id);

        const _fragment = try Shader.create(path ++ ".frag", .frag);
        c.glAttachShader(_id, _fragment.id);
        
        c.glLinkProgram(_id);
        return ShaderProgram{
            .id = _id,
            .path = path,
            .vertex = _vertex,
            .fragment = _fragment,
        };
    }
    pub fn setUniformMat4f(self: ShaderProgram, name: [:0]const u8, mat: math.Mat4) void {
        c.glUniformMatrix4fv(self.getUniform(name), 1, c.GL_FALSE, @ptrCast([*c]const f32, &mat.fields));
    }

    fn getUniform(self: ShaderProgram, name: [:0]const u8) c_int {
        const location = c.glGetUniformLocation(self.id, name);
        return location;
    }
    pub fn destroy(self: ShaderProgram) void {
        c.glDeleteShader(self.vertex.id);
        c.glDetachShader(self.id, self.vertex.id);

        c.glDeleteShader(self.fragment.id);
        c.glDetachShader(self.id, self.fragment.id);

        c.glDeleteProgram(self.id);
    }
};
pub const Shader = struct {
    id: c_uint,
    _type: Shader_type,
    pub fn create(comptime src: []const u8, _type: Shader_type) !Shader {
        const id = try compile(@embedFile(src), _type);
        return Shader{
            .id = id,
            ._type = _type,
        } ;
    }
    
    pub fn destroy(self: Shader) void {
        _ = c.glDeleteShader(shader.id);
    }
};

fn compile(src: []const u8, _type: Shader_type) !c_uint {
    const shader = c.glCreateShader(
        switch(_type){
            .vert => c.GL_VERTEX_SHADER,
            .frag => c.GL_FRAGMENT_SHADER,
        }
    );
    errdefer c.glDeleteShader(shader);

    c.glShaderSource(
        shader,
        1,
        &@ptrCast([*c] const u8, src),
        &(@intCast(c_int, src.len)),
    );
    c.glCompileShader(shader);
    var success: c_int = undefined;
    c.glGetShaderiv(shader, c.GL_COMPILE_STATUS, &success);
    if(success != c.GL_TRUE){
        logGlInfoLog(.shader, shader);
        return error.CompileShaderError;
    }
    return shader;
}
const GlInfoLogKind = enum {
    shader,
    program,
};
fn logGlInfoLog(object_kind: GlInfoLogKind, object: c_uint) void {
    const info_log_max_len = 4096; // TODO Use allocator?
    var info_log: [info_log_max_len]u8 = undefined;
    var info_log_len: c_int = undefined;
    switch (object_kind) {
        .shader => c.glGetShaderInfoLog(object, info_log.len, &info_log_len, &info_log),
        .program => c.glGetProgramInfoLog(object, info_log.len, &info_log_len, &info_log),
    }
    if (info_log_len > 0 and info_log[@intCast(usize, info_log_len) - 1] == '\n') info_log_len -= 1;
    std.log.scoped(.gl).notice("GL {} info log:\n=== begin log ===\n{}\n=== end log ===", 
    .{
        @tagName(object_kind),
        info_log[0..@intCast(usize, info_log_len)],
    });
}
/// OpenGL error set.
/// Source: https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/glGetError.xhtml
const GlError = error{
    /// An unacceptable value is specified for an enumerated argument. The
    /// offending command is ignored and has no other side effect than to set
    /// the error flag.
    InvalidEnum,
    /// A numeric argument is out of range. The offending command is ignored
    /// and has no other side effect than to set the error flag.
    InvalidValue,
    /// The specified operation is not allowed in the current state. The
    /// offending command is ignored and has no other side effect than to set
    /// the error flag.
    InvalidOperation,
    /// The framebuffer object is not complete. The offending command is
    /// ignored and has no other side effect than to set the error flag.
    InvalidFramebufferOperation,
    /// There is not enough memory left to execute the command. The state of
    /// the GL is undefined, except for the state of the error flags, after
    /// this error is recorded.
    OutOfMemory,
    /// An attempt has been made to perform an operation that would cause an
    /// internal stack to underflow.
    StackUnderflow,
    /// An attempt has been made to perform an operation that would cause an
    /// internal stack to overflow.
    StackOverflow,
};
fn glGetError() GlError!void {
    switch (c.glGetError()) {
        c.GL_NO_ERROR => return,
        c.GL_INVALID_ENUM => return error.InvalidEnum,
        c.GL_INVALID_VALUE => return error.InvalidValue,
        c.GL_INVALID_OPERATION => return error.InvalidOperation,
        c.GL_INVALID_FRAMEBUFFER_OPERATION => return error.InvalidFramebufferOperation,
        c.GL_OUT_OF_MEMORY => return error.OutOfMemory,
        c.GL_STACK_UNDERFLOW => return error.StackUnderflow,
        c.GL_STACK_OVERFLOW => return error.StackOverflow,
        else => unreachable,
    }
}
