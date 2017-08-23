#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;

my $usage = q{ Usage: };

my ($day, $name, %where, %wherenot, @out, @fnout, @nout, $eval, $use);

GetOptions(
 "day=s" => \$day,
 "name=s" => \$name,
 "where=s%" => \%where,
 "wherenot=s%" => \%wherenot,
 "out=s" => \@out,
 "nout=s" => \@nout,
 "fnout=s" => \@fnout,
 "eval=s" => \$eval,
 "M=s" => \$use,
) or die "Bad opt!";

eval "use $use" if $use;

if ($day or $name){
    $day or die "day!";
    $name or die "name!";
}    
@out = split /\,/, join ',', @out;
@nout = split /\,/, join ',', @nout;

if ($day and $name){
    my $src="/usr/local/rle/var/share3/TIKETS/986/RESULT/40/$day/$name";
    push @ARGV, $src;
}    

# uid=>22004886540*sec=>1427291749*sid=>195513*target=>3E3C1326-B38F-11E4-9FD4-B45B795FDBE3*
#   dom=>wildberries.ru,sz=>NULL,price_type=>CPA2,expire=>30,site_paid=>0,start=>2015-02-13,stop=>NULL,mediaplan=>D922AD82-9546-11E2-8F0C-D7846F87CFFF*
#   jump_sec=>1427291749*from_sid=>79354

my %f;
$\="\n";

LINE: while(<>){
    chomp;
    my $fn = 1;
    %f = map { my($k,$v) = split /\=\>/, $_, -1; ( $k, $v ) = ( "FIELD".($fn++), $k||"" ) if !defined $v; ($k,$v) } split /\*|\,/, $_, -1;
    $f{ALL} = $_;

    if ($eval){
	no warnings;
	eval $eval;
	die $@ if $@;
    }


    exists $f{$_} or die "($name) not exists field $_ Have: ".Dumper(\%f) for @fnout, @out, @nout, keys %where, keys %wherenot;
    for my $wk ( keys %where ){
	next LINE if $where{ $wk } ne $f{ $wk };
    }
    for my $wk ( keys %wherenot ){
	next LINE if $wherenot{ $wk } eq $f{ $wk };
    }


    if (@out or @nout or @fnout){
	print join "*", map( {"$_=>$f{$_}"} @fnout ), @f{ @out }, map {"$_=>$f{$_}"} @nout;
    }else{
	print;
    }	
}




