import os
import requests
import zipfile
import shutil
import subprocess
import glob

def get_latest_release_info():
    response = requests.get("https://api.github.com/repos/aria2/aria2/releases/latest")
    release_info = response.json()
    tag_name = release_info['tag_name']
    version = tag_name.replace("release-", "")
    download_url = next(asset['browser_download_url'] for asset in release_info['assets'] if "win-64bit-build1.zip" in asset['name'])
    body = release_info['body'].replace('\n', ' ')
    return version, download_url, body

def download_file(url, path):
    response = requests.get(url, stream=True)
    with open(path, 'wb') as file:
        for chunk in response.iter_content(chunk_size=8192):
            file.write(chunk)

def extract_zip(file_path, extract_to):
    with zipfile.ZipFile(file_path, 'r') as zip_ref:
        zip_ref.extractall(extract_to)

def repackage_folder(src_folder, output_file):
    shutil.make_archive(output_file, 'zip', src_folder)

def move_files_to_folder(src_folder, dest_folder):
    if not os.path.exists(dest_folder):
        os.makedirs(dest_folder)
    for filename in os.listdir(src_folder):
        src_file = os.path.join(src_folder, filename)
        shutil.move(src_file, dest_folder)

def create_git_tag(version):
    result = subprocess.run(["git", "ls-remote", "--tags", "origin"], capture_output=True, text=True)
    if f"refs/tags/v{version}" in result.stdout:
        return True
    else:
        subprocess.run(["git", "tag", f"v{version}"])
        subprocess.run(["git", "push", "origin", f"v{version}"])
        return False

def main():
    version, download_url, body = get_latest_release_info()
    os.environ["VERSION"] = version
    os.environ["DOWNLOAD_URL"] = download_url
    os.environ["BODY"] = body
    print(f"Version: {version}, Download URL: {download_url}")

    download_file(download_url, "aria2.zip")
    print("Downloaded aria2.zip")
    extract_zip("aria2.zip", "aria2")
    print("Extracted aria2.zip")

    # Use glob to find the actual directory name
    extracted_dirs = glob.glob("aria2/aria2-*-win-64bit-build1")
    if not extracted_dirs:
        raise FileNotFoundError("The expected directory was not found after extraction.")
    
    extracted_dir = extracted_dirs[0]
    new_dir = f"aria2/aria2-{version}-win-64bit"
    move_files_to_folder(extracted_dir, new_dir)
    print(f"Moved files to {new_dir}")

    shutil.copy("dl.cmd", f"{new_dir}/dl.cmd")
    print("Copied dl.cmd")
    repackage_folder(new_dir, f"aria2-{version}-win-64bit")
    print(f"Repackaged to aria2-{version}-win-64bit.zip")

    tag_exists = create_git_tag(version)
    print(f"Tag already exists: {tag_exists}")

    # Write environment variables to file
    with open("env_vars.txt", "w") as env_file:
        env_file.write(f"VERSION={version}\n")
        env_file.write(f"DOWNLOAD_URL={download_url}\n")
        env_file.write(f"BODY={body}\n")
        env_file.write(f"TAG_ALREADY_EXISTS={str(tag_exists).lower()}\n")

if __name__ == "__main__":
    main()
