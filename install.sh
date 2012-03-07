#!/bin/bash
rm *.ipk
palm-package --use-v1-format .
palm-install *.ipk
palm-launch com.tehtorq.puzzled

