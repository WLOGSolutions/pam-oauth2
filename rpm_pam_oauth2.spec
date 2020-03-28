%define _buildrootdir %{_builddir}
  
Name:           pam_oauth2
Version:        %{ver}
Release:        1
Summary:        PAM module to autenticate user over KeyCloak OCID

Vendor:         WLOG Solution <info@wlogsolutions.com>
License:        MIT
URL:            https://wlogsolutions.com
Group:          Development/Tools
Source:         %{name}-%{version}.tar.gz
BuildArch:      x86_64

Requires(post): info
Requires(preun): info

%description
PAM module to autenticate users with KeyCloak access token.

%prep
%setup

%build
# Empty section.

%install
install -d %{buildroot}/lib64/security
install -m 644 pam_oauth2.so %{buildroot}/lib64/security

%clean

%files
/lib64/security/pam_oauth2.so
