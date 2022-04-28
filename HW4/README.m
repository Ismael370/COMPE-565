% COMPE 565 HW4
% May 1, 2022
% Names: Ismael Chavez, Charles Kaui
% Red ID: 819113653, 818404386
% Email: ichavez1191@sdsu.edu, ckaui3713@sdsu.edu

%%%Note: run this script to replicate the results
clc, clear

video = VideoReader('football_qcif.avi');

y_ref = zeros(144, 176);

for i = 10:14
    curr_frame = read(video, i);
    curr_frame = rgb2ycbcr(curr_frame);
    
    %%%Separate the ycbcr channels in 4:2:0
    y_curr = curr_frame(:,:,1);
    cb_curr_sub = curr_frame(1:2:144,1:2:176, 2);
    cr_curr_sub = curr_frame(1:2:144,1:2:176, 3);
    
    y_predicted = uint8(zeros(144, 176));
    
    if(i > 10)
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

                %%%Reconstruct predicted frame
                y_predicted(mb_row-15:mb_row, mb_col-15:mb_col) = y_ref(bm_row-15:bm_row, ...
                    bm_col-15:bm_col); 
            end
        end

        %%%Calculate difference frame
        y_diff = y_curr - y_predicted;
    end
        
    %%%DCT on difference frame
    y_diff_decoded = uint8(zeros(144, 176));
    y_decoded = uint8(zeros(144, 176));
    
    %%%Y-channel
    for x = 1:8:144
        for y = 1:8:176
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Encoder
            % M-file name: dct.m, README.m
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if(i > 10)
                y_dct = dct(y_diff(x:x+7, y:y+7));
            else
                y_dct = dct(y_curr(x:x+7, y:y+7));
            end
            
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
    
    if(i > 10)
        y_decoded = y_diff_decoded + y_predicted;
    else
        y_decoded = y_diff_decoded;
        y_diff_decoded = zeros(144, 176);
    end
    
    %%%DCT on Cb and Cr channels
    cb_sub_decoded = uint8(zeros(72, 88));
    cr_sub_decoded = uint8(zeros(72, 88));
    
    cb_decoded = uint8(zeros(144, 176));
    cr_decoded = uint8(zeros(144, 176));
    
    for x = 1:8:72
        for y = 1:8:88
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Encoder
            % M-file name: dct.m, README.m
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            cb_dct = dct(cb_curr_sub(x:x+7, y:y+7));
            cr_dct = dct(cr_curr_sub(x:x+7, y:y+7));

            cb_quant = round(cb_dct/28);
            cr_quant = round(cr_dct/28);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Decoder
            % M-file name: inv_dct.m, README.m
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            cb_quant_inv = cb_quant*28;
            cr_quant_inv = cr_quant*28;
            
            cb_dct_inv = inv_dct(cb_quant_inv);
            cr_dct_inv = inv_dct(cr_quant_inv);
            
            cb_sub_decoded(x:x+7, y:y+7) = cb_dct_inv;
            cr_sub_decoded(x:x+7, y:y+7) = cr_dct_inv;
        end
    end
    
    %%%Store frame
    y_ref = y_curr;
    
    %%%Upsample Cb and Cr using replication
    cb_decoded(1:2:144, 1:2:176) = cb_sub_decoded(:, :);
    cb_decoded(2:2:144, :) = cb_decoded(1:2:144, :);
    cb_decoded(:, 2:2:176) = cb_decoded(:, 1:2:176);
    cb_decoded = cb_decoded;
    
    cr_decoded(1:2:144, 1:2:176) = cr_sub_decoded(:, :);
    cr_decoded(2:2:144, :) = cr_decoded(1:2:144, :);
    cr_decoded(:, 2:2:176) = cr_decoded(:, 1:2:176);
    cr_decoded = cr_decoded;
        
    %%%Get RGB frames
    ycbcr_decoded = cat(3, y_decoded, cb_decoded, cr_decoded);
    rgb_decoded = ycbcr2rgb(ycbcr_decoded);
    
    %%%Display difference frame and reconstructed frame
    figure, subplot(1, 2, 1), subimage(y_diff_decoded), title('Decoded Difference frame');
    subplot(1, 2, 2), subimage(rgb_decoded), title('Reconstructed frames');
end
