import Pkg;
using Plots;
using SerialPorts;
using FFTW;
using Statistics;
include("chirp.ji");

# Pkg.add("SerialPorts")

# %% define rect
rect(t) = (abs.(t) .<= 0.5)*1.0;
# https://github.com/JuliaIO/LibSerialPort.jl/blob/master/examples/console.jl
# function serial_loop(sp::SerialPort)
#     input_line = ""
#     mcu_message = ""
#
#     println("Starting I/O loop. Press ESC [return] to quit")
#
#     while true
#         # Poll for new data without blocking
#         @async input_line = readline(keep=true)
#         @async mcu_message *= read(sp, String)
#
#         # Alternative read method:
#         # Requires setting a timeout and may cause bottlenecks
#         # @async mcu_message = readuntil(sp, "\r\n", 50)
#
#         occursin("\e", input_line) && exit()
#
#         # Send user input to device
#         if endswith(input_line, '\n')
#             write(sp, "$input_line")
#             plotrec(sp)
#             input_line = ""
#         end
#
#         # Give the queued tasks a chance to run
#         sleep(0.0001)
#     end
# end
#
# function console(args...)
#
#     # if length(args) != 2
#     #     println("Usage: $(basename(@__FILE__)) port baudrate")
#     #     println("Available ports:")
#     #     list_ports()
#     #     return
#     # end
#
#     # Open a serial connection to the microcontroller
#     mcu = SerialPort("COM3:", 9600);
#
#     serial_loop(mcu)
# end
#
# console();

rect(t) = (abs.(t) .<= 0.5)*1.0;

function plotrec()
    # set up Axes
    receivePeriod = 7.246e-6
    receivingTime = 60e-3
    receiveTimeAxis = collect(5e-3:receivePeriod:receivingTime + 5e-3)
    B = 2000
    f0 = 40e3

    # create range array
    c = 343
    range = c * receiveTimeAxis / 2

    # define frequency axis
    N = length(receiveTimeAxis)
    Δf = 1 / (N * receivePeriod)
    f_axis = (0:N-1) * Δf

    Δω = 2*pi*Δf;
    ω = 2*pi .* f_axis;
    ω0 = 2*pi*f0;

    CHIRP = fft(chirp);
    H = conj(CHIRP);


    BPF = rect((ω .- ω0)/(2*π*B)) + rect( (ω .+ (ω0 .- 2*π/receivePeriod) )/(2*π*B) );


    rangeDependence = range.^2;
    v_mf_compensated = rangeDependence .* v_mf;

    sp = SerialPort("/dev/tty.usbmodem48351501", 9600);
    # sp = SerialPort("COM3:", 9600);
    while true
        readavailable(sp)

        write(sp,"s\n")
        write(sp,"c\n")
        write(sp,"a\n")

        while bytesavailable(sp) < 1
            sleep(0.1)
        end
        sleep(0.1);

        global sbuffera = "";

        while true
            sleep(0.01)
            if bytesavailable(sp) < 1
                break
            end
            global sbuffera = string(sbuffera,readavailable(sp))
        end


        write(sp,"b\n")
        global sbufferb = "";
        while true
            sleep(0.01)
            if bytesavailable(sp) < 1
                break
            end
            global sbufferb = string(sbufferb,readavailable(sp))
        end

        v_rxl_string = split(sbuffera,"\r\n")
        v_rxr_string = split(sbufferb,"\r\n")

        v_rxl = parse.(Float64, v_rxl_string)
        v_rxr = parse.(Float64, v_rxr_string)

        # remove DC Component from received signal
        avg_inl = mean(v_rxl);
        v_rxl = v_rxl .- avg_inl;

        # remove DC Component from received signal
        avg_inr = mean(v_rxr);
        v_rxr = v_rxr .- avg_inr;

        # fourier transforms
        V_RXL = fft(v_rxl);
        V_RXR = fft(v_rxr);

        # # filtering
        # V_RXL = V_RXL .* BPF;
        # V_RXR = V_RXR .* BPF;

        # matched filteringn
        V_MFL = H.*V_RXL;
        V_MFR = H.*V_RXR;

        v_mfl = ifft(V_MFL);
        v_mfr = ifft(V_MFR);

        maxVal_l = maximum(v_mfl);
        maxInd_l = argmax(v_mfl);
        maxVal_r = maximum(v_mfr);
        maxInd_r = argmax(v_mfr);

        V_ANAL_L = 2*V_MFL; # make a copy and double the values
        N = length(V_MFL);
        if mod(N,2)==0 # case N even
            neg_freq_range = Int(N/2):N; # Define range of "neg-freq" components
        else # case N odd
            neg_freq_range = Int((N+1)/2):N;
        end
        V_ANAL_L[neg_freq_range] .= 0; # Zero out neg components in 2nd half of array.
        v_anal_l = ifft(V_ANAL_L);

        V_ANAL_R = 2*V_MFR; # make a copy and double the values
        N = length(V_MFR);
        if mod(N,2)==0 # case N even
            neg_freq_range = Int(N/2):N; # Define range of "neg-freq" components
        else # case N odd
            neg_freq_range = Int((N+1)/2):N;
        end
        V_ANAL_R[neg_freq_range] .= 0; # Zero out neg components in 2nd half of array.
        v_anal_r = ifft(V_ANAL_R);

    end

end

#to find maximum index argmin(X), to find maximum value maximum(X)
