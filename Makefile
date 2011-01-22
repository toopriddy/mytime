LOCALIZABLE_MERGE=LocalizableMerge/build/Release/LocalizableMerge
LANGUAGES = \
Croatian.lproj \
Danish.lproj \
Dutch.lproj \
en_UK.lproj \
French.lproj \
German.lproj \
Greek.lproj \
Italian.lproj \
Japanese.lproj \
Portuguese.lproj \
Spanish.lproj \
Swedish.lproj \
Slovak.lproj \
Norwegian.lproj \
Korean.lproj \


all: genstrings

genstrings:
	rm -f en_US.lproj/Localizable.strings
	genstrings Classes/*.m Classes/*.h MyTime/*.m MyTime/*.h -s AlternateLocalizedString -o en_US.lproj/
	cp en_US.lproj/Localizable.strings English.lproj/

merge:
	echo "Working on Localizable.strings"
	for x in $(LANGUAGES); do $(LOCALIZABLE_MERGE) English.lproj/Localizable.strings $$x/Localizable.strings; done
	echo "Working on Settings.bundle Root.strings"
	for x in $(LANGUAGES); do $(LOCALIZABLE_MERGE) Classes/Settings.bundle/English.lproj/Root.strings Classes/Settings.bundle/$$x/Root.strings; done

zip:
	rm -rf translations.zip
	rm -rf SettingsTranslations
	mkdir SettingsTranslations
	cp -rf Classes/Settings.bundle/*.lproj SettingsTranslations/
	zip translations.zip $(patsubst %,%/Localizable.strings,$(LANGUAGES)) $(patsubst %,SettingsTranslations/%/Root.strings,$(LANGUAGES))
	rm -rf SettingsTranslations

VERSION=$(shell defaults read `pwd`/Info CFBundleVersion)

test-zip:
	cd build/AdHoc\ Distribution-iphoneos/ && rm -f MyTime-${VERSION}AdHoc.zip MyTime-${VERSION}AdHoc.app.dSYM.zip
	cd build/AdHoc\ Distribution-iphoneos/ && ditto -ck --keepParent MyTime.app MyTime-${VERSION}AdHoc.zip
	cd build/AdHoc\ Distribution-iphoneos/ && ditto -ck --keepParent MyTime.app.dSYM MyTime-${VERSION}AdHoc.app.dSYM.zip 
	cd build/AdHoc\ Distribution-iphoneos/ && mv MyTime.ipa MyTime-${VERSION}.ipa

test: zip build/AdHoc\ Distribution-iphoneos/MyTime.app zip test-zip
	svn copy https://mytime.googlecode.com/svn/trunk https://mytime.googlecode.com/svn/tags/test-${VERSION} -m "${VERSION} to beta testers"

release-zip:
	cd build/Distribution-iphoneos/ && rm -f MyTime-${VERSION}.zip MyTime-${VERSION}.app.dSYM.zip Mytime.zip
	cd build/Distribution-iphoneos/ && ditto -ck --keepParent MyTime.app MyTime-${VERSION}.zip
	cd build/Distribution-iphoneos/ && cp -f MyTime-${VERSION}.zip MyTime.zip
	cd build/Distribution-iphoneos/ && ditto -ck --keepParent MyTime.app.dSYM MyTime-${VERSION}.app.dSYM.zip
	
release: build/Distribution-iphoneos/MyTime.app release-zip
	svn copy https://mytime.googlecode.com/svn/trunk https://mytime.googlecode.com/svn/tags/${VERSION} -m "${VERSION} to AppStore"
