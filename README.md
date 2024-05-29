# SSH-GeoIP-Filter
SSH GeoIP Filtering script using MaxMind GeoIP2 & GeoLite2 via mmdblookup.

The script was orignally inspired by authors in found in [Acknowledgements](#acknowledgements), with modifications made by me to use the latest supported `mmdblookup` utility from MaxMind to interact with the GeoIP2/GeoLite2 database instead of the outdated `geoiplookup/geoiplookup6` utility that only works for the GeoIP Legacy database.

The `mmdblookup` supports both IPv4 and IPv6 addresses, and different mmdb database files such as GeoLite2-ASN.mmdb, GeoLite2-City.mmdb, GeoLite2-Country.mmdb etc depending on your subscription with MaxMind, but the free GeoLite2 would be more than enough for GeoIP filtering.

The script currently uses the `GeoLite2-Country.mmdb` file to do [two-letter country code](https://dev.maxmind.com/geoip/docs/databases/city-and-country#:~:text=City-,country_iso_code,-string%20(2)) lookup, refered to as `ISO 3166-1 alpha-2`. It could be changed depending on your needs by editing the `ALLOW_COUNTRIES` line in the script.

## Requirements

To update your GeoIP database you need an free MaxMind License Key - register an account
with MaxMind, see [MaxMind's docs on geoipupdate](https://dev.maxmind.com/geoip/updating-databases).

You would also need to install the latest `geoipupdate` version,
you can find the lastest version & installation instruction on [MaxMind's geoipupdate repo](https://github.com/maxmind/geoipupdate).

From the docs, you will also be able to follow the instruction to download a sample configuration file to be put at `/etc/GeoIP.conf`.

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

After which you can follow the instructions below to get started in installing the script.

## Getting Started

1. Install required packages:

```bash
$ sudo apt update
$ sudo apt install libmaxminddb0 libmaxminddb-dev mmdb-bin geoipupdate
```

- libmaxminddb0 libmaxminddb-dev – MaxMind Geolocation database libraries
- mmdb-bin – binary. Program to call from the command line. Use this command to geolocate IP manually.
- geoipupdate – package that assists in configuring and updating GeoIP2 / GeoLite2.

2. Download the latest release:

```bash
# Download the latest release
$ wget https://github.com/xKhronoz/SSH-GeoIP-Filter/releases/latest
```

3. Copy the script to `/usr/local/bin`, add execute permissions and edit the `ALLOW_COUNTRIES` line to suit your needs:

```bash
$ cd SSH-GeoIP-Filter
$ sudo cp ssh-geoip-filter.sh /usr/local/bin/
$ sudo chmod +x /usr/local/bin/ssh-geoip-filter.sh
```

4. Edit line *5* in `sshd-geoip-filter.sh` to countries that you want to allow ssh from, separated by space (if more than 1), in uppercase ISO country codes (e.g. `SG` for Singapore).

```bash
$ sudo nano /usr/local/bin/ssh-geoip-filter.sh
```

```bash
4: # UPPERCASE space-separated ISO country codes to ACCEPT
5: ALLOW_COUNTRIES="SG"
```

5. Update `/etc/hosts.allow` & `/etc/hosts.deny`

```bash
sudo nano /etc/hosts.deny
# Add in this line:
sshd: ALL

sudo nano /etc/hosts.allow
# Add in this line:
sshd: ALL: aclexec /usr/local/bin/ssh-geoip-filter.sh %a
```

- Using aclexec in hosts.allow will allow the sshd service to take into account the exit code and abort connection attempts.

6. Setup Crontab to run geoipupdate periodically:

```bash
# Setup crontab as sudo
$ sudo crontab -e
```

```bash
# Add in the lines below, change the timezone and schedule according to your preference (Use https://crontab.guru to get the schedule)
# Disable mailing (Optional, remove MAILTO="" to enable mailing)
MAILTO=""

# CRON TIMEZONE (Optional, change to your preferred timezone)
CRON_TZ=Asia/Singapore

# Update Maxmind GeoIP2 Database at 4am every thursday & saturday, logs to a file
0 4 * * 4,6 /usr/bin/geoipupdate -v >> /var/log/cron.log 2>&1
```

## Compatible Operating Systems

Tested on Ubuntu 22.04 and Debian 11, should work on other similar linux systems running sshd.

## TODO

- [ ] Create a installation script to automate the installation process.
- [ ] Add support to edit the 'ALLOW_COUNTRIES' by user in installation script.

## Acknowledgements <a name = "acknowledgements"></a>

- [CristianCantoro's ssh-geoip-filter](https://github.com/CristianCantoro/ssh-geoip-filter)
- [Ralph Slooten at axllent.org](https://www.axllent.org/docs/view/ssh-geoip/)
- [Ryan Harg at blog.reinhard.codes](https://blog.reinhard.codes/2023/04/02/restricting-access-to-ssh-using-fail2ban-and-geoip/)
