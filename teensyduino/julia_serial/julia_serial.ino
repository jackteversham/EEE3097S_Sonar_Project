
int counter = 0;

void setup() {
  Serial.begin(9600);
  while (!Serial);

}

void loop() {
  if (Serial.available()){
    char input = Serial.read(); // read the command
    Serial.write(input);
  } else {
    Serial.write('a');
    Serial.write('\n');
    delay(1000);
  }
}
