#!/bin/sh

# Current as working as of 2012/4/17
# Xcode 4.3.2

PROJECT_ROOT="$HOME/Development/THPopQuiz"

WORKSPACE="$PROJECT_ROOT/THPopQuiz.xcodeproj/project.xcworkspace"
CONFIG="AdHoc"
SCHEME="THPopQuiz"
SDK="iphoneos"
TARGET="THPopQuiz"
BUILDDIR="$HOME/build$TARGET"
OUTPUTDIR="$BUILDDIR/AdHoc-iphoneos"
APPNAME="TH PopQuiz"
DEVELOPER_NAME="Ryne Cheow (CLAS2G6QPJ)"
PROVISIONING_PROFILE="$PROJECT_ROOT/THPopQuizAdHoc.mobileprovision"

echo $BUILDDIR

cd $PROJECT_ROOT

echo "********************"
echo "*     Cleaning     *"
echo "********************"
xcodebuild -alltargets clean

 echo "********************"
 echo "*     Archiving     *"
 echo "********************"
 xcodebuild -workspace $WORKSPACE -scheme $SCHEME archive

echo "********************"
echo "*     Building     *" 
echo "********************"
xcodebuild -sdk "$SDK" -target $TARGET -configuration "$CONFIG" OBJROOT=$BUILDDIR SYMROOT=$BUILDDIR

echo "********************"
echo "*     Signing      *"
echo "********************"
xcrun -log -sdk iphoneos PackageApplication -v "$OUTPUTDIR/$APPNAME.app" -o "$OUTPUTDIR/$APPNAME.ipa" -sign "$DEVELOPER_NAME" -embed "$PROVISIONING_PROFILE"

API_TOKEN="c1a29f46-4c93-4e9a-8b89-0ec297bf1622"
TEAM_TOKEN="7300480fc38c08d298408dfcc731e089_MTI3NTA0MjAxMi0wOS0wMSAwNjoxNjo0NS44NjM3ODk"
RELEASE_NOTES="TBD"

# remove the old zipped dSYM
rm -rf "$OUTPUTDIR/$APPNAME.app.dSYM.zip"
# zip up the new dSYM, we must cd to where the dSYM is or the zip command will zip up tons of intermediate dirs
cd $OUTPUTDIR
zip -r -9 "$OUTPUTDIR/$APPNAME.app.dSYM.zip" "$APPNAME.app.dSYM"

curl http://testflightapp.com/api/builds.json \
  -F file="@$OUTPUTDIR/$APPNAME.ipa" \
  -F dsym="@$OUTPUTDIR/$APPNAME.app.dSYM.zip" \
  -F api_token="$API_TOKEN" \
  -F team_token="$TEAM_TOKEN" \
  -F notes="$RELEASE_NOTES" -v

echo "********************"
echo "*    Cleaning up   *"
echo "********************"
echo $BUILDDIR
rm -Rf "$BUILDDIR"
