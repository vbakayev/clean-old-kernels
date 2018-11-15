# clean-old-kernels

Quick script for cleaning old Debian/Ubuntu-based stash of installed kernel packages, that takes into account:
* current running kernel which should never be removed,
* newest installed kernel version,
* other (outdated) kernels.

Original code by Julien Moreau AKA PixEye, origin was here:  
[http://stoilis.wordpress.com/2010/06/18/automatically-remove-old-kernels-from-debian-based-distributions/] (http://stoilis.wordpress.com/2010/06/18/automatically-remove-old-kernels-from-debian-based-distributions/).
