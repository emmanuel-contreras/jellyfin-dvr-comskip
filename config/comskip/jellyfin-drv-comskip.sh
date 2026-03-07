#!/usr/bin/env bash

#
# This is for Jellyfin docker. 
# The comskip.ini file used is stored in /config/comskip for easy access, editing and to survive upgrades.
#

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

# Set ffmpeg path to Jellyfin ffmpeg
__ffmpeg="$(which ffmpeg || echo '/usr/lib/jellyfin-ffmpeg/ffmpeg')"

# Set to skip commericals (mark as chapters) or cut commericals
# __command="/config/comskip"
#__command="/config/comcut"
__command="/home/nabiki/Desktop/jellyfin-dvr-comskip/config/comskip/comchap"

__comskip_ini='/home/nabiki/Desktop/jellyfin-dvr-comskip/config/comskip/comskip.ini'

# Set video codec for ffmpeg
__videocodec="libx264"

# Set audio codec for ffmpeg
__audiocodec="aac"

# Set bitrate for audio codec for ffmpeg
__bitrate="128000"

# Set video container
__container="mkv"

# Set CRF
__crf="20"

# Set Preset
__preset="slow"

# Green Color
GREEN='\033[0;32m'

# No Color
NC='\033[0m'

# Set Path
__path="${1:-}"


PWD="$(pwd)"

die () {
	echo >&2 "$@"
	cd "${PWD}"
	exit 1
}

# verify a path was provided
[ -n "$__path" ] || die "path is required"
# verify the path exists
[ -f "$__path" ] || die "path ($__path) is not a file"

__dir="$(dirname "${__path}")"
__file="$(basename "${__path}")"
__base="$(basename "${__path}" ".ts")"

__outfile="${__base}.${__container}"

# Debbuging path variables
# printf "${GREEN}path:${NC} ${__path}\ndir: ${__dir}\nbase: ${__base}\n"

# Change to the directory containing the recording
cd "${__dir}"

# Extract closed captions to external SRT file
# printf "[post-process.sh] %bExtracting subtitles...%b\n" "$GREEN" "$NC"
# $__ffmpeg -f lavfi -i movie="${__file}[out+subcc]" -map 0:1 "${__base}.en.srt"

#comcut/comskip - currently using jellyfin ffmpeg in docker
# .ts doesn't support chapters so if your chapters aren't being added, then it's because the input and output at .ts files
# $__command --ffmpeg=$__ffmpeg --comskip=/usr/bin/comskip --lockfile=/tmp/comchap.lock --comskip-ini="${__comskip_ini}" "${__file}" "temp.mkv"
$__command --ffmpeg=$__ffmpeg --comskip=/usr/bin/comskip --lockfile=/tmp/comchap.lock --comskip-ini="${__comskip_ini}" "${__file}" "temp.mkv"

# Transcode to mkv, crf parameter can be adjusted to change output quality
# printf "[post-process.sh] %bTranscoding file..%b\n" "$GREEN" "$NC"
$__ffmpeg -i 'temp.mkv' -map 0 -acodec "${__audiocodec}" -b:a "${__bitrate}" -vcodec "${__videocodec}" -vf yadif=parity=auto -crf "${__crf}" -preset "${__preset}" "${__outfile}"

# Remove temp mkv file
printf "[post-process.sh] %bRemoving temp.mkv file...%b\n" "$GREEN" "$NC"
rm "temp.mkv"

# Remove the original recording file
#printf "[post-process.sh] %bRemoving originial file...%b\n" "$GREEN" "$NC"
#rm "${__file}"


# Return to the starting directory
cd "${PWD}"
