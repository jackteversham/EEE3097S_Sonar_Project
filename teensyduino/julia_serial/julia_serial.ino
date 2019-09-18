
/**
 * Global Variables
 */
int a[25000];
int b[10000];

/**
 * Setup Method
 */
void setup() {
  Serial.begin(115200);
  while (!Serial);
  pinMode(29,OUTPUT);
  int count = 0;
  for(int i=0; i<25000; i++){
    if(count<65){
      a[i]=0;
      count++;
    }else{
      a[i]=1;
      count++;
    }
    if(count == 130){
      count = 0;
    }
  }

}

/**
 * Main Method
 */
void loop() {
    int e = 0;
//  for(int i = 0; i<25000;i++){
//    digitalWrite(29, a[i]);
//  }
  for(int i = 0; i<10000;i++){
    b[i] = analogRead(32);
  }
    elapsedMicros usec = 0;
  for(int i = 0; i<1000;i++){
    Serial.print(b[i]);
    Serial.print("\n");
  }
  
  
  e = usec;
  Serial.print("\n");Serial.print("\n");Serial.print("\n");
  Serial.println(e);Serial.print("\n");Serial.print("\n");Serial.print("\n");
  while(true);
  
//  if (Serial.available()){
//    char input = Serial.read(); // read the command
//    Serial.write(input);
//  } else {
//    Serial.write('a');
//    Serial.write('\n');
//    delay(100);
//  }
}
