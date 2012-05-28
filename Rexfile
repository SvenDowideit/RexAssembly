#!rex -wT

use strict;
use warnings;

use Data::Dumper;

use Rex::Commands::SCM;
use Rex::Commands::Pkg;
use Rex::Box;
use Rex::Box::Config;
use Rex::Args;


desc "create or set up a box --name=";
task "create", sub {
    my ($params) = @_;
    
    Rex::Logger::info('running create on '.run 'uname -a');
    return;
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

before 'create' => sub {
    my ($server, $server_ref, $params) = @_;
    
    print "\n-----------\n".Dumper($params)."\n----\n";
    #TODO: this presumes that <local> can talk directly to the vm - which might also not be true.
    die 'need to define a --name= param' unless $params->{name};
    die "--name=$params->{name} ambiguous, please use another name" if ($params->{name} eq '1');
    
    group 'vm', $params->{name};
    
    my $cfg = Rex::Box::Config->get();

    #make sure the vm exists, or create it
    #Rex::TaskList->get_task("Box:exists")->run($cfg->{virtualization_host}, params => $params);
    do_task 'Box:exists';
    
    my $vmtask = Rex::TaskList->get_task("create");
	my $base_box = Rex::Box::Config->get(qw(Base TemplateImages), Rex::Box::Config->get(qw(Base DefaultBox)));    
	$vmtask->set_user($base_box->{user});
	$vmtask->set_password($base_box->{password});
    ##CAN"T CALL THIS IN BEFORE()    $vmtask->set_server($params->{name});
    $$server_ref = $params->{name};
	pass_auth(); #TODO: it bothers me that pass_auth works different from user() and password()
	#TODO: looks like specifying the host here isn't working
    #$vmtask->run($params->{name}, params => $params);
    #do_task 'create';
};


1;
__DATA__
need to set:
* domain
* tz
* adduser?
* apt-sources
its a basic debian setup with ssh and 'standard system utilities'

__REX__
need a vncdisplay so i can say 
rex create start connect --servername=newserver --box=debian
