#!/bin/bash
rm /tmp/core
ulimit -c unlimited
ulimit -s 81920
sysctl -w kernel.core_pattern=/tmp/core
