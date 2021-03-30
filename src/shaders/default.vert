#version 330 core
layout (location = 0) in vec3 position;
layout (location = 1) in vec3 aColor; // 
layout (location = 2) in vec2 aUv;
out vec2 uv;
out vec3 ourColor; 
uniform mat4 model;
uniform mat4 projection;
uniform mat4 view;

void main() {
    gl_Position = projection * view * model * vec4(position.x, position.y, position.z, 1.0);
    ourColor = aColor;
    uv = aUv;
}