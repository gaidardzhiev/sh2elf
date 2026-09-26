#!/bin/sh
yes | /usr/bin/head -n 3
yes hello world | /usr/bin/head -n 2
yes abc | /usr/bin/head -c 100000 | cksum
yes "" | /usr/bin/head -n 2
