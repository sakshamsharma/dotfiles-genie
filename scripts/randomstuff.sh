#! /bin/bash

cat /dev/urandom | hexdump -C | grep "ca fe"
