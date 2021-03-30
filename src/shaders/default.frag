#version 330 core
out vec4 FragColor;
in vec3 ourColor;
in vec2 uv;
uniform sampler2D ourTexture;
void main()
{
    FragColor = texture(ourTexture, uv) * vec4(ourColor, 1.0);
} 