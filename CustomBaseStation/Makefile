COMPONENT=CustomBaseStationAppC
TOSMAKE_PRE_EXE_DEPS = MotionDetectorMsg.py
TOSMAKE_CLEAN_EXTRA = MotionDetectorMsg.py

MotionDetectorMsg.py: MotionDetector.h
	nescc-mig python $(CFLAGS) $(NESC_PFLAGS) -python-classname=MotionDetectorMsg MotionDetector.h radio_motion_msg -o $@

TINYOS_ROOT_DIR?=../..
include $(TINYOS_ROOT_DIR)/Makefile.include

