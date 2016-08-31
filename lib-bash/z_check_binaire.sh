# - > EMPLACEMENT DES FICHIERS BINAIRES
liste_binaire=('which' 'date' 'df' 'mv' 'cp' 'rm' 'tar' 'cat' 'sed' 'mkdir' 'ls' 'mount' 'umount' 'grep' 'sort' 'awk' 'touch' 'hostname' 'du' 'free' 'uname' 'uptime' 'test' 'echo' 'basename' 'dirname' 'whoami' 'ssh')
i=0;
while [ $i -lt ${#liste_binaire[*]} ];
do
	test_fichier_binaire "${liste_binaire[${i}]}";
	let i++
done

CHROOT_BIN_DATE=`/usr/bin/which date` &>/dev/null;
CHROOT_BIN_DF=`/usr/bin/which df` &>/dev/null;
CHROOT_BIN_DU=`/usr/bin/which du` &>/dev/null;
CHROOT_BIN_MOUNT=`/usr/bin/which mount` &>/dev/null;
CHROOT_BIN_UMOUNT=`/usr/bin/which umount` &>/dev/null;
CHROOT_BIN_TOUCH=`/usr/bin/which touch` &>/dev/null;
CHROOT_BIN_HOSTNAME=`/usr/bin/which hostname` &>/dev/null;
CHROOT_BIN_BIN_DU=`/usr/bin/which du` &>/dev/null;
CHROOT_BIN_FREE=`/usr/bin/which free` &>/dev/null;
CHROOT_BIN_UNAME=`/usr/bin/which uname` &>/dev/null;
CHROOT_BIN_UPTIME=`/usr/bin/which uptime` &>/dev/null;


CHROOT_BIN_CAT=`/usr/bin/which cat` &>/dev/null;
CHROOT_BIN_RM=`/usr/bin/which rm` &>/dev/null;
CHROOT_BIN_AWK=`/usr/bin/which awk` &>/dev/null;
CHROOT_BIN_SED=`/usr/bin/which sed` &>/dev/null;

CHROOT_BIN_MKDIR=`/usr/bin/which mkdir` &>/dev/null;
CHROOT_BIN_MV=`/usr/bin/which mv` &>/dev/null;
CHROOT_BIN_CP=`/usr/bin/which cp` &>/dev/null;

CHROOT_BIN_DIRNAME=`/usr/bin/which dirname` &>/dev/null;
CHROOT_BIN_BASENAME=`/usr/bin/which basename` &>/dev/null;

CHROOT_BIN_TAR=`/usr/bin/which tar` &>/dev/null;
CHROOT_BIN_BZIP2=`/usr/bin/which bzip2` &>/dev/null;
CHROOT_BIN_WHOAMI=`/usr/bin/which whoami` &>/dev/null;
CHROOT_BIN_SSH=`/usr/bin/which ssh` &>/dev/null;

