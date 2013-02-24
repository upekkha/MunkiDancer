  MunkiDancer
===============

A [Perl Dancer](http://www.perldancer.org) app that parses your [munki](http://code.google.com/p/munki) repository to generate an index of available packages. It can also fetch information about the latest version numbers from Macupdate and display a list of available updates for your applications.

##### Example:
[munki.phys.ethz.ch](http://munki.phys.ethz.ch)

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

##### Configuration:
Create a symlink `repo` pointing to your munki repository. By default, a folder structure of the following form is expected:

    ./repo
    ├── catalogs/          # munki catalogs
    ├── manifests/         # munki host manifests
    │   └── bundles/       # munki bundles
    └── web/               # special folder for MunkiDancer
        ├── img/           # folder with application icons
        └── appinfo.yml    # parsed application infos

The `img` folder may contain png files with the same name as the packages to be used as icons on the index page.

The `appinfo.yml` file can contain further information about the applications, like the license type, the application's homepage and Macupdate page to look for the latest version number.

```yaml
---
AppName:
    homepage:           'http://AppName.example.com'
    update_url:         'http://www.macupdate.com/app/mac/123456/AppName'
    license:            free
```

To change the appearance of the html pages, you can edit the layout templates in the `view` folder, as well as the corresponding stylesheets inside `public/styles`.

Any other customizations have to be made in the perl code. For instance one can modify the regular expressions in `lib/MunkiDancer/Common.pm` to define which applications are to be excluded from the index or updates pages.


##### Dependencies:
The script makes use of several perl modules available on [cpan](http://www.cpan.org) or through [MacPorts](www.macports.org).

```
sudo port install p5-dancer p5-yaml-tiny p5-www-mechanize
```
