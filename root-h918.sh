cd lglaf
echo "Backing up laf"
./partitions.py --dump laf.img laf
./partitions.py --dump laftest.img laf
LAFHASH=`sha256sum laf.img | cut -f1 -d""`
LAFTESTHASH=`sha256sum laftest.img | cut -f1 -d""`
#Compare hashes

#Fail
echo "Hash check failed for laf. You do not have a good backup of laf. Try again."

# Success
echo "laf hash OK!"
echo ""
echo "Backing up misc"
./partitions.py --dump misc.img misc
echo "Flashing TWRP to laf. This will take a few minutes."
echo "When it is finished, your phone will reboot. Enter download mode again,"
echo "and you will have TWRP."
echo "When the phone reboots, you will have to click on Devices / USB and "
echo "pick LG H918 so that the phone is reattached to VirtualBox"
echo "Once you are back in download mode, run ./post-root-h918.sh"
./partitions.py --restoremisc h918-twrp.img carrier
./partitions.py --dump testtwrp.img carrier
dd if=testtwrp.img of=twrptest.img bs=1024 count=24092

echo "Flash done -- verifying"
./partitions.py --dump testtwrp.img laf
sha256sum -c twrp_hash --quiet --strict --warn
if [ $? != 0 ]; then
	echo "HASH FAILED! You need to try again." && rm testtwrp.img && exit
fi
echo "Hash check was OK. Rebooting the phone"
rm testtwrp.img
./lglaf.py -c "!CTRL RSET"
