# 2D Sonar Range Finder
The aim of this project is to design and implement a functional 2D direction ﬁnding system operating at 40kHz in air. This involves building on the previously developed 1D range proﬁle and designing a two element receiving array which will be used to determine the phase difference between different targets.

The 1D range proﬁle consisting of one transmitting transducer and one receiving transducer is able to determine the range to a target based off a two way time delay. By adding a second receiver, at some ﬁxed distance d in the horizontal plane, it is possible to attain the direction of arrival based on the measured time delay or phase difference. The range and angle allows the location of the target in the horizontal plane to be determined.

Notes on teensy-julia communication:
  uses Serial on teeny and SerailPorts on julia
  Teensy:
    Serial.write(int) sends one byte i.e. x % 255
  Julia:
    
  
