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
svn_version.c \


RESOURCES=\
street.png \
streetSelected.png \
time.png \
timeSelected.png \
Default.png \
icon.png \

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

all: $(PRODUCT_ABS)


copy:
	scp build/Release/MyTime.app/MyTime root@10.10.10.254:/Applications/MyTime.app/

backup:
	scp root@10.10.10.254:/var/root/Library/MyTime/record.plist ./

zip:
	cd $(CONFIGURATION_BUILD_DIR)/ && zip MyTime.zip $(WRAPPER_NAME)/*
	mv $(CONFIGURATION_BUILD_DIR)/MyTime.zip ./

##
## on every build, record the working copy revision string
##
.PHONY:svn_version.c
svn_version.c: 
	echo -n 'const char* svn_version(void) { const char* SVN_Version = "' > svn_version.c
	svnversion -n .                   >> svn_version.c
	echo '"; return SVN_Version; }'   >> svn_version.c


$(PRODUCT_ABS): svn_version.c $(APP_ABS) $(OBJECTS_ABS)
	$(LD) $(LDFLAGS) -o $(PRODUCT_ABS) $(OBJECTS_ABS)

$(APP_ABS): $(INFOPLIST_ABS)
	mkdir -p $(APP_ABS)
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
