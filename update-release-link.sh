#!/bin/bash

release_version=$1
mac_link_base=$2
mac_link_near=$3
windows_download_link_base=$4
windows_preview_link_base=$5
windows_download_link_near=$6
windows_preview_link_near=$7

if [ -z "${release_version}" ]; then
  echo "Please specify the release version"
  exit 0
fi

if [ -z "${mac_link_base}" ]; then
  echo "Please specify the mac link for base"
  exit 0
fi

if [ -z "${mac_link_near}" ]; then
  echo "Please specify the mac link for near"
  exit 0
fi


if [ -z "${windows_download_link_base}" ]; then
  echo "Please specify the windows link for base"
  exit 0
fi

if [ -z "${windows_preview_link_base}" ]; then
  echo "Please specify the windows preview link for base"
  exit 0
fi

if [ -z "${windows_download_link_near}" ]; then
  echo "Please specify the windows link for near"
  exit 0
fi

if [ -z "${windows_preview_link_near}" ]; then
  echo "Please specify the windows preview link for near"
  exit 0
fi



mac_link_base_escaped=$(printf '%s\n' "$mac_link_base" | sed -e 's/[\/&]/\\&/g')
mac_link_near_escaped=$(printf '%s\n' "$mac_link_near" | sed -e 's/[\/&]/\\&/g')

windows_download_link_base_escaped=$(printf '%s\n' "$windows_download_link_base" | sed -e 's/[\/&]/\\&/g')
windows_preview_link_base_escaped=$(printf '%s\n' "$windows_preview_link_base" | sed -e 's/[\/&]/\\&/g')

windows_download_link_near_escaped=$(printf '%s\n' "$windows_download_link_near" | sed -e 's/[\/&]/\\&/g')
windows_preview_link_near_escaped=$(printf '%s\n' "$windows_preview_link_near" | sed -e 's/[\/&]/\\&/g')



files=(
  "README.md"
  "node-hosting/start-a-node/README.md"
  "node-hosting/start-a-node/start-a-node-windows.md"
  "node-hosting/start-a-node/start-a-node-mac.md"
#  "node-hosting/start-a-node/start-a-node-linux.md"
)

for file in "${files[@]}"
do
	echo "processing file: $file"

	cp "templates/$file" "gitbook/$file"

	# replace file links
	sed -i "s/RELEASE_VERSION/$release_version/g" "gitbook/$file"
  sed -i "s/MAC_LINK_BASE/$mac_link_base_escaped/g" "gitbook/$file"
  sed -i "s/MAC_LINK_NEAR/$mac_link_near_escaped/g" "gitbook/$file"
	sed -i "s/WINDOWS_DOWNLOAD_LINK_BASE/$windows_download_link_base_escaped/g" "gitbook/$file"
	sed -i "s/WINDOWS_PREVIEW_LINK_BASE/$windows_preview_link_base_escaped/g" "gitbook/$file"
	sed -i "s/WINDOWS_DOWNLOAD_LINK_NEAR/$windows_download_link_near_escaped/g" "gitbook/$file"
	sed -i "s/WINDOWS_PREVIEW_LINK_NEAR/$windows_preview_link_near_escaped/g" "gitbook/$file"
	# sed -i "s/LINUX_DOWNLOAD_LINK/$linux_download_link_escaped/g" "gitbook/$file"
	# sed -i "s/LINUX_PREVIEW_LINK/$linux_preview_link_escaped/g" "gitbook/$file"
done
