import io
import os
import urllib.request
import zipfile

URL = "https://github.com/godotengine/godot/releases/download/4.6.1-stable/Godot_v4.6.1-stable_export_templates.tpz"
TARGET_DIR = os.path.expanduser("~/.local/share/godot/export_templates/4.6.1.stable")

class RemoteZipFile(io.RawIOBase):
    def __init__(self, url):
        self.url = url
        req = urllib.request.Request(url, headers={"User-Agent": "GodotInstaller/1.0"})
        with urllib.request.urlopen(req) as resp:
            self.redirected_url = resp.geturl()
            self.size = int(resp.headers["Content-Length"])
        self.pos = 0
        self.buffer = b""
        self.buffer_start = 0
        print(f"Archive connected: {self.size / (1024*1024):.1f} MB")

    def seekable(self): return True
    def readable(self): return True
    def seek(self, offset, whence=io.SEEK_SET):
        if whence == io.SEEK_SET: self.pos = offset
        elif whence == io.SEEK_CUR: self.pos += offset
        elif whence == io.SEEK_END: self.pos = self.size + offset
        return self.pos
    def tell(self): return self.pos

    def _fetch_buffer(self, start, min_bytes=4*1024*1024):
        fetch_len = max(min_bytes, 4*1024*1024)
        end = min(start + fetch_len - 1, self.size - 1)
        req = urllib.request.Request(self.redirected_url, headers={"Range": f"bytes={start}-{end}", "User-Agent": "GodotInstaller/1.0"})
        with urllib.request.urlopen(req) as resp:
            self.buffer = resp.read()
        self.buffer_start = start

    def readinto(self, b):
        if self.pos >= self.size: return 0
        needed = len(b)
        if not (self.buffer_start <= self.pos < self.buffer_start + len(self.buffer)):
            self._fetch_buffer(self.pos, needed)
        
        offset = self.pos - self.buffer_start
        avail = len(self.buffer) - offset
        to_copy = min(needed, avail)
        b[:to_copy] = self.buffer[offset : offset + to_copy]
        self.pos += to_copy
        return to_copy

def main():
    remote_stream = RemoteZipFile(URL)
    os.makedirs(TARGET_DIR, exist_ok=True)
    
    with zipfile.ZipFile(remote_stream) as z:
        print("Zip directory parsed successfully!")
        for info in z.infolist():
            bname = os.path.basename(info.filename)
            if bname.startswith("android_") or bname == "version.txt":
                out_path = os.path.join(TARGET_DIR, bname)
                print(f"Extracting {bname} ({info.file_size / (1024*1024):.2f} MB)...")
                with z.open(info) as src, open(out_path, "wb") as dst:
                    while True:
                        chunk = src.read(256 * 1024)
                        if not chunk: break
                        dst.write(chunk)
                print(f"  -> Saved {out_path} ({os.path.getsize(out_path)} bytes)")

    print("ALL ANDROID TEMPLATES INSTALLED SUCCESSFULLY!")

if __name__ == "__main__":
    main()
