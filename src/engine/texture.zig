const c = @import("../c.zig").c;
const panic = @import("std").debug.panic;
pub const Texture = struct {
    path: [:0]const u8,
    width: c_int,
    height: c_int,
    id: u32,
    pub fn create(comptime path: [:0]const u8) !Texture {
        var width: c_int = undefined;
        var height: c_int = undefined;
        var channel_count: c_int = undefined;

        const data = c.stbi_load(path, &width, &height, &channel_count, 0);
        if(data == null){
            panic("Error creating texture: {s}\n", .{c.stbi_failure_reason()});
        }
        var id: u32 = undefined;

        c.glGenTextures(1, &id);
        c.glBindTexture(c.GL_TEXTURE_2D, id);
        // set the texture wrapping parameters
        c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_S, c.GL_REPEAT);
        c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_T, c.GL_REPEAT);
        // set texture filtering parameters
        c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_LINEAR);
        c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_LINEAR);

        c.glTexImage2D(c.GL_TEXTURE_2D, 0, c.GL_RGB, width, height, 0, c.GL_RGB, c.GL_UNSIGNED_BYTE, data);
        c.glGenerateMipmap(c.GL_TEXTURE_2D);
        c.stbi_image_free(data);

        return Texture {
            .path = path,
            .width = width,
            .height = height,
            .id = id,
        };
    }
    pub fn bind(self: Texture) void {
        c.glBindTexture(c.GL_TEXTURE_2D, self.id);
    }
};

