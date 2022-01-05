#!/bin/bash
#
# NAME
# mp4-converter - Convert an mp4 video to webp|ogv optimized for web and save the first frame as jpeg
#
# SYNOPSIS
# mp4-converter video-input.mp4
#
# INSTALLATION
# sudo chmod +x /path/to/mp4-converter
#
# REQUIREMENTS
# - ffmpeg package
#
# AUTHOR:
# mp4-converter is written by Alfio Salanitri <www.alfiosalanitri.it> and are licensed under MIT license.
#

#############################################################
# Icons	and color
# https://www.techpaste.com/2012/11/print-colored-text-background-shell-script-linux/
# https://apps.timwhitlock.info/emoji/tables/unicode
#############################################################
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;33m'
nocolor='\033[0m'
icon_ok='\xE2\x9C\x94'
icon_ko='\xe2\x9c\x97'
icon_wait='\xE2\x8C\x9B'
icon_rocket='\xF0\x9F\x9A\x80'

# Usage
if [ $# -eq 0 ]; then
  cat <<-EOF
  Usage: $0 input-video.mp4
  Convert an mp4 video to webp|ogv optimized for web and save the first frame as jpeg

  input-vide.mp4  | A valid mp4 file to convert.
EOF
  exit 1
fi

# user input gif
mp4=$1

if ! command -v ffmpeg &> /dev/null; then
  printf "[${red}${icon_ko}${nocolor}] Sorry, but ${green}ffmpeg${nocolor} is required. Install it with apt install ffmpeg.\n"
  exit 1;
fi

# Check if input is gif
if [[ $(file "$mp4") != *MP4* ]]; then
  printf "[${red}${icon_ko}${nocolor}] Input file '$mp4' is not an mp4 video.\n"
  exit 1
fi

# convert gif to mp4
printf "[${yellow}${icon_wait}${nocolor}] optimizing mp4...\n"
ffmpeg -i "${mp4}" \
       -vcodec h264 \
       -b:v 1000k \
       -crf 24 \
       -an \
       "${mp4}-optimized.mp4" > /dev/null 2>&1
printf "[${green}${icon_ok}${nocolor}] Mp4 optimized.\n"
echo ""

# convert mp4 to webm
printf "[${yellow}${icon_wait}${nocolor}] converting mp4 to webm...\n"
ffmpeg -i "${mp4}-optimized.mp4" -vcodec libvpx -acodec libvorbis "$mp4.webm" > /dev/null 2>&1
printf "[${green}${icon_ok}${nocolor}] Webm saved.\n"
echo ""

# convert mp4 to ogv
printf "[${yellow}${icon_wait}${nocolor}] converting mp4 to ogv...\n"
ffmpeg -i "$mp4-optimized.mp4" -vcodec libtheora -q:v 2 "$mp4.ogv" > /dev/null 2>&1
printf "[${green}${icon_ok}${nocolor}] Ogv saved.\n"
echo ""

# save cover
printf "[${yellow}${icon_wait}${nocolor}] extracting cover from video...\n"
ffmpeg -i "$mp4" -vf fps=1 $mp4-cover-%d.jpg > /dev/null 2>&1
#keep only the first frame
mv "${mp4}-cover-1.jpg" "${mp4}-cover.jpg"
rm ${mp4}-cover-*
printf "[${green}${icon_ok}${nocolor}] cover saved.\n"
echo ""

# end
printf "\n\n ${icon_rocket} That's all!\n"
exit 1
