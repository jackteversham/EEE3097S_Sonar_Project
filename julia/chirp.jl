import Pkg;
using SerialPorts;
using Plots;
using Statistics;
include("chirppulse.jl");
# Pkg.add("GR")

# recording chirp
sp = SerialPort("/dev/tty.usbmodem48351501", 9600);

readavailable(sp)

write(sp,"s\n")
# write(sp,"c\n")
write(sp,"a\n")

while true
    write(sp,"s\n")
    # sleep(0.0)
end


while bytesavailable(sp) < 1
    sleep(0.01)
end
sleep(1);

global sbuffera = "";

while true
    sleep(0.02)
    if bytesavailable(sp) < 1
        break
    end
    global sbuffera = string(sbuffera,readavailable(sp))
end

# sbuffera = readavailable(sp);
sbs = split(sbuffera,"\r\n")
v_rxl_string = sbs[1:24000];
# print(length(sbs))

write(sp,"b\n")
global sbufferb = "";
while true
    sleep(0.02)
    if bytesavailable(sp) < 1
        break
    end
    global sbufferb = string(sbufferb,readavailable(sp))
end

sbsb = split(sbufferb,"\r\n")
v_rxr_string = sbsb[1:24000];

v_rxr1 = parse.(Float64, v_rxr_string)
v_rxl1 = parse.(Float64, v_rxl_string)
plot(v_rxl1)
plot(v_rxr1)

# v_rxl = parse.(Float64, v_rxl_string)
# v_rxr = parse.(Float64, v_rxr_string)
#
# using Statistics
#
# avg_chirp = mean(chirp);
# chirp = chirp .- avg_chirp;
#
# chirp_padded = zeros(24000)
# for i = 1:length(chirp)-2300
#     chirp_padded[i+2300]=chirp[i]
# end
# print(chirp_padded)
#
# avg_inl = mean(v_rxl);
# v_rxl = v_rxl .- avg_inl;
#
# using FFTW;
# V_RXL = fft(v_rxl);
# CHIRP = fft(chirp_padded);
# H = conj(CHIRP)
# V_MF = V_RXL .* H
# v_mf = ifft(V_MF)
# plot(real(v_mf))
#
# # v_rx = Vector{UInt16}(sbuffer);
#
# # avg_in = mean(v_rx)
# # v_rx = v_rx .- avg_in;
#
# # plot(v_rx);
# # print(v_rx);
#
# # lower =
# # upper =
#
# # chirp_unpadded = v_rx[lower:upper]
#
# # plot(chirp_unpadded);
# #
# # chirp = zeros(8281)
# # for i = 1:length(chirp_unpadded)
# #   chirp[i] = chirp_unpadded[i];
# # end
# #
# # # for i = 1:length(chirp)
# # #   println(chirp);
# # # end
# #
# # print(chirp);
# #
# # # chirp array
# # chirp = []
# |
