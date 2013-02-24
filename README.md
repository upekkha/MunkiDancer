  MunkiDancer
===============

A [Perl Dancer](http://www.perldancer.org) app that parses your [munki](http://code.google.com/p/munki) repository to generate an index of available packages. It can also fetch information about the latest version numbers from Macupdate and display a list of available updates for your applications.

##### Routes:

* `/`: repo index page with list of available packages
* `/updates`: list of packages with available updates
* `/catalog/<name>`: list of packages in a given catalog
* `/host/<name>`: list of packages deployed on a given host

Routes yielding JSON output as interface for other apps:

* `/catalog/<name>/exists`: boolean flag to check existence of a catalog
* `/catalog/<name>/raw`: list of packages in a given catalog
* `/host/<name>/exists`: boolean flag to check existance of a host
* `/host/<name>/raw`: list of packages deployed on a given host

##### Example:
[munki.phys.ethz.ch](http://munki.phys.ethz.ch)

##### Dependencies:
The script makes use of several perl modules available on [cpan](http://www.cpan.org) or through [MacPorts](www.macports.org).

```
sudo port install p5-dancer p5-yaml-tiny p5-www-mechanize
```
