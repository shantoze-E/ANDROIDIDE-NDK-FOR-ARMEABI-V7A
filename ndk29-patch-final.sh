#!/bin/sh

# created:shantoze
# t.me/shantoze

set -e

echo "================================================"
echo "         INSTALLING REQUIRED PACKAGES           "
echo "================================================"
echo ""

is_pkg_installed() {
    dpkg -s "$1" &> /dev/null
    return $?
}


PACKAGES=("cmake" "ninja")
for pkg in "${PACKAGES[@]}"; do
    if is_pkg_installed "$pkg"; then
        echo "Package '$pkg' is already installed. Skipping."
    else
        echo "Installing package '$pkg'..."
        pkg install "$pkg" -y
        
        if [ "$?" -ne 0 ]; then
            echo "ERROR: Failed to install package '$pkg'. Exiting."
            exit 1
        fi
        echo "Package '$pkg' installed successfully."
    fi
done

echo "All required packages checked/installed successfully."
echo ""


NDK_TAR_XZ_PATH="/storage/emulated/0/dd/ndk29.tar.xz"
NDK_VERSION_NAME="29.0.13599879"


install_dir="$HOME"
sdk_dir="$install_dir/android-sdk"
ndk_base_dir="$sdk_dir/ndk"
ndk_dir="$ndk_base_dir/$NDK_VERSION_NAME"

echo  "================================================"
echo "       NDK OFFLINE Installation Script           "
echo "================================================="
echo ""


if [ ! -f "$NDK_TAR_XZ_PATH" ]; then
   echo "ERROR: NDK file not found in: $NDK_TAR_XZ_PATH"
   echo "Make sure the NDK_TAR_XZ_PATH variable in the script is correct."
   exit 1
fi


if [ ! -d "$ndk_base_dir" ]; then
   echo "Creating NDK base directory: $ndk_base_dir"
   mkdir -p "$ndk_base_dir"
fi


if [ -d "$ndk_dir" ]; then
   echo "NDK $NDK_VERSION_NAME already exists. Removing old one for clean install..."
   rm -rf "$ndk_dir"
fi


echo "Creating NDK target directory: $ndk_dir"
mkdir -p "$ndk_dir"


echo "Extracting NDK from $NDK_TAR_XZ_PATH directly to $ndk_dir..."
echo "waiting..."


tar -vxJf "$NDK_TAR_XZ_PATH" -C "$ndk_dir" --strip-components=1
if [ "$?" -ne 0 ]; then
   echo "ERROR: Failed to extract NDK files. Check file integrity or storage space."
   rm -rf "$ndk_dir"
   exit 1
fi

echo "NDK extraction successful."


echo "Setting execute permissions for NDK toolchains..."
if [ -d "$ndk_dir/toolchains" ]; then
   chmod -R +x "$ndk_dir/toolchains"
   echo "Execute permissions for the 'toolchains' directory have been set."
fi


if [ ! -d "$ndk_dir/toolchains" ]; then
   echo "FATAL ERROR: Target NDK directory '$ndk_dir' seems to be incomplete (toolchains not found)."
   echo "NDK installation failed."
   exit 1
fi

echo ""
echo "=================================================="
echo "         NDK Offline Installation Completed       "
echo "=================================================="
echo "NDK $NDK_VERSION_NAME successfully installed in: $ndk_dir"
echo ""


ANDROID_SDK_HOME="/data/user/0/com.itsaky.androidide/files/home/android-sdk"
CUSTOM_MAKE_PATH="/data/user/0/com.itsaky.androidide/files/home/android-sdk/ndk/29.0.13599879/prebuilt/linux-arm/bin/make"

# --- Don't Change the Code Below ---

NDK_BUILD_TARGET_PATH="${ANDROID_SDK_HOME}/ndk/${NDK_VERSION_NAME}/ndk-build"

echo "================================================"
echo "             NDK PATCHING SCRIPT                "
echo "================================================"
echo ""

echo "Verifying target NDK-build path: ${NDK_BUILD_TARGET_PATH}"


if [ ! -f "$NDK_BUILD_TARGET_PATH" ]; then
   echo "ERROR: The ndk-build file was not found in ${NDK_BUILD_TARGET_PATH}."
   echo "Make sure ANDROID_SDK_HOME and NDK_VERSION are correct."
   exit 1
fi

echo "Target ndk-build file found. Proceeding to create backup..."


cp "$NDK_BUILD_TARGET_PATH" "${NDK_BUILD_TARGET_PATH}.bak.$(date +%Y%m%d%H%M%S)"
if [ "$?" -ne 0 ]; then
   echo "ERROR: Failed to create backup of ndk-build file. Check permissions."
   exit 1
fi
echo "Backup successfully created."

echo "Rewriting ndk-build file contents..."


cat <<EOL > "$NDK_BUILD_TARGET_PATH"
#!/bin/sh
# Custom ndk-build script enhanced for automatic host detection.

# hacked ndk-build
# created:shantoze
# https://t.me/shantoze

PROG_DIR=\$(dirname "\$0")
PROG_NAME=\$(basename "\$0")
NDK_ROOT=\$(cd "\$PROG_DIR" && pwd -P)

unset PYTHONHOME
unset PYTHONPATH

case "\$PROG_DIR" in 
    *\\ *) echo "ERROR: NDK path cannot contain space"
          exit 1
        ;;
esac

if [ -z "\$NDK_LOG" ]; then
  NDK_LOG=0
fi

if [ -z "\$NDK_ANALYZE" ]; then
  NDK_ANALYZE=0
fi

PROJECT_PATH=
PROJECT_PATH_NEXT=
for opt; do
    if [ -z "\$PROJECT_PATH" ] && [ "\$PROJECT_PATH_NEXT" = "yes" ] ; then
        PROJECT_PATH=\$opt
        PROJECT_PATH_NEXT=
    else
        case \$opt in
          NDK_LOG=1|NDK_LOG=true)
            NDK_LOG=1
            ;;
          NDK_LOG=*)
            NDK_LOG=0
            ;;
          NDK_ANALYZE=1|NDK_ANALYZE=true)
            NDK_ANALYZE=1
            ;;
          NDK_ANALYZE=*)
            NDK_ANALYZE=0
            ;;
          -C)
            PROJECT_PATH_NEXT="yes"
            ;;
        esac
    fi
done

if [ "\$NDK_LOG" = "true" ]; then
  NDK_LOG=1
fi

if [ "\$NDK_ANALYZE" = "true" ]; then
  NDK_ANALYZE=1
fi

if [ "\$NDK_LOG" = "1" ]; then
  log () {
    echo "\$@"
  }
else
  log () {
    : # nothing
  }
fi

# Detect host operating system and architecture
. "\$NDK_ROOT/build/tools/ndk_bin_common.sh"
log "HOST_OS=\$HOST_OS"
log "HOST_ARCH=\$HOST_ARCH"
log "HOST_TAG=\$HOST_TAG"




GNUMAKE="$CUSTOM_MAKE_PATH"

case \$(uname -s) in
   Linux)
     case \$(uname -m) in
       armv8l) HOST_TAG="linux-arm" ;;
       armv7l) HOST_TAG="linux-arm" ;;
       armv7) HOST_TAG="linux-arm" ;;
       *) echo "ERROR: Unsupported host architecture, Lol this for armv7 only!! your host is: \$(uname -m)";  exit 1 ;;
     esac
;;
*) echo "ERROR: Host operating system not supported: \$(uname -s)"; exit 1 ;;
esac

# Verify if custom make binary exists.
if [ ! -f "\$GNUMAKE" ]; then
   echo "ERROR: Custom make binary not found in \$GNUMAKE"
   echo "install make first with comand: pkg install make -y"
   exit 1
fi

NDK_ANALYZER_FLAGS=
if [ "\$NDK_ANALYZE" = 1 ]; then
    # Continue supporting the old interface to the static analyzer. clang-tidy
    # does all the same checks by default (and some new ones).
    NDK_ANALYZER_FLAGS=APP_CLANG_TIDY=true
fi

export PATH="\$NDK_ROOT/toolchains/llvm/prebuilt/\$HOST_TAG/bin:\$PATH"
export PATH="\$NDK_ROOT/prebuilt/\$HOST_TAG/bin:\$PATH"

exec "\$GNUMAKE" -O -f "\$NDK_ROOT/build/core/build-local.mk" \$NDK_ANALYZER_FLAGS "\$@"
EOL

if [ "$?" -ne 0 ]; then
   echo "ERROR: Failed to rewrite ndk-build file. Check permissions."
   exit 1
fi
echo "The contents of ndk-build file were successfully updated."


chmod +x "$NDK_BUILD_TARGET_PATH"
if [ "$?" -ne 0 ]; then
   echo "ERROR: Failed to grant execute permission to $NDK_BUILD_TARGET_PATH."
   exit 1
fi

echo "SUCSESS: Success to grant execute permission to $NDK_BUILD_TARGET_PATH."

chmod +x "$CUSTOM_MAKE_PATH"
if [ "$?" -ne 0 ]; then
   echo "ERROR: Failed to grant execute permission to $CUSTOM_MAKE_PATH."
   exit 1
fi

echo "SUCSESS: Success to grant execute permission to $CUSTOM_MAKE_PATH."

echo "Execute permission granted."
echo "The ndk-build script was successfully replaced. You can now try building your project."
echo "Restart your AndroidIDE first before start build..."
echo "=================================================="
echo "      ALL OPERATIONS COMPLETED SUCCESSFULLY!      "
echo "=================================================="
exit 0
