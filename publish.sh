#!/bin/sh
base_dir=$(pwd)
for gem in ant-*; do
  cd $base_dir/$gem;
  rm *.gem;
  gem build $gem.gemspec;
  gem push *.gem;
done;

cd $base_dir;
