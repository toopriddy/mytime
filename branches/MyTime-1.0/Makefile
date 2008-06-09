INFOPLIST_FILE=Info.plist
SOURCES=\
App.m \
Main.m \
PublicationView.m \
MainView.m \
CallView.m \
AddressView.m \
SortedCallsView.m \
DatePickerView.m \
TimeView.m \
StatisticsView.m \
TimePickerView.m \
SettingsView.m \
UIOrientingApplication.m \
MainTransitionView.m \
svn_version.c \


RESOURCES=\
street.png \
streetSelected.png \
time.png \
timeSelected.png \
Default.png \
icon.png \
settings.png \
settingsSelected.png \
statistics.png \
statisticsSelected.png \
timer.png \
timerSelected.png \

HEAVENLY=/usr/local/share/iphone-filesystem/
CC=/usr/local/bin/arm-apple-darwin-gcc
CFLAGS=-g -Wall -Wp,-MMD -Wp,-MP
LD=$(CC)
LDFLAGS=-lobjc \
-framework WebCore \
-framework CoreFoundation \
-framework Foundation \
-framework CoreGraphics \
-framework GraphicsServices \
-framework UIKit \
-framework LayerKit \

ifndef PRODUCT_NAME
	PRODUCT_NAME=MyTime
	CONFIGURATION_BUILD_DIR=build/Release
	SRCROOT=.
endif
WRAPPER_NAME=$(PRODUCT_NAME).app
EXECUTABLE_NAME=$(PRODUCT_NAME)
SOURCES_ABS=$(addprefix $(SRCROOT)/,$(SOURCES))
RESOURCES_ABS=$(addprefix $(SRCROOT)/,$(RESOURCES))
INFOPLIST_ABS=$(addprefix $(SRCROOT)/,$(INFOPLIST_FILE))
OBJECTS=\
	$(patsubst %.c,%.o,$(filter %.c,$(SOURCES))) \
	$(patsubst %.cc,%.o,$(filter %.cc,$(SOURCES))) \
	$(patsubst %.cpp,%.o,$(filter %.cpp,$(SOURCES))) \
	$(patsubst %.m,%.o,$(filter %.m,$(SOURCES))) \
	$(patsubst %.mm,%.o,$(filter %.mm,$(SOURCES)))
OBJECTS_ABS=$(addprefix $(CONFIGURATION_BUILD_DIR)/,$(OBJECTS))
APP_ABS=$(CONFIGURATION_BUILD_DIR)/$(WRAPPER_NAME)
PRODUCT_ABS=$(APP_ABS)/$(EXECUTABLE_NAME)

VERSION=$(shell svnversion -n . | tr ":" ".")

all: $(PRODUCT_ABS)


$(CONFIGURATION_BUILD_DIR)/svn_version.o: $(SRCROOT)/svn_version.c

copy:
	scp build/Release/MyTime.app/MyTime root@10.10.10.220:/Applications/MyTime.app/

backup:
	scp root@10.10.10.220:/var/root/Library/MyTime/record.plist ./

zip: all
	cd $(CONFIGURATION_BUILD_DIR)/ && zip MyTime.zip $(WRAPPER_NAME)/*
	cat temp.mytime.plist | sed -e "s/DATESTRING/`date +"%s"`/g" | \
	                            sed -e "s/VERSIONSTRING/$(VERSION)/g" | \
	                            sed -e "s/FILELENGTHSTRING/`ls -l  $(CONFIGURATION_BUILD_DIR)/MyTime.zip |sed -e "s/  / /g" | cut -d " " -f 5`/g" | \
	                            sed -e "s/MD5STRING/`md5 $(CONFIGURATION_BUILD_DIR)/MyTime.zip  | cut -d "=" -f 2 | sed -e "s/ //g"`/g" > temp1.mytime.plist
ifdef CHANGES
	cat temp1.mytime.plist |sed -e "s/IFCHANGES//g" | \
	                            sed -e "s%CHANGESSTRING%$(CHANGES)%g" > mytime.plist
else
	cat temp1.mytime.plist |grep -v IFCHANGES > mytime.plist
endif
	rm -f temp1.mytime.plist
	mv $(CONFIGURATION_BUILD_DIR)/MyTime.zip ./MyTime-$(VERSION).zip
	@echo "Using version = $(VERSION)"
	@echo "You need to visit this to get your password: http://code.google.com/hosting/settings"
	python googlecode_upload.py -s "Version $(VERSION)" -u toopriddy -P `cat ~/.googlecodepassword` -p mytime MyTime-$(VERSION).zip
	svn commit mytime.plist --force-log  -m "updating to version $(VERSION)"

##
## on every build, record the working copy revision string
##
.PHONY:svn_version.c
svn_version.c: 
	echo 'const char* svn_version(void) {return "$(VERSION)"; }' > svn_version.c


$(PRODUCT_ABS): svn_version.c $(APP_ABS) $(OBJECTS_ABS)
	$(LD) $(LDFLAGS) -o $(PRODUCT_ABS) $(OBJECTS_ABS)

.PHONY: $(APP_ABS)
$(APP_ABS):
	mkdir -p $(APP_ABS)
	chmod 775 $(APP_ABS)
	cp $(INFOPLIST_ABS) $(APP_ABS)/
	cp $(RESOURCES_ABS) $(APP_ABS)/

$(CONFIGURATION_BUILD_DIR)/%.o: $(SRCROOT)/%.m
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(CPPFLAGS) -Wp,-MF -Wp,$(@:.o=.d) -c $< -o $@

$(CONFIGURATION_BUILD_DIR)/%.o: $(SRCROOT)/%.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(CPPFLAGS) -Wp,-MF -Wp,$(@:.o=.d) -c $< -o $@

clean:
	rm -f $(OBJECTS_ABS) $(OBJECTS_ABS:.o=.d) svn_version.c
	rm -rf $(APP_ABS)

ifdef OBJECTS_ABS
-include $(OBJECTS_ABS:.o=.d)
endif
