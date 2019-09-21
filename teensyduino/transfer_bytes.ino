#define ARR_LEN 10000

uint16_t test_arr[ARR_LEN];

void setup() {
  
  // initialise test_arr with numbers from 0 to 65535
  for (int i=0; i<sizeof(test_arr)/sizeof(test_arr[0]); i++){
    test_arr[i] = i;
  }

  // setup serial
  Serial.begin(9600);
  while (!Serial);
  
}

void loop() {
  // send start
  Serial.write("start");

  // allow some time to recieve start
  delay(500);

  // write arr to serial port
  for (uint16_t val : test_arr){
    Serial.write(val);
  }

  // just some extra time for debugging
  delay(1000);
}
