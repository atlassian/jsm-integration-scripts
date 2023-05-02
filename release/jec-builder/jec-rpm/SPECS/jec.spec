Name: %INTEGRATION%
Version: %VERSION%
Summary: JEC (%INTEGRATION%) for Connecting On-Premise Monitoring and ITSM Tools
Release: 1
License: Apache-2.0
URL: https://www.atlassian.com/
Group: System
Packager: Atlassian
BuildRoot: .

%description
Jira Edge Connector (JEC) is designed to resolve challenges faced in the integration of internal and external systems.

%prep
echo "BUILDROOT = $RPM_BUILD_ROOT"
mkdir -p $RPM_BUILD_ROOT/usr/local/bin/
mkdir -p $RPM_BUILD_ROOT/etc/systemd/system/
mkdir -p $RPM_BUILD_ROOT/home/jsm/jec/
cp $GITHUB_WORKSPACE/.release/jec-rpm/JiraEdgeConnector $RPM_BUILD_ROOT/usr/local/bin/
cp $GITHUB_WORKSPACE/.release/jec-rpm/jec.service $RPM_BUILD_ROOT/etc/systemd/system/
cp -R $GITHUB_WORKSPACE/.release/jec-rpm/jec-scripts/. $RPM_BUILD_ROOT/home/jsm/jec/

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

chmod +x /etc/systemd/system/jec.service
chmod +x /usr/local/bin/JiraEdgeConnector
systemctl daemon-reload
systemctl enable jec

%postun
systemctl daemon-reload

%files
/usr/local/bin/JiraEdgeConnector
/etc/systemd/system/jec.service
/home/jsm/jec/