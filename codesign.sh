CMD="codesign -s 'Developer ID Application: ' -v"

for i in dokibox.app/Contents/Frameworks/*; do
	eval $CMD $i
done

for i in dokibox.app/Contents/PlugIns/*; do
	if [ -d "$i/Contents/Frameworks" ]; then
		for j in $i/Contents/Frameworks/*; do
			eval $CMD $j
		done
	fi
	eval $CMD $i
done

eval $CMD dokibox.app