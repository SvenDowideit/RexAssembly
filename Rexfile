#!rex -wT

use strict;
use warnings;

use Data::Dumper;

use Rex::Assembly;
unshift(@INC, '~/.rex');
use RexConfig;

use Rex::Commands::SCM;

set repository => "foswiki_trunk",
      url => "http://svn.foswiki.org/trunk/",
      type => "subversion";


desc "create";
task "create", sub {
    my ($params) = @_;
    die 'need to define a --name= param' unless $params->{name};
push(@ARGV, '--sven=dowideit');

print "one: $params->{sven}\n";
    #TODO: need to (optionally) tell it what I want to create too
    #$params->{vmimgtemplate} = 'debianbox';  #ie, name of img file in box..
    $params->{vmuser} = 'root';
    $params->{vmpassword} = 'rex';
    $params->{vmauth} = 'pass_auth';
	Rex::Task->modify_task("Assembly:Remote:set_hostname", "auth", {user=>$params->{vmuser}, password=>$params->{vmpassword}});
#the above $params settings and the modify_task dont' work, but this hack...
push(@ARGV, '--vmuser=root');
push(@ARGV, '--vmpassword=rex');
push(@ARGV, '--vm_auth=pass_auth');

    needs Rex::Assembly "exists";
    
    ###########
    # this is the actual bit - if i could use 'before' in a cross host IPC way, then this would be simpler to write
    
    #install a few things that I find useful
	Rex::Task->modify_task("Assembly:Remote:install", "auth", {user=>$params->{vmuser}, password=>$params->{vmpassword}});
    Rex::Task->run("Assembly:Remote:install", $params->{name}, {%$params, packages=>[qw/vim git subversion curl ssmtp/]});

    #ssmtp setup
    #Rex::Task->run("Assembly:Remote:run", $params->{ip}{$params->{name}}, {%$params, run=>'rsync -avz sven@quad:/etc/ssmtp/* /etc/ssmtp/'});
    
    #TODO: extract to debian builder task
    #Rex::Task->run("_install", $$ips[0], {%$params, packages=>[qw/reprepro make gcc fakeroot devscripts dpatch/]});
    #Rex::Task->run("_checkout_code", $$ips[0], $params);
    #Rex::Task->run("_build_pre", $$ips[0], $params);
    #Rex::Task->run("_run_EPM", $$ips[0], $params);

    #checkout foswiki
    #checkout 'foswiki_trunk', path=>'foswiki';
    
    #do stuff to configure it
};

around create => sub {
	print "### test2 ###\n";
};

before 'Ncreate' => sub {
    my ($server, $server_ref, $params) = @_;

    die 'need to define a --name= param' unless $params->{name};


	print "### before ###\n";
    
    #I wanted to write do_task, but it does not have a $params hash.. so i'll use the Task->run
    #do_task 'Assembly:exists';
    Rex::Task->run("Assembly:exists", $server, $params);
    
    #we have a vm
	$$server_ref = $params->{name};
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
