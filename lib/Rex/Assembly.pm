package Rex::Assembly;

=pod

=head1 NAME

Rex::Assembly - Assemble virtual machines for deployment

=head1 SYNOPSIS

Its unlikely that you will access this module directly?

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

unshift(@INC, '~/.rex');
use RexConfig;


use Rex::Assembly::Remote;

use Data::Dumper;

use Net::VNC;

=pod

=head2 new

  my $object = Rex::Assembly->new(
      foo => 'bar',
  );

The C<new> constructor lets you create a new B<Rex::Assembly> object.

So no big surprises there...

Returns a new B<Rex::Assembly> or dies on error.

=cut

sub new {
	my $class = shift;
	my $self  = bless { @_ }, $class;
	return $self;
}


=pod

=head2 Assembly:exists

used to ensure a host exists before the rexfile configures it

=cut

desc "exists";
task "exists", sub {
    my ($params) = @_;
    
    Rex::Task->run("Assembly:create", undef, $params);
    

};



=pod

=head2 Assembly:create

lists the virtual machines in the RexConfig hoster group

=cut

desc "create";
task "create", group => "hoster", "name", sub {
    my ($params) = @_;

    #given that the list of params is built by rex, can it error out?
    die 'need to define a --name= param' unless $params->{name};
    
    #TODO: refuse to name a vm with chars you can't use in a hostname
    #refuse to create if the host already exists - test not only libvirsh, but dns etc too (add a --force..)
    if (1==2) {
        print "Creating vm named: $params->{name} \n";
        vm create => $params->{name},
		network => [
         {  type    => "bridge",
            bridge  => "br100",
         },],
         storage     => [
             {
                file   => "/home/sven/virsh/".$params->{name}.".img",
                template   => "/home/sven/virsh/templates/debianbox.img",
             },
          ],
          graphics => { type=>'vnc',
                        port=>'-1',
                        autoport=>'yes',
                        listen=>'*'
          };
        print "Starting vm named: $params->{name} \n";
          
        vm start => $params->{name};
    }      

    my $ips;
    my $count = 0;
    while (!defined($ips) || !defined($$ips[0])) {
		__use_vnc($params->{name}) if ($count == 1); #kick the server with vnc if we don't get instant success'
        print "   try\n";
        $ips = __vm_getip($params->{name});
        sleep(1);
	    $count++;
    }
    
    print "IP: --$$ips[0]--\n";
    set $params->{name}, $$ips[0];
    Rex::Config->set('ip', $$ips[0]);
    #TODO: terrible assumption - how to deal with more than one network interface per host?
    #can't pass the ip back to eh calller :()
    
    #TODO: This is dependant on the template vm :/
    user 'root';
    password 'rex';
    pass_auth;

	Rex::Task->modify_task("Assembly:Remote:set_hostname", "user", 'root');
	Rex::Task->modify_task("Assembly:Remote:set_hostname", "password", 'rex');
    
    #TODO: I wish this was not in the Rexfile, as imo its part of the VM only creation..
    #but, to run it, we need the vm's user details..
    #OH. those are also vm details..
    Rex::Task->run("Assembly:Remote:set_hostname", $$ips[0], $params);
      
    #Rex::Task->run("Assembly:Remote:set_hostname", $$ips[0], $params);
    #Rex::Task->run("_install", $$ips[0], {%$params, packages=>[qw/vim git subversion curl ssmtp/]});

    #ssmtp setup
    #Rex::Task->run("_run", $$ips[0], {%$params, run=>'rsync -avz sven@quad:/etc/ssmtp/* /etc/ssmtp/'});
    
    #TODO: extract to debian builder task
    #Rex::Task->run("_install", $$ips[0], {%$params, packages=>[qw/reprepro make gcc fakeroot devscripts dpatch/]});
    #Rex::Task->run("_checkout_code", $$ips[0], $params);
    #Rex::Task->run("_build_pre", $$ips[0], $params);
    #Rex::Task->run("_run_EPM", $$ips[0], $params);
};

around create => sub {
	print "### test ###\n";
};


=pod

=head2 Assembly:list

lists the virtual machines in the RexConfig hoster group

=cut

desc "lists the virtual machines in the RexConfig hoster group";
task "list", group => "hoster", sub {    
	print Dumper vm list => "all";
};


desc "start --name=";
task "start", group => "hoster", "name", sub {    
    my ($params) = @_;
    
    #given that the list of params is built by rex, can it error out?
    die 'need to define a --name= param' unless $params->{name};
    
    print "Starting vm named: $params->{name} \n";
	print Dumper vm start => $params->{name};
};
desc "stop --name=";
task "stop", group => "hoster", "name", sub {    
    my ($params) = @_;
    
    #given that the list of params is built by rex, can it error out?
    die 'need to define a --name= param' unless $params->{name};
    
    print "Stoping vm named: $params->{name} \n";
	print Dumper vm shutdown => $params->{name};
};


desc "info --name=";
task "info", group => "hoster", sub {  
    my ($params) = @_;  
    #given that the list of params is built by rex, can it error out?
    die 'need to define a --name= param' unless $params->{name};

    print Dumper vm dumpxml => $params->{name};
};


desc "delete --name=";
task "delete", group => "hoster", "name", sub {    
    my ($params) = @_;
    
    #given that the list of params is built by rex, can it error out?
    die 'need to define a --name= param' unless $params->{name};
    
    print "Deleting vm named: $params->{name} \n";
	print Dumper vm delete => $params->{name};
	
	die "need to delete $params->{name}.img file\n";
};



desc "vnc port";
task "vnc", group => "hoster", "name", sub {
    my ($params) = @_;
    
    #given that the list of params is built by rex, can it error out?
    die 'need to define a --name= param' unless $params->{name};
    
    
    print "getting vnc server:port for vm named: $params->{name} \n";
#TODO: replace * with server name - how do we get the name of the server?
    my $vnc = vm vncdisplay => $params->{name};
    print "VNC: $vnc\n";
};

desc "ip";
task "ip", group => "hoster", "name", sub {
    my ($params) = @_;
    
    #given that the list of params is built by rex, can it error out?
    die 'need to define a --name= param' unless $params->{name};
    
    print "getting ip for vm named: $params->{name} ... ".hostname()." \n";

    my $ips = __vm_getip($params->{name});
    print "IP: ".join(',', @$ips)."\n";
};


sub __use_vnc {
    my $vmname = shift;
    
    my $server = Rex::get_current_connection()->{server};
    my $vncport = vm vncdisplay => $vmname;
    $vncport =~ s/.*:(.*)/$1/;
    $vncport = 5900+$1;
    print "---- vnc to $server : $vncport\n";
   
    #TODO: use the vnc console to trigger traffic between the vmserver (where arp is running) and the vm
	my $vnc = Net::VNC->new({hostname => $server, port=>$vncport});
	#$vnc->depth(8); - don't do this.
	$vnc->login;
	#in case we need to log in?
    $vnc->send_key_event_string('root');
    $vnc->send_key_event(0xff0d);
	sleep(1);
    $vnc->send_key_event_string('rex');
    $vnc->send_key_event(0xff0d);
	sleep(1);
    $vnc->send_key_event_string('ping -c 10 big');
    $vnc->send_key_event(0xff0d);
	sleep(1);
	#TODO: er, $vnc->close() ???
    
}
sub __vm_getip {
    my $vmname = shift;
#see http://rwmj.wordpress.com/2010/10/26/tip-find-the-ip-address-of-a-virtual-machine/
    my %addrs;
    my @arp_lines = split /\n/, run 'arp -an';
    foreach (@arp_lines) {
        if (/\((.*?)\) at (.*?) /) {
            $addrs{lc($2)} = $1;
        }
    }
  
	my $opt = vm dumpxml => $vmname;
	my $interfaces = $opt->{devices}->{interface};
	#i presume that if there are 2 network if's that this is a list..
	$interfaces = [$interfaces] unless (ref($interfaces) eq 'ARRAY');
	
	my @ips;
	foreach my $if (@{$interfaces}) {
	    my $mac = lc($if->{mac}->{address});
	    print "\t$mac => $addrs{$mac}\n";
	    push(@ips, $addrs{$mac});
	}
	return \@ips;
};


1;

=pod

=head1 SUPPORT

No support is available

=head1 AUTHOR

Copyright 2012 SvenDowideit@home.org.au .

=cut
