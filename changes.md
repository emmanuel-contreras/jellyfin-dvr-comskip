## Changes made to the jellyfin-dvr-comskip script 
---

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
---

### Changes to comchap

The comchap file has a bug where if your filenames have spaces you will see the error: 
* ***[: too many arguments***

```bash
#line 76 needs quotes if your filenames have spaces
# if [ -z $infile ]; then 
if [ -z "$infile" ]; then
```


