#!rex -wT

use strict;
use warnings;

use Rex::Box;
use Rex::Commands::SCM;
use Rex::Commands::Pkg;


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

Rex::Box->configurewith('create');


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
