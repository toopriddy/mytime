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



all: genstrings

genstrings:
	genstrings Classes/*.m Classes/*.h -s AlternateLocalizedString -o en_US.lproj/
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

test: build/AdHoc\ Distribution-iphoneos/MyTime.app zip
	svn copy https://mytime.googlecode.com/svn/trunk https://mytime.googlecode.com/svn/tags/${VERSION} -m "${VERSION} to beta testers"
	zip -r MyTime-${VERSION}AdHoc.zip build/AdHoc\ Distribution-iphoneos-iphoneos/MyTime.app
	zip -r MyTime-${VERSION}AdHoc.app.dSYM.zip build/AdHoc\ Distribution-iphoneos-iphoneos/MyTime.app.dSYM


release: build/Distribution-iphoneos/MyTime.app
	svn copy https://mytime.googlecode.com/svn/trunk https://mytime.googlecode.com/svn/tags/${VERSION} -m "${VERSION} to AppStore"
	zip -r MyTime-${VERSION}.zip build/Distribution-iphoneos/MyTime.app
	zip -r MyTime-${VERSION}.app.dSYM.zip build/Distribution-iphoneos/MyTime.app.dSYM
