#!/usr/bin/env perl

=head1 NAME 
    
    LeadDetectorQuelle.pm

=cut

=head1 SYNOPSIS

    like a LeadDetectorDefault.pm
    
=cut    

package LeadDetectorQuelle;

use strict;
use warnings;
use Data::Dumper;

=head2 quelle

    ! для quelle при обнаружении ORDER|CONFIRM задан жестко expire=30 (пофиксить ?)
    Для quelle обнаруживаемые лиды делятся на ORDER - мы считаем что был лид и CONFIRM - quelle подтвердила лид.
    ORDER: кука пришла из /home/basket в /home/checkout и следующие >=5 раз посетила /home/checkout
    CONFIRM: Quelle делает подтверждение на 8 sz
    
=cut

    
my $expire = 30;
 
sub detect {
 my $recs = $_[0] or die "recs!";
# warn "Quelle detect";
 #return [ {record=>{ sid=>123, sz=>22, uid=>345345 }, info=>{ expire=>30, mark=>"ORDER" }}] 
 my @rv;
 my ($orderbegin,$checkout);

 for my $r ( @$recs ){
    # sid uid timestamp sz dom path bdom bpath
#    warn "record:".Dumper($r);
    if ( $r->{path}=~m|/home/checkout| and $r->{bpath}=~m|/home/basket| ){
	$orderbegin=1;
	$checkout=1;
    }else{
	if ( $orderbegin ){
	    if ( $r->{path}=~m|/home/checkout| ){
		$checkout++;
		if ( $checkout>=5 ){
		    push @rv, { record=>$r, info=>{ mark=>"ORDER", expire=>$expire } };
		    ($orderbegin,$checkout)=(0,0);
		}
	    }
	}
    }
 
    #> Quelle делает подтверждение на 8 sz:
    if ( $r->{sz} == 8 ){
	push @rv, { record=>$r, info=>{ mark=>"CONFIRM", expire=>$expire } };
    }
 
 }

 return \@rv;
}


1;



