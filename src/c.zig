  
pub const c = @cImport({
    @cInclude("glad.h");
    @cInclude("SDL.h");
    @cInclude("stb_image.h");
});
