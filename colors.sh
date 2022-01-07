#!/bin/bash
# Creates color palettes based on TEXT or JSON data
# Author: majamin <majamin at gmail dot com>
# License: MIT

# You can run this script as-is, but if you want to grab the original data
# here are the instructions:

# First grab some JSON-formatted data and write 'colors.json'
#	curl -s -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" \
#	"http://www.colourlovers.com/api/palettes/top?format=json&numResults=100&resultOffset=0" |\
#	jq . > colors.json

# With the generate 'colors.json' file, turn into plain text:
#
#	cat colors{0,1,2,3,4,5,6,7,8,9}.json |\
#	jq --raw-output '.[].colors |\
#	@tsv' > colors.txt

#-----------------------------------------------------------------------------
# Dependencies: cat, ImageMagick, bc
cmd_failures=''
for cmd in cat ImageMagick bc; do
  command -v "${cmd}" >/dev/null 2>&1 || cmd_failures="${cmd_failures},${cmd}"
done

# Environment
colorsfile="colors.txt"
colorsdir="generated" && [[ ! -d $colorsdir ]] && mkdir $colorsdir
font="Noto-Sans-Mono-Bold"
maskimage="mask.png"

# Generate rounded-corner rectangle mask
convert -size 1200x720 xc:none -draw "roundrectangle 0,0,1200,720,15,15" $maskimage

# should the font be white or black?
white_or_black() {
	# HEX to RGB
	# https://stackoverflow.com/a/7253786/10059841
	hex="$1"
	r=$(echo "ibase=16; ${hex:0:2}/FF" | bc -l)
	g=$(echo "ibase=16; ${hex:2:2}/FF" | bc -l)
	b=$(echo "ibase=16; ${hex:4:2}/FF" | bc -l)

	# Calculate luminance (in a rough way)
	# https://gamedev.stackexchange.com/a/38561
	L=$(echo "0.2126*$r + 0.7152*$g + 0.0722*$b" | bc -l)

	threshold=0.5  # values from 0 to 1
	# use_black is 1 if true, 0 otherwise
	use_black=$(echo "$L > $threshold" | bc -l)

	[[ $use_black -eq 1 ]] && echo "black" || echo "white"
}

while IFS=$'\t' read -r H1 H2 H3 H4 H5; do
	filename="$H1-$H2-$H3-$H4-$H5.png"
	convert -size 1200x720 xc:\#ffffff \
		-draw "fill \"#${H1}\" rectangle 0,0 240,720" \
		-draw "fill \"#${H2}\" rectangle 240,0 480,720" \
		-draw "fill \"#${H3}\" rectangle 480,0 720,720" \
		-draw "fill \"#${H4}\" rectangle 720,0 960,720" \
		-draw "fill \"#${H5}\" rectangle 960,0 1200,720" \
		-font $font \
		-pointsize 30 \
		-fill "$(white_or_black "$H1")" -annotate +66+680   "$H1" \
		-fill "$(white_or_black "$H2")" -annotate +306+680  "$H2" \
		-fill "$(white_or_black "$H3")" -annotate +546+680  "$H3" \
		-fill "$(white_or_black "$H4")" -annotate +786+680  "$H4" \
		-fill "$(white_or_black "$H5")" -annotate +1026+680 "$H5" \
		temp.png

	# round the corners and write the file
	if [[ -e "$colorsdir/$filename" ]]; then
		printf "%s\n" "File $colorsdir/$filename exists - skipping"
	else
		convert temp.png -matte $maskimage -compose DstIn -composite "$colorsdir/$filename" &&\
		printf "Success: %s/%s written!\n" "$colorsdir" "$filename"
	fi

done <<< "$(cat $colorsfile)"

rm temp.png
