start:
    @PID_FILE=".pid"; \
    LOG_FILE=".log"; \
    if [ -f "$$PID_FILE" ] && kill -0 "$(cat "$$PID_FILE")" 2>/dev/null; then \
        echo "Gateway already running (pid $(cat "$$PID_FILE"))"; \
        exit 0; \
    fi; \
    mkdir -p "$(dirname "$$LOG_FILE")"; \
    nohup openclaw gateway run --verbose > "$$LOG_FILE" 2>&1 & \
    echo $$! > "$$PID_FILE"; \
    echo "Started gateway (pid $$!)"

stop:
    @PID_FILE=".pid"; \
    if [ -f "$$PID_FILE" ]; then \
        PID="$(cat "$$PID_FILE")"; \
        if kill -0 "$$PID" 2>/dev/null; then \
            kill "$$PID"; \
            echo "Stopped gateway (pid $$PID)"; \
        else \
            echo "Gateway pid not running (pid $$PID)"; \
        fi; \
        rm -f "$$PID_FILE"; \
    else \
        echo "No PID file found"; \
    fi

restart:
    @PID_FILE=".pid"; \
    LOG_FILE=".log"; \
    if [ -f "$$PID_FILE" ]; then \
        PID="$(cat "$$PID_FILE")"; \
        if kill -0 "$$PID" 2>/dev/null; then \
            kill "$$PID"; \
            echo "Stopped gateway (pid $$PID)"; \
        fi; \
        rm -f "$$PID_FILE"; \
    fi; \
    mkdir -p "$(dirname "$$LOG_FILE")"; \
    nohup openclaw gateway run --verbose > "$$LOG_FILE" 2>&1 & \
    echo $$! > "$$PID_FILE"; \
    echo "Started gateway (pid $$!)"

status:
    @PID_FILE=".pid"; \
    if [ -f "$$PID_FILE" ]; then \
        PID="$(cat "$$PID_FILE")"; \
        if kill -0 "$$PID" 2>/dev/null; then \
            echo "Gateway running (pid $$PID)"; \
        else \
            echo "Gateway not running (stale pid $$PID)"; \
        fi; \
    else \
        echo "Gateway not running (no pidfile)"; \
    fi

config:
    @code ~/.openclaw/openclaw.json

download file:
    @test -n "$YT_BASE_DIR"
    @case "{{file}}" in *..*|*/*|*\$*|*~*) echo "Invalid file name: {{file}}"; exit 1;; esac
    @mkdir -p "$YT_BASE_DIR/{{file}}/video" "$YT_BASE_DIR/{{file}}/frames"
    @curl -L "https://bettr-casino-assets.s3.us-west-2.amazonaws.com/yt/{{file}}" -o "$YT_BASE_DIR/{{file}}/video/{{file}}"

extract file timestamp:
    @test -n "$YT_BASE_DIR"
    @case "{{file}}" in *..*|*/*|*\$*|*~*) echo "Invalid file name: {{file}}"; exit 1;; esac
    @./scripts/extract-frame.sh "$YT_BASE_DIR/{{file}}/video/{{file}}" "{{timestamp}}" "$YT_BASE_DIR/{{file}}/frames"
