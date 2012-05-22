RexAssembly
===========

A self assembling kitchen sink.

Portable Vagrant
================
I'd like a simple RexFile that would cfg manage whatever choice of deployment options I prefer.

so the Rexfile would be OS independent - i'll start with linux distro indept. 

local cfg would tell it where to deploy - and if its set for 'libvirt' then it would create the (set of) named vm's (unless they already existed) and then deploy on to those.

I really do want to be able to 'create' a host from any source img - vmware, vbox, vagrant box, etc)
INCLUDING WINDOWS

If there's no cfg, we should either question the user to make one, or do local stuff..

should register cd's and img's and allow copying an existing vm..

Rex
===
Rex has several overlapping operation modes:
* run on 'this' computer
* run on one or more remote computers
* set up some virtual machines either on 'this' or remote computers, and then execute more things on those created machines

and
* simple linear script - no checking, just do XYZ, and if that task is run again, blindly do the same again
* linear with checks - can be run again, but code needs unless(installed) {doit}
* task => {pending=>sub{}, execute=>{}} cfg mgmt mode

and
* rev master driven (not scalable) where the admin executes a script on one host which then runs code on the group
* async master where we try (and fail) to mitigate this by having the masters push from a que
* pull - where all managed systems have rex installed, and use git to pull cfg's that they should execute - using some regular local trigger (and the master can kick hosts that have not returned statuses.

use cases
=========
* dev/test/support setups - a rexfile for a project that can set up whats needed to et started - either locally, local vm (vagrant style), remote servers, or remove vm server
* network admin mgmt - a set of tasks that a group of servers use to keep their cfg's uptodate
* 



