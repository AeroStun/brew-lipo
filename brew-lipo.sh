#!/bin/sh
#    Copyright 2022 AeroStun
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

brew_prefix=$(brew --prefix)

formulae=$1
formulae_prefix=$(brew --prefix $formulae)
native_ark=$(brew fetch $formulae | grep "Homebrew/downloads" | grep 'tar.gz' | awk -F": " '{ print $NF }')
native_tag=$(basename $native_ark | sed -e 's/\(.*\)\.bottle.*/\1/' -e 's/.*\.\(.*\)$/\1/')

version=$(basename $native_ark | sed -e "s/^.*--${formulae}--\(.*\)\.${native_tag}.*$/\1/")

# FIXME support arm hosts

foreign_tag="arm64_${native_tag}"
foreign_ark=$(brew fetch --bottle-tag=$foreign_tag $formulae | grep "Homebrew/downloads" | grep 'tar.gz' | awk -F": " '{ print $NF }')

mkdir -p /tmp/brew-lipo/
cd /tmp/brew-lipo/
tar xf $foreign_ark
cd $formulae/$version
for f in $(find . -name '*.dylib' -or -name '*.a'); do
  tail=$(echo $f | sed 's_^\./__')
  echo $tail
  lipo -create ./$tail $formulae_prefix/$tail -output $formulae_prefix/$tail
  if [ -e $brew_prefix/$tail ]; then
    lipo -create ./$tail $brew_prefix/$tail -output $brew_prefix/$tail
  fi 
done
exit
rm -rdf /tmp/brew-lipo/$formulae
