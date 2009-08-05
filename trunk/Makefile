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

clang:
	scan-build xcodebuild
		