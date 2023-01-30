classdef Packet_Types
    methods
        % Returns 1 if no error
        function result = System_A(~)
            my_functions = FunctionAPI;
            %System A, Hamming(7,4)
            %20 byte data = 160 bits
            %44 codewords => 38.5 bytes
            % Create packet
            packet = my_functions.create_packet(160); 
            %Calculate CRC
            crc = my_functions.encode_crc(packet); 
            %Add crc to packet
            packet_crc = [packet crc]; 
            %Add Hammingcode to the packet
            hammingcoded_packet = my_functions.encode_hamming(packet_crc); 
            %Transmit
            hammingcoded_packet = my_functions.BSC(hammingcoded_packet);
            %Decoding the hamming code
            decoded_packet = my_functions.decode_hamming(hammingcoded_packet);
            remainder = my_functions.decode_crc(decoded_packet);
            result = (all(remainder == 0));
        end
        %Returns 1 if no error
        function result = System_B(~)
            my_functions = FunctionAPI;
            %System B, 296 bits and 16 bits CRC
            packet = my_functions.create_packet(296);
            %Calculate CRC
            crc = my_functions.encode_crc(packet);
            %Add CRC to packet
            packet_crc = [packet crc];
            %BSC
            packet_crc = my_functions.BSC(packet_crc);

            %Decode and error detection
            reminder = my_functions.decode_crc(packet_crc);
            result = all(reminder == 0);
        end

    end
end
















