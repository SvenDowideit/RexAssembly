#!rex -wT

use strict;
use warnings;

use Data::Dumper;

use Rex::Assembly;
unshift(@INC, '~/.rex');
use RexConfig;


desc "create";
task "create", sub {
    my ($params) = @_;

    #TODO: need to (optionally) tell it what I want to create too
    needs Rex::Assembly 'exists';

    #given that the list of params is built by rex, can it error out?
    die 'need to define a --name= param' unless $params->{name};
    
    my $ip = get $params->{name};
    print "rexfile get ip = $ip\n";
    $ip = Rex::Config->get('ip');
    print "rexfile get ip = $ip\n";
    $ip = Rex::Config->set('ip', $params->{name});
    $ip = Rex::Config->get('ip');
    print "rexfile get ip = $ip\n";
    
    
    #TODO: This is dependant on the template vm :/
    user 'root';
    password 'rex';
    pass_auth;
    
    #TODO: I wish this was not in the Rexfile, as imo its part of the VM only creation..
    #but, to run it, we need the vm's user details..
    #OH. those are also vm details..
    Rex::Task->run("Assembly:Remote:set_hostname", $ip, $params);
    
    #install a few things that I find useful
    #Rex::Task->run("Assembly:Remote:install", $params->{ip}{$params->{name}}, {%$params, packages=>[qw/vim git subversion curl ssmtp/]});

    #ssmtp setup
    #Rex::Task->run("Assembly:Remote:run", $params->{ip}{$params->{name}}, {%$params, run=>'rsync -avz sven@quad:/etc/ssmtp/* /etc/ssmtp/'});
    
    #TODO: extract to debian builder task
    #Rex::Task->run("_install", $$ips[0], {%$params, packages=>[qw/reprepro make gcc fakeroot devscripts dpatch/]});
    #Rex::Task->run("_checkout_code", $$ips[0], $params);
    #Rex::Task->run("_build_pre", $$ips[0], $params);
    #Rex::Task->run("_run_EPM", $$ips[0], $params);
};

########################################################
## commands to manipulate the created vm

use Rex::Commands::Sysctl;
use Rex::Commands::Pkg;
use Rex::Commands::SCM;
use Rex::Commands::Rsync;
use Rex::Commands::Upload;

set repository => "foswiki_builder",
      url => "http://fosiki.com/svn/projects/Perl/FoswikiInstaller/",
      type => "subversion";

    
desc "_checkout_code --name=";
task "_checkout_code", sub {    
    my ($params) = @_;

    checkout 'foswiki_builder', path=>'foswiki';
};

desc "_build_pre --name=";
task "_build_pre", sub {    
    my ($params) = @_;

    run 'cd foswiki/EPM/tools ; tar zxvf epm-4.2-source.tar.gz';
    run 'cd foswiki/EPM/tools/epm-4.2 ; ./configure --disable-gui';
    run 'cd foswiki/EPM/tools/epm-4.2 ; make';
    run 'cd foswiki/EPM/tools/epm-4.2 ; make install';

#TODO: need to get the gnupg key for signing the repo over
    run 'rsync -avz sven@quad:/data/home/sven/.gnupg .';
#TODO: set up svn credentials to svn up
#TODO: add cronjob to runitall

    #get packages..
    #can't do this - as sync doesn't get 'run' from 'this server'
    #sync 'sven@quad:/data/home/sven/src/distributedinformation/projects/Perl/FoswikiInstaller/Packages/*', 'foswiki/Packages/';
    run 'rsync -avz sven@quad:/data/home/sven/src/distributedinformation/projects/Perl/FoswikiInstaller/Packages/* foswiki/Packages/';
    run 'rsync -avz sven@quad:/data/home/sven/src/distributedinformation/projects/Perl/FoswikiInstaller/Packages/.git foswiki/Packages/';
    run 'rsync -avz sven@quad:/data/home/sven/src/distributedinformation/projects/Perl/FoswikiInstaller/Foswiki_debian/* foswiki/Foswiki_debian/';

};

desc "_run EPM --name=";
task "_run_EPM", sub {    
    my ($params) = @_;
    
    run 'cd foswiki ; ./updateAndBuildPackages.sh > run.log 2>&1';
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
