#!/bin/sh -ex
base_dir=$(pwd)
for gem in kybus-*; do
  cd $base_dir/$gem;
  bundle update
  bundle exec rake test
done;

cd $base_dir;
