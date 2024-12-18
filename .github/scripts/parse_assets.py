import json
import sys

def parse_assets(json_file):
    with open(json_file, 'r') as f:
        data = json.load(f)

    new_version = data.get("tag_name", "").replace("release-", "")
    print(new_version, file=open("new_version.txt", "w"))

    assets_info = []
    for asset in data.get("assets", []):
        browser_url = asset.get("browser_download_url", "")
        asset_name = asset.get("name", "")

        if "win-" in browser_url:
            arch = "64bit" if "64bit" in asset_name else "32bit"
            assets_info.append((browser_url, asset_name, arch))

    with open("assets_info.txt", "w") as out_file:
        for url, filename, arch in assets_info:
            out_file.write("\n".join((url, filename, arch)) + "\n")

if __name__ == "__main__":
    parse_assets(sys.argv[1])
