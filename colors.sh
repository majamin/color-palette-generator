#!/bin/sh
# Creates color palettes based on JSON data
# DEPS: Sed, ImageMagick

curl -LO "https://raw.githubusercontent.com/Jam3/nice-color-palettes/master/1000.json"

# Rounded rectangle mask
convert -size 1200x720 xc:none -draw "roundrectangle 0,0,1200,720,15,15" mask.png

# Color JSON file
json_colors="1000.json"

# sed 's/\],/\n/g' 1000.json | sed 's/^\[//g' | sed 's/\[\[//g' | sed 's/\]\]//g' > colors.txt

worb() {
	# Should font color be black or white?
	# https://stackoverflow.com/a/7253786/10059841
	# HEX to RGB
	hexinput=$(echo $1 | sed 's/#//' | tr '[:lower:]' '[:upper:]')

	x=`echo $hexinput | cut -c-2`
	y=`echo $hexinput | cut -c3-4`
	z=`echo $hexinput | cut -c5-6`

	r=$(echo "ibase=16; $x" | bc)
	g=$(echo "ibase=16; $y" | bc)
	b=$(echo "ibase=16; $z" | bc)

	L=$(echo "$r*0.299 + $g*0.587 + $b*0.114 > 186" | bc)

	[[ $L -eq 1 ]] && echo "black" || echo "white"

}

while read H1 H2 H3 H4 H5; do
	filename="$(echo $H1-$H2-$H3-$H4-$H5 | sed 's/#//g')".png
	H1NOHASH=$(printf $H1 | sed 's/#//')
	H2NOHASH=$(printf $H2 | sed 's/#//')
	H3NOHASH=$(printf $H3 | sed 's/#//')
	H4NOHASH=$(printf $H4 | sed 's/#//')
	H5NOHASH=$(printf $H5 | sed 's/#//')
	echo $H1NOHASH  $H2NOHASH  $H3NOHASH  $H4NOHASH  $H5NOHASH
	convert -size 1200x720 xc:\#ffffff \
		-draw "fill #$H1 rectangle 0,0 240,720" \
		-draw "fill #$H2 rectangle 240,0 480,720" \
		-draw "fill #$H3 rectangle 480,0 720,720" \
		-draw "fill #$H4 rectangle 720,0 960,720" \
		-draw "fill #$H5 rectangle 960,0 1200,720" \
		-font Noto-Sans-Bold \
		-pointsize 30 \
		-fill $(worb $H1) -annotate +66+680   $H1NOHASH \
		-fill $(worb $H2) -annotate +306+680  $H2NOHASH \
		-fill $(worb $H3) -annotate +546+680  $H3NOHASH \
		-fill $(worb $H4) -annotate +786+680  $H4NOHASH \
		-fill $(worb $H5) -annotate +1026+680 $H5NOHASH \
		$filename

	# rounded corners
	convert $filename -matte mask.png -compose DstIn -composite $filename

	# we're done!
	echo "$filename generated"

done <<<$(cat colors.txt | sed 's/#//g')

# 1000.json from:
# https://github.com/Jam3/nice-color-palettes
