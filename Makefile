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
SortedByPickerView.m \
NotesTextView.m \
PublicationPicker.m \
NumberedPicker.m \
LiteraturePlacementView.m \
BulkLiteraturePlacementView.m \
svn_version.c \
CallTableCell.m \


RESOURCES=\
street.png \
streetSelected.png \
city.png \
citySelected.png \
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
studies.png \
studiesSelected.png \
bulkPlacements.png \
bulkPlacementsSelected.png \

LANGUAGES = \
English.lproj \
Dutch.lproj \

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
LANGUAGES_ABS=$(addprefix $(SRCROOT)/,$(LANGUAGES))
LANGUAGES_DEST_ABS=$(addprefix $(CONFIGURATION_BUILD_DIR)/$(WRAPPER_NAME)/$(SRCROOT)/,$(LANGUAGES))
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
IPHONE=10.10.10.212
#IPHONE=192.168.0.101

all: $(PRODUCT_ABS)


$(CONFIGURATION_BUILD_DIR)/svn_version.o: $(SRCROOT)/svn_version.c

copy:
	scp build/Release/MyTime.app/MyTime root@$(IPHONE):/Applications/MyTime.app/

copy-resources:
	scp $(RESOURCES) root@$(IPHONE):/Applications/MyTime.app/

copy-languages:
	scp -r English.lproj/Localizable.strings root@$(IPHONE):/Applications/MyTime.app/English.lproj/

backup:
	scp root@$(IPHONE):/var/mobile/Library/MyTime/record.plist ./

# this builds the release file
zip: all
	for x in $(LANGUAGES); do mkdir -p $(APP_ABS)/$$x; cp -f $$x/Localizable.strings $(APP_ABS)/$$x; done
	cd $(CONFIGURATION_BUILD_DIR)/ && zip -r MyTime.zip $(WRAPPER_NAME)/*
	cat temp.mytime.plist | sed -e "s/DATESTRING/`date +"%s"`/g" | \
	                            sed -e "s/VERSIONSTRING/$(VERSION)/g" | \
	                            sed -e "s/FILELENGTHSTRING/`ls -l  $(CONFIGURATION_BUILD_DIR)/MyTime.zip |sed -e "s/  / /g" | cut -d " " -f 5`/g" | \
	                            sed -e "s/MD5STRING/`md5 $(CONFIGURATION_BUILD_DIR)/MyTime.zip  | cut -d "=" -f 2 | sed -e "s/ //g"`/g" > temp1.mytime.plist
ifdef CHANGES
	cat temp1.mytime.plist |sed -e "s/IFCHANGES//g" | \
	                            sed -e "s%CHANGESSTRING%$(CHANGES)%g" > temp2.mytime.plist
else
	cat temp1.mytime.plist |grep -v IFCHANGES > temp2.mytime.plist
endif
	rm -f temp1.mytime.plist
	mv $(CONFIGURATION_BUILD_DIR)/MyTime.zip ./MyTime-$(VERSION).zip
	@echo "Using version = $(VERSION)"
	@echo "You need to visit this to get your password: http://code.google.com/hosting/settings"
	python googlecode_upload.py -s "Version $(VERSION)" -u toopriddy -P `cat ~/.googlecodepassword` -p mytime MyTime-$(VERSION).zip
	mv -f  temp2.mytime.plist mytime.plist
	svn commit mytime.plist --force-log  -m "updating to version $(VERSION)"

fixgenstrings: fixgenstrings.c
	gcc fixgenstrings.c -o fixgenstrings
	
genstrings: fixgenstrings
#	rm -f English.lproj/Localizable.strings
#	for x in $(SOURCES); do genstrings $$x -a -s AlternateLocalizedString -o English.lproj/; done
	genstrings $(SOURCES) -s AlternateLocalizedString -o English.lproj/
	./fixgenstrings English.lproj/Localizable.strings > English.lproj/temp.strings
	cat English.lproj/temp.strings | sed -e "s/%1\$$a %2\$$b %3\$$d, %4\$$Y/%a %b %d, %Y/" | sed -e "s/%1\$$a %2\$$b %3\$$d/%a %b %d/" > English.lproj/Localizable.strings
	rm -f English.lproj/temp.strings
	

##
## on every build, record the working copy revision string
##
.PHONY:svn_version.c
svn_version.c:
	echo 'const char* svn_version(void) {return "$(VERSION)"; }' > svn_version.c.tmp
	if [ -e svn_version.c ]; then if [  "x`diff -q svn_version.c svn_version.c.tmp`" == "x" ]; then rm svn_version.c.tmp; echo "Not upating svn_version.c"; else mv -f svn_version.c.tmp svn_version.c; echo "Updating svn_version.c"; fi; else mv svn_version.c.tmp svn_version.c; fi


$(PRODUCT_ABS): svn_version.c $(APP_ABS) $(OBJECTS_ABS)
	$(LD) $(LDFLAGS) -o $(PRODUCT_ABS) $(OBJECTS_ABS)

.PHONY: $(APP_ABS)
$(APP_ABS):
	mkdir -p $(APP_ABS)
	chmod 775 $(APP_ABS)
	cp $(INFOPLIST_ABS) $(APP_ABS)/
	cp $(RESOURCES_ABS) $(APP_ABS)/
	$(shell for x in $(LANGUAGES_ABS); do mkdir -p $(APP_ABS)/$$x && cp $$x/Localizable.strings $(APP_ABS)/$$x; done)
	
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
