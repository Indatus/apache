# Chef cookbook for Apache.

Version 2 provides a whole bunch of improvements such as:
* foodcritic tests compliance
* support for rhel and ebian family via platform_family ohai feature


The default recipe determines the platform it's running on and calls the appropriate recipe. If you need to be specific, call `apache::debian` or `apache::rhel` directly in your runlist.
