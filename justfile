set shell := ["bash", "-cu"]

start:
    @if [ -f ".pid.current" ] && kill -0 "$(cat .pid.current)" 2>/dev/null; then \
        echo "Gateway already running (pid $(cat .pid.current))"; \
        exit 0; \
    fi; \
    nohup openclaw gateway run --verbose > ".log.tmp" 2>&1 & \
    PID="$!"; \
    mv ".log.tmp" "${PID}.log"; \
    echo "$PID" > "${PID}.pid"; \
    ln -sf "${PID}.pid" .pid.current; \
    ln -sf "${PID}.log" .log.current; \
    echo "Started gateway (pid ${PID})"

stop:
    @if [ -f .pid.current ]; then \
        PID="$(cat .pid.current)"; \
        if kill -0 "$PID" 2>/dev/null; then \
            kill "$PID"; \
            echo "Stopped gateway (pid ${PID})"; \
        else \
            echo "Gateway pid not running (pid ${PID})"; \
        fi; \
        rm -f "${PID}.pid" "${PID}.log"; \
        rm -f .pid.current .log.current; \
    else \
        echo "No PID file found"; \
    fi

restart:
    @if [ -f .pid.current ]; then \
        PID="$(cat .pid.current)"; \
        if kill -0 "$PID" 2>/dev/null; then \
            kill "$PID"; \
            echo "Stopped gateway (pid ${PID})"; \
        fi; \
        rm -f .pid.current .log.current; \
    fi; \
    nohup openclaw gateway run --verbose > ".log.tmp" 2>&1 & \
    PID="$!"; \
    mv ".log.tmp" "${PID}.log"; \
    echo "$PID" > "${PID}.pid"; \
    ln -sf "${PID}.pid" .pid.current; \
    ln -sf "${PID}.log" .log.current; \
    echo "Started gateway (pid ${PID})"

status:
    @if [ -f .pid.current ]; then \
        PID="$(cat .pid.current)"; \
        if kill -0 "$PID" 2>/dev/null; then \
            echo "Gateway running (pid ${PID})"; \
            echo "Log: ${PID}.log"; \
        else \
            echo "Gateway not running (stale pid ${PID})"; \
        fi; \
    else \
        echo "Gateway not running (no pidfile)"; \
    fi

logs:
    @openclaw logs --follow

config:
    @code ~/.openclaw/openclaw.json

download file:
    @test -n "$YT_BASE_DIR"
    @echo "{{file}}" | grep -Eq '^[A-Za-z0-9_-]+(\.webm)?$'
    @base="{{file}}"; base="${base%.webm}"; \
        mkdir -p "$YT_BASE_DIR/$base/video" "$YT_BASE_DIR/$base/frames"; \
        curl -L "https://bettr-casino-assets.s3.us-west-2.amazonaws.com/yt/$base.webm" -o "$YT_BASE_DIR/$base/video/$base.webm"

extract file timestamp:
    @test -n "$YT_BASE_DIR"
    @echo "{{file}}" | grep -Eq '^[A-Za-z0-9_-]+(\.webm)?$'
    @/workspaces/clawd-slots-assets-pipeline/scripts/extract-frame.sh "{{file}}" "{{timestamp}}"


reset-memory:
    @cp constitution/MEMORY.starter.md constitution/MEMORY.md
    @if [ -f /home/codespace/.openclaw/memory/main.sqlite ]; then \
        mv /home/codespace/.openclaw/memory/main.sqlite /home/codespace/.openclaw/memory/main.sqlite.bak; \
        echo "Moved main.sqlite to main.sqlite.bak"; \
    else \
        echo "No main.sqlite found"; \
    fi
