#!/bin/bash

# This script uploads the APK resulting from a CI build to Telegram
version_name=$(cat app/build.gradle | grep "versionCode" | awk '{print $2}' | cut -d '=' -f1)
sha_hash=$(git rev-parse --short HEAD)
cp app/build/outputs/apk/FireKernel-*.apk app/build/outputs/apk/release/FireKernel-"$version_name"_"$sha_hash".apk
apk=app/build/outputs/apk/release/FireKernel-"$version_name"_"$sha_hash".apk

function notify() {
  # Notify via Telegram
  if [ "$1" = "success" ]
  then
  tg_message="[$sha_hash](https://github.com/FireLord1/FireKernel-Updater/commit/$sha_hash) passed"
  else
  tg_message="[$sha_hash](https://github.com/FireLord1/FireKernel-Updater/commit/$sha_hash) failed"
  fi
  curl -F chat_id="$TG_GRP_ID" -F parse_mode="markdown" -F text="$tg_message" "https://api.telegram.org/bot$TG_BOT_ID/sendMessage"
}

function sendfile() {
  curl -F chat_id="$TG_GRP_ID" -F document="@$apk" "https://api.telegram.org/bot$TG_BOT_ID/sendDocument"
}

. buildReleaseApp.sh

if [ -f "$apk" ];
then
notify success
sendfile
exit 0
else
notify failure
exit 1
fi
