  MunkiDancer
===============

A [Perl Dancer](http://www.perldancer.org) app that parses your [munki](http://code.google.com/p/munki) repository to generate an index of available packages. It can also fetch the latest version numbers from Macupdate and display the list of applications in your repo for which updates are available. Additionally you may view the list of packages contained in a given catalog, or being deployed on a certain client. The information can also be fetched in JSON format to be used as interface for another webservice.

##### Routes
* `/`: repo index page with list of available packages
* `/updates`: list of packages with available updates
* `/catalog/<name>`: list of packages in a given catalog
* `/host/<name>`: list of packages deployed on a given host

Routes yielding JSON output:

* `/catalog/<name>/exists`: boolean flag to check existence of a catalog
* `/catalog/<name>/json`: list of packages in a given catalog in JSON format
* `/host/<name>/exists`: boolean flag to check existence of a host
* `/host/<name>/json`: list of packages deployed on a given host in JSON format
* `/costunits/json`: hash of all cost units and the corresponding list of hosts in JSON format
* `/costunit/<number>/json`: list of hosts in a given cost unit in JSON format
* `/licenses/json`: hash of licenced packages, costs, assigned hosts and total number of installations

##### Configuration
Create a symlink `repo` pointing to your munki repository. By default, a folder structure of the following form is expected:

    ./repo
    ├── catalogs/          # munki catalogs
    ├── icons/             # munki application icons
    ├── manifests/         # munki host manifests
    │   └── bundles/       # munki bundles
    └── web/               # special folder for MunkiDancer
        └── appinfo.yml    # parsed application infos

The `icons` folder should contain png files with the same name as the packages to be used as icons on the index page.

The `appinfo.yml` file can contain further information about the applications, like the license type, the application's homepage and Macupdate page to look for the latest version number.

```yaml
---
AppName:
    homepage:       'http://AppName.example.com'
    update_url:     'http://www.macupdate.com/app/mac/123456/AppName'
    license:        'free'
```

To change the appearance of the html pages, you can edit the layout templates in the `view` folder, as well as the corresponding stylesheets inside `public/styles`.

Any other customizations have to be made in the perl code. For instance one can modify the regular expressions in `lib/MunkiDancer/Common.pm` to define which applications are to be excluded from the index or updates pages.


##### Dependencies
The script makes use of several perl modules available on [cpan](http://www.cpan.org) or through [MacPorts](www.macports.org).

```
sudo port install p5-dancer p5-json p5-template-toolkit p5-yaml-tiny p5-www-mechanize p5-sort-versions
```

When deploying on a Linux server, the dependencies can be installed with your favorite package manager, for instance:

```
aptitude install libdancer-perl libjson-perl libtemplate-perl libyaml-tiny-perl libwww-mechanize-perl libsort-versions-perl
```

We use [starman](https://github.com/miyagawa/Starman) as multi-threaded perl webserver and apache as proxy. The `etc` folder contains examples of an init script and apache config.
