This directory contains files for the continuous test of DAMON.

It checks updates to several kernel trees, trigger tests on remote test
machines, and retrieve the test results from them.

Usage
=====

First, setup your test machines.  The machines should be able to be accessed
via `ssh` from your host machine (the machine that runs humble_ci) without any
password prompt.  For that, you could set the `~/.ssh/authorized_keys` file of
the test machine.  The test account should also be able to run `sudo` without
prompts (this can be done by editing the sudoer file).

Second, write down your own `config.sh` file for your test machines setup.
Specifically, the file should define `test_machines`, `test_users`,
`test_ssh_ports` variables as arrays.  Optionally, if your machine is
configured to send mail via `git send-email` without prompts, you may set
`result_noti_recipients` variable.  For an example:

    test_machines=(test_machine1_x86 test_machine2_arm64)
    test_users=(alice alice)
    test_ssh_ports=(22 2222)
    result_noti_recipients="alice@wonder.land"

Third, execute `run.sh` file.  It will check update to upstream trees having
DAMON code, including LTS, stable, mainline, and -mm tree every hour.  Then, if
any update to any of the tree is found, the script will install the updated
kernel on your test machines, reboot, and run the `damon-tests/corr` tests.
Summarized results will be sent to you as email if you set
`result_noti_recipients` variable in the `config.sh` file.
