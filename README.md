# Generate Color Palettes

A shell script that generates color palettes in PNG format based on JSON file input.

# Instructions

0. `git clone https://github.com/majamin/color-palette-generator`
0. `cd color-palette-generator`
0. `chmod +x colors.sh`
0. `./colors.sh`

# What it does

0. `colors.sh` downloads 1000.json from my [repo](https://github.com/majamin/nice-color-palettes) (original: https://github.com/Jam3/nice-color-palettes).
0. Converts the JSON file to a simple plain text file of one palette per line.
0. Calculates whether a black or white font color should be used depending on color.
0. Uses ImageMagick to convert each color to a rectangle and combines.
0. Uses ImageMagick to create a nice "rounded rectangle" image mask.
0. Writes output to a separate directory.

# Preview

One:

![One example](example.png)

Many:

![Gallery](short-gallery.png)

# Issues

PRs are welcome.
