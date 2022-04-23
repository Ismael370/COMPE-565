function values = inv_dct(block)
    values = zeros(8, 8);
    block = double(block);
    
    for i = 1:8
        for j = 1:8
            
            %%%Summation of block elements
            for k = 1:8
                for l = 1:8                         
                    %%%Multiply by coefficients inside the summation
                    if k == 1 && l == 1
                        values(i,j) =  values(i,j) + 0.5*block(k,l)*cos(((2*(i-1)+1)*pi*(k-1))/16)*cos(((2*(j-1)+1)*pi*(l-1))/16);
                    elseif k == 1 || l == 1
                        values(i,j) =  values(i,j) + (1/sqrt(2))*block(k,l)*cos(((2*(i-1)+1)*pi*(k-1))/16)*cos(((2*(j-1)+1)*pi*(l-1))/16);
                    else
                        values(i,j) = values(i,j) + block(k,l)*cos(((2*(i-1)+1)*pi*(k-1))/16)*cos(((2*(j-1)+1)*pi*(l-1))/16);
                    end
                end
            end
            
            %%%Multiply by coefficients outside the summation
            values(i,j) = values(i,j)*0.25;
            
        end
    end
    values = round(values+128);
    values = uint8(values);
end