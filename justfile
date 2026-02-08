start:
    openclaw gateway start

stop:
    openclaw gateway stop

restart:
    openclaw gateway restart

status:
    openclaw gateway status

config:
    code ~/.openclaw/openclaw.json

download file:
    test -n "$YT_BASE_DIR"
    case "{{file}}" in *..*|*/*|*\$*|*~*) echo "Invalid file name: {{file}}"; exit 1;; esac
    mkdir -p "$YT_BASE_DIR/{{file}}/video" "$YT_BASE_DIR/{{file}}/frames"
    curl -L "https://bettr-casino-assets.s3.us-west-2.amazonaws.com/yt/{{file}}" -o "$YT_BASE_DIR/{{file}}/video/{{file}}"

extract file timestamp:
    test -n "$YT_BASE_DIR"
    case "{{file}}" in *..*|*/*|*\$*|*~*) echo "Invalid file name: {{file}}"; exit 1;; esac
    ./scripts/extract-frame.sh "$YT_BASE_DIR/{{file}}/video/{{file}}" "{{timestamp}}" "$YT_BASE_DIR/{{file}}/frames"
