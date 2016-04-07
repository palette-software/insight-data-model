#!/usr/bin/env bash
# Extract the $MAJOR part from strings: $PATH/$MAJOR.$MINOR.$PATCH
function getMajor {
    local version=$1
    local major=${version%%.*}
    echo $major
    return 0
}

# Extract the $MINOR part from strings: $PATH/$MAJOR.$MINOR.$PATCH
function getMinor {
    local version=$1
    version=${version#*.}
    local minor=${version%%.*}
    echo $minor
    return 0
}

# Extract the $PATCH part from strings: $PATH/$MAJOR.$MINOR.$PATCH
function getPatch {
    local version=$1
    version=${version#*.}
    version=${version#*.}
    local patch=${version%%.*}
    echo $patch
    return 0
}

function getMaxVersion() {
    local maxVersion=v0.0.0
    local path=$1
    local fileList=$path"/*"
    for fileName in $fileList
    do
        local fileName=${fileName#$path/}
        local versionString=${fileName#*v}
        local major=$(getMajor $versionString)
        local minor=$(getMinor $versionString)
        local patch=$(getPatch $versionString)
        local maxMajor=$(getMajor $maxVersion)
        local maxMinor=$(getMinor $maxVersion)
        local maxPatch=$(getPatch $maxVersion)
        if (( major > maxMajor )) || ( (( major == maxMajor )) && (( minor > maxMinor )) ) || ( (( major == maxMajor )) && (( minor == maxMinor )) && (( patch > maxPatch )) )
        then
           maxVersion=$versionString
        fi
    done
    echo "v$maxVersion"
}

echo $(getMaxVersion "migrations")

