#!rex -wT

use strict;
use warnings;

use Data::Dumper;

use Rex::Args;
use Rex::Commands::SCM;
use Rex::Commands::Pkg;

#TODO: move the cfg code out into a 'task module cfg / persistence module'
#tasks need to register what options they need so that we cna test and die before we start running them
use YAML qw(LoadFile);
my $cfg = YAML::LoadFile('/home/sven/.rex/config.yml');# if (-f '~/.rex/config.yml');

#print "\n===========\n".Dumper($cfg)."\n===========\n";

map {
		#print STDERR $_;
		group $_, $cfg->{groups}->{$_}->{hosts} 
	} keys (%{$cfg->{groups}});
set virtualization => $cfg->{virtualization};


use Rex::Assembly;


my %args = Rex::Args->get();

#opefully this too can move to somewhere general
if (defined($args{name})) {
	print "\n----".$args{name}."\n";
	group 'vm', $args{name};
}


desc "create";
task "create", sub {
    my ($params) = @_;
    print "\n-----------\n".Dumper($params)."\n----\n";
    #TODO: this presumes that <local> can talk directly to the vm - which might also not be true.
    die 'need to define a --name= param' unless $params->{name};
    die "--name=$params->{name} ambiguous, please use another name" if ($params->{name} eq '1');
    
    #make sure the vm exists, or create it
    Rex::TaskList->get_task("Assembly:exists")->run($cfg->{virtualization_host}, params => $params);
    
	pass_auth(); #TODO: it bothers me that pass_auth works different from user() and password()
    #Rex::Task->run("vmcreate", $params->{name}, $params);
    #do_task 'vmcreate';
    Rex::TaskList->get_task("vmcreate")->run($params->{name}, params => $params);
    
};

user('root');
password('rex');
#pass_auth(); #darn, using this here breaks the ssh key based hoster access
task "vmcreate", group=> 'vm', sub {
    my ($params) = @_;
    
    Rex::Logger::info('running create on '.run 'uname -a');
    
    #install a few things that I find useful 
    #TODO: move this into my local config..
    update_package_db;
    install package => [qw/vim git subversion curl ssmtp/];

    #force quad to be in ssh known_hosts so that rsync just works    
    run 'ssh -o StrictHostKeyChecking=no quad &';
    sleep(1);

    #ssmtp setup
    run 'rsync -avz sven@quad:/etc/ssmtp/* /etc/ssmtp/';

	#this needs to run on the vm, not here..
    #checkout foswiki
    #checkout 'foswiki_trunk', path=>'foswiki';
    
    #do stuff to configure it
};




1;
__DATA__
need to set:
* hostname: debianbox
* domain
* tz
* adduser?
* apt-sources
its a basic debian setup with ssh and 'standard system utilities'
root pwd: rex
user: rex: rex

__REX__
need a vncdisplay so i can say 
rex create start connect --servername=newserver --box=debian
