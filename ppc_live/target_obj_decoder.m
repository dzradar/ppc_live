function [obj_list] = target_obj_decoder(data_frame, frame_num, Ntarget)

obj_list = [];
offset = 0;
pos = 16;
for n=1:Ntarget
    target_id = typecast(uint8(data_frame(pos+offset+1:pos+offset+2)), 'uint16');
    offset = offset +2;
    confi = typecast(uint8(data_frame(pos+offset+1:pos+offset+2)), 'uint16');
    offset = offset +2;
    x = typecast(uint8(data_frame(pos+offset+1:pos+offset+4)), 'single');
    offset = offset +4;
    y = typecast(uint8(data_frame(pos+offset+1:pos+offset+4)), 'single');
    offset = offset +4;
    z = typecast(uint8(data_frame(pos+offset+1:pos+offset+4)), 'single');
    offset = offset +4;
    vx = typecast(uint8(data_frame(pos+offset+1:pos+offset+4)), 'single');
    offset = offset +4;
    vy = typecast(uint8(data_frame(pos+offset+1:pos+offset+4)), 'single');
    offset = offset +4;
    vz = typecast(uint8(data_frame(pos+offset+1:pos+offset+4)), 'single');
    offset = offset +4;
    obj_rad = typecast(uint8(data_frame(pos+offset+1:pos+offset+2)), 'uint16');
    offset = offset +2;
    fall_flag = typecast(uint8(data_frame(pos+offset+1:pos+offset+2)), 'uint16');
    offset = offset +2;
    
    
    obj_list = [obj_list; x y z vx vy vz single(obj_rad) single(fall_flag) single(target_id) single(confi) ];
end

end