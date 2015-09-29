#!/usr/bin/perl

use strict;
use warnings;
use LWP::UserAgent;
my $ua;#dummy user
my $url;
my %headers;#dummy header
my %params;
my %gene;
my %path;
my %map;#key: gene, value: array of path
my %rMap;#key: apth, value: array of gene


my $species=$ARGV[0]?$ARGV[0]:"cel";

createUA();
$url="http://rest.kegg.jp/link/cel/pathway";
my $response_1 = $ua->post($url, \%params, %headers);
my $data=$response_1->content;
my @data=split(/\n/,$data);


foreach(@data){
	$_=~s/CELE_//g;
	#path:cel00010	cel:CELE_C01B4.6
	if($_ =~ /path:(.*)	cel:(.*)/){
		$gene{$2}++;
		$path{$1}++;
		push @{$map{$2}},$1;
		push @{$rMap{$1}},$2;
	}
}

print "Gene\tPATH\tGene_IN_PATH\tGene_Connection\tAve_Path_Connection\n";
foreach my $gene (keys %gene){
	foreach my $path(@{$map{$gene}}){
		print "$gene\t$path\t$path{$path}\t$gene{$gene}";
		my $sum=0;
		foreach my $pathGene(@{$rMap{$path}}){
			$sum+= $gene{$pathGene};
		}
		printf "\t%2.2f\n",$sum/$path{$path};
		
	}


}

sub createUA{
	my ($list)=@_;
	#robot header, I am saying this is a window OS with firefox...
	 %headers = (
	  'User-Agent' => 'Mozilla/5.0 (Windows; U; Windows NT 6.1; pl; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13',
	  'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
	  'Accept-Language'=>'en-US,en;q=0.5',
      'Accept-Encoding'=>'gzip, deflate',
      #'Cookie'=>'JSESSIONID=0707B646BBE94F91547B2F8E1EE9B8CA',
      'Connection'=> 'keep-alive',
	  'Content-Type' => 'application/x-www-form-urlencoded',
	);

	#create the robot, and accept cookies....
	$ua = LWP::UserAgent->new();
}
