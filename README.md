# SSH-GeoIP-Filter
SSHD GeoIP Filtering script using MaxMind GeoIP2 & GeoLite2.

The script was inspired by
[Ralph Slooten at axllent.org](https://www.axllent.org/docs/view/ssh-geoip/) & [Ryan Harg at blog.reinhard.codes](https://blog.reinhard.codes/2023/04/02/restricting-access-to-ssh-using-fail2ban-and-geoip/)
with modifications made by me to use the latest supported `mmdblookup` utility from MaxMind to interact with the GeoIP2/GeoLite2 database instead of the outdated `geoiplookup/geoiplookup6` utility that only works for the GeoIP Legacy database.

The `mmdblookup` supports both IPv4 and IPv6 addresses, and different mmdb database files such as GeoLite2-ASN.mmdb, GeoLite2-City.mmdb, GeoLite2-Country.mmdb etc depending on your subscription with MaxMind, but the free GeoLite2 would be more than enough for GeoIP filtering.

The script currently uses the `GeoLite2-Country.mmdb` file to do iso country code lookup, and could be changed depending on your needs.

## GeoIP by MaxMind

To be able to update your GeoIP database you need to register an account
with MaxMind, see [MaxMind's docs on geoipupdate](https://dev.maxmind.com/geoip/updating-databases).

You would also need to install the latest `geoipupdate` version,
you can find the lastest version & installation instruction on [MaxMind's `geoipupdate` repo](https://github.com/maxmind/geoipupdate).

From the docs, you will be able to follow the instruction to download a sample configuration file to be put at `/etc/GeoIP.conf`.

The `/etc/GeoIP.conf` should look like this:

```plain
# GeoIP.conf file for `geoipupdate` program, for versions >= 3.1.1.
# Used to update GeoIP databases from https://www.maxmind.com.
# For more information about this config file, visit the docs at
# https://dev.maxmind.com/geoip/updating-databases.

# `AccountID` is from your MaxMind account.
AccountID YOUR_ACCOUNT_ID_HERE

# Replace YOUR_LICENSE_KEY_HERE with an active license key associated
# with your MaxMind account.
LicenseKey YOUR_LICENSE_KEY_HERE

# `EditionIDs` is from your MaxMind account.
EditionIDs GeoLite2-ASN GeoLite2-City GeoLite2-Country
```

After which you can follow the instructions to add geoipupdate to crontab to update the GeoIP2/GeoLite2 database automatically.

## How to install

1. Install geoip packages:

```bash
$ sudo apt update
$ sudo apt install libmaxminddb0 libmaxminddb-dev mmdb-bin geoipupdate
```
- libmaxminddb0 libmaxminddb-dev – MaxMind Geolocation database libraries
- mmdb-bin – binary. Program to call from the command line. Use this command to geolocate IP manually.
- geoipupdate – package that assists in configuring and updating GeoIP2 / GeoLite2.

2. Clone the repo:

```bash
$ git clone https://github.com/xKhronoz/SSHD-GeoIP-Filter.git
```

3. Copy the script to `/usr/local/bin` & add execute permissions

```bash
$ cd SSHD-GeoIP-Filter
$ sudo cp sshd-geoip-filter.sh /usr/local/bin/
$ sudo chmod +x /usr/local/bin/sshd-geoip-filter.sh
```

4. Update `/etc/hosts.allow` & `/etc/hosts.deny`

```bash
# After `sudo nano /etc/hosts.deny` add in this line:
sshd: ALL

# After `sudo nano /etc/hosts.allow` add in this line:
sshd: ALL: aclexec /usr/local/bin/sshd-geoip-filter.sh %a
```
- Using aclexec in hosts.allow will allow the sshd service to take into account the exit code and abort connection attempts. 

5. Setup Crontab to run geoipupdate

```bash
# Setup crontab as sudo
$ sudo crontab -e

# Add in the lines below, change the timezone and schedule according to your preference (Use https://crontab.guru to get the schedule)
'''
# Disable mailing
MAILTO=""

# CRON TIMEZONE
CRON_TZ=Asia/Singapore

# Update Maxmind GeoIP2 Database at 4am every thursday & saturday, logs to a file
0 4 * * 4,6 /usr/bin/geoipupdate -v >> /var/log/cron.log 2>&1
'''
```

## Compatible Operating Systems

Tested on Ubuntu 22.04 and Debian, should work the same on other similar linux systems.
