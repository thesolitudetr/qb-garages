#!/bin/bash
set -e

# Setup Lua if it doesn't exist
if [ ! -f "lua-5.4.6/src/lua" ]; then
    echo "Downloading and building Lua 5.4.6..."
    curl -s -R -O http://www.lua.org/ftp/lua-5.4.6.tar.gz || curl -s https://www.lua.org/ftp/lua-5.4.6.tar.gz > lua-5.4.6.tar.gz
    tar -zxf lua-5.4.6.tar.gz
    cd lua-5.4.6
    make linux test > /dev/null
    cd ..
fi

echo "Running tests..."
./lua-5.4.6/src/lua tests/client_main_test.lua
