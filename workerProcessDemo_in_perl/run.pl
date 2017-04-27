#!/usr/bin/perl

use strict;
use warnings;
use lib './';
use MLDBM qw(DB_File);
use Fcntl;
use AnyEvent;
use AnyEvent::Fork;
use AnyEvent::Fork::Pool;


#generate a hash of arrays
my %matrix;
tie (%matrix,"MLDBM","matrix.db",O_CREAT|O_RDWR, 0640) or die "$!\n";
for(my $i=1;$i<=100;$i++){
	my @array;
	for(my $j=1;$j<=100;$j++){
		push @array,$j+$i;
	}
	#note you'd have to use array reference here for usying hash of arraies with matrix.db
	$matrix{$i}=\@array;
}

#define some heavy jobs for query
my @start=(1..50);


#calculate with fork
my %result;
my $done=AE::cv;
my $pool=AnyEvent::Fork
         		->new()
		 		->require("CompFuns")
		 		->AnyEvent::Fork::Pool::run(
		  		"CompFuns::cals_mean",
		   		max => 4,
		   		idle=>1,
		   		async=>1,
		   		load=>2,
		   		on_destroy => $done,
			);

foreach my $start(@start){

		# sending $done, $start and $start+50 to process
		# sub function receives the returned value as a list/array
		# I added them into %result 
		$pool->($done,$start,$start+50,sub{
			foreach(@_){
				$result{"$start\-$_"}=$_;
			}
		});
}

#wait for all process
undef $pool;
$done->recv;

#print result
foreach my $key(keys %result){
	print "$key\t$result{$key}\n";
}
