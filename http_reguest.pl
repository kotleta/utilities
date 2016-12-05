#!/usr/bin/env perl

use strict;

use Text::CSV;
use EV;
use AE;
use AnyEvent::HTTP;

use Data::Dumper;

my $field_ip = 3;
my $field_license = 4;
my $port = 443;
my $sep_char = ',';

# your program
my $do_program = sub {
	my $cb = pop;
	my ($hdr,$body,$license) = @_;
	warn $hdr->{Status};
	#warn Dumper($hdr);

	# это оставить, иначе прога не закончится
	$cb->();
};

my $file = $ARGV[0] or die "Need to get CSV file on the command line\n";
my $csv  = Text::CSV->new({ sep_char => $sep_char });

open(my $data, '<', $file) or die "Could not open '$file' $!\n";

my $cv = AE::cv { print("Done.\n"); EV::unloop(); };
$cv->begin();

while (my $line = <$data>) {
	chomp $line;
	if ($csv->parse($line)) {
		my @fields = $csv->fields();
		my $ip = $fields[($field_ip - 1)];
		my $license = $fields[($field_license - 1)];
		$cv->begin();
		http_request GET => "https://" . $ip . ":" . $port, sub {
			my ($body, $hdr) = @_;
			$do_program->($hdr,$body,$license, sub{$cv->end();});
		};
	} else {
		warn "Line could not be parsed: $line\n";
	}
}
$cv->end();

EV::loop();

1;
