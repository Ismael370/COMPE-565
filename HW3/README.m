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
    
    y_ref = ref_frame(:,:,1);
    cb_ref_sub = ref_frame(1:2:144,1:2:176, 2);
    cr_ref_sub = ref_frame(1:2:144,1:2:176, 3);
    
    y_curr = curr_frame(:,:,1);
    cb_curr_sub = curr_frame(1:2:144,1:2:176, 2);
    cr_curr_sub = curr_frame(1:2:144,1:2:176, 3);
    
    sad = zeros(1, 289);
    
    %%%Iterate through the macroblocks
    for n=1:16:144
        for m=1:16:176
            mb_ref = y_ref(n:n+15, m:m+15);
            mb_curr = y_curr(n:n+15, m:m+15);
            
            %%%Search window rows and cols
            start_row = n-8;
            end_row = n+23;
            start_col = m-8;
            end_col = m+23;
            
            if n == 1
                start_row = 1;
            end
            
            if m == 1
                start_col = 1;
            end
            
%             sad() = abs(sum(mb_ref(:)-mb_curr(:)));
        end
    end
%     figure, subimage(y_ref);
%     figure, subimage(y_curr);
end

