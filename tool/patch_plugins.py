"""Patch third-party Flutter plugins whose Android Gradle files still use the
removed `proguard-android.txt` default file.

Newer Android Gradle Plugin / R8 versions reject
`getDefaultProguardFile('proguard-android.txt')` because it contains
`-dontoptimize`. The supported replacement is `proguard-android-optimize.txt`.

Run AFTER `flutter pub get` and BEFORE `flutter build apk`.
"""
from pathlib import Path
import os
import sys

OLD = "proguard-android.txt"
NEW = "proguard-android-optimize.txt"


def pub_cache_roots():
    roots = []
    env = os.environ.get("PUB_CACHE")
    if env:
        roots.append(Path(env))
    roots.append(Path.home() / ".pub-cache")
    return [r for r in roots if r.exists()]


def main() -> int:
    patched = []
    for root in pub_cache_roots():
        hosted = root / "hosted"
        if not hosted.exists():
            continue
        for gradle in hosted.glob("*/*/android/build.gradle*"):
            if gradle.suffix not in (".gradle", ".kts"):
                continue
            try:
                text = gradle.read_text(encoding="utf-8")
            except (OSError, UnicodeDecodeError):
                continue
            if OLD in text:
                gradle.write_text(text.replace(OLD, NEW), encoding="utf-8")
                patched.append(gradle)

    if patched:
        for path in patched:
            print(f"Patched: {path}")
    else:
        print("No plugin Gradle files needed patching.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
