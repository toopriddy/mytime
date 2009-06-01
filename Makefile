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

all: genstrings

genstrings:
	genstrings Classes/*.m Classes/*.h -s AlternateLocalizedString -o en_US.lproj/
	cp en_US.lproj/Localizable.strings English.lproj/

merge:
	for x in $(LANGUAGES); do $(LOCALIZABLE_MERGE) English.lproj/Localizable.strings $$x/Localizable.strings; done

zip:
	rm -rf translations.zip
	zip translations.zip $(patsubst %,%/Localizable.strings,$(LANGUAGES))

clang:
	scan-build xcodebuild
		