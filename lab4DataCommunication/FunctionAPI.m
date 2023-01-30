classdef FunctionAPI
    methods 
        %Generate a packet, binary vector of n bits
        function packet = create_packet(~,n)
            packet = randi([0 1],1,n); 
        end

        % Generating the FCS 16 bits CRC-encoding
        function crc = encode_crc(~, message)
            P = [1 1 0 0 0 0 0 0 0 0 0 0 0 1 0 1]; %CRC-16 polynom
            message_shifted = [message zeros(1, 16)]; % Shift 16 bits

            crc = xor(message_shifted(1:length(P)), P);
            i = 0;
            while length(message_shifted) > length(P) + i
                if crc(1) == 0
                    crc = circshift(crc, -1);
                    crc(length(crc)) = message_shifted(length(P)+i+1);
                    i = i + 1;
                else
                    crc = xor(crc, P);
                end
            end
        end
        
        %Checksum on the received message with CRC-16 polynom
        function remainder = decode_crc(~,received_packet)
            P = [1 1 0 0 0 0 0 0 0 0 0 0 0 1 0 1]; %CRC-16 polynom
            remainder = xor(received_packet(1:length(P)), P);

            i = 0;
            while length(received_packet) > length(P) + i
                if remainder(1) == 0
                    remainder = circshift(remainder, -1);
                    remainder(length(remainder)) = received_packet(length(P)+i+1);
                    i = i + 1;
                else
                    remainder = xor(remainder, P);
                end
            end
        end

        %Adding an error vector to transmitted packet
        function adding_error_vector = BSC(~,packet) 
            n = length(packet);
            p = 0.001; 
            error_vector = zeros(1,n);

            for i = 1:n
                if rand() < p
                    error_vector(i) = 1;
                end
            end
            adding_error_vector = xor(packet, error_vector);
        end

        %System A
        %20 byte data = 160 bits
        function hamming = encode_hamming(~,packet)
            %Will return a vector of size 1.75*length
            %G = [I:A] Generator matrix
            G = [1 0 0 0 1 1 1;
                 0 1 0 0 0 1 1;
                 0 0 1 0 1 0 1;
                 0 0 0 1 1 1 0];
            
            %Generating codewords and adding to new hammingcoded packet
            hamming = [];
            for i = 1:4:ceil(length(packet))
                data = packet(i:i+3);
                codeword = mod(data*G, 2); %mod 2
                hamming = horzcat(hamming,codeword);
            end  
        end

        %Decode the hammingcode in receivers end
        function decoded_packet = decode_hamming(obj,packet)
            %Will return a vector of size length/1.75
            %H= [-A_transpose:I] Parity check matrix
            H = [1 0 1 1 1 0 0
                 1 1 0 1 0 1 0
                 1 1 1 0 0 0 1];
            H_transpose = transpose(H);
            decoded_packet = [];
            
            for i = 1:7:length(packet)
                S = mod(packet(i:i+6)*H_transpose,2); %Calculating the syndrome
                if length(packet(i:i+6)) < 7
                    % Not enough elements to form a complete codeword
                    break;
                end
                if ~all(S==0)
                    index_of_error = 0;
                    for j = 3:-1:1
                        index_of_error = index_of_error + S(j)*power(2,-(j-3));
                    end
                    if index_of_error > 7 || index_of_error + i - 1 > 308
                        break;
                    end
                    index_converted = obj.convert_index(index_of_error);
         
                    packet(i+index_converted-1) = bitxor(packet(i+index_converted-1), 1); % Correct the error
                end
                decoded_packet = [decoded_packet, packet(i:i+3)];
            end
        end
        %Help function in order to make the syndrome right
        function index = convert_index(~, index_to_convert)
            if index_to_convert == 1
                index = 7;
            elseif index_to_convert == 2
                index = 3;
            elseif index_to_convert == 3
                index = 5;
            elseif index_to_convert == 4
                index = 6;
            elseif index_to_convert == 5
                index = 4;
            elseif index_to_convert == 6
                index = 2;
            elseif index_to_convert == 7
                index = 1;
            end
        end
    end                        
end



