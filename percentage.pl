#!/usr/bin/env perl

use strict;

use Data::Dumper;

my $file = $ARGV[0];
my $dot = "%.2f";

my $data = do { open my $f, '<', $file or die "open $file failed: $!"; local $/; <$f> };

my $data_hash = {};
my $all => { 'number' => 0, 'percent' => 100, 'deal' => 1 };

while ($data =~ m/
	([^\s]+)
	\s+
	([^\s]+)
	/sgx) {
	my ($a,$b) = ($1,$2);
	if ($a =~ /^\d+$/) { $data_hash->{$b}{'number'} = 0+$a; $all->{'number'}+=$a; }
	elsif ($b =~ /^\d+$/) { $data_hash->{$a}{'number'} = 0+$b; $all->{'number'}+=$b;}
	else { print("Cant quantify: $a or $b\n"); }
}

foreach my $param ( keys %$data_hash ) {
	$data_hash->{$param}{'percent'} = sprintf($dot, ( $data_hash->{$param}{'number'}*100/$all->{'number'} ));
}
foreach my $param ( sort { $data_hash->{$a}{'percent'} <=> $data_hash->{$b}{'percent'} } keys %$data_hash ) {
	print("$param\t$data_hash->{$param}{'percent'}%\t$data_hash->{$param}->{number}\n");
}

print("all\t100%\t$all->{number}\n");


1;
