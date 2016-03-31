#!/bin/bash

export PATH="/usr/local/bin:$PATH"

if [ "$#" -lt "5" ]; then
    echo "Invalid call (5 parameters need to be present)!"
    exit 1
fi

count="$1"
lines="$2"
exposure="$3"
filename_base="$4"
cmvreg_calls="$5"

if [ ! -d $(dirname "${4}" ) ]; then
	echo "Directory doesn't exist."
	exit 2
fi

if [ "$6" != "-live" ]; then
	echo "Capture with parameters:"
	echo "Number of Pictures: $count"
	echo "Capture lines: $lines"
	echo "Filename-Base: $filename_base"
	echo "CMVreg_calls: $cmvreg_calls"
	echo ""; echo ""
	
	if [ -f "${4}.raw12" ] || [ -f "${4}.seq12" ] || [ -f "${4}.00.raw12" ]; then
		echo "File already exits."
		exit 3
	fi
fi

if [ ! -z "$cmvreg_calls" ]; then
	echo "Set CMVreg:"
	ssh apertus "$cmvreg_calls"
	echo ""; echo ""
fi

if [ "$6" != "-live" ]; then
	echo "Capture: ..."
	echo "./cmv_snap3 -B0x08000000 -x -N${count} -L${lines} -r -2 -e ${exposure}" >"$filename_base.capture_command"
fi

ssh apertus "./cmv_snap3 -B0x08000000 -x -N${count} -L${lines} -r -2 -e ${exposure}" >"$filename_base.raw12"

if [ "$6" != "-live" ]; then
	echo "Record camera state ..."
	ssh apertus "/root/ingmar/system_state.bash" >"$filename_base.state"
fi

# Split image sequence into single image files
mv "$filename_base.raw12" "$filename_base.seq12"
gsplit -b $((4096*12*lines/8)) -d "$filename_base.seq12" "$filename_base." --additional-suffix=".raw12"
rm "$filename_base.seq12"
mv "$filename_base.$(printf "%02d" $count).raw12" "$filename_base.register_dump"

# Add sensor register dump to every shot
if [ "$count" -eq "1" ]; then
	cat "$filename_base.00.raw12" "$filename_base.register_dump" >"$filename_base.raw12"
	rm "$filename_base.00.raw12"
else
	dirname="$(dirname "$filename_base")"
	basename_clean="$(echo "$filename_base" | sed -E "s|^$dirname||" | sed 's|^/||')"
	for file in $(find "$dirname" -iname "${basename_clean}*.raw12" ); do
		mv "$file" "${file}.tmp"
		cat "${file}.tmp" "$filename_base.register_dump" >"$file"
		rm "${file}.tmp"
	done
fi