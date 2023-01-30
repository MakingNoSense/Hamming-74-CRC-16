%System A transmits 160 bits/packet
%System B transmits 296 bits/packet
sim = Packet_Types;
func = FunctionAPI;


test = sim.System_A;
test2 = sim.System_B;
%Transmitting for a minute

system1 = 0;
system2 = 0;
for i = 1:800
 system1 = system1 + sim.System_A;
 system2 = system2 + sim.System_B;
end



            

