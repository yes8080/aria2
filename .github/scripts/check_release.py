import json
import os
import requests

def get_latest_release_info():
    latest_release_url = "https://api.github.com/repos/aria2/aria2/releases/latest"
    response = requests.get(latest_release_url, headers={"Accept": "application/vnd.github.v3+json"})
    response.raise_for_status()
    return response.json()

def check_new_version():
    latest_info = get_latest_release_info()
    latest_tag = latest_info['tag_name'].lstrip('v')

    current_tag = ''
    if os.path.exists('.latest_version'):
        with open('.latest_version', 'r') as file:
            current_tag = file.read().strip()

    if current_tag != latest_tag:
        print(f"::set-output name=new_version::{latest_tag}")
        with open('.latest_version', 'w') as file:
            file.write(latest_tag)

        assets = [asset['browser_download_url'] for asset in latest_info['assets'] if '-win' in asset['name']]
        print(f"::set-output name=download_urls::{json.dumps(assets)}")
    else:
        print("No new version found.")

if __name__ == "__main__":
    check_new_version()
