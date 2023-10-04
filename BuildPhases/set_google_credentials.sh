# This script will insert the reverse client id as URL Scheme in the Info.plist

CLIENT_ID=$(/usr/libexec/PlistBuddy -c "Print CLIENT_ID" "$SRCROOT"/Aspire\ Budgeting/Resources/credentials.plist)
REVERSED_CLIENT_ID=$(/usr/libexec/PlistBuddy -c "Print REVERSED_CLIENT_ID" "$SRCROOT"/Aspire\ Budgeting/Resources/credentials.plist)

INFO_PLIST=$SRCROOT/Aspire\ Budgeting/Info.plist
echo $CLIENT_ID
echo $REVERSED_CLIENT_ID
echo $INFO_PLIST

if [[ $REVERSED_CLIENT_ID == *"com.google"* ]]; then

  if grep -q $REVERSED_CLIENT_ID "$INFO_PLIST"; then
    echo "REVERSE_CLIENT_ID exists in Info.plist"
    exit 0;
  fi

  echo "Inserting Credentials into Info.plist"
  /usr/libexec/PlistBuddy -c "Add :GIDClientID string ${CLIENT_ID}" "$INFO_PLIST"
  /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes array" "$INFO_PLIST"
  /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0 dict" "$INFO_PLIST"
  /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes array" "$INFO_PLIST"
  /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes: string ${REVERSED_CLIENT_ID}" "$INFO_PLIST"
  echo "Credentials inserted."
  exit 0
fi

echo "error: Failed to add credentials to Info.plist"
exit 1

