rm -rf build
mkdir build

xcodebuild archive -project Musicord.xcodeproj -scheme Musicord -archivePath build/Output -configuration Release

cd build/Output.xcarchive/Products/Applications

create-dmg \
  --volname "Musicord" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --icon "Musicord.app" 200 190 \
  --hide-extension "Musicord.app" \
  --app-drop-link 600 185 \
  "Musicord.dmg" \
  "."

mv Musicord.dmg ../../../

cd ../../../
rm -rf Output.xcarchive

echo "Done"
