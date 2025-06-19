# ANDROIDIDE-NDK-FOR-ARMEABI-V7A


# MANUAL GUIDE + HACK +INSTALL NDK IN ANDROIDIDE FOR armeabi-v7a(32 bit) Android 10+

NOTES:
*DWYR
*BACKUP FIRST!!

EXAMPLE:

to backup;

```
tar -zcvf /storage/emulated/0/ANDROIDIDE.tar.gz -C /data/data/com.itsaky.androidide/files ./home ./usr
```

to restore;
```
tar -zxvf /storage/emulated/0/ANDROIDIDE.tar.gz -C /data/data/com.itsaky.androidide/files --recursive-unlink --preserve-permissions
```

Before starting, create a folder in internal storage named dd (storage/emulated/0/dd to place the script and ndk)

download my script and put ndk29-patch-final.sh scripts in the dd folder

download ndk for armeabi-v7a from the link below and rename it to ndk29.tar.xz and put it in the dd folder

link ndk:

```
[Ndk armeabi-v7a](https://github.com/HomuHomu833/android-ndk-custom/releases/download/r29-beta2/android-ndk-r29-beta2-arm-linux-musleabihf.tar.xz)
```


Open terminal in androidide (if you open project close it before)
typing:

comand:
```
cd
```

comand:
```
bash /storage/emulated/0/dd/ndk29-patch-final.sh
```

wait until finish

comand:
```
nano .bashrc
```

copy this code:

# start code

```
export ANDROID_HOME="/data/user/0/com.itsaky.androidide/files/home/android-sdk"
export ANDROID_NDK_HOME="/data/user/0/com.itsaky.androidide/files/home/android-sdk/ndk/29.0.13599879"

# local bin
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# SDK and NDK tools
export PATH="$PATH:$ANDROID_HOME/build-tools"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-arm/bin"
export PATH="$PATH:$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin"
export PATH="$PATH:$ANDROID_NDK_HOME/prebuilt/linux-arm/bin"

```
# end code

ctrl x ,y ,enter to save


exit

close your androidide


add this in your build.gradle;

EXAMPLE:

```
plugins {
    id 'com.android.application'
}

android {
    compileSdk 33
    
    defaultConfig {
        applicationId "com.myapplication"
        minSdk 23
        targetSdk 33
        versionCode 1
        versionName "1.0"
    }
    
    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    externalNativeBuild {
        ndkVersion = "29.0.13599879"
        //if use cmake
        cmake {
            version = "3.28.0"
            path = file("src/main/cpp/CMakeLists.txt")
       }
        
        //if use ndk
        //ndkBuild {
            //path = file("src/main/cpp/Android.mk") 
       //}
       
    }
    
    
}

dependencies {
   ...
}
```


Thanks to:
- [x] [HomuHomu833](https://github.com/HomuHomu833/android-ndk-custom) for ndk
