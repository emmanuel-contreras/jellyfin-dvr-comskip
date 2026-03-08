# jellyfin-dvr-comskip

This is a script that is called after a video is recorded in Jellyfin Live TV. It attempts to mark or remove the commercials using Comcut & Comskip and then converts the video using Jellyfin ffmpeg.

The script also attempts to extract closed captions as SRT subtitles.

You can find where to put this script by going to the Server Dashboard in the Jellyfin web interface, then DVR under Live TV, then "Post-processing application:" field.

ComChap - A script that marks commericals as chapters that can be skipped.<br>
ComCut - A script that removes marked commericals.

If you have updates for this script please submit a PR so everyone can benefit.

You will need to have Comskip already installed from here:
https://github.com/erikkaashoek/Comskip

---
---

### Changes made to the jellyfin-dvr-comskip script 
---

> Note: I am running into *Segmentation fault (core dump)* errors running comskip. It seems to be related to this issue below where the logo.txt file needs to be created and comskip run again. To fix this I run comskip once again if the edl file is not found after running it, all inside comchap, with deletion of the logo.txt file disabled in comchap so that comskip finds that file on the next run 
https://github.com/erikkaashoek/Comskip/issues/158


#### As this issue mentions i made the following changes:
https://github.com/Protektor-Desura/jellyfin-dvr-comskip/issues/5

``` bash
# Set video codec for ffmpeg
__videocodec="libx264"
# Set audio codec for ffmpeg
__audiocodec="aac"
```

The original script has three underscores for container so that is fixed

``` bash
# Set video container
__container="mkv"
```


Removed the *local* part from --comskip=/usr/local/bin/comskip because it gets installed in /bin.

``` bash
#comcut/comskip - currently using jellyfin ffmpeg in docker
$__command --ffmpeg=$__ffmpeg --comskip=/usr/bin/comskip --comskip-ini=/config/comskip/comskip.ini "${__file}"
```

Two more changes to this line
1) Created a variable to set the path to the *comskip.ini* file at the top
2) The input file from OTA broadcast is a .ts file which does not store chapters, so I specify a temp.mkv file as output of **comchap** otherwise you end up with no chapters in the .ts file.
``` bash
$__command --ffmpeg=$__ffmpeg --comskip=/usr/bin/comskip --lockfile=/tmp/comchap.lock --comskip-ini="${__comskip_ini}" "${__file}" "temp.mkv"
```

Comskip is not perfect so I am using comchap to add chapters instead of cutting them out completely.

``` bash
# Set to skip commericals (mark as chapters) or cut commericals
# __command="/config/comskip"
# __command="/config/comcut"
__command="/home/nabiki/Desktop/jellyfin-dvr-comskip/config/comskip/comchap"
```


I also didn't see the need to extract the subtitles from the file and this was causing the .ts file to not play properly after running this line, so I just commented it out.

``` bash
# Extract closed captions to external SRT file
# printf "[post-process.sh] %bExtracting subtitles...%b\n" "$GREEN" "$NC"
# $__ffmpeg -f lavfi -i movie="${__file}[out+subcc]" -map 0:1 "${__base}.en.srt"
```

---
### Changes to comchap

The comchap file has a bug where if your filenames have spaces you will see the error: 
* ***[: too many arguments***

```bash
#line 76 needs quotes if your filenames have spaces
# if [ -z $infile ]; then 
if [ -z "$infile" ]; then
```

Also as this PR request, I added ***-map 0*** to the ffmpeg line to copy all input streams to the output file

https://github.com/BrettSheleski/comchap/pull/51/changes/ab8670d76b19a04dacc709b75ea9007a7cce0eba

``` bash
    if $ffmpegPath -loglevel error -hide_banner -nostdin -i "$infile" -i "$metafile" -map 0 -map_metadata 1 -codec copy -y "$outfile" 1>&3 2>&4; then

```