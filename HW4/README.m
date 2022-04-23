% COMPE 565 HW4
% May 1, 2022
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
    
    %%%Separate the ycbcr channels in 4:2:0
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
    for mb_row = 16:16:144
        for mb_col = 16:16:176
            min_sad = 999999;
            bm_row = 1;% Best macth ending row
            bm_col = 1; % Best macth ending col
            mb_curr = y_curr(mb_row-15:mb_row, mb_col-15:mb_col);
            
            %%%Search window rows and cols
            start_row = mb_row-23;
            end_row = mb_row+8;
            start_col = mb_col-23;
            end_col = mb_col+8;
            
            %%%Handle edge cases
            if mb_row == 16
                start_row = 1;
            end
            
            if mb_row == 144
                end_row = 144;
            end
            
            if mb_col == 16
                start_col = 1;
            end
            
            if mb_col == 176
                end_col = 176;
            end
            
            %%%Search each macroblock in the window
            for sw_row = start_row+15:end_row
                for sw_col = start_col+15:end_col
                    %%%Calculate SAD
                    mb_ref = y_ref(sw_row-15:sw_row,sw_col-15:sw_col);
                    sad = abs(sum(sum(mb_ref-mb_curr)));
                    
                    if sad < min_sad
                        min_sad = sad;
                        bm_row = sw_row;
                        bm_col = sw_col;
                    end
                end
            end
            
            %append reference point and each motion vector 
            motionVectors = [motionVectors;mb_row,mb_col,bm_row,bm_col];
            
            %%%Reconstruct predicted frame
            y_predicted(mb_row-15:mb_row, mb_col-15:mb_col) = y_ref(bm_row-15:bm_row, ...
                bm_col-15:bm_col); 
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Display the error, reconstrcuted video frames and
    % motion vectors
    % M-file name: README.m
    % Output: Figures 1-4
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    y_diff = y_curr - y_predicted;
    figure, subplot(2,2, 1), imshow(y_predicted), title('Predicted frame');
    subplot(2, 2, 2), imshow(y_diff), title('Difference frame');
    subplot(2,2,[3,4]), quiver(motionVectors(:,1),motionVectors(:,2), ...
        motionVectors(:,3),motionVectors(:,4)),title('Motion Vectors');
        
    %%%DCT on residual frame
    y_diff_decoded = zeros(144, 176);
    y_decoded = zeros(144, 176);
        
    for x = 1:8:144
        for y = 1:8:176
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Encoder
            % M-file name: dct.m, README.m
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            y_dct = dct(y_diff(x:x+7, y:y+7));
            y_quant = round(y_dct/28);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Decoder
            % M-file name: inv_dct.m, README.m
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            y_quant_inv = y_quant*28;
            y_dct_inv = inv_dct(y_quant_inv);
            
            y_diff_decoded(x:x+7, y:y+7) = y_dct_inv;
        end
    end
    
    y_decoded = uint8(y_diff_decoded) + y_predicted;
    
end
