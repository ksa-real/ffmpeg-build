set -x
apk add --no-cache bash cmake make g++ curl git bash yasm pkgconfig
export OS=alpine
bash build-linux.sh
