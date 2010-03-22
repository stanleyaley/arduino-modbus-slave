/*
   Copyright (C) 2009, 2010 Matt Reba, Jermeiah Dillingham

    This file is part of BrewTroller.

    BrewTroller is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    BrewTroller is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with BrewTroller.  If not, see <http://www.gnu.org/licenses/>.

FermTroller - Open Source Fermentation Computer
Software Lead: Matt Reba (matt_AT_brewtroller_DOT_com)
Hardware Lead: Jeremiah Dillingham (jeremiah_AT_brewtroller_DOT_com)

Documentation, Forums and more information available at http://www.brewtroller.com

Compiled on Arduino-0017 (http://arduino.cc/en/Main/Software)
With Sanguino Software v1.4 (http://code.google.com/p/sanguino/downloads/list)
using PID Library v0.6 (Beta 6) (http://www.arduino.cc/playground/Code/PIDLibrary)
using OneWire Library (http://www.arduino.cc/playground/Learning/OneWire)
*/

#include <OneWire.h>
//One Wire Bus on 
OneWire ds(5);

void getDSAddr(byte addrRet[8]){
  byte scanAddr[8];
  ds.reset_search();
  byte limit = 0;
  //Scan at most 10 sensors (In case the One Wire Search loop issue occurs)
  while (limit <= 10) {
    if (!ds.search(scanAddr)) {
      //No Sensor found, Return
      ds.reset_search();
      return;
    }
    boolean found = 0;
    for (byte i = 0; i < NUM_ZONES + 1; i++) {
      if (scanAddr[0] == tSensor[i][0] &&
          scanAddr[1] == tSensor[i][1] &&
          scanAddr[2] == tSensor[i][2] &&
          scanAddr[3] == tSensor[i][3] &&
          scanAddr[4] == tSensor[i][4] &&
          scanAddr[5] == tSensor[i][5] &&
          scanAddr[6] == tSensor[i][6] &&
          scanAddr[7] == tSensor[i][7])
      { 
          found = 1;
          break;
      }
    }
    if (!found) {
      for (byte i = 0; i < 8; i++) addrRet[i] = scanAddr[i];
      return;
    }
    limit++;
  }
}

void convertAll() {
  ds.reset();
  ds.skip();
  ds.write(0x44,1);         // start conversion, with parasite power on at the end
}

word read_temp(byte* addr) {
  word temp;
  byte data[12];
  ds.reset();
  ds.select(addr);   
  ds.write(0xBE);         // Read Scratchpad

  for (byte i = 0; i < 9; i++) 
    data[i] = ds.read();
  if ( OneWire::crc8( data, 8) != data[8]) 
    return -1; 
  temp = (data[1] << 8) + data[0];
  if ( addr[0] != 0x28)
    return temp;  
}
