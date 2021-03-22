const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{ .default_target = .{ .abi = .gnu } });
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("zigl", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);

    const vcpkg_path = "D:\\libs\\vcpkg\\installed\\x64-windows\\";

    // SDL2
    exe.addIncludeDir    (vcpkg_path ++ "include\\SDL2");
    exe.addLibPath       (vcpkg_path ++ "lib");
    b.installBinFile     (vcpkg_path ++ "bin\\SDL2.dll", "SDL2.dll");
    exe.linkSystemLibrary("sdl2");

    // glad
    exe.addIncludeDir("deps/glad/");
    exe.addCSourceFile("deps/glad/glad.c", &[_][]const u8{"-std=c99"});
    //exe.linkSystemLibrary("glad");

    exe.linkLibC();
    exe.install();
}
