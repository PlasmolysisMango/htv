#!/bin/bash
cd /c/Users/jack/project/htv/iptv-api || exit 1
FF=/c/UserProgram/ffmpeg-master-latest-win64-gpl-shared/bin/ffmpeg.exe
OUT=audit_frames/new
mkdir -p "$OUT"

run_grab() {
  local tag="$1" url="$2"
  timeout 55 "$FF" -nostdin -hide_banner -loglevel error -threads 1 \
    -user_agent "AptvPlayer/1.4.10" -i "$url" -ss 8 -frames:v 1 \
    -vf scale=640:360 -y "$OUT/$tag.jpg" 2>"$OUT/$tag.err"
  echo "rc=$? $tag"
}
export -f run_grab
export FF OUT

xargs -P 4 -I{} bash -c 'IFS="|" read -r t u <<< "{}"; run_grab "$t" "$u"' <<'EOF'
n01_107-150-60-122_cctv5|http://107.150.60.122/live/cctv5hd.m3u8
n02_107-150-60-122_hnws|http://107.150.60.122/live/hnwshd.m3u8
n03_107-150-60-122_ssws|http://107.150.60.122/live/ssws.m3u8
n04_204-12-221-218_cctv14|http://204.12.221.218:8181/3m1080p/cctv14.m3u8
n05_207-56-13-146_cctv16|http://207.56.13.146:81/cdnlive/cctv16.m3u8
n06_101-35-240-114_szws|http://101.35.240.114:88/live.php?id=深圳卫视
n07_69-30-245-50_cctv3|http://69.30.245.50/live/cctv3.m3u8
n08_173-208-212-130_cctv4|http://173.208.212.130:8181/1080p/cctv4.m3u8
n09_38-64-72-148_szws|http://38.64.72.148:80/hls/modn/list/4007/playlist.m3u8
n10_218-13-170-98_gsws|http://218.13.170.98:9901/tsfile/live/0141_1.m3u8
n11_198-204-240-250_cctv6|http://198.204.240.250:82/live/cctv6.m3u8
n12_124-165-251-82_cctv8|http://124.165.251.82:85/tsfile/live/0008_1.m3u8?key=txiptv&playlive=1&authid=0
n13_111-59-139-82_hnws|http://111.59.139.82:11888/tsfile/live/0139_1.m3u8?key=txiptv&playlive=1&authid=0
EOF
echo "ALL DONE"
