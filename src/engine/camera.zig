
const math = @import("zlm");
const tau = @import("std").math.tau;


pub const Camera = struct {
    position: math.Vec3,
    target: math.Vec3,
    direction: math.Vec3,
    up: math.Vec3,

    yaw: f32 = -tau/4.0,
    pitch: f32 = 0,

    max_pitch: f32 = tau/8.0,
    pub fn create(pos: math.Vec3, dir: math.Vec3, up: math.Vec3) Camera {
        return Camera{
            .position = pos,
            .target = math.Vec3.add(pos,dir),
            .direction = dir,
            .up = up,
        };
    }
    pub fn move_side(self: *Camera, amount: f32) void {
        const right = math.Vec3.cross(self.direction, self.up);

        self.position = math.Vec3.add(self.position, math.Vec3.scale(math.Vec3.normalize(right), amount));
    }
    pub fn move_straight(self: *Camera, amount: f32) void {
        const _dir = math.Vec3.scale(self.direction, amount) ;
        self.position = math.Vec3.add(self.position, _dir);
    }
    pub fn pan(self: *Camera, offset: math.Vec2) void {
        self.yaw += offset.x;
        self.pitch += offset.y;

       
        if (self.pitch > self.max_pitch) {
            self.pitch = self.max_pitch;
        } 
        else if(self.pitch < -self.max_pitch) {
            self.pitch = -self.max_pitch;
        }
       

        self.direction.x = @cos(self.yaw) * @cos(self.pitch);
        self.direction.y = @sin(self.pitch);
        self.direction.z = @sin(self.yaw) * @cos(self.pitch);
        self.direction = math.Vec3.normalize(self.direction);

        self.target = math.Vec3.add(self.position, self.direction);

    }
    pub fn getMatrix(self: Camera) math.Mat4 {
        return math.Mat4.createLook(self.position, self.direction, math.vec3(0.0,-1.0,0.0));
    }
};