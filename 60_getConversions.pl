#!/usr/bin/perl -w

# запускать с dm5 или где установлен модуль.

use strict;

use Adriver::LeadCalc::Client;
use DateTime;
use Data::Dumper;

my $start=shift;
my $stop=shift;
my $client = Adriver::LeadCalc::Client->new( base_uri => 'http://api.leadcalc.adriver.x' );
#my $stop = DateTime->now->subtract( days => 1 )->truncate( to => 'day' );
#my $start = $stop->clone->subtract( days => 1 );

if ($start=~/(\d{4})-(\d{2})-(\d{2})/){
	$start = DateTime->new(
	      year      => $1,
	      month     => $2,
	      day       => $3,
		time_zone => 'Europe/Moscow'
	  );
}
else {
	die "wrong start date\n";
}
if ($stop=~/(\d{4})-(\d{2})-(\d{2})/){
	$stop = DateTime->new(
	      year      => $1,
	      month     => $2,
	      day       => $3,
		time_zone => 'Europe/Moscow'
	  );
}
else {
	die "wrong stop date\n";
}
#=cut
#my $usergroups = [ 1 .. 16 ];
my $usergroups = [ shift ];
#print Dumper($usergroups);
my $conversions_iterator = $client->conversions->get( $start, $stop, $usergroups );
#warn Dumper( $conversions_iterator->value ) 
$\="\n";
while ($conversions_iterator->isnt_exhausted){
#	warn Dumper( $conversions_iterator->value );
	my $c = $conversions_iterator->value;
	my $target_id=$c->{'target_id'};
	my $sid = $c->{'reason'}->{'site'};
	my $second = $c->{'reason'}->{'second'};
	my $click = $c->{'attribution'}->[0]->{'weights'}->[0]->{'click'};
	my $jump = $c->{'attribution'}->[0]->{'weights'}->[0]->{'jump'};
	my $expid = $click->{'exp'};
	my $uid = $click->{'user'};
	my $clickSite = $click->{'site'};
	my $ad = $click->{'ad'};
	my $s2 = $click->{'second'};
	my $s3 = $jump->{'second'};
	my $cp_id = $c->{'attribution'}->[0]->{control_point_id};

	print join "*", "li_uid=>$uid","li_sec=>$second","li_sid=>$sid","li_jump_sec=>$s3","li_click_site=>$clickSite","li_cp_id=>$cp_id",$cp_id;
}	
