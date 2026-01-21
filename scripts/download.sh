#!/bin/sh


print_help()
{
  echo "
  Usage:  bash run.sh -p <TARGET_PLATFORM> -v <VERSION> -d <RELEASE_DATE> [-o <OUTPUT_FILEPATH>]

    Parameters:
      - TARGET_PLATFORM: Target platform for which the setup shall be downloaded. (required: yes)
      - VERSION:        Version of the setup to be downloaded. (required: yes)
      - RELEASE_DATE:    Release date of the setup to be downloaded (required: yes)
      - OUTPUT_FILEPATH: Path where the downloaded setup file shall be stored. (required: no, default=${PWD}/codabix.setup)
  "
}

# Get script root directory
SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# Setting the parameter defaults

OUTPUT_FILEPATH="${PWD}/codabix.setup"


while getopts ":p:v:d:o:h" opt; do
  case $opt in
    p) TARGET_PLATFORM="$OPTARG"
    ;;
    v) VERSION="$OPTARG"
    ;;
    d) RELEASE_DATE="$OPTARG"
    ;;
    o) OUTPUT_FILEPATH="$OPTARG"
    ;;
    h) print_help; exit
    ;;
    \?) echo "
  Invalid option \"-$OPTARG\"">&2; print_help; exit
    ;;
  esac
done

if [ -z "$TARGET_PLATFORM" ]
then
  echo "Required parameter <TARGET_PLATFORM> not set."
  print_help
  exit
fi

if [ -z "$VERSION" ]
then
  echo "Required parameter <VERSION> not set."
  print_help
  exit
fi

if [ -z "$RELEASE_DATE" ]
then
  echo "Required parameter <RELEASE_DATE> not set."
  print_help
  exit
fi

echo "Downloading setup file for target platform: $TARGET_PLATFORM"

PLATFORMID=""

if [ "${TARGET_PLATFORM}" = "linux/amd64" ]
then
    PLATFORMID="linux-x64"
elif [ "${TARGET_PLATFORM}" = "linux/arm/v7" ]
then
    PLATFORMID="linux-arm32"
elif [ "${TARGET_PLATFORM}" = "linux/arm64" ]
then
    PLATFORMID="linux-arm64"
else
    echo "Target platform \"${TARGET_PLATFORM}\" is not supported."
    exit -1
fi

DOWNLOAD_LINK="https://www.codabix.com/downloads/installers/codabix-${VERSION}/codabix-${PLATFORMID}-${RELEASE_DATE}-${VERSION}.setup"
echo "Downloading from following link: $DOWNLOAD_LINK"
curl ${DOWNLOAD_LINK} --fail --output ${OUTPUT_FILEPATH}
