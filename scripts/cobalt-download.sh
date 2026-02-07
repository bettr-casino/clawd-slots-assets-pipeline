#!/usr/bin/env bash
# cobalt-download.sh — Download a YouTube video via cobalt.tools API
# Usage: bash scripts/cobalt-download.sh "<YouTube URL>" "<output.mp4>"
#
# Primary video downloader for the Clawd Slots pipeline.
# cobalt.tools is free and requires no authentication.

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

COBALT_API="https://api.cobalt.tools/"

if [[ $# -lt 1 ]]; then
    echo -e "${RED}Usage: $0 <YouTube URL> [output filename]${NC}"
    exit 1
fi

VIDEO_URL="$1"
OUTPUT="${2:-video.mp4}"

# Ensure dependencies
for cmd in curl jq; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${RED}Error: $cmd is required but not installed${NC}"
        exit 1
    fi
done

echo -e "${BLUE}Requesting download URL from cobalt.tools...${NC}"
echo -e "${BLUE}Video: $VIDEO_URL${NC}"

RESPONSE=$(curl -s -X POST "$COBALT_API" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d "{\"url\":\"$VIDEO_URL\"}")

# Check for error in response
if echo "$RESPONSE" | jq -e '.error' &> /dev/null; then
    ERROR_MSG=$(echo "$RESPONSE" | jq -r '.error // .text // "Unknown error"')
    echo -e "${RED}cobalt.tools error: $ERROR_MSG${NC}"
    echo -e "${YELLOW}Full response: $RESPONSE${NC}"
    exit 1
fi

# Extract download URL — cobalt returns different response shapes
DOWNLOAD_URL=""
STATUS=$(echo "$RESPONSE" | jq -r '.status // empty')

if [[ "$STATUS" == "redirect" || "$STATUS" == "stream" ]]; then
    DOWNLOAD_URL=$(echo "$RESPONSE" | jq -r '.url // empty')
elif [[ "$STATUS" == "tunnel" ]]; then
    DOWNLOAD_URL=$(echo "$RESPONSE" | jq -r '.url // empty')
elif [[ "$STATUS" == "picker" ]]; then
    # Multiple formats available — pick the first video
    DOWNLOAD_URL=$(echo "$RESPONSE" | jq -r '.picker[0].url // empty')
fi

# Fallback: try .url directly
if [[ -z "$DOWNLOAD_URL" ]]; then
    DOWNLOAD_URL=$(echo "$RESPONSE" | jq -r '.url // empty')
fi

if [[ -z "$DOWNLOAD_URL" || "$DOWNLOAD_URL" == "null" ]]; then
    echo -e "${RED}Failed to extract download URL from cobalt response${NC}"
    echo -e "${YELLOW}Response: $RESPONSE${NC}"
    exit 1
fi

echo -e "${BLUE}Downloading to $OUTPUT...${NC}"
if curl -L -o "$OUTPUT" "$DOWNLOAD_URL"; then
    FILE_SIZE=$(stat --printf="%s" "$OUTPUT" 2>/dev/null || stat -f%z "$OUTPUT" 2>/dev/null || echo "unknown")
    echo -e "${GREEN}Download complete: $OUTPUT ($FILE_SIZE bytes)${NC}"
else
    echo -e "${RED}Download failed${NC}"
    exit 1
fi
