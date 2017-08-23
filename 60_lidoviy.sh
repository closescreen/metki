#!/usr/bin/env bash
#>
(
set -u
#set -x
set -o pipefail
cd `dirname $0`

day=${1?"Day!"} # yyyy-mm-dd
day2=`hours -d=$day -shift=1day -n=1 -days`

resdir=/usr/local/rle/var/share3/TIKETS/986/RESULT/40/$day
resbase=lidoviy.txt
resfile=$resdir/$resbase

old=`find "$resdir" -name "$resbase*"`
[[ -n "$old" ]] && rm $old

for proc in `seq 1 8`; do
    (
    for part in `seq 1 32`; do 
	ug=$(( 32*($proc-1)+$part ))
	echo -n " $ug ">&2; 
	./60_getConversions.pl "$day" "$day2" $ug | 
	addf -df=<(
	    cat /usr/local/rle/var/share3/DATA/dicts/leads_control_points.txt | 
	    awk -F'\t' -v"OFS=*" '{ print $14, 
		"cp_dom=>"$3, "cp_sz=>"$2, "cp_price_type=>"$4, "cp_expire=>"$5, "cp_site_paid=>"$10, "cp_start=>"$11, "cp_stop=>"$12, 
		"cp_title=>"$13, "cp_id=>"$14, "cp_mediaplan=>"$15 }'
	) -k=7 -repl -dadd=2,3,4,5,6,7,8,9,10 -false="cp_dom=>*cp_sz=>*cp_price_type=>*cp_expire=>*cp_site_paid=>*cp_start=>*cp_stop=>*cp_title=>*cp_id=>*cp_mediaplan=>" >> $resfile.$proc 
    done
    ) &
done

echo "wait">&2
wait
echo "OK">&2
files=`find "$resdir" -name "$resbase.*" | wc -l`
cat $resfile.* > $resfile
rm $resfile.*


)#>>"$0.log" 2>&1


# control_points:
#   1      2    3      4      5         6         7        8        9         10        11        12      13   14     15
#  sId   szId  url priceType Expire leadPagesNum status statType billingType sitePaid startDate stopDate title id mediaplanId