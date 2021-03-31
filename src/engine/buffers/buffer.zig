


pub const BufferType = enum {
    array_buffer,
    element_array_buffer,
};


pub const Buffer = struct {
    _type: BufferType,
    // instance: T,
    pub fn create() Buffer {

    }
    pub fn bind(self: Buffer) void {

    }
    pub fn unbind(self: Buffer) void {
        
    }
    pub fn destroy(self: Buffer) void {
        
    }
};