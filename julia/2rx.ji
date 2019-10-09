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
function serial_loop(sp::SerialPort)
    input_line = ""
    mcu_message = ""

    println("Starting I/O loop. Press ESC [return] to quit")

    while true
        # Poll for new data without blocking
        @async input_line = readline(keep=true)
        @async mcu_message *= read(sp, String)

        # Alternative read method:
        # Requires setting a timeout and may cause bottlenecks
        # @async mcu_message = readuntil(sp, "\r\n", 50)

        occursin("\e", input_line) && exit()

        # Send user input to device
        if endswith(input_line, '\n')
            write(sp, "$input_line")
            plotrec(sp)
            input_line = ""
        end

        # Give the queued tasks a chance to run
        sleep(0.0001)
    end
end

function console(args...)

    # if length(args) != 2
    #     println("Usage: $(basename(@__FILE__)) port baudrate")
    #     println("Available ports:")
    #     list_ports()
    #     return
    # end

    # Open a serial connection to the microcontroller
    mcu = SerialPort("COM3:", 115200);

    serial_loop(mcu)
end

console();

rect(t) = (abs.(t) .<= 0.5)*1.0;

function plotrec(sp::SerialPort)
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

    while true
    # read from serial
        write(sp, "s")
        write(sp, "c")
        write(sp, l)
        while bytesavailable(sp) == 0
            sleep(0.1)
        end
        sbuffer = readavailable(sp)
        v_rxl = Vector{UInt8}(sbuffer)

        write(sp, r)
        while bytesavailable(sp) == 0
            sleep(0.01)
        end
        sbuffer = readavailable(sp)
        v_rxr = Vector{UInt8}(sbuffer)

        # remove DC Component from received signal
        avg_inl = mean(v_rxl);
        v_rxl = v_rxl .- avg_inl;

        # remove DC Component from received signal
        avg_inr = mean(v_rxr);
        v_rxr = v_rxr .- avg_inr;

        # fourier transforms
        V_RXL = fft(v_rxl);
        V_RXR = fft(v_rxr);

        # filtering
        V_RXL = V_RXL .* BPF;
        V_RXR = V_RXR .* BPF;

        # matched filteringn
        V_MFL = H.*V_RXL;
        V_MFR = H.*V_RXR;

        v_mfl = ifft(V_MFL);
        v_mfr = ifft(V_MFR);

        maxVal_l = maximum(v_mfl);
        maxInd_l = argmax(v_mfl);
        maxVal_r = maximum(v_mfr);
        maxInd_r = argmax(v_mfr);

        timediff = (maxInd_l-maxInd_r)*receivePeriod
        phaseangle =

    end

end

#to find maximum index argmin(X), to find maximum value maximum(X)
