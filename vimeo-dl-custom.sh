#!/bin/bash
set -eu

# master.json
# eg: URL="https://86vod-adaptive.akamaized.net/exp=1234567890~acl=%2F1234567890-1234-abcd-efgh-1234567890%2F%2A~hmac=1234567890abcdef1234567890abcdef/1234567890abcdef1234567890abcdef/sep/video/12345asdf,12345asdf,34a56sdf,4as6d,3asdf/master.json?base64_init=1"
VIMEO_URL="${VIMEO_URL:-${1:-}}"
echo "[DEBUG] VIMEO_URL=${VIMEO_URL}"
if [ -z "${VIMEO_URL}" ] ; then 
  echo "No VIMEO_URL env was specified (master.json URL)"
  echo "Usage:"
  echo "  docker run -v \"\$(pwd)/downloads:/downloads\" ${DOCKER_IMAGE_NAME:-vimeo-dl} \"https://...../master.json?....\""
  exit 1
fi

# video/audio quality to download
VIDEO_HEIGHT="${VIDEO_HEIGHT:-720}"
AUDIO_SAMPLE_RATE="${AUDIO_SAMPLE_RATE:-48000}"
AUDIO_BITRATE="${AUDIO_BITRATE:-128000}"
USER_AGENT="${USER_AGENT:-Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36 Browser/9.9}"

# Auto detect video_id and audio_id from master.json metadata
resp=$(curl -sL "${VIMEO_URL}")
VIDEO_ID=$(echo "$resp" | jq -r ".video[] | select( .height == ${VIDEO_HEIGHT} ) | .id ")
AUDIO_ID=$(echo "$resp" | jq -r ".audio[] | select( .sample_rate == ${AUDIO_SAMPLE_RATE} ) | select( .bitrate == ${AUDIO_BITRATE} ) | .id")


vimeo-dl \
  --input      "${VIMEO_URL}" \
  --video-id   "${VIDEO_ID}" \
  --audio-id   "${AUDIO_ID}" \
  --user-agent "${USER_AGENT}" \
  --combine

