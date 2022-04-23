function coeff = dct(block)
    coeff = zeros(8, 8);
    block = double(block)-128;
    
    for k = 1:8
        for l = 1:8
            
            %%%Summation of block elements
            for i = 1:8
                for j = 1:8
                    coeff(k,l) = coeff(k,l) + block(i,j)*cos(((2*(i-1)+1)*pi*(k-1))/16)*cos(((2*(j-1)+1)*pi*(l-1))/16);
                end
            end
            
            %%%Multiply by coefficients
            if k == 1
                coeff(k,l) = coeff(k,l)*(1/sqrt(2));
            end
            if l == 1
                coeff(k,l) = coeff(k,l)*(1/sqrt(2));
            end
            
            coeff(k,l) = coeff(k,l)*(2/sqrt(64));
            
        end
    end
end