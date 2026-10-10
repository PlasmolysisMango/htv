#!/bin/bash
cd /c/Users/jack/project/htv/iptv-api/audit_frames/new || exit 1
FF=/c/UserProgram/ffmpeg-master-latest-win64-gpl-shared/bin/ffmpeg.exe
FONT='C\:/Windows/Fonts/arial.ttf'

build() {
  out="$1"; shift
  n=0; ins=(); fc=""
  for spec in "$@"; do
    label="${spec%%::*}"; file="${spec##*::}"
    ins+=(-i "$file")
    fc+="[${n}:v]scale=320:180,setsar=1,drawtext=fontfile='${FONT}':text='${label}':x=4:y=4:fontsize=15:fontcolor=white:borderw=2:bordercolor=black[a${n}];"
    n=$((n+1))
  done
  stack=""; for ((i=0;i<n;i++)); do stack+="[a${i}]"; done
  fc+="${stack}xstack=inputs=${n}:layout=0_0|320_0|640_0|0_180|320_180|640_180[out]"
  "$FF" -hide_banner -loglevel error "${ins[@]}" -filter_complex "$fc" -map "[out]" -frames:v 1 -y "$out"
  echo "rc=$? $out"
}

build mont_n1.jpg \
 "1 107.150.60.122 CCTV-5::n01_107-150-60-122_cctv5.jpg" \
 "2 107.150.60.122 HunanWS::n02_107-150-60-122_hnws.jpg" \
 "3 107.150.60.122 SanshaWS::n03_107-150-60-122_ssws.jpg" \
 "4 204.12.221.218 CCTV-14::n04_204-12-221-218_cctv14.jpg" \
 "5 207.56.13.146 CCTV-16::n05_207-56-13-146_cctv16.jpg" \
 "6 111.59.139.82 HenanWS::n13_111-59-139-82_hnws.jpg"

build mont_n2.jpg \
 "7 69.30.245.50 CCTV-3::n07_69-30-245-50_cctv3.jpg" \
 "8 173.208.212.130 CCTV-4::n08_173-208-212-130_cctv4.jpg" \
 "9 38.64.72.148 ShenzhenWS::n09_38-64-72-148_szws.jpg" \
 "10 218.13.170.98 GansuWS::n10_218-13-170-98_gsws.jpg" \
 "11 198.204.240.250 CCTV-6::n11_198-204-240-250_cctv6.jpg" \
 "12 124.165.251.82 CCTV-8::n12_124-165-251-82_cctv8.jpg"
