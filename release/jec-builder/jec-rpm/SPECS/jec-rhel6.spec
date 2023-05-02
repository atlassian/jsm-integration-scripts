Name: %INTEGRATION%-rhel6
Version: %VERSION%
Summary: JEC (%INTEGRATION%) for Connecting On-Premise Monitoring and ITSM Tools
Release: 1
License: Apache-2.0
URL: https://www.atlassian.com/
Group: System
Packager: Atlassian
BuildRoot: ~/rpmbuild/

%description
Jira Edge Connector (JEC) is designed to resolve challenges faced in the integration of internal and external systems.

%prep
echo "BUILDROOT = $RPM_BUILD_ROOT"
mkdir -p $RPM_BUILD_ROOT/usr/local/bin/
mkdir -p $RPM_BUILD_ROOT/home/jsm/jec/
cp $GITHUB_WORKSPACE/.release/jec-rpm/JiraEdgeConnector $RPM_BUILD_ROOT/usr/local/bin/
cp -R  $GITHUB_WORKSPACE/.release/jec-rpm/jec-scripts/. $RPM_BUILD_ROOT/home/jsm/jec/

mkdir -p $RPM_BUILD_ROOT/etc/init.d/
cp $GITHUB_WORKSPACE/.release/jec-rpm/rhel6-service/jec $RPM_BUILD_ROOT/etc/init.d/

%pre
if [ ! -d "/var/log/jec" ]; then
    mkdir /var/log/jec
fi

if [ ! -d "/home/jsm" ]; then
    mkdir /home/jsm
fi

if [  -z $(getent passwd jec) ]; then
    groupadd jec -r
    useradd -g jec jec -r -d /home/jsm
fi

%post
chown -R jec:jec /home/jsm
chown -R jec:jec /var/log/jec

chmod +x /usr/local/bin/JiraEdgeConnector

chmod +x /etc/init.d/jec
service jec start

%postun
service jec stop
rm /etc/init.d/jec

%files
/usr/local/bin/JiraEdgeConnector
/etc/init.d/jec
/home/jsm/jec/

%changelog
