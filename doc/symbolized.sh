#!/bin/sh

#*** Set command environment for symbolicatecrash start***
export DEVELOPER_DIR='/Applications/Xcode.app/Contents/Developer'

#iPhoneSimulator.platform: 只查找iphone模拟器对应的symbolicatecrash地址
symbolicatecrash_address_value=`find /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform -name symbolicatecrash -type f`

alias symbolicatecrash="$symbolicatecrash_address_value"
#*** Set command environment for symbolicatecrash end***

rm -f crash_log_list.txt

var_crash_logs=crash_logs

ls $var_crash_logs/ > crash_log_list.txt

currentPWD=`pwd`

symbolized_crash_logs_folder="symbolized_crash_logs"

if [ ! -d "$currentPWD"/"$symbolized_crash_logs_folder"/ ];then
    mkdir "$currentPWD"/"$symbolized_crash_logs_folder"
else
    echo ""$symbolized_crash_logs_folder" exists"
fi

MyApp(你的app名字)_ipa_file=$currentPWD/MyApp.ipa（你的app名字）
MyApp(你的app名字)_zip_file=$currentPWD/MyApp.zip（你的app压缩包名）

if [ -f "$MyApp(你的app名字)_ipa_file" ];then
    #MyApp.ipa(你的app名字) exists and rename MyApp.ipa(你的app名字) -> MyApp.zip(你的app名字)
    mv MyApp.ipa(你的app名字) MyApp.zip(你的app名字)
else
    if [ ! -f "$MyApp(你的app名字)_zip_file" ];then
    echo "MyApp.ipa(你的app名字) and MyApp.zip(你的app名字) are both not exist, at least one file must exist!"
    fi
fi

if [ -f "$MyApp(你的app名字)_zip_file" ];then
    #MyApp.zip(你的app名字) exists and Unzip MyApp.zip(你的app名字)
    unzip -o MyApp.zip(你的app名字)
else
    echo "MyApp.zip(你的app名字) not exists!"
fi

while read -r LINE; do

var_file="$currentPWD/$var_crash_logs/$LINE"
file_suffix=$(echo "${var_file##*.}" | tr '[A-Z]' '[a-z]')

if [ "$file_suffix"x = "crash"x ];then
    symbolicatecrash $var_crash_logs/"$LINE" Payload/MyApp.app(你的app名字) > "$symbolized_crash_logs_folder"/"$LINE"
else
   echo ""$LINE" is not .crash file!"
fi
done < crash_log_list.txt

作者：飘金
链接：https://www.jianshu.com/p/e002e358af2e
來源：简书
简书著作权归作者所有，任何形式的转载都请联系作者获得授权并注明出处。