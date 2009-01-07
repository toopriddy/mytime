all: genstrings

genstrings:
	genstrings Classes/*.m classes/*.h -s AlternateLocalizedString -o en_US.lproj/
	cp en_US.lproj/Localizable.strings English.lproj/

clang:
	scan-build xcodebuild
		