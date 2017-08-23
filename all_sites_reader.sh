#!/bin/bash

set +o posix;
set -o nounset;
set -o errexit;
set -o pipefail;

f_uids="${1:-}"; # file with uids list for filter

awk -v f_uids=$f_uids 'BEGIN {
if (f_uids != "") {
  while (0 < getline < f_uids) { uids[$1] }
  close(f_uids);
}
FS = OFS = "\t";
}
{
if(NF == 8) { uid=$1""; time=$2; sid=$3; sz=$4; site=$5; url=$6; bsite=$7; burl=$8; out() }
else{
  if(uid == 0) next;
  if(NF == 7) { time = time + $1; sid=$2; sz=$3; site=$4; url=$5; bsite=$6; burl=$7; out() }
  else {
    if(NF == 5) { time = time + $1; sid=$2; sz=$3; if($5=="=")burl=url;else burl=$5; url=$4; if(burl!="-")bsite=site; out() }
    else {
      if(NF == 6) { uid=$1""; time=$2; sid=$3; sz=$4; site="NA"; url=$5; bsite="NA"; burl=$6; out() }
    }
  }
}
}
function out() {
  if(length(uids)>0 && !(uid in uids)) { uid=0 }
  else {
    print uid,time,sid,sz,site,url,bsite,burl;
  }
}
'
