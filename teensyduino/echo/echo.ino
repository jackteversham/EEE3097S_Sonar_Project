
int i = 0;

void setup() {
 Serial.begin(9600); // Open a serial coms channel with specified baud rate*.
}
void loop() {
//  Serial.print(i);
//  i++;
//  delay(1000);
 if (Serial.available()){ // Waiting for commands from the computer
 char input = Serial.read(); // read the command
 
 Serial.write(input);
 Serial.write('\n');
}
}
