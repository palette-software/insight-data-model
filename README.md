[![Build Status](https://travis-ci.com/palette-software/insight-data-model.svg?token=qWG5FJDvsjLrsJpXgxSJ&branch=master)](https://travis-ci.com/palette-software/insight-data-model)


## Using the installer:

The ```insight-datamodel-install.sh``` script can be used to install or
migrate a DataModel version.

Basic usage:
(a full install followed by an upgrade).

```
# Install the data model v1.1.16
insight-datamodel-install.sh v1.1.16

# upgrade the data model to v1.1.17
insight-datamodel-install.sh v1.1.17
```


## Building an RPM package

By tagging your commit, travis will automatically create an RPM package
that'll be uploaded to the palette rpm server.

Adding this tag:

```
git tag -a v1.1.17 -m "Merry Supernova
* added something
* changed something
* even fixed some bugs"
```

Note: the code name generator currently used is:
[http://names.pub/code-names](http://names.pub/code-names)
