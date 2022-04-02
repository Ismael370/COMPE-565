% COMPE 565 HW3
% April 3, 2022
% Names: Ismael Chavez, Charles Kaui
% Red ID: 819113653, 818404386
% Email: ichavez1191@sdsu.edu, ckaui3713@sdsu.edu

%%%Note: run this script to replicate the results
clc, clear

video = VideoReader('football_qcif.avi');

for i = 10:13
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
    
    y_predicted = uint8(zeros(144, 176));
    
    %create array to hold motion vectors of this frame and empty
    motionVectors = zeros(1,4);
    motionVectors(:,:) = [];
    
    %%%Iterate through the macroblocks
    for n = 16:16:144
        for m = 16:16:176
            min_sad = 999999;
            bm_row = 1;% Best macth ending row
            bm_col = 1; % Best macth ending col
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
            
            %%%Search each macroblock in the window
            for row = start_row+15:end_row
                for col = start_col+15:end_col
                    %%%Calculate SAD
                    mb_ref = y_ref(row-15:row,col-15:col);
                    sad = abs(sum(sum(mb_ref-mb_curr)));
                    
                    if sad < min_sad
                        min_sad = sad;
                        bm_row = row;
                        bm_col = col;
                    end
                end
            end
            %append reference point and each motion vector 
            motionVectors = [motionVectors;row,col,bm_row,bm_col];
            
            %%%Reconstruct predicted frame
            y_predicted(n-15:n, m-15:m) = y_ref(bm_row-15:bm_row, ...
                bm_col-15:bm_col); 
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Display the error and reconstrcuted video frames
    % M-file name: README.m
    % Output: Figures 1-4
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    y_diff = y_curr - y_predicted;
    figure, subplot(2,2, 1), imshow(y_predicted), title('Predicted frame');
    subplot(2, 2, 2), imshow(y_diff), title('Difference frame');
    subplot(2,2,[3,4]), quiver(motionVectors(:,1),motionVectors(:,2), ...
        motionVectors(:,3),motionVectors(:,4)),title('Motion Vectors');
    
end
