
const int a = 2;
const int b =  3;  

int contador = 0;

void setup() {
  // put your setup code here, to run once:
   pinMode(a, OUTPUT);
   pinMode(b, OUTPUT);
}

void loop() {
  // put your main code here, to run repeatedly
  switch(contador){
    case 0: {
      digitalWrite(a, LOW); digitalWrite(b, LOW);
    break;}
    case 1:{ 
      digitalWrite(a, HIGH); digitalWrite(b, LOW);
    break;}
    case 2:{ 
      digitalWrite(a, LOW); digitalWrite(b, HIGH);
    break;}
    default:{
     // contador = 0;
      break;}
  }
  //contador++;
  delay(5000);


}
