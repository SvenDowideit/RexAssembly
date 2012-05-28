#!rex -wT

use strict;
use warnings;

use Data::Dumper;

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

use Rex::Box;


desc "create";
task "create", sub {
    my ($params) = @_;
    print "\n-----------\n".Dumper($params)."\n----\n";
    #TODO: this presumes that <local> can talk directly to the vm - which might also not be true.
    die 'need to define a --name= param' unless $params->{name};
    die "--name=$params->{name} ambiguous, please use another name" if ($params->{name} eq '1');
    
    group 'vm', $params->{name};
    
    #make sure the vm exists, or create it
    Rex::TaskList->get_task("Box:exists")->run($cfg->{virtualization_host}, params => $params);
    
    my $vmtask = Rex::TaskList->get_task("vmcreate");
    $vmtask->set_user('root');
    $vmtask->set_password('rex');
	pass_auth(); #TODO: it bothers me that pass_auth works different from user() and password()
    $vmtask->run($params->{name}, params => $params);
    
};

task "vmcreate", group=> 'vm', sub {
    my ($params) = @_;
    
    Rex::Logger::info('running create on '.run 'uname -a');
    
    #install a few things that I find useful 
    #TODO: move this into my local config..
    update_package_db;
    install package => [qw/vim git subversion curl ssmtp/];

    #ssmtp setup
    #force quad to be in ssh known_hosts so that rsync just works    
    run 'rsync -avz -e "ssh -o StrictHostKeyChecking=no" sven@quad:/etc/ssmtp/* /etc/ssmtp/';

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
