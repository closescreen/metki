#!/usr/bin/env bash
#> Антон просил отчет ДЕНЬ и три колонки ad_cpamarketing criteo soloway из 50_rep_04_concurrents_leads.gz за период с 2014.11.01 по 2015.01.28 
# разовый отчет
(
set -u
set -x
set -o pipefail

# выводит отчет в bin (все наоборот)

cd `dirname $0`
#cd ../../../bin

ff=$( hours -d 2014-11-01 -tod=today -days | files ../RESULT/50/%F/50_rep_04_concurrents_leads.gz | only -s  )
( echo "day*ad_cpamarketing*criteo*soloway" ; ( for f in $ff; do day=$(fn2days $f); zcat $f | awk -v"OFS=*" -v"day=$day" '$3~"ad_cpamarketing|criteo|soloway" {print day, $3, $1}'; done ) | lae -lb="day chan leads" 'my @n=qw(ad_cpamarketing criteo soloway); g{ my %v; map { $v{$_->{chan}}=$_->{leads} } rec(); print $K,@v{@n} } -key=>"day"' ) | viatmp concurent_by_days.txt

)#>>"$0.log" 2>&1
