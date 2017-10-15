#!/bin/sh

git submodule init
git submodule update

cd jemalloc; \
sh autogen.sh --with-jemalloc-prefix=je_; \
make dist; \
make; \
make install; \
cd ..
