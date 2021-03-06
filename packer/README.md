# Packer Templates

This folder contains files to build base images with Packer.

The `basebuild.json` file contains the Packer definitions.  This currently uses a base Ubuntu 14.04.3 AMI and adds a local Chef Solo invocation to install desired cookbooks.  It also installs the Consul and Nomad binaries.

## Requirements

A Ruby stack with `bundle`.  Running `bundle install` inside this directory will install the Gem dependencies.

## Cookbooks

The cookbooks to be installed in the Packer image should be added to the `cookbooks/Berksfile`.  The applications installed into the image are `git` and`java`.

## Scripts
There are some scripts that are used to install `consul`, `vault` and `nomad`.

## Building the Image

The image is built with this command:

```bash
packer build -var aws_access_key=${AAKI} -var aws_secret_key=${ASAK} basebuild.json
```

## Upload the AMI ID to Consul

To upload the AMI to Consul use the following commands:

```bash
#!/usr/bin/env bash
set -e

echo "Started: $(date)"
echo "Generating AMI..."
export AAKI=$(sed "2q;d" ~/.aws/credentials | awk -F'=' '{print $2}' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
export ASAK=$(sed "3q;d" ~/.aws/credentials | awk -F'=' '{print $2}' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
export AMI_ID=$(packer build -var aws_access_key=${AAKI} -var aws_secret_key=${ASAK} -machine-readable basebuild.json | awk -F, '$0 ~/artifact,0,id/ {print $6}' | cut -f2 -d:)

echo "Generating AMI Complete"
echo "Finished: $(date)"
```

## Rake

Running `rake` will install the cookbooks locally using `berks install` and vendor them appropriately, and then run the Packer build.

## Tests

Some basic [ServerSpec](http://serverspec.org) tests are used to ensure that required packages are installed in the AMI.  The Spec tests are modelled after [Gareth Rushgrove's examples](https://github.com/garethr/packer-serverspec-example).  These tests are run by Packer after the Chef run, but before the AMI is built and registered, so this task can be run in a pipeline.

A basic test checks that the `git` package has been installed. Other tests should be added to the `tests/spec` directory as the Chef Solo build gets more complicated.
