# Do not clean the install folder
%define __spec_install_pre true

# Use md5 file digest method.
# The first macro is the one used in RPM v4.9.1.1
%define _binary_filedigest_algorithm 1
# This is the macro I find on OSX when Homebrew provides rpmbuild (rpm v5.4.14)
%define _build_binary_file_digest_algo 1

# Use bzip2 payload compression
%define _binary_payload w9.bzdio


Name: palette-insight-reporting
Version: %version
Epoch: 1
Release: %buildrelease
BuildArch: noarch
Summary: Palette Insight Reporting
AutoReqProv: no
# Seems specifying BuildRoot is required on older rpmbuild (like on CentOS 5)
# fpm passes '--define buildroot ...' on the commandline, so just reuse that.
BuildRoot: %buildroot
# Add prefix, must not end with /

Prefix: /

Group: default
License: Proprietary
Vendor: Palette Software
URL: http://www.palette-software.com
Packager: Palette Developers <developers@palette-software.com>

Requires: palette-greenplum-installer
Requires: palette-insight-toolkit
Requires: palette-insight-gp-import
Requires: palette-insight-reporting-framework

%description
Palette Insight Reporting SQL Jobs

%pre
# Stop if required palette packages are not installed
rpm -q palette-greenplum-installer palette-insight-toolkit palette-insight-gp-import palette-insight-reporting-framework

%build
# noop

%install
# noop

%clean
# noop

%files
%defattr(-,insight,insight,-)

# Reject config files already listed or parent directories, then prefix files
# with "/", then make sure paths with spaces are quoted.
/opt/palette-insight-reporting
/etc/palette-insight-server
%dir /var/log/palette-insight-reporting

%post
su -c "/opt/palette-insight-reporting/gpadmin-install-data-model.sh" gpadmin &> /var/log/palette-insight-reporting/install-data-model.log

%changelog
