#include "MotionDetector.h"
#include "message.h"

configuration MotionDetectorAppC{}
implementation {
  components MainC, MotionDetectorC as App;
  MainC.Boot <- App;

  components new AMReceiverC(AM_RADIO_MOTION_MSG);
  App.Packet -> ActiveMessageC.Packet;
  App.AMPacket -> AMReceiverC.AMPacket;
  App.Receive -> AMReceiverC.Receive;

  components new AMSenderC(AM_RADIO_MOTION_MSG) as AMSendToBaseStation;
  App.AMSendToDevice -> AMSendToDevice.AMSend;

  components new AMSenderC(AM_RADIO_MOTION_MSG) as AMSendToDevice;
  App.AMSendToBaseStation -> AMSendToBaseStation.AMSend;
  
  components ActiveMessageC;
  App.SplitControl -> ActiveMessageC;

  components RFA1ActiveMessageC;
  App.PacketRSSI -> RFA1ActiveMessageC.PacketRSSI;
  
  components new TimerMilliC() as Timeout;
  App.Timeout -> Timeout;

  components new TimerMilliC() as Delay;
  App.Delay -> Delay;

  components LedsC;
  App.Leds -> LedsC.Leds;

  components DiagMsgC;
  App.DiagMsg -> DiagMsgC;
  
}

