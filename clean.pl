use strict;
use warnings;
use 5.012;

my $file = 'glacier.txt';
open my $fh, '<', $file or die "Could not open '$file' $!\n";
#sample object details:
#{u'LastModified': datetime.datetime(2020, 5, 20, 21, 45, 16, tzinfo=tzutc()), u'ETag': '"84230855207ba19dfd680ea1975e3944"', u'StorageClass': 'GLACIER', u'Key': u'backup-csv/engine_z_lossless.csv', u'Size': 1299}

while (my $line = <$fh>) {
   chomp $line;
   my @strings = $line =~ /u'Key': u'(.*?)'/;
   foreach my $s (@strings) {
     say "'$1'";
   }
}
