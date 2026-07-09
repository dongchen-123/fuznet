#!/usr/bin/env bash
# makes Quartus .vo readable by yosys
# removes translate_on / off to make lut_mask readable
# replaces unreadable tri by supply (check correctness later)
sed -e '/synopsys translate_off/d' \
    -e '/synopsys translate_on/d' \
    -e 's/\btri0\b/supply0/g' \
    -e 's/\btri1\b/supply1/g'\
    "$1" > "$2"