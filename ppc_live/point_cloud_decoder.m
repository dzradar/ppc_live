function point_list = point_cloud_decoder(data_frame, frame_num, Ntarget)

point_list = [];

pos = 16;
offset = 0;
for n=1:Ntarget
    r = typecast(uint8(data_frame(pos+offset+1:pos+offset+4)), 'single');
    offset = offset +4;
    v = typecast(uint8(data_frame(pos+offset+1:pos+offset+4)), 'single');
    offset = offset +4;
    x = typecast(uint8(data_frame(pos+offset+1:pos+offset+4)), 'single');
    offset = offset +4;
    y = typecast(uint8(data_frame(pos+offset+1:pos+offset+4)), 'single');
    offset = offset +4;
    id = typecast(uint8(data_frame(pos+offset+1:pos+offset+4)), 'single');
    offset = offset +4;
    snr = typecast(uint8(data_frame(pos+offset+1:pos+offset+4)), 'single');
    offset = offset +4;
    point_list = [point_list; r v x y id snr];
end

end