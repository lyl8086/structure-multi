#!/usr/bin/env perl
#@Author:Yulong Li
#@Parallel script for STRUCTURE.
use strict;
use warnings;
use Parallel::ForkManager;
use Getopt::Long;
#
#Command line options:

#-m mainparams
#-e extraparams
#-s stratparams
#-K MAXPOPS 
#-L NUMLOCI
#-N NUMINDS
#-i input file
#-o output file
#-D SEED


my($mpar,$epar,$spar,$K,$L,$N,$i,$o,$R,$help);
my $out_path    = '.';
my $num_threads = 1;
GetOptions(
    "mpar=s" => \$mpar,
    "epar=s" => \$epar,
    "spar=s" => \$spar,
    "K=i"    => \$K,
    "L=i"    => \$L,
    "N=i"    => \$N,
    "i=s"    => \$i,
    "o=s"    => \$out_path,
    "R=i"    => \$R,
    "h:1"    => \$help,
    "threads=i" => \$num_threads) or die $!;

die "
    -m mainparams
    -e extraparams
    -s stratparams
    -K MAXPOPS 
    -L NUMLOCI
    -N NUMINDS
    -i input file
    -o output path
    -R Reps
    -t threads
" unless ($mpar&&$epar&&$K&&$L&&$N&&$i&&!$help);
$spar = $spar ? "-s $spar" : '';
$R    = $R ? $R : 10;
my $thread_m = new Parallel::ForkManager($num_threads);
my $j = 0;

foreach my $k (1..$K){
    foreach (1..$R) {
    $j++;
    my $rand= int(rand(10000));
    my $o   = $i . "_run_${j}";
    $thread_m->start and next;
    my $cmd ="-m $mpar -e $epar $spar -K $k -L $L -N $N -i $i -D $rand -o $out_path/$o";
    print STDERR "structure $cmd\n";
    `structure $cmd`;
    $thread_m->finish;
    }
}

$thread_m->wait_all_children;
