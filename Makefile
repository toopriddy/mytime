LOCALIZABLE_MERGE=LocalizableMerge/build/Release/LocalizableMerge


all: genstrings

genstrings:
	genstrings Classes/*.m classes/*.h -s AlternateLocalizedString -o en_US.lproj/
	cp en_US.lproj/Localizable.strings English.lproj/

merge:
	$(LOCALIZABLE_MERGE) English.lproj/Localizable.strings Croatian.lproj/Localizable.strings
	$(LOCALIZABLE_MERGE) English.lproj/Localizable.strings Danish.lproj/Localizable.strings
	$(LOCALIZABLE_MERGE) English.lproj/Localizable.strings Dutch.lproj/Localizable.strings
	$(LOCALIZABLE_MERGE) English.lproj/Localizable.strings en_UK.lproj/Localizable.strings
	$(LOCALIZABLE_MERGE) English.lproj/Localizable.strings French.lproj/Localizable.strings
	$(LOCALIZABLE_MERGE) English.lproj/Localizable.strings German.lproj/Localizable.strings
	$(LOCALIZABLE_MERGE) English.lproj/Localizable.strings Italian.lproj/Localizable.strings
	$(LOCALIZABLE_MERGE) English.lproj/Localizable.strings Japanese.lproj/Localizable.strings
	$(LOCALIZABLE_MERGE) English.lproj/Localizable.strings Portuguese.lproj/Localizable.strings
	$(LOCALIZABLE_MERGE) English.lproj/Localizable.strings Spanish.lproj/Localizable.strings
	$(LOCALIZABLE_MERGE) English.lproj/Localizable.strings Swedish.lproj/Localizable.strings

clang:
	scan-build xcodebuild
		