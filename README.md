# Generate Color Palettes

A shell script that generates color palettes in PNG format.
Other than the dependencies, this is a turn-key script.
Instructions on how to download and process the JSON data use is described in `colors.sh`.

The original repo that inspired this script: https://github.com/Jam3/nice-color-palettes

# Instructions

You'll need `cat` (present on most systems), `ImageMagick`, and `bc`. Optionally, `curl` and `jq`.

1. `git clone https://github.com/majamin/color-palette-generator`
1. `cd color-palette-generator`
1. `chmod +x colors.sh`
1. `./colors.sh`

# What it does

1. Uses ImageMagick to convert each color to a rectangle and combines.
1. Uses ImageMagick to create a nice "rounded rectangle" image mask.
1. Calculates whether a black or white font color should be used depending on color.
1. Writes output to a separate directory.

# Preview

One:

![One example](example.png)

Many:

![Gallery](short-gallery.png)

# Issues

PRs are welcome.
