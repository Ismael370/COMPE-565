% COMPE 565 HW3
% April 3, 2022
% Names: Ismael Chavez, Charles Kaui
% Red ID: 819113653, 818404386
% Email: ichavez1191@sdsu.edu, ckaui3713@sdsu.edu

%%%Note: run this script to replicate the results
clc, clear

video = VideoReader('football_qcif.avi');

for i = 10:10
    ref_frame = read(video,i);
    curr_frame = read(video, i+1);
    
    ref_frame = rgb2ycbcr(ref_frame);
    curr_frame = rgb2ycbcr(curr_frame);
    
    %%%Separate the ycbcr channels
    y_ref = ref_frame(:,:,1);
    cb_ref_sub = ref_frame(1:2:144,1:2:176, 2);
    cr_ref_sub = ref_frame(1:2:144,1:2:176, 3);
    
    y_curr = curr_frame(:,:,1);
    cb_curr_sub = curr_frame(1:2:144,1:2:176, 2);
    cr_curr_sub = curr_frame(1:2:144,1:2:176, 3);
    
    sad = zeros(1, 289);
    i = 1;
    
    %%%Iterate through the macroblocks
    for n = 16:16:144
        for m = 16:16:176
%             mb_ref = y_ref(n-15:n, m-15:m);
            mb_curr = y_curr(n-15:n, m-15:m);
            
            %%%Search window rows and cols
            start_row = n-23;
            end_row = n+8;
            start_col = m-23;
            end_col = m+8;
            
            %%%Handle edge cases
            if n == 16
                start_row = 1;
            end
            
            if n == 144
                end_row = 144;
            end
            
            if m == 16
                start_col = 1;
            end
            
            if m == 176
                end_col = 176;
            end
            
            for row = start_row:end_row-16
                for col = start_col:end_col-16
                    mb_ref = y_ref(row:row+15,col:col+15);
                    sad(i) = abs(sum(sum(mb_ref-mb_curr)));
                    i = i+1;
                end
            end
            i = 0;
            
        end
    end
end

