/****************************************************************************/	
/*  ***************************************************************************************/
/*  Script for iterationstive measurement of a color sample only in free-running mode     */
/*  For example,"R F 1 2 3 4" stands for R= remote F=Free-running 1= Gain_1               */
/*  2= Preescaler_2, 3= Integration time=400ms, 4= numbre of consecutive measures (Max 9) */
/*  ***************************************************************************************/
// This software is based in the example by www.seedstudio.com
// https://github.com/Seeed-Studio/Grove_I2C_Color_Sensor/tree/master
//
// Hardware: Arduino UNO and Grove - I2C Color Sensor
// Arduino IDE: Arduino-1.0.5
// Authors: J. Enrique Agudo, Pedro J. Pardo, Héctor Sánchez, Ángel Luis Pérez y Maria Isabel Suero
// Contact: jeagudo@unex.es, pjpardo@unex.es
// Date: Feb 27,2014
// Version: v1.0
// by University of Extremadura
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
//
/******************************************************************************/

#include <Wire.h>
#include <math.h>
#define COLOR_SENSOR_ADDR  0x39//the I2C address for the color sensor 
#define REG_CTL 0x80
#define REG_TIMING 0x81
#define REG_INT 0x82
#define REG_INT_SOURCE 0x83
#define REG_ID 0x84
#define REG_GAIN 0x87
#define REG_LOW_THRESH_LOW_BYTE 0x88
#define REG_LOW_THRESH_HIGH_BYTE 0x89
#define REG_HIGH_THRESH_LOW_BYTE 0x8A
#define REG_HIGH_THRESH_HIGH_BYTE 0x8B
#define REG_BLOCK_READ 0xD0 //Corrected from the original file
#define REG_GREEN_LOW 0xD0 
#define REG_GREEN_HIGH 0xD1
#define REG_RED_LOW 0xD2
#define REG_RED_HIGH 0xD3
#define REG_BLUE_LOW 0xD4
#define REG_BLUE_HIGH 0xD5
#define REG_CLEAR_LOW 0xD6
#define REG_CLEAR_HIGH 0xD7
#define CTL_DAT_INIITIATE 0x03
#define CTL_ADC_OFF 0x01
#define CLR_INT 0xE0
//Timing Register
#define SYNC_EDGE 0x40
#define INTEG_MODE_FREE 0x00
#define INTEG_MODE_MANUAL 0x10
#define INTEG_MODE_SYN_SINGLE 0x20
#define INTEG_MODE_SYN_MULTI 0x30
 
#define INTEG_PARAM_PULSE_COUNT1 0x00
#define INTEG_PARAM_PULSE_COUNT2 0x01
#define INTEG_PARAM_PULSE_COUNT4 0x02
#define INTEG_PARAM_PULSE_COUNT8 0x03
//Interrupt Control Register 
#define INTR_STOP 40
#define INTR_DISABLE 0x00
#define INTR_LEVEL 0x10
#define INTR_LEVEL_STOP 0x50
#define INTR_PERSIST_EVERY 0x00
#define INTR_PERSIST_SINGLE 0x01
//Interrupt Souce Register
#define INT_SOURCE_GREEN 0x00
#define INT_SOURCE_RED 0x01
#define INT_SOURCE_BLUE 0x10
#define INT_SOURCE_CLEAR 0x03
//Gain Register
#define GAIN_1 0x00
#define GAIN_4 0x10
#define GAIN_16 0x20
#define GAIN_64 0x30
#define PRESCALER_1 0x00
#define PRESCALER_2 0x01
#define PRESCALER_4 0x02
#define PRESCALER_8 0x03
#define PRESCALER_16 0x04
#define PRESCALER_32 0x05
#define PRESCALER_64 0x06
//////////////////////////
#define MAX_ITER 9 // Max iterations
#define MAX_READ 20 // For reading buffer
#define MSG_SIZE 10 // Message size
#define CHAR_R 82 // character 'R'
#define CHAR_F 70 // character 'F'
#define CHAR_ZERO 48  // character '0'

int readingdata[MAX_READ];
int ctl,length,flag,iterations;
unsigned int green,red,blue,clr,clrup, clrdown,t;
unsigned int greenReadings[MAX_ITER],redReadings[MAX_ITER],blueReadings[MAX_ITER],clearReadings[MAX_ITER];
float greenAverage,redAverage,bluePromedio,clearAverage;
int mode, gain, prescaler, integrationTime;
int incomingByte = 0;
float X,Y,Z,x,y,z,sumDeviation;

void setup()
{  
	Serial.begin(9600);
	Wire.begin(); // join i2c bus (address optional for master)
        //default integration mode
        mode=INTEG_MODE_MANUAL;
        //default integration time 
        integrationTime=INTEG_PARAM_PULSE_COUNT1;
        // Flag for stop free-running mode after a number of measurements
        flag=0;
        //Default number of iterationstions in each measurement
        iterations=9;
              
        // Default gain and preescaler
        gain=GAIN_1;
        prescaler=PRESCALER_1;
}

void loop()
{
  // Inicialize length of input buffer
  length=0;
  //Inicialize 4-channels mean measurement variables
  greenAverage=redAverage=bluePromedio=clearAverage=0;
  //Set Integration mode and time
  setTimingReg(mode);
  setTimingReg(integrationTime);
  setInterruptControlReg(INTR_LEVEL_STOP|INTR_PERSIST_EVERY);//Set interrupt mode
  setGain(gain|prescaler);//Set gain value and prescaler value
  
  // Start of measurement loop
  while((length<=MSG_SIZE))
 {   
   //If mode is free-running
   if (mode==INTEG_MODE_FREE){

     //Update measurement number
     setEnableADC();//Start ADC of the color sensor
     delay(t);//Delay for integration time
     setDisableADC();// Disable ADC
     readRGB();//Read RGB measured values
     clearInterrupt(); 
     //Put measured values in an array
     redReadings[flag]=red;
     greenReadings[flag]=green;
     blueReadings[flag]=blue;
     clearReadings[flag]=clr;
     //Increment measured value for mean 
     greenAverage=greenAverage+green;
     redAverage=redAverage+red;
     bluePromedio=bluePromedio+blue;
     clearAverage=clearAverage+clr;
     // Serial comm of RGB data
    Serial.print(red,DEC);  Serial.print(" ");
    Serial.print(green,DEC);Serial.print(" ");
    Serial.println(blue,DEC);
    flag=flag+1;
    }
    // if the number of measures match the target
   if ((mode==INTEG_MODE_FREE)&&(flag==iterations)){
    //Calculate the mean value
     green=greenAverage/iterations;
     red=redAverage/iterations;
     blue=bluePromedio/iterations;
     clr=clearAverage/iterations;
     //Calculate Standard deviation of green channel
     for(int i=0; i < iterations; i++){
       sumDeviation = sumDeviation + (greenReadings[i]-green)*(greenReadings[i]-green);
     }
   
   //Calculate chromatics coordinates
   calculateCoordinate();
   
   //Inicialize auxiliar varibles again;
   flag=0;
   sumDeviation=0;
   mode=INTEG_MODE_MANUAL;
   }// end while
   
   // are there serial data available?
   length=Serial.available();
  
  //if length of serial data is higher than 10
  if (length>MSG_SIZE) {
    //define a char array
    char message[length+1];
    // Put serial IN data on a char array
    for (int i=0; i < length; i++){
    message[i] = Serial.read();
   }
   message[length]=0;// End line char

    //Check if the incoming message is correct
    //           R                    F               
    if ((message[0]==CHAR_R) && ((message[2]==CHAR_F))){
    // Fix GAIN value
    switch (int(message[4])-CHAR_ZERO) { // Ganancia
          case 1:
          //Gain 1
                gain=GAIN_1;
                break;
          case 2:
          //Gain 4
                gain=GAIN_4;
                break;
          case 3:
          //Gain 16
                gain=GAIN_16;
                break;
          case 4:
          //Gain 24
                gain=GAIN_64;
                break;
      }
      //Fix preescaler value
      switch (int(message[6])-CHAR_ZERO) { 
          case 1:
          //Preescaler 1
                prescaler=PRESCALER_1;
                break;
          case 2:
          //Preescaler 2
                prescaler=PRESCALER_2;
                break;
          case 3:
          //Preescaler 4
                prescaler=PRESCALER_4;
                break;
          case 4:
          //Preescaler 8
                prescaler=PRESCALER_8;
                break;
      }
      // If mode is Free Running
      if (message[2]==CHAR_F){
        //Fix integration time
        switch (int(message[8])-CHAR_ZERO) { // integrationTime
          case 1:
          //Integration time=12 ms
                integrationTime=INTEG_PARAM_PULSE_COUNT1;
                t=12;
                break;
          case 2:
          //Integration time=100 ms
                integrationTime=INTEG_PARAM_PULSE_COUNT2;
                t=100;
                break;
          case 3:
          //Integration time=400 ms
                integrationTime=INTEG_PARAM_PULSE_COUNT4;
                t=400;
                break;
        }
        // Fix free-running mode
        mode=INTEG_MODE_FREE;
        
        // Fix number of iterationstive measurements (1-9)
        if (int(message[10])-CHAR_ZERO<=MAX_ITER)
          iterations=int(message[10])-CHAR_ZERO;
        else
          iterations =MAX_ITER;
          
        Serial.end(); // Clear serial buffer  
        Serial.begin(9600); // Start again serial communication
    }else
    {
      Serial.println("Command not valid");
    }

  }
 }
}
}
/************************************/
void setTimingReg(int x)
{
   Wire.beginTransmission(COLOR_SENSOR_ADDR);
   Wire.write(REG_TIMING);
   Wire.write(x);
   Wire.endTransmission();  
   delay(100); 
}
void setInterruptSourceReg(int x)
{
   Wire.beginTransmission(COLOR_SENSOR_ADDR);
   Wire.write(REG_INT_SOURCE);
   Wire.write(x);
   Wire.endTransmission();  
   delay(100);
}
void setInterruptControlReg(int x)
{
   Wire.beginTransmission(COLOR_SENSOR_ADDR);
   Wire.write(REG_INT);
   Wire.write(x);
   Wire.endTransmission();  
   delay(100);
}
void setInterruptThresholdUpperLevel(int x)
{
   Wire.beginTransmission(COLOR_SENSOR_ADDR);
   Wire.write(REG_HIGH_THRESH_HIGH_BYTE);
   Wire.write(x);
   Wire.endTransmission();  
   delay(100);
}
void setGain(int x)
{
   Wire.beginTransmission(COLOR_SENSOR_ADDR);
   Wire.write(REG_GAIN);
   Wire.write(x);
   Wire.endTransmission();
}
void setEnableADC()
{
 
   Wire.beginTransmission(COLOR_SENSOR_ADDR);
   Wire.write(REG_CTL);
   Wire.write(CTL_DAT_INIITIATE);
   Wire.endTransmission();  
   delay(100);  
}
void setDisableADC()
{
 
   Wire.beginTransmission(COLOR_SENSOR_ADDR);
   Wire.write(REG_CTL);
   Wire.write(CTL_ADC_OFF);
   Wire.endTransmission();  
   delay(100);  
}
void clearInterrupt()
{
   Wire.beginTransmission(COLOR_SENSOR_ADDR);
   Wire.write(CLR_INT);
   Wire.endTransmission(); 
}
void readRGB()
{
  Wire.beginTransmission(COLOR_SENSOR_ADDR);
   Wire.write(REG_BLOCK_READ);
   Wire.endTransmission();
 
   Wire.beginTransmission(COLOR_SENSOR_ADDR);
   Wire.requestFrom(COLOR_SENSOR_ADDR,8);
   delay(500);
   if(8<= Wire.available())    // if two bytes were received 
  { 
    for(int i=0;i<8;i++)
    {
      readingdata[i]=Wire.read();
  
     }
  }
  green=readingdata[1]*256+readingdata[0];
  red=readingdata[3]*256+readingdata[2];
  blue=readingdata[5]*256+readingdata[4];
  clr=readingdata[7]*256+readingdata[6];
    
}
void calculateCoordinate()
{
  X=(-0.0438)*(float)red+(0.1567)*(float)green+(-0.1000)*(float)blue;
  Y=(-0.0545)*(float)red+(0.1561)*(float)green+(-0.0827)*(float)blue;
  Z=(-0.0836)*(float)red+(0.0932)*(float)green+(0.0294)*(float)blue;
  x=X/(X+Y+Z);
  y=Y/(X+Y+Z);
  Serial.print("Mean ");
  Serial.print(red,DEC);  Serial.print(" ");
  Serial.print(green,DEC);Serial.print(" ");
  Serial.print(blue,DEC);Serial.print(" ");
  Serial.print(clr,DEC);  Serial.print(" ");
  Serial.print(t,DEC);  Serial.print(" ");
  Serial.print(sqrt(sumDeviation/iterations)/green*100);Serial.print(" "); 
  
  if((X>0)&&(Y>0)&&(Z>0))
  {

   Serial.print(x,4);Serial.print(" ");

    Serial.println(y,4);

  }
 else
 Serial.println("Error,the value overflow");
}
