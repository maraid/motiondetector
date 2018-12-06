#ifndef RADIO_COUNT_TO_LEDS_H
#define RADIO_COUNT_TO_LEDS_H

typedef nx_struct radio_motion_msg {
  nx_uint8_t payload;
} radio_motion_msg_t;

enum {
  AM_RADIO_MOTION_MSG = 6,
};

#endif
