LANGUAGES = \
English.lproj \
Dutch.lproj \
German.lproj \

all: genstrings

fixgenstrings: fixgenstrings.c
	gcc fixgenstrings.c -o fixgenstrings
	
genstrings: fixgenstrings
#	rm -f English.lproj/Localizable.strings
#	for x in $(SOURCES); do genstrings $$x -a -s AlternateLocalizedString -o English.lproj/; done
	genstrings Classes/*.m classes/*.h -s AlternateLocalizedString -o English.lproj/
	./fixgenstrings English.lproj/Localizable.strings > English.lproj/temp.strings
	cat English.lproj/temp.strings | sed -e "s/%1\$$a %2\$$b %3\$$d, %4\$$Y/%a %b %d, %Y/" | sed -e "s/%1\$$a %2\$$b %3\$$d/%a %b %d/" > English.lproj/Localizable.strings
	rm -f English.lproj/temp.strings
	
clang:
	scan-build xcodebuild
		