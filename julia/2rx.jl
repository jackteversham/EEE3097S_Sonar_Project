import Pkg;
# Pkg.add("Interact")
# Pkg.add("PyPlot")
# Pkg.add("Blink")
# using Plots;
using SerialPorts;
using FFTW;
using Statistics;
using PyPlot ;
using Interact;
using Blink;
include("chirppulse.jl");
include("gui.jl");

setupGUI();
setupPlot();

# Pkg.add("SerialPorts")

# %% define rect
rect(t) = (abs.(t) .<= 0.5)*1.0;

# set up Axes
receivePeriod = 1/400000
receivingTime = 24000*receivePeriod
receiveTimeAxis = collect(1:24000)*receivePeriod
# receiveTimeAxis = receiveTimeAxis[1:20000];
B = 2000
f0 = 40e3

# create range array
c = 343
range = c * receiveTimeAxis / 2

lambda = c/f0; #wavelength

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

sp = SerialPort("/dev/tty.usbmodem48351501", 9600);

ion()
# fig1 = figure(figsize=(10, 8))
    

while true
    #empty the serial buffer
    readavailable(sp)

    write(sp,"s\n");
    write(sp,"a\n");
    println("chirp sent and recieving");
    while bytesavailable(sp) < 1
        sleep(0.01)
    end
    sleep(1);

    sbuffera = "";

    while true
        sleep(0.02)
        if bytesavailable(sp) < 1
            break
        end
        sbuffera = string(sbuffera,readavailable(sp))
    end

    write(sp,"b\n")
    sbufferb = "";
    while true
        sleep(0.02)
        if bytesavailable(sp) < 1
            break
        end
        sbufferb = string(sbufferb,readavailable(sp))
    end
    b = (occursin(sbuffera,"Timeout") || occursin(sbufferb,"Timeout"));
    while b
        readavailable(sp)

        write(sp,"s\n")
        write(sp,"a\n")

        while bytesavailable(sp) < 1
            sleep(0.01)
        end
        sleep(1);

        sbuffera = "";

        while true
            sleep(0.02)
            if bytesavailable(sp) < 1
                break
            end
            sbuffera = string(sbuffera,readavailable(sp))
        end

        write(sp,"b\n")
        sbufferb = "";
        while true
            sleep(0.02)
            if bytesavailable(sp) < 1
                break
            end
            sbufferb = string(sbufferb,readavailable(sp))
        end
        b = (occursin(sbuffera,"Timeout") || occursin(sbufferb,"Timeout"))
    end
    
    #ignoring last empty line
    sbs = split(sbuffera,"\r\n")
    v_rxl_string = sbs[1:24000];

    sbsb = split(sbufferb,"\r\n")
    v_rxr_string = sbsb[1:24000];

    v_rxl1 = parse.(Float64, v_rxl_string)
    v_rxl = zeros(24000)

    # ignoring first metre
    for i = 1:22000
        v_rxl[2000+i] = v_rxl1[i];
    end

    v_rxr1 = parse.(Float64, v_rxr_string)

    v_rxr = zeros(24000)

    v_rxr = zeros(24000)
    for i = 1:22000
        v_rxr[2000+i] = v_rxr1[i];
    end
    println("signal processing");
    # remove DC Component from received signal
    avg_inl = mean(v_rxl);
    v_rxl = v_rxl .- avg_inl;

    # remove DC Component from received signal
    avg_inr = mean(v_rxr);
    v_rxr = v_rxr .- avg_inr;

    # fourier transforms
    V_RXL = fft(v_rxl);
    V_RXR = fft(v_rxr);

    # matched filtering
    V_MFL = H.*V_RXL;
    V_MFR = H.*V_RXR;

    v_mfl = ifft(V_MFL);
    v_mfr = ifft(V_MFR);

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

    i=im;

    # baseband signals
    v_bb_l = v_anal_l .* exp.(-i*2*pi*f0 .*receiveTimeAxis);
    v_bb_r = v_anal_r .* exp.(-i*2*pi*f0 .*receiveTimeAxis);

    v_bb_angle = v_bb_l .* conj(v_bb_r); #multiply left channel by conjugate of right channel
    maxIndex = argmax(abs.(v_bb_angle))
    phi = angle(v_bb_angle[maxIndex]);
    print("Phi = ")
    println(phi)

    maxVal_l = maximum(abs.(v_bb_l));
    maxInd_l = argmax(abs.(v_bb_l));
    maxVal_r = maximum(abs.(v_bb_r));
    maxInd_r = argmax(abs.(v_bb_r));

    r = ((maxInd_r+maxInd_l)/2)/(400e3)*343/2;
    r2 = (maxIndex)/(400e3)*343/2;
    println("RANGE: ")
    println(r2)

    anglemax_l = angle(v_bb_l[maxInd_l]);
    anglemax_r = angle(v_bb_l[maxInd_r]);

    # println(maxInd_l);
    # println(anglemax_l);
    # println(maxInd_r);
    # println(anglemax_r);
    println("Plotting");

    subplot(411)
    cla()
    plot(range,v_rxl1)
    plot(range,v_rxr1)

    subplot(412)
    cla()   
    plot(range,angle.(v_bb_l))          

    # subplot(512)  
    # cla()
    plot(range,angle.(v_bb_r))       

    subplot(413)
    cla()
    plot(range,abs.(v_bb_l))     

    # subplot(514)
    # cla()
    plot(range,abs.(v_bb_r))     
    

    argument = (8.575e-3)*(phi)/(2*pi*0.025);
    theta = asin(argument); #0.122 seems to be a delay from the zero angle - a fork of calibration
    println(theta)
    degrees = theta*(180/(pi));
    println(degrees);
    println("done")

    updateGUI(theta,r);
    show()

end


#to find maximum index argmin(X), to find maximum value maximum(X)
