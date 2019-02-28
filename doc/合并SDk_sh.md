#set -e
#Sets the target folders and the final framework product.
FMK_NAME=${PROJECT_NAME}

#Install dir will be the final output to the framework.
#The following line create it in the root folder of the current project.
INSTALL_DIR=${SRCROOT}/Products/${FMK_NAME}.framework

#Working dir will be deleted after the framework creation.
#WRK_DIR=build
DEVICE_DIR=${BUILD_DIR}/Release-iphoneos/${FMK_NAME}.framework
SIMULATOR_DIR=${BUILD_DIR}/Debug-iphonesimulator/${FMK_NAME}.framework

#-configuration ${CONFIGURATION}
#Clean and Building both architectures.
#分别编译生成真机和模拟器使用的framework
#使用debug是因为Build Active Architecture Only
#为设置为NO的时候，会编译支持的所有的版本
#设置为YES的时候，是为Debug的时候速度更快，它只编译当前的architecture 版本
#不使用workspace时候执行下方两个命令
#xcodebuild -configuration "Release" -target "${FMK_NAME}" -sdk iphoneos clean build
#xcodebuild -configuration "Release" -target "${FMK_NAME}" -sdk iphonesimulator clean build
#使用workspace时候执行下方两个命令
xcodebuild -workspace ${FMK_NAME}.xcworkspace -scheme ${FMK_NAME} -configuration "Release" -sdk iphoneos clean build
xcodebuild -workspace ${FMK_NAME}.xcworkspace -scheme ${FMK_NAME} -configuration "Debug" -sdk iphonesimulator -arch i386 -arch x86_64 clean build

#xcodebuild clean -workspace "ACFaceCheckLib.xcworkspace" -scheme "ACFaceCheckLib" -configuration "Release" -sdk iphonesimulator -arch i386 -arch x86_64
#xcodebuild clean -workspace "ACFaceCheckLib.xcworkspace" -scheme "ACFaceCheckLib" -configuration "Release" -sdk iphoneos

#Cleaning the oldest.
if [ -d "${INSTALL_DIR}" ]
then
rm -rf "${INSTALL_DIR}"
fi

mkdir -p "${INSTALL_DIR}"

cp -R "${DEVICE_DIR}/" "${INSTALL_DIR}/"

#Uses the Lipo Tool to merge both binary files (i386 + armv6/armv7) into one Universal final product.
#使用lipo命令将其合并成一个通用framework
#最后将生成的通用framework放置在工程根目录下新建的Products目录下
lipo -create "${DEVICE_DIR}/${FMK_NAME}" "${SIMULATOR_DIR}/${FMK_NAME}" -output "${INSTALL_DIR}/${FMK_NAME}"

rm -r "${BUILD_DIR}"


