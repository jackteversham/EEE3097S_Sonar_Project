
/**
 * Global Variables
 */
int chirp[]= {};
int outputChirp = 39;

/**
 * Setup Method
 * Setup code to be run once
 */
void setup() {
  Serial.begin(115200);
  while (!Serial);
  for(int i =0; i <25000; i+=2){
    chirp[i]=1;
    chirp[i+1]=0;
  }
  pinMode(outputChirp, OUTPUT);
  analogWriteResolution(12);
}

/**
 * Main Method
 * Main loop to be run continuously 
 */
void loop(){
  elapsedMicros usec = 0;
  for(unsigned int i = 0; i < (sizeof(chirp)/sizeof(chirp[0])); i++){
    digitalWrite(outputChirp, chirp[i]);
    delayMicroseconds(20);
    Serial.print(chirp[i]);
    Serial.print("\n");
  }
  digitalWrite(outputChirp, 0);
  delay(100);
  int e = usec;
  Serial.print("\n");Serial.print("\n");Serial.print("\n");
  Serial.println(e);Serial.print("\n");Serial.print("\n");Serial.print("\n");
}
