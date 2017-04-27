package CompFuns;

use Exporter;
use AnyEvent;
use Statistics::Basic qw(:all);
use MLDBM qw(DB_File);
use Fcntl;
use Data::Dumper;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = ();
@EXPORT_OK   = qw(cals_mean);



sub cals_mean{
	# receive the ARGVs from the main function
	my ($done,$sth,$start,$end)=@_;
	#print Dumper $sth;
	my (%matrix,@result);
	tie (%matrix,"MLDBM","matrix.db",O_CREAT|O_RDWR, 0666) or die "$!\n";
	for(1..100){
		for(my $i=$start;$i<=$end;$i++){
			my $mean=mean(@{$matrix{$i}});
			push @result,$mean;
		}
	}
	@result=@result[1..50];
	#return result as a list/array
	$done->(@result);
}

1;
