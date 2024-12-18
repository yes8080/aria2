import os

OUTPUT_DIR = os.getenv("GITHUB_WORKSPACE", ".")  # 默认工作目录

def parse_assets(json_filepath):
    with open(json_filepath, 'r') as f:
        data = json.load(f)

    version_tag = data.get('tag_name', '').replace('release-', '')

    with open(os.path.join(OUTPUT_DIR, 'new_version.txt'), 'w') as f:
        f.write(version_tag)

    asset_info = []
    for asset in data.get('assets', []):
        url = asset.get('browser_download_url', '')
        name = asset.get('name', '')

        if "win-" in url:
            arch = "64bit" if "64bit" in name else "32bit"
            asset_info.append((url, name, arch))

    with open(os.path.join(OUTPUT_DIR, 'assets_info.txt'), 'w') as f:
        for url, filename, arch in asset_info:
            f.write(f"{url}\n{filename}\n{arch}\n")