#define THRESHOLD 2
#define LOOPCOUNT 6
#define TIMEOUT 1000
#define DELAY 35

module MotionDetectorC @safe()
{
  uses interface Boot;
  uses interface Receive;
  uses interface AMSend as AMSendToBaseStation;
  uses interface AMSend as AMSendToDevice;
  uses interface SplitControl;
  uses interface DiagMsg;
  uses interface PacketField<uint8_t> as PacketRSSI;
  uses interface AMPacket;
  uses interface Timer<TMilli> as Timeout;
  uses interface Timer<TMilli> as Delay;
  uses interface Packet;
  uses interface Leds;
}
implementation {
  const uint8_t devices[] = {10, 2, 3, 1};
  uint8_t mask, max_rssi, min_rssi, counter;
  message_t packet_device, packet_bs;
  radio_motion_msg_t* rmm_in;
  
  event void Boot.booted() {
		call SplitControl.start();
    if (TOS_NODE_ID == 1)
      call Timeout.startPeriodic(TIMEOUT);
    mask = 1 << (TOS_NODE_ID - 1);
  }
  
  void init_values() {
    rmm_in->payload = 0x80;  // 0b10000000 MSB = reset flag
    max_rssi = 0;
    min_rssi = 0xFF;
    counter = 0;
  }

	event void SplitControl.startDone(error_t err) {}
  event void SplitControl.stopDone(error_t err) {}
  
  void send_to_device() {
    memcpy(call AMSendToDevice.getPayload(&packet_device, sizeof(radio_motion_msg_t)), rmm_in, sizeof(radio_motion_msg_t));
    // call AMSendToDevice.send(devices[TOS_NODE_ID], &packet_bs, sizeof(radio_motion_msg_t));
    call AMSendToDevice.send(devices[TOS_NODE_ID], &packet_device, sizeof(radio_motion_msg_t));
  }

  event void AMSendToDevice.sendDone(message_t* bufPtr, error_t error) {} 

  void send_to_bs() {
    memcpy(call AMSendToBaseStation.getPayload(&packet_bs, sizeof(radio_motion_msg_t)), rmm_in, sizeof(radio_motion_msg_t));
    call AMSendToBaseStation.send(devices[0], &packet_bs, sizeof(radio_motion_msg_t));
  }
  
  event void AMSendToBaseStation.sendDone(message_t* bufPtr, error_t error) {}  

  event void Timeout.fired() {
    call Leds.set(0);
    init_values();
    send_to_device();
  }

  void print(uint8_t text[], uint8_t val){
    if(call DiagMsg.record()){
      call DiagMsg.str(text);
      call DiagMsg.uint8(val);
      call DiagMsg.send();
    } 
  }

  event void Delay.fired() {
    /*
    print("counter: ", counter);
    print("LOOPCOUNT: ", LOOPCOUNT);
    print("max_rssi: ", max_rssi);
    print("min_rssi: ", min_rssi);
    print("THRESHOLD: ", THRESHOLD);
    print("rmm_in->payload: ", rmm_in->payload);
    print("mask: ", mask);
    */
    
    if (call Timeout.isRunning() && !counter) {
      send_to_bs();
      rmm_in->payload = 0;
    }
    if (counter++ == LOOPCOUNT) {
      if ((max_rssi - min_rssi) > THRESHOLD)
        rmm_in->payload |= mask;
      max_rssi = 0;
      min_rssi = 0xFF;
      counter = 0;
    }
    send_to_device();
  }

  

  int8_t getRssi(message_t *msg){
    if(call PacketRSSI.isSet(msg))
      return (int8_t) call PacketRSSI.get(msg);
    else
      return 0xFF;
  }

  void displayRssi(uint8_t rssi) {
    call Leds.set(0xFF >> (7 - rssi / 4));
  }

	event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len){
    uint8_t rssi;

    if (len != sizeof(radio_motion_msg_t)) {return bufPtr;}
    
    rmm_in = (radio_motion_msg_t*)payload;

    if (call Timeout.isRunning()) {
      call Timeout.startPeriodic(TIMEOUT);  // reset the timeout
      rmm_in->payload &= 0x7F;  // 0b0xxxxxxx -- remove reset flag
    }
    
    if (rmm_in->payload == 0x80 ) 
      init_values();

    rssi = getRssi(bufPtr);
    // print("current rssi", rssi);
    displayRssi(rssi);
    max_rssi = rssi > max_rssi ? rssi : max_rssi;
    min_rssi = rssi < min_rssi ? rssi : min_rssi;

    call Delay.startOneShot(DELAY);
    
		return bufPtr;
	}
}
