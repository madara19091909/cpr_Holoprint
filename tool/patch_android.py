from pathlib import Path
import re
import sys

manifest = Path('android/app/src/main/AndroidManifest.xml')
if not manifest.exists():
    print(f'Android manifest not found: {manifest}', file=sys.stderr)
    sys.exit(1)

text = manifest.read_text(encoding='utf-8')
if 'android.permission.INTERNET' not in text:
    match = re.search(r'<manifest\b[^>]*>', text)
    if not match:
        print('Could not locate manifest root element.', file=sys.stderr)
        sys.exit(1)
    insert_at = match.end()
    text = text[:insert_at] + '\n    <uses-permission android:name="android.permission.INTERNET" />' + text[insert_at:]

text = re.sub(r'android:label="[^"]*"', 'android:label="CPR Holoprint"', text, count=1)
manifest.write_text(text, encoding='utf-8')
print('Android manifest configured: INTERNET permission + CPR Holoprint label.')
