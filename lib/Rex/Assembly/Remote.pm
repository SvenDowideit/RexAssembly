package Rex::Assembly::Remote;

=pod

=head1 NAME

Rex::Assembly::Remote - My author was too lazy to write an abstract

=head1 SYNOPSIS

  my $object = Rex::Assembly::Remote->new(
      foo  => 'bar',
      flag => 1,
  );
  
  $object->dummy;

=head1 DESCRIPTION

The author was too lazy to write a description.

=head1 METHODS

=cut

use 5.010;
use strict;
use warnings;

our $VERSION = '0.01';

use Rex;
use Rex::Config;
use Rex::Group;
use Rex::Batch;
use Rex::Task;
use Rex::Cache;
use Rex::Logger;
use Rex::Output;
use Rex::Commands::Virtualization;

use Rex -base;

#use Rex::Assembly::Remote;

use Data::Dumper;

=pod

=head2 new

  my $object = Rex::Assembly::Remote->new(
      foo => 'bar',
  );

The C<new> constructor lets you create a new B<Rex::Assembly::Remote> object.

So no big surprises there...

Returns a new B<Rex::Assembly::Remote> or dies on error.

=cut

sub new {
	my $class = shift;
	my $self  = bless { @_ }, $class;
	return $self;
}

=pod

=head2 dummy

This method does something... apparently.

=cut

sub dummy {
	my $self = shift;

	# Do something here

	return 1;
}


use Rex::Commands::Sysctl;
use Rex::Commands::Pkg;
use Rex::Commands::SCM;
use Rex::Commands::Rsync;
use Rex::Commands::Upload;

desc "set_hostname --name=";
task "set_hostname", sub {    
    my ($params) = @_;

print "three: $params->{sven}\n";

    run "echo $params->{name} > /etc/hostname ; /etc/init.d/hostname.sh";
    #CAREFUL: don't call run sysctl '' - as sysctl already has a run in it.
    my $newhost = sysctl "kernel.hostname='$params->{name}'";
    #die "failed to set hostname (should be $params->{name}) is $newhost;\n" unless ($params->{name} eq $newhost);

    #get dhclient to tell the dhcp server its name too
    run "echo send host-name \\\"$params->{name}\\\"\\\; >> /etc/dhcp/dhclient.conf ; dhclient";
    
    #throw the ssh key over.
    #shame that upload doesn't do dir's
    run 'mkdir .ssh ; chmod 700 .ssh';
    upload $ENV{HOME}.'/.ssh/id_rsa', '.ssh';
    #force quad to be in ssh known_hosts so that rsync just works    
    Rex::Task->run("_run", $params->{name}, {%$params, run=>'ssh -o StrictHostKeyChecking=no quad'});


};

desc "run --name=";
task "run", sub {    
    my ($params) = @_;

    run $params->{run};
};

desc "install --name=";
task "install", sub {    
    my ($params) = @_;

    install package => $params->{packages};
};

1;

=pod

=head1 SUPPORT

No support is available

=head1 AUTHOR

Copyright 2012 Anonymous.

=cut
