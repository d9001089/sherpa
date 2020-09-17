![icon](images/sherpa.wide.png)

## Description

A mini-package-manager to install various media-management apps into QNAP NAS.

**sherpa** is able to install several search and download apps. App configuration will be retained when upgrading or reinstalling apps.

Any existing installation of Entware will be used automatically. If Entware is not installed, a version appropriate to your NAS will be installed.

---
## Before you begin

This is a **command-line** package manager. If you're not comfortable using the BASH command shell, then please look at some of the fine GUI-only packaged alternatives available from the [Qnapclub Store](https://qnapclub.eu/en). You'll have a much better user-experience.

---
## Applications available
[![SABnzbd](images/SABnzbd.gif)](https://github.com/sabnzbd/sabnzbd)
[![nzbToMedia](images/nzbToMedia.gif)](https://github.com/clinton-hall/nzbToMedia)
[![LaztLibrarian](images/LazyLibrarian.gif)](https://lazylibrarian.gitlab.io/)
[![Medusa](images/OMedusa.gif)](https://github.com/pymedusa/Medusa)
[![SickChill](images/SickChill.gif)](https://github.com/SickChill/SickChill)
[![SickGear](images/OSickGear.gif)](https://github.com/SickGear/SickGear)
[![Mylar3](images/Mylar3.gif)](https://github.com/mylar3/mylar3)
[![NZBGet](images/NZBGet.gif)](https://nzbget.net/)
[![Transmission](images/OTransmission.gif)](https://transmissionbt.com/)
[![Deluge](images/Deluge-web.gif)](https://dev.deluge-torrent.org/)

---
## Current status

STABLE

---
## Requirements

Any model QNAP NAS with at-least 1GB RAM and running QTS 4.0 or-later.

---
## Usage

1) Install the sherpa QPKG. Available here: 

1) [SSH](https://wiki.qnap.com/wiki/How_to_SSH_into_your_QNAP_device) into your NAS as the 'admin' user,

4) Then, to install (or reinstall) an app, run **sherpa** with the name of your required apps as arguments.

For example: to install SABnzbd and SickChill, use:

```
sherpa install SABnzbd SickChill
```

... or:

```
sherpa install nzbToMedia

sherpa install LazyLibrarian

sherpa install Medusa

sherpa install SickGear

sherpa install Mylar3

sherpa install NZBGet

sherpa install Transmission

sherpa install Deluge-server

sherpa install Deluge-web
```

Or, install everything!
```
sherpa --install-all-applications
```

---
## Known issues

1) Python 2.7.16 is no-longer available via Entware/OpenWRT so the **Headphones** QPKG can no-longer be installed. I'll need to find another Python2 source with installable modules, but I'm not hopeful.

2) Sometimes, it seems existing installations of OpenWRT can become "difficult" to work with. So, Entware can also be reinstalled, but this should only be used as a last resort. Using:

```
sherpa reinstall Entware
```

... will force **sherpa** to uninstall your existing Entware QPKG, then install a new one. **Note:** OpenWRT will be reverted back to default, and only the IPKGs required to support your installed **sherpa** apps will be installed. All **sherpa** installed applications will be restarted afterward.


3) **sherpa** is incompatible with Optware-NG as it's missing a few required packages.


4) All the latest issues can be seen on GitHub: [https://github.com/OneCDOnly/sherpa/issues](https://github.com/OneCDOnly/sherpa/issues)

---
## Problems?

This will happen from time-to-time as the environment changes. If it's not shown above in '**Known issues**' then you may have found something new, so please add to [this thread](https://forum.qnap.com/viewtopic.php?f=320&t=132373) with the details of the problem you encountered. Diagnose where you can and provide a solution if you're able. The functions in this script are a community effort. ;)

Sometimes the debug log will be required. This is always created. You can view this with:

```
sherpa log
```

Or run the installer in debug-mode to see it realtime. e.g.:

```
sherpa install SABnzbd --debug
```
NEW! Your debug log can now be posted online courtesy of [https://termbin.com](https://termbin.com):

```
sherpa paste
```

A link will be generated to view this log online. Share it here if you need assistance.

**Note:** your log will be **publicly accessible** to anyone who knows the link details. It will be automatically deleted after 1 month. The debug log typically won't contain any personally-identifiable information. Your public and private IP addresses, email address and so-on are not recorded. However, there is a chance some info may leak if an app generates a backtrace and this is pasted into the sherpa debug log. So, check it first before pasting online.

To upgrade all your sherpa QPKGs:

```
sherpa upgrade-all
```

This option will install any additional QPKGs or IPKGs to support any sherpa-installed applications present on your NAS:

```
sherpa check
```


---
## Firmware compatibility

* QTS 4.4.x - **OK**
* QTS 4.3.x - **OK**
* QTS 4.2.x - **OK**
* QTS 4.1.x or earlier - **Unknown**

---
## Notes

* Deluge is available in two parts: a server daemon, and a web UI. You can install either or both. Both are needed if you don't already have a Deluge daemon running.

* The default login password for **Deluge-web** is 'deluge'.

* Supports application configuration-only backup and restore via the 'backup' and 'restore' arguments. This can be scripted via cron to create a regular backup of each app.

QPKG (configuration-only) backups will be stored in a new hidden directory located under your default userdata volume called [.qpkg_config_backup/]. Hopefully, QNAP won't mess with this location (I'm looking at you Malware Remover).

To jump to this path:

```
cd $(getcfg SHARE_DEF defVolMP -f /etc/config/def_share.info)/.qpkg_config_backup
```

Each QPKG has a single [config.tar.gz] file to backup into. Each new backup replaces the old one (so, no versioning available).

Example: to backup SABnzbd:

```
/etc/init.d/sabnzbd3.sh backup
```
Example: to restore SABnzbd:
```
/etc/init.d/sabnzbd3.sh restore
```

* The information contained therein was constructed from the efforts of many community members on both the [QNAP](https://forum.qnap.com/viewtopic.php?f=320&t=132373) and [SABnzbd](https://forums.sabnzbd.org/) community forums. Thank you to everyone who has contributed.

* Updating an app is easy - just restart it via its App Center icon. Clicking 'stop' then 'start' will force an update.

* **Medusa** will appear as 'OMedusa' in your App Center to avoid conflict with the existing **Medusa** package available in the Qnapclub Store.

* **SickGear** will appear as 'OSickGear' in your App Center to avoid conflict with the existing **SickGear** package available in the Qnapclub Store.

* **Transmission** will appear as 'OTransmission' in your App Center to avoid conflict with the existing **Transmission** packages available.
