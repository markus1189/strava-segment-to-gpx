set -e

# For access token, go to https://www.strava.com/settings/api
AUTH_TOKEN="${1:?USAGE: segment-to-gpx.sh TOKEN SEGMENT_ID  Get token at https://www.strava.com/settings/api}"
export SEGMENT_ID="${2:?no-segment-given}"

TARGET_FILE="${SEGMENT_ID}.gpx"
RESULT="$(curl --fail -s -H "Authorization: Bearer ${AUTH_TOKEN}" "https://www.strava.com/api/v3/segments/${SEGMENT_ID}")"

POLYLINE="$(echo "${RESULT}" | jq -r '.map.polyline')"

GPX_NAME="$(echo "${RESULT}" | jq -r .name)"
export GPX_NAME

FASTEST_TIME="$(echo "${RESULT}" | jq -r .xoms.kom)"
export FASTEST_TIME

ACTIVITY_TYPE="$(echo "${RESULT}" | jq -r .activity_type)"
export ACTIVITY_TYPE


echo Downloading segment "$SEGMENT_ID" to "$TARGET_FILE"

curl --fail \
     -s 'http://polylinetogpx.herokuapp.com/' \
     -H 'Content-Type: application/x-www-form-urlencoded' \
     --data-raw "polyline=$POLYLINE&button=Convert" |
    pup '.gpx pre text{}' |
    pandoc -f html -t plain |
    xq -x '.gpx.trk.trkseg.trkpt = .gpx.wpt | .gpx.trk.name = env.GPX_NAME | .gpx.trk.desc = "Type: \(env.ACTIVITY_TYPE)\nFastest Time: \(env.FASTEST_TIME)\nLink: https://www.strava.com/segments/\(env.SEGMENT_ID)" | del(.gpx.wpt)' |
       tee "${TARGET_FILE}" > /dev/null

echo "Saved to ${TARGET_FILE}" >&2
