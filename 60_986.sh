#!/usr/bin/env bash
#>
(
set -u
set +x
set -o pipefail
cd `dirname $0`
#                  1    2     3     4    5    6     7     8    9        10         11		12		13
# leads_channels: sid, dom, chan, mark, uid, sec, check, sz, expire, chan_sec, chan_bdom, would_be_channel, would_be_sec

#day=2015-03-25
day=${1?"Day!"} # yyyy-mm-dd

srcdir=/usr/local/rle/var/share3/TIKETS/986/RESULT/40/$day

zcat $srcdir/leads_channels.gz | 
 awk -F* -v"OFS=*" '$4=="LEAD" { 
    print "lc_sid=>"$1, "lc_dom=>"$2, "lc_channel=>"$3, "lc_uid=>"$5, "lc_sec=>"$6, "lc_sz=>"$8, "lc_expire=>"$9, "lc_jump_sec=>"$10, "lc_from_dom=>"$11, "lc_wb_chan=>"$12,
     "lc_wb_chan_sec=>"$13 
 }' |
 viatmp $srcdir/986.txt




)#>>"$0.log" 2>&1
