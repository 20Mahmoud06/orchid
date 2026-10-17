
#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="3.38.5"
FLUTTER_DIR="$HOME/flutter"

if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
  ARCHIVE="/tmp/flutter.tar.xz"
  URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

  curl -fsSL "$URL" -o "$ARCHIVE"

  echo "a264940cfc431c1778f34f7413fa6ab71443ad52c71f38c50b0284397a4039b0  $ARCHIVE" | sha256sum -c -

  tar -xf "$ARCHIVE" -C "$HOME"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

flutter config --enable-web
flutter pub get
flutter build web --release
