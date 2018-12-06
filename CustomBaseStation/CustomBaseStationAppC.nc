 #include "MotionDetector.h"

configuration CustomBaseStationAppC {}
implementation {
  components MainC, CustomBaseStationC as App;
  MainC.Boot <- App.Boot;

  components LedsC;
  App.Leds -> LedsC;
  
  components SerialActiveMessageC;
  App.SerialSplitControl -> SerialActiveMessageC;
  App.AMSend -> SerialActiveMessageC.AMSend[16];
  App.Packet -> SerialActiveMessageC;

  components ActiveMessageC;
  App.SplitControl -> ActiveMessageC;
  App.Receive -> ActiveMessageC.Receive[AM_RADIO_MOTION_MSG];
}


