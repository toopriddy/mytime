all: genstrings

genstrings:
	genstrings Classes/*.m classes/*.h -s AlternateLocalizedString -o en_US.lproj/

clang:
	scan-build xcodebuild
		