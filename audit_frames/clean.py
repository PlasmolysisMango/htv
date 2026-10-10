import re
import shutil
from datetime import datetime
from pathlib import Path

ROOT = Path(r"C:\Users\jack\project\htv\iptv-api")
OUT = ROOT / "output"
BAD = ["47.97.252.137", "218.84.12.186", "120.76.248.139", "dsdqbv/cctv11hd", "061899.xyz", "207.56.13.146", "101.35.240.114"]

SICHUAN_MARK = "112.27.5.218:9901/tsfile/live/0111_1"
CCTV5P_MARK = "cctv5p.m3u8"

TS = datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def is_bad(line):
    return any(b in line for b in BAD)


URL_RE = re.compile(r"^(?P<name>.+?),(?P<url>https?://.+)$")


def rename_txt(line):
    m = URL_RE.match(line)
    if not m:
        return line
    name, url = m.group("name"), m.group("url")
    if SICHUAN_MARK in url and name == "西藏卫视":
        name = "四川卫视"
    elif CCTV5P_MARK in url and name == "CCTV-5":
        name = "CCTV-5+"
    return f"{name},{url}"


def clean_txt(path):
    lines = path.read_text(encoding="utf-8").splitlines()
    kept = [rename_txt(l) for l in lines if not is_bad(l)]

    first_url = None
    for l in kept:
        m = URL_RE.match(l)
        if m and "#genre#" not in l:
            first_url = m.group("url")
            break

    genre_idx = next(i for i, l in enumerate(kept) if "#genre#" in l and "更新时间" in l)
    nxt = kept[genre_idx + 1] if genre_idx + 1 < len(kept) else ""
    stamp = f"{TS},{first_url}"
    if re.match(r"^\d{4}-\d{2}-\d{2} .+,https?://", nxt):
        kept[genre_idx + 1] = stamp
    else:
        kept.insert(genre_idx + 1, stamp)

    path.write_text("\n".join(kept) + "\n", encoding="utf-8")
    removed = len(lines) - (len(kept) - 1)
    print(f"{path.name}: {len(lines)} -> {len(kept)} lines (removed {removed})")


def fix_extinf(ext, url):
    if SICHUAN_MARK in url and "西藏卫视" in ext:
        ext = (
            ext.replace('tvg-id="西藏卫视"', 'tvg-id="四川卫视"')
            .replace('tvg-name="西藏卫视"', 'tvg-name="四川卫视"')
            .replace("logo/西藏卫视.png", "logo/四川卫视.png")
        )
        ext = ext[: ext.rfind(",") + 1] + "四川卫视"
    elif CCTV5P_MARK in url and 'tvg-id="CCTV-5"' in ext:
        ext = (
            ext.replace('tvg-id="CCTV-5"', 'tvg-id="CCTV-5+"')
            .replace('tvg-name="CCTV-5"', 'tvg-name="CCTV-5+"')
            .replace("tvlogo/CCTV-5.png", "tvlogo/CCTV-5+.png")
        )
        ext = ext[: ext.rfind(",") + 1] + "CCTV-5+"
    return ext


def clean_m3u(path):
    raw = path.read_text(encoding="utf-8").splitlines()
    out = []
    extinf = None
    first_ext = None
    first_url = None
    for line in raw:
        if line.startswith("#EXTM3U"):
            out.append(line)
            continue
        if line.startswith("#EXTINF"):
            extinf = line
            continue
        if not line.strip():
            continue
        if extinf is not None:
            if not is_bad(line) and not (extinf and "更新时间" in extinf):
                fixed = fix_extinf(extinf, line)
                if first_ext is None:
                    first_ext, first_url = fixed, line
                out.append(fixed)
                out.append(line)
        extinf = None

    header_attrs = first_ext.split(" group-title=")[0] if first_ext else '#EXTINF:-1 tvg-id="CCTV-1" tvg-name="CCTV-1"'
    update_ext = f'{header_attrs} group-title="🕘️更新时间",{TS}'
    out.insert(1, update_ext)
    out.insert(2, first_url)

    path.write_text("\n".join(out) + "\n", encoding="utf-8")
    extinf_count = sum(1 for l in out if l.startswith("#EXTINF"))
    print(f"{path.name}: {len(raw)} -> {len(out)} lines, {extinf_count} EXTINF entries")


for rel in ["result.txt", "ipv4/result.txt"]:
    clean_txt(OUT / rel)
for rel in ["result.m3u", "ipv4/result.m3u"]:
    clean_m3u(OUT / rel)

shutil.copyfile(OUT / "ipv4/result.m3u", OUT / "speed_result.m3u")
print("speed_result.m3u rebuilt from ipv4/result.m3u")
