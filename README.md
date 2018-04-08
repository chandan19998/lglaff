# LGLAF.py
LGLAF.py is a utility for communication with LG devices in Download Mode. This
allows you to execute arbitrary shell commands on a LG phone as root.

Contents of this repository:

 - [auth.py](auth.py) - challenge/response on newer devices (see below).
 - [lglaf.py](lglaf.py) - main script for communication (see below).
 - [partitions.py](partitions.py) - manage (list / read / write) partitions.
 - [extract-partitions.py](extract-partitions.py) - Dump all partitions
   (convenience script that uses partitions.py under the hood). By default the
   largest partitions (system, cache, cust, userdata) are not dumped though.
   This can be changed with the `--max-size` option.
 - [dump-file.py](dump-file.py) - dumps a regular file from device.
 - [protocol.md](protocol.md) - Protocol documentation.
 - [lglaf.lua](lglaf.lua) - Wireshark dissector for LG LAF protocol.
 - [scripts/](scripts/) - Miscellaneous scripts.

## Requirements
LGLAF.py depends on:

 - Python 3: https://www.python.org/
 - (Windows) LG driver,
   [LGMobileDriver\_WHQL\_Ver\_4.0.3.exe](http://18d5a.wpc.azureedge.net/8018D5A/tool/dn/downloader.dev?fileKey=UW00120120425)
   (12986920 bytes,
   sha256sum: 86e893b7f5da7f7d2656d9ce2563f082271983bb63903d0ed5cb279c560db459)
 - PyUSB: pip install PyUSB (use pip3 on Linux)
 - cryptography: pip install cryptography (use pip3 on Linux)
 - cryptdome: pip install cryptdome (use pip3 on Linux)

On Linux, you must also install
[rules.d/42-usb-lglaf.rules](rules.d/42-usb-lglaf.rules) to `/etc/udev/rules.d/`
in order to give the regular user access to the USB device.

Tested with:

 - LG G3 (D855) on 64-bit Arch Linux (Python 3.5.1, pyusb 1.0.0b2, libusb 1.0.20)
 - LG G3 (D855) on 32-bit Windows XP (Python 3.4.4, LG drivers).
 - LG G2 (VS985).
 - LG G4 (VS986) on Linux (Python 3.5) and Windows.
 - LG G4 (H810,H811,H812,H815) on 64 bit Arch Linux | [FWUL](https://tinyurl.com/FWULatXDA) (Python 2.7.13, pyusb 1.0.0-5, libusb 1.0.21-2)
 - LG V20 (H918, H910)
 - LG V10 (H901)
 - LG G6 (H872)
If you don't install these rules, you will have to use sudo.

## Usage
This tool provides an interactive shell where you can execute commands in
Download Mode. To enter this mode:

 1. Power off the phone.
 2. Connect the phone to a computer using a USB cable.
 3. Press and hold **Volume up**.
 4. Briefly press the power button.
 5. Wait for the **Download mode** screen to appear.
 6. Release keys. You should now see a **Firmware Update** screen.

Now you can issue commands using the interactive shell:

    (venv)[peter@al lglaf]$ python lglaf.py
    LGLAF.py by Peter Wu (https://lekensteyn.nl/lglaf)
    Type a shell command to execute or "exit" to leave.
    # pwd
    /
On current versions of lafd there is a very limited set of commands that you can run:
ls, lsof, lsmod, dmesg, TODO: list the rest


When commands are piped to stdin (or given via `-c`), the prompt is hidden:

 TODO: list new examples 

## Advanced usage
If you know the [protocol](protocol.md), you can send commands directly. Each
request has a command, zero to four arguments and possibly a body. The
`lglaf.py` tool accepts this command:

    ![command] [arguments] [body]

All of these words accept escape sequences such as `\0` (octal escape), `\x00`
(hex), `\n`, `\r` and `\t`. The command must be exactly four bytes, the
arguments and body are optional.

Arguments are comma-separated and must either be four-byte sequences (such as
`\0\1\2\3`) or numbers (such as 0x03020100). If no arguments are given, but a
body is needed, keep two spaces between the command and argument.

Reboot device (command CTRL, arg1 RSET, no body):

    $ ./lglaf.py  --debug -c '!CTRL RSET'
    LGLAF.py: DEBUG: Hello done, proceeding with commands
    LGLAF.py: DEBUG: Header: b'CTRL' b'RSET' b'\0\0\0\0' b'\0\0\0\0' b'\0\0\0\0' b'\0\0\0\0' b'\xc7\xeb\0\0' b'\xbc\xab\xad\xb3'

Execute a shell command (command EXEC, no args, with body):

    $ ./lglaf.py --debug --skip-hello -c '!EXEC  id\0'
    LGLAF.py: DEBUG: Header: b'EXEC' b'\0\0\0\0' b'\0\0\0\0' b'\0\0\0\0' b'\0\0\0\0' b'/\0\0\0' b'\x8dK\0\0' b'\xba\xa7\xba\xbc'
    uid=0(root) gid=0(root) context=u:r:toolbox:s0

## Backing up and flashing partitons
The partitions.py command can be used to backup and restore partitions. For now, in UFS devices, it can only write to /dev/block/sda.

 - $ ./partitions.py --dump recovery.img recovery
 - $ ./partitions.py --restoremisc twrp.img recovery
 - $ ./partitions.py --restoremisc twrp.img laf

On eMMC device, revcovery can be written to directly, on UFS device, TWRP has to be written to laf. 

## License
See the [LICENSE](LICENSE) file for the license (MIT).
