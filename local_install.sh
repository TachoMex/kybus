#!/bin/sh
base_dir=$(pwd)
for gem in kybus-*; do
  cd $base_dir/$gem;
  rm *.gem;
  gem build $gem.gemspec;
  gem install *.gem -l;
done;

cd $base_dir;
