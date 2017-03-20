#!/usr/bin/env perl

use strict;

use Text::CSV;
use EV;
use AE;
use AnyEvent::HTTP;
use Scalar::Util qw/weaken/;

$AnyEvent::HTTP::USERAGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36';
$AnyEvent::HTTP::MAX_PER_HOST = 50;

use Data::Dumper;

my $field_ip = 3;
my $field_license = 4;
my $port = 443;
my $sep_char = ',';
my $pool = 2;

my $go_do_program;

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

my @list = ();
while (my $line = <$data>) {
	chomp $line;
	if ($csv->parse($line)) {
		my @fields = $csv->fields();
		my $ip = $fields[($field_ip - 1)];
		my $license = $fields[($field_license - 1)];
		push @list, {ip=>$ip,license=>$license};
	} else {
		warn "Line could not be parsed: $line\n";
	}
}

$go_do_program = sub {
	my ($rcb) = (@_);
	my $go_do_program_next = $go_do_program;
	my $prm = shift @list;
	return $rcb->() unless $prm;
	my $cb = sub {
		return $go_do_program_next->($rcb);
	};
	http_request GET => "https://" . $prm->{ip} . ":" . $port, sub {
		my ($body, $hdr) = @_;
		$do_program->($hdr,$body,$prm->{license}, $cb);
	};
};

my $cv = AE::cv { print("Done.\n"); EV::unloop(); };
$cv->begin();
for (1..$pool) {
	$cv->begin;
	$go_do_program->(sub{
		$cv->end;
	});
	weaken($go_do_program) if $_ == 1;
}
$cv->end;

EV::loop();

1;
