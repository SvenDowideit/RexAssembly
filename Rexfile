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

    #TODO: need to (optionally) tell it what I want to create too
    #$params->{vmimgtemplate} = 'debianbox';  #ie, name of img file in box..
    $params->{vmuser} = 'root';
    $params->{vmpassword} = 'rex';
    $params->{vmauth} = 'pass_auth';
	
#the above $params settings do not find their way to the needs(task), but this hack does....
push(@ARGV, '--vmuser=root');
push(@ARGV, '--vmpassword=rex');
push(@ARGV, '--vm_auth=pass_auth');

    needs Rex::Assembly "exists";
    
    VMTASK: {
        ###########
        # this is the actual bit - if i could use 'before' in a cross host IPC way, then this would be simpler to write
		user($params->{vmuser});
		password($params->{vmpassword});
		pass_auth();
        
        #delay loading the Rex::Assembly::Remote so that it uses the vm's user&pwd specified above, and thus i don't need to modify_task.
        eval 'use Rex::Assembly::Remote;';

        
        #install a few things that I find useful
        #Rex::Task->modify_task("Assembly:Remote:install", "auth", {user=>$params->{vmuser}, password=>$params->{vmpassword}});
        Rex::Task->run("Assembly:Remote:install", $params->{name}, {%$params, packages=>[qw/vim git subversion curl ssmtp/]});

        #force quad to be in ssh known_hosts so that rsync just works    
        #Rex::Task->run("run", $params->{name}, {%$params, run=>'ssh -o StrictHostKeyChecking=no quad'});

        #ssmtp setup
        #Rex::Task->run("Assembly:Remote:run", $params->{ip}{$params->{name}}, {%$params, run=>'rsync -avz sven@quad:/etc/ssmtp/* /etc/ssmtp/'});

        #checkout foswiki
        #checkout 'foswiki_trunk', path=>'foswiki';
        
        #do stuff to configure it
    }
};

after 'Assembly:create' => sub {
    my ($server, $server_ref, $params) = @_;
    
    print "after Assembly:create - running on $server\n";
};

around create => sub {
    my ($server, $server_ref, $params) = @_;
	print "### test2 - running on $server ###\n";
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
