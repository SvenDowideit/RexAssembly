#!rex -wT

use strict;
use warnings;

use Data::Dumper;

use Rex::Assembly;
unshift(@INC, '~/.rex');
use RexConfig;

use Rex::Commands::SCM;
use Rex::Commands::Pkg;

set repository => "foswiki_trunk",
      url => "http://svn.foswiki.org/trunk/",
      type => "subversion";


desc "create";
task "create", sub {
    my ($params) = @_;
	pass_auth(); #TODO: it bothers me that pass_auth works different from user() and password()
    Rex::Task->run("vmcreate", $params->{name}, $params);
};

#TODO: I'd like to move this before() declaration into Rex::Assembly, but that presumes that we can forward declare these
before create => sub {
    my ($server, $server_ref, $params) = @_;
	print "### test2 - running on $server ($params->{name})###\n";
	
    die 'need to define a --name= param' unless $params->{name};
    die "--name=$params->{name} ambiguous, please use another name" if ($params->{name} eq '1');

    Rex::Task->run("Assembly:exists", $server, $params);
    #do_task 'Assembly:exists', $params;
    
    #we have a vm
	$$server_ref = $params->{name};
};

user('root');
password('rex');
#pass_auth(); #darn, using this here breaks the ssh key based hoster access
task "vmcreate", sub {
    my ($params) = @_;
    #TODO: this presumes that <local> can talk directly to the vm - which might also not be true.
    die 'need to define a --name= param' unless $params->{name};
    die "--name=$params->{name} ambiguous, please use another name" if ($params->{name} eq '1');
    
    Rex::Logger::info('running create on '.run 'uname -a');
    
    #install a few things that I find useful 
    #TODO: move this into my local config..
    update_package_db;
    install package => [qw/vim git subversion curl ssmtp/];

    #force quad to be in ssh known_hosts so that rsync just works    
    run=>'ssh -o StrictHostKeyChecking=no quad';

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
