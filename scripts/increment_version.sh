#!/bin/bash

# Increment a version string using Semantic Versioning (SemVer) terminology.

# Parse command line options.

while getopts ":Mmpb" Option
do
  case $Option in
    M ) major=true;;
    m ) minor=true;;
    p ) patch=true;;
    b ) build=true;;
  esac
done

shift $(($OPTIND - 1))

version=$1

# Build array from version string.

a=( ${version//./ } )

# If version string is missing or has the wrong number of members, show usage message.

if [ ${#a[@]} -ne 4 ]
then
  echo "usage: $(basename $0) [-Mmpb] major.minor.patch.build"
  exit 1
fi

# Increment version numbers as requested.

if [ ! -z $major ]
then
  ((a[0]++))
  a[1]=0
  a[2]=0
  a[3]=0
fi

if [ ! -z $minor ]
then
  ((a[1]++))
  a[2]=0
  a[3]=0
fi

if [ ! -z $patch ]
then
  ((a[2]++))
  a[3]=0
fi

if [ ! -z $build ]
then
  ((a[3]++))
fi

echo "${a[0]}.${a[1]}.${a[2]}.${a[3]}"
