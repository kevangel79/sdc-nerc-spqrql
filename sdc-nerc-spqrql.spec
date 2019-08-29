Name:		sdc-nerc-sparql
Version:	1.0.1
Release:	2%{?dist}
Summary:	Nagios - SPARQL ENDPOINT NVS probe
License:	GPLv3+
Packager:	Themis Zamani <themiszamani@gmail.com>

Source:		%{name}-%{version}.tar.gz
BuildArch:	noarch
BuildRoot:	%{_tmppath}/%{name}-%{version}
Requires(pre):  gridsite-clients
AutoReqProv: no

%description
Nagios probes to check functionality of Nagios SPARQL ENDPOINT NVS

%prep
%setup -q

%define _unpackaged_files_terminate_build 0 

%install

install -d %{buildroot}/%{_libexecdir}/argo-monitoring/probes/sdc-nerc-sparql
install -d %{buildroot}/%{_sysconfdir}/nagios/plugins/sdc-nerc-sparql
install -m 755 sdc-nerc-sparql.sh %{buildroot}/%{_libexecdir}/argo-monitoring/probes/sdc-nerc-sparql/sdc-nerc-sparql.sh

%files
%dir /%{_libexecdir}/argo-monitoring
%dir /%{_libexecdir}/argo-monitoring/probes/
%dir /%{_libexecdir}/argo-monitoring/probes/sdc-nerc-sparql

%attr(0755,root,root) /%{_libexecdir}/argo-monitoring/probes/sdc-nerc-sparql/sdc-nerc-sparql.sh

%changelog
* Thu Aug 29 2019 Themis Zamani <themiszamani@gmail.com>  - 1.0.0-1%{?dist}
- Initial version of the package. Work done by Micahlis Iordanis - iordanism@hcmr.gr 

