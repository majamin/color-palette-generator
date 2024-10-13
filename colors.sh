#!/bin/bash
# Creates color palettes based on TEXT or JSON data
# Author: Marian Minar <majamin at gmail dot com>
# License: MIT

# Usage: ./colors.sh <COLFILE>
# See colors.txt for an example of <COLFILE>.

# You can run this script as-is, but if you want to grab the original data
# here are the instructions:

# First grab some JSON-formatted data and write 'colors.json'
# curl -s -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" \
#   "http://www.colourlovers.com/api/palettes/top?format=json&numResults=100&resultOffset=0" |
#   jq . >colors.json

# With the generate 'colors.json' file, turn into plain text:
#
# cat colors{0,1,2,3,4,5,6,7,8,9}.json |
#   jq --raw-output '.[].colors |\ @tsv' >colors.txt

#-----------------------------------------------------------------------------
# Dependencies: cat, magick, bc
cmd_failures=''
for cmd in cat magick bc; do
  command -v "${cmd}" >/dev/null 2>&1 || cmd_failures="${cmd_failures},${cmd}"
done

if (("${#cmd_failures}" > 0)); then
  printf -- '%s\n' "The following dependencies are missing: ${cmd_failures/,/}" >&2
  exit 1
fi

#-----------------------------------------------------------------------------
# Vars
COLFILE="$1"
FONTFILE="JetBrainsMonoNL-ExtraBold.ttf"
MASKFILE="mask.png"
TEMPFILE="temp.png"
OUTDIR="out"

#-----------------------------------------------------------------------------
# Contrast for the color descriptor should be readable.
# This function decides whether to make the font black or white.
# More on luminance: https://stackoverflow.com/a/7253786/10059841
# More on threshold: https://gamedev.stackexchange.com/a/38561
white_or_black() {
  # HEX to RGB
  HEX="$1"
  RED=$(echo "ibase=16; ${HEX:0:2}/FF" | bc -l)
  GREEN=$(echo "ibase=16; ${HEX:2:2}/FF" | bc -l)
  BLUE=$(echo "ibase=16; ${HEX:4:2}/FF" | bc -l)

  # Calculate luminance (in a rough way)
  LUMINANCE=$(echo "0.2126*${RED} + 0.7152*${GREEN} + 0.0722*${BLUE}" | bc -l)

  CONTRAST_THRESHOLD=0.5 # values from 0 to 1
  # use_black is 1 if true, 0 otherwise
  USEBLACK=$(echo "$LUMINANCE > $CONTRAST_THRESHOLD" | bc -l)

  [[ $USEBLACK -eq 1 ]] && echo "black" || echo "white"
}

usage() {
  printf -- '%s\n' "Usage: $0 <COLFILE>"
}

# use a red error message and exit
die() {
  printf -- '\033[31m%s\033[0m\n' "$1" >&2
  exit 1
}

#-----------------------------------------------------------------------------

# Check if $1 is a file
[[ ! -f "$COLFILE" ]] &&
  usage &&
  die "Colors file not provided. See colors.txt for an example."

# Make the out dir
[[ ! -d "$OUTDIR" ]] && mkdir -p "$OUTDIR" 2>/dev/null

# Generate mask
magick -size 1200x720 xc:none -draw "roundrectangle 0,0,1200,720,15,15" "$MASKFILE"

COL1="+66"
COL2="+306"
COL3="+546"
COL4="+786"
COL5="+1026"
ROW1="+680"
ROW2="+590"
ROW3="+550"
ROW4="+510"
ROW5="+470"
# Main loop
# Fill a small square inside each rectangle with the
# color of the next rectangle in the row.
# Also, colorize the hex values with the same color
# and draw each combination in a row
while IFS=$'\t' read -r H1 H2 H3 H4 H5; do
  FILEOUT="$H1-$H2-$H3-$H4-$H5.png"
  magick -size 1200x720 xc:\#ffffff \
    -draw "fill \"#${H1}\" rectangle 0,0 240,720" \
    -draw "fill \"#${H2}\" rectangle 240,0 480,720" \
    -draw "fill \"#${H3}\" rectangle 480,0 720,720" \
    -draw "fill \"#${H4}\" rectangle 720,0 960,720" \
    -draw "fill \"#${H5}\" rectangle 960,0 1200,720" \
    \
    -draw "fill \"#${H1}\" rectangle 320,360 400,280" \
    -draw "fill \"#${H2}\" rectangle 560,360 640,280" \
    -draw "fill \"#${H3}\" rectangle 800,360 880,280" \
    -draw "fill \"#${H4}\" rectangle 1040,360 1120,280" \
    -draw "fill \"#${H5}\" rectangle 80,360 160,280" \
    \
    -draw "fill \"#${H1}\" rectangle 560,280 640,200" \
    -draw "fill \"#${H2}\" rectangle 800,280 880,200" \
    -draw "fill \"#${H3}\" rectangle 1040,280 1120,200" \
    -draw "fill \"#${H4}\" rectangle 80,280 160,200" \
    -draw "fill \"#${H5}\" rectangle 320,280 400,200" \
    \
    -draw "fill \"#${H1}\" rectangle 800,200 880,120" \
    -draw "fill \"#${H2}\" rectangle 1040,200 1120,120" \
    -draw "fill \"#${H3}\" rectangle 80,200 160,120" \
    -draw "fill \"#${H4}\" rectangle 320,200 400,120" \
    -draw "fill \"#${H5}\" rectangle 560,200 640,120" \
    \
    -draw "fill \"#${H1}\" rectangle 1040,120 1120,40" \
    -draw "fill \"#${H2}\" rectangle 80,120 160,40" \
    -draw "fill \"#${H3}\" rectangle 320,120 400,40" \
    -draw "fill \"#${H4}\" rectangle 560,120 640,40" \
    -draw "fill \"#${H5}\" rectangle 800,120 880,40" \
    \
    -font "$FONTFILE" \
    -pointsize 30 \
    -fill "$(white_or_black "$H1")" -annotate "${COL1}${ROW1}" "$H1" \
    -fill "$(white_or_black "$H2")" -annotate "${COL2}${ROW1}" "$H2" \
    -fill "$(white_or_black "$H3")" -annotate "${COL3}${ROW1}" "$H3" \
    -fill "$(white_or_black "$H4")" -annotate "${COL4}${ROW1}" "$H4" \
    -fill "$(white_or_black "$H5")" -annotate "${COL5}${ROW1}" "$H5" \
    \
    -fill "\#$H1" -annotate "${COL2}${ROW2}" "$H1" \
    -fill "\#$H2" -annotate "${COL3}${ROW2}" "$H2" \
    -fill "\#$H3" -annotate "${COL4}${ROW2}" "$H3" \
    -fill "\#$H4" -annotate "${COL5}${ROW2}" "$H4" \
    -fill "\#$H5" -annotate "${COL1}${ROW2}" "$H5" \
    \
    -fill "\#$H1" -annotate "${COL2}${ROW2}" "$H1" \
    -fill "\#$H2" -annotate "${COL3}${ROW2}" "$H2" \
    -fill "\#$H3" -annotate "${COL4}${ROW2}" "$H3" \
    -fill "\#$H4" -annotate "${COL5}${ROW2}" "$H4" \
    -fill "\#$H5" -annotate "${COL1}${ROW2}" "$H5" \
    \
    -fill "\#$H1" -annotate "${COL3}${ROW3}" "$H1" \
    -fill "\#$H2" -annotate "${COL4}${ROW3}" "$H2" \
    -fill "\#$H3" -annotate "${COL5}${ROW3}" "$H3" \
    -fill "\#$H4" -annotate "${COL1}${ROW3}" "$H4" \
    -fill "\#$H5" -annotate "${COL2}${ROW3}" "$H5" \
    \
    -fill "\#$H1" -annotate "${COL4}${ROW4}" "$H1" \
    -fill "\#$H2" -annotate "${COL5}${ROW4}" "$H2" \
    -fill "\#$H3" -annotate "${COL1}${ROW4}" "$H3" \
    -fill "\#$H4" -annotate "${COL2}${ROW4}" "$H4" \
    -fill "\#$H5" -annotate "${COL3}${ROW4}" "$H5" \
    \
    -fill "\#$H1" -annotate "${COL5}${ROW5}" "$H1" \
    -fill "\#$H2" -annotate "${COL1}${ROW5}" "$H2" \
    -fill "\#$H3" -annotate "${COL2}${ROW5}" "$H3" \
    -fill "\#$H4" -annotate "${COL3}${ROW5}" "$H4" \
    -fill "\#$H5" -annotate "${COL4}${ROW5}" "$H5" \
    "$TEMPFILE"

  # round the corners and write the file
  if [[ -e "$OUTDIR/$FILEOUT" ]]; then
    printf "%s\n" "File $OUTDIR/$FILEOUT exists - skipping"
  else
    magick "$TEMPFILE" -alpha Set "$MASKFILE" -compose DstIn -composite "$OUTDIR/$FILEOUT" &&
      printf "Success: %s/%s written\n" "$OUTDIR" "$FILEOUT"
  fi
done <<<"$(cat "$COLFILE")"

rm "$TEMPFILE"
