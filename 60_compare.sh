#!/usr/bin/env bash
set -u
set +x
set -o pipefail
cd `dirname $0`

day=${1?" Day! "} # yyyy-mm-dd
sid=${2?" sid! "} # sid
sz=${3?" sz! "} # sz
recalc=${4:-""} # force recalc (any string or number f.e. "Y")

[[ ! -s /usr/local/rle/var/share3/TIKETS/986/RESULT/40/$day/lidoviy.txt || -n "$recalc" ]] && ./60_lidoviy.sh "$day" # данные по лидам из лидового
[[ ! -s /usr/local/rle/var/share3/TIKETS/986/RESULT/40/$day/986.txt || -n "$recalc" ]] && ./60_986.sh "$day" # данные по лидам из 986

[[ ! -s /usr/local/rle/var/share3/TIKETS/986/RESULT/40/$day/lidoviy-986.txt ]] && \
perl -Mstrict -MData::Dumper -M'Date::Calc qw(Time_to_Date)' -e'
 my ($file_986,$file_lid)=@ARGV;
 my %join;

# lidoviy:
# li_uid, li_sec, li_sid, li_jump_sec, li_click_site, li_cp_id, cp_dom, cp_sz, cp_price_type, cp_expire, cp_site_paid, cp_start, cp_stop, cp_title, cp_id, cp_mediaplan

 open FILE, $file_lid or die "$file_lid: $!";
 while(<FILE>){
    chomp;
    my %fi = map {split /\=\>/,$_,-1} split /\*/;
    next if $fi{ cp_sz } eq "NULL" or !$fi{ cp_sz };
    my $k = join "*", @fi{ qw( li_sid cp_sz li_uid li_sec ) };
    $fi{li_jump_day} = sprintf"%d-%02d-%02d",Time_to_Date($fi{li_jump_sec});
    $fi{li_jump_expire} = ($fi{li_sec} - $fi{li_jump_sec})/86400;
    for (keys %fi){
	$join{$k}{$_} = $fi{$_};
    }
    $join{$k}{have}.="li";
 }

# 986:
# lc_sid, lc_dom, lc_channel, lc_uid, lc_sec, lc_sz, lc_expire, lc_jump_sec, lc_from_dom, lc_wb_chan, lc_wb_chan_sec
 
 open FILE, $file_986 or die "$file_986: $!";
 while(<FILE>){
    chomp;
    my %fi = map {split /\=\>/,$_,-1} split /\*/;
    my $k = join "*", @fi{ qw( lc_sid lc_sz lc_uid lc_sec ) };
    $fi{lc_jump_day} = sprintf"%d-%02d-%02d",Time_to_Date($fi{lc_jump_sec});
    for (keys %fi){
	$join{$k}{$_} = $fi{$_};
    }
    $join{$k}{have}.="986";
 }

 my @print_fi = qw( have cp_expire li_jump_expire li_jump_sec lc_jump_sec li_jump_day lc_jump_day lc_channel lc_wb_chan_sec lc_wb_chan cp_id );

 local $\="\n"; 
 for my $k ( keys %join ){
    my %flds = %{ $join{$k} };
    defined( $flds{$_} ) or $flds{$_}="" for @print_fi;
    print join "*", $k, map { "$_=>$flds{$_}" } @print_fi;
 }
 

' "/usr/local/rle/var/share3/TIKETS/986/RESULT/40/$day/986.txt" "/usr/local/rle/var/share3/TIKETS/986/RESULT/40/$day/lidoviy.txt" |
 sort -t\* -n -k1,1 -k2,2 -k3,3 -k4,4 |
 viatmp /usr/local/rle/var/share3/TIKETS/986/RESULT/40/$day/lidoviy-986.txt

query="./60_select.pl -day "$day" -name lidoviy-986.txt"

echo "Lidoviy without 986: $( $query -where FIELD1="$sid" -where FIELD2="$sz" -where have="li" | wc -l )"
echo "All Lidoviy + matched 986 (all channels): $( $query -where FIELD1="$sid" -where FIELD2="$sz" -wherenot have="986" | wc -l )"
echo "All Lidoviy + matched 986 (soloway): $( $query -where FIELD1="$sid" -where FIELD2="$sz" -wherenot have="986" -where lc_channel=soloway | wc -l )"

echo "Not soloway by cause:
'cp_expired' 		- lidoviy uses expired jump (but 986 skip it)
'concurrent <chan>' 	- channel ne \"soloway\" ( 986 found concurrent channel <chan> )
'later' 		- 986 found jump later then lidoviy jump
'expired <chan>'	- 986 found expired channel
"

set -v

$query -M="Date::Calc qw(Localtime)" -where FIELD1="$sid" -where FIELD2="$sz" -wherenot have=986 -wherenot lc_channel=soloway -eval='

 push @{$f{cause_a}}, "cp_expired ( >$f{cp_expire} ) jump" if $f{li_jump_expire}>$f{cp_expire}; 
 push @{$f{cause_a}}, "concurrent $f{lc_channel}" if $f{lc_channel} and $f{lc_channel} ne "soloway"; 
 push @{$f{cause_a}}, "later" if $f{lc_jump_sec}>$f{li_jump_sec}; 
 push @{$f{cause_a}}, "expired $f{lc_wb_chan}" if $f{lc_wb_chan};
 
 $f{cause}=join" ", @{$f{cause_a}||[]};
 
 ' -fnout=cause | sort | uniq -c 














