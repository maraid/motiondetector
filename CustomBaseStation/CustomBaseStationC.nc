#include "MotionDetector.h"

module CustomBaseStationC @safe() {
  uses {
    interface Leds;
    interface Boot;
    interface Receive;
    interface AMSend;
    interface SplitControl;
    interface SplitControl as SerialSplitControl;
    interface Packet;
  }
}
implementation {

  message_t packet;

  event void Boot.booted() {
    call SplitControl.start();
    call SerialSplitControl.start();
  }

  event void SplitControl.startDone(error_t err) {}
  event void SplitControl.stopDone(error_t err) {}

  event void SerialSplitControl.startDone(error_t err) {}
  event void SerialSplitControl.stopDone(error_t err) {}

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {}

  event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
    if (len == sizeof(radio_motion_msg_t)) {
      radio_motion_msg_t* rmm = (radio_motion_msg_t*)payload;
      call Leds.set(rmm->payload);
      memcpy(call Packet.getPayload(&packet, sizeof(radio_motion_msg_t)), rmm, sizeof(radio_motion_msg_t));
      call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_motion_msg_t));
    }
    return bufPtr;
  }
}

