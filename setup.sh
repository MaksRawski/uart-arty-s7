#!/usr/bin/env bash

if ! ls vivadwow; then
   echo "This script should be run while in a directory containing your project, with vivadwow being a subdirectory."
   exit 1
fi
ln -s vivadwow/Makefile Makefile
# ln -s vivadwow/ Makefile
