import Pkg;
using SerialPorts;
# using Plots;

# recording chirp
sp = SerialPort("/dev/tty.usbmodem48351501", 9600);

readavailable(sp)

write(sp,"s\n")
write(sp,"c\n")
write(sp,"a\n")

while true
    write(sp,"s\n")
end


while bytesavailable(sp) < 1
    sleep(1)
end
sleep(1);
global sbuffera = "";

while true
    sleep(0.01)
    if bytesavailable(sp) < 1
        break
    end
    global sbuffera = string(sbuffera,readavailable(sp))
end

# sbuffera = readavailable(sp);
sbs = split(sbuffera,"\r\n")
# print(length(sbs))

write(sp,"b\n")
global sbufferb = "";
while true
    sleep(0.01)
    if bytesavailable(sp) < 1
        break
    end
    global sbufferb = string(sbufferb,readavailable(sp))
end

sbsb = split(sbufferb,"\r\n")



# v_rx = Vector{UInt16}(sbuffer);

# avg_in = mean(v_rx)
# v_rx = v_rx .- avg_in;

# plot(v_rx);
# print(v_rx);

# lower =
# upper =

# chirp_unpadded = v_rx[lower:upper]

# plot(chirp_unpadded);
#
# chirp = zeros(8281)
# for i = 1:length(chirp_unpadded)
#   chirp[i] = chirp_unpadded[i];
# end
#
# # for i = 1:length(chirp)
# #   println(chirp);
# # end
#
# print(chirp);
#
# # chirp array
# chirp = []
