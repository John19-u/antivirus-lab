# Simple Antivirus Daemon

This project is a small antivirus made with shell scripts. The daemon checks a
folder every few seconds, and if something changed it scans the files. Bad files
are moved to a quarantine folder. There is also a restore tool to get back files
that were flagged by mistake.

## Folder hierarchy

```
antivirus-lab/
    antivirusd.sh       - the antivirus daemon (Part 1)
    restore.sh          - restore / delete tool (Part 2)
    antivirus-cron.sh   - the cron version (Bonus 1)
    Makefile            - targets: run, restore, prebuild, clean
    README.md
    test_dir/           - folder that is monitored (made by make)
    malicious_dir/      - quarantine folder (made by make)
    directory-info.last - old ls -l output (made when running)
    directory-info.new  - new ls -l output (made when running)
    whitelist.txt       - restored files names (made by restore.sh)
```

The monitored folder must have only files in it, no subfolders.

## Prerequisites

Everything used (bash, ls, diff, grep, cp, mv, rm) is already on Ubuntu except
maybe `make` and `cron`. To install them:

```
sudo apt update
sudo apt install make cron
```

## How to run

1. Open a terminal in the project folder.
2. Make the scripts executable (only needed if you run them directly):
   `chmod +x antivirusd.sh restore.sh antivirus-cron.sh`
3. Put some files in `test_dir/`.
4. Start the antivirus:
   ```
   make run
   ```
   This first creates `malicious_dir` (pre-build step) and then runs
   `antivirusd.sh test_dir malicious_dir 5`. You can change the values like this:
   `make run dir=my_folder malicious_dir=quarantine interval=10`.
   Press Ctrl+C to stop it.
5. To review the quarantined files (do not run it at the same time as the
   daemon, stop the daemon first):
   ```
   make restore
   ```
   - Type the number of a file.
   - Type 1 to restore it, 2 to delete it permanently, 3 to go back to the list.
   - Type 0 in the list to quit.
6. `make clean` deletes the info files and the whitelist.

## Where the flagged lists are

At the top of `antivirusd.sh` (and also in `antivirus-cron.sh`):

```
extensions="exe bat vbs scr ps1"
keywords="virus trojan malware worm ransomware"
```

## Whitelist (Bonus 2)

- When the user chooses option 1 in `restore.sh`, the file name is added as a new
  line at the end of `whitelist.txt`.
- During a scan, before checking a file, the daemon looks for the file name in
  `whitelist.txt` using `grep -qxF`. If it is found the file is skipped, even if
  it has a bad extension or keyword.
- The whitelist is a normal file so it is still there when the daemon is stopped
  and started again.

## Cron job (Bonus 1)

`antivirus-cron.sh dir malicious_dir` does the same scan as the daemon but only
once and then exits, so cron can run it.

### Before starting
- Cron must be installed and running:
  ```
  sudo apt install cron
  sudo systemctl enable --now cron
  systemctl status cron
  ```
- The scripts must be executable (`chmod +x antivirus-cron.sh`).
- Use full paths for the folders because cron does not start in the project
  folder. Use `pwd` to get the full path.

### Steps
1. Run `crontab -e` and pick an editor if it asks.
2. Cron cannot do seconds, so to run every minute at second 23 we run every
   minute and wait 23 seconds first. Add this line (change the paths):
   ```
   * * * * * sleep 23; /home/user/antivirus-lab/antivirus-cron.sh /home/user/antivirus-lab/test_dir /home/user/antivirus-lab/malicious_dir >> /home/user/antivirus-lab/cron.log 2>&1
   ```
3. Save and close the editor.
4. Check it was saved with `crontab -l`.
5. Look at `cron.log` after a minute to see the output.
6. To stop it, run `crontab -e` again and delete the line.

### 3rd Friday of the month at 12:31 am

The 3rd Friday is always between the 15th and the 21st. In cron if you write both
the day of month and the day of week it runs when either one matches, so
`31 0 15-21 * 5` would be wrong (it runs every Friday and every day 15-21).
Instead the day of week is 5 and the date is checked in the command (the `%` must
have a backslash in crontab):

```
31 0 * * 5 [ "$(date +\%d)" -ge 15 ] && [ "$(date +\%d)" -le 21 ] && /home/user/antivirus-lab/antivirus-cron.sh /home/user/antivirus-lab/test_dir /home/user/antivirus-lab/malicious_dir >> /home/user/antivirus-lab/cron.log 2>&1
```
