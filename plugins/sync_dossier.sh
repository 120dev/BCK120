#!/bin/bash
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
#
VER='0.2';
#************************************************#
#                  Sync_HDD                      #
#           written by Candir Vincent            #
#           Contact : 120@caledonien.org         #
#                Vendredi 22 mai 2009            #
#                                                #
#       SYNCRONISATION DES DISQUES               #
#************************************************#
#120 22/05/2009
FICHIER_FUNCTION="/cygdrive/c/Users/caledonien/Desktop/Ressources/SCRIPT/bck120/plugins/lib.sh"
SCRIPT_PATH="/cygdrive/c/Users/caledonien/Desktop/Ressources/SCRIPT/bck120/plugins";

if [ -f "${FICHIER_FUNCTION}" ]; then source "${FICHIER_FUNCTION}"; else  echo "DIE !! Problème de chargement du fichier '${FICHIER_FUNCTION}'"; exit 1; fi

# SOURCES
HDD_500_BCK="/cygdrive/h/BCK";
HDD_250="/cygdrive/g/BCK";
HDD_140_EXTERNE_BCK="/cygdrive/w/BCK";

RETURN_ERR=0;
# Permet de ne pas affichier la sortie en couleur (uniquement dans le prompt);
noShellExec="";
#  "${HDD_500_BCK}" "${HDD_140_EXTERNE_BCK}"
BACKUP_TO=("${HDD_500_BCK}" "${HDD_250}");

if [ -z ${1} ]
then
	show_couleurs 'rouge' "photos bureau apps wwwroot";
	kill $$;
fi

####################
# Backup des photos
####################
if [ ${1} == "photos" ] || [ ${1} == "all" ]
then
	titre="Backup des photos";
	BACKUP_FROM=("/cygdrive/d/Photos");
	
	# Exclusions
	chroot_exclusion='/tmp/exclusion_photos.txt';
	echo ".comments" >> ${chroot_exclusion}
	echo "thumbs.db" >> ${chroot_exclusion}
	echo "Thumbs.db" >> ${chroot_exclusion};

	# Backup
	sync_rsync "${BACKUP_FROM}" ${BACKUP_TO} ${chroot_exclusion} "${titre}"
fi

###################
# Backup bu bureau 
###################
if [ ${1} == "bureau" ] || [ ${1} == "all" ]
then
	titre="Backup du bureau";
	BACKUP_FROM=("/cygdrive/c/Users/caledonien/Desktop" "/cygdrive/c/Users/caledonien/Documents/My Games" "/cygdrive/d/Mes Docs");

	# Exclusions
	chroot_exclusion='/tmp/exclusion_bureau.txt';
	echo "*.avi" >> ${chroot_exclusion};
	echo "*.part" >> ${chroot_exclusion};
	echo "*~*" >> ${chroot_exclusion};
	echo "*dtapart*" >> ${chroot_exclusion};
	echo "*.iso" >> ${chroot_exclusion};
	echo 'Divers-Non-RSYNC' >> ${chroot_exclusion};
	echo 'Thumbs.db' >> ${chroot_exclusion};
	echo "CONF-USER" >> ${chroot_exclusion};
	echo "*Cache*" >> ${chroot_exclusion};
	echo "*.wmv" >> ${chroot_exclusion};
	echo "*.flv" >> ${chroot_exclusion};
	echo "*.lnk" >> ${chroot_exclusion};
	echo "*.exe" >> ${chroot_exclusion};

	# Backup
	sync_rsync "${BACKUP_FROM}" ${BACKUP_TO} ${chroot_exclusion} "${titre}" "CALEDONIEN"
fi

##############
# Backup APPS 
##############
if [ ${1} == "apps" ] || [ ${1} == "all" ]
then
	titre="Backup APPS";
	BACKUP_FROM=("/cygdrive/d/Soft deja install" "/cygdrive/d/App");
	# Exclusions
	chroot_exclusion='/tmp/exclusion_apps.txt';
	echo 'Divers-Non-RSYNC' >> ${chroot_exclusion};

	# Backup
	sync_rsync "${BACKUP_FROM}" ${BACKUP_TO} ${chroot_exclusion} "${titre}" "SOFTS"
fi

#################
# Backup WWWROOT
#################
if [ ${1} == "wwwroot" ] || [ ${1} == "all" ]
then
	titre="Backup du WWWROOT (windows)";
	BACKUP_FROM=("/cygdrive/d/WWWROOT/WWWROOT");
	
	# Exclusions
	chroot_exclusion='/tmp/exclusion_wwwroot.txt';
	echo "chroot_upload" >> ${chroot_exclusion}

	# Backup
	sync_rsync "${BACKUP_FROM}" ${BACKUP_TO} ${chroot_exclusion} "${titre}" 'WWWROOT-Win'
fi
