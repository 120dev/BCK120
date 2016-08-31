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
#                                                #
#       Script Avancé de Sauvegarde Linux        #
#************************************************#
#120 03/07/2009
FICHIER_FUNCTION="/home/caledonien/Bureau/SCRIPT/bck120/plugins/lib.sh";
SCRIPT_PATH="/home/caledonien/Bureau/SCRIPT/bck120/plugins";

if [ -f "${FICHIER_FUNCTION}" ]; then source "${FICHIER_FUNCTION}"; else  echo "DIE !! Problème de chargement du fichier '${FICHIER_FUNCTION}'"; exit 1; fi

# SOURCES
HDD_500_BCK="/media/500/BCK";
HDD_300_1_BCK="/media/300.1/BCK";
HDD_300_2_BCK="/media/300.2/BCK";

RETURN_ERR=0;

# Permet de ne pas affichier la sortie en couleur (uniquement dans le prompt);
noShellExec="true";

init_bck ()
{
	echo "-----------------------------------------------------------------------------------------------------------"
	echo "I N I T I A L I S A T I O N. . . . . . . . . ."
	echo "-----------------------------------------------------------------------------------------------------------"
}


while true; do
  choice="$(zenity --width=200 --height=300 --list --column "" --title="--120--" \
  "Photos" \
  "Home caledonien" \
  "Mes Docs" \
  "Apps" \
  "Exit ")" 
 case "${choice}" in

	####################
	# Backup des photos
	####################
	"Photos" )
	{
		init_bck

		titre="Backup des photos";
		BACKUP_FROM=("/media/RAID5/Photos");
	
		# Exclusions
		chroot_exclusion='/tmp/exclusion_photos.txt';
		echo ".comments" >> ${chroot_exclusion}
		echo "thumbs.db" >> ${chroot_exclusion}

		# Backup
		BACKUP_TO=("${HDD_300_1_BCK}" "${HDD_300_2_BCK}" "${HDD_500_BCK}");
		sync_rsync "${BACKUP_FROM}" ${BACKUP_TO} ${chroot_exclusion} "${titre}";
	}| zenity --text-info --title "Backup" --width=600 --height=500
		break;
	;;
	###################
	# Backup bu bureau 
	###################
	"Home caledonien" )
	{
			titre="Backup du bureau";
			BACKUP_FROM=("/home/caledonien/Bureau" "/home/caledonien/.gnome2/nautilus-scripts" "/home/caledonien/.filezilla" "/home/caledonien/.tsclient" "/home/caledonien/.ssh");

			# Exclusions
			chroot_exclusion='/tmp/exclusion_bureau.txt';
			echo "*.avi" >> ${chroot_exclusion};
			echo "*.part" >> ${chroot_exclusion};
			echo "*~*" >> ${chroot_exclusion};
			echo "*dtapart*" >> ${chroot_exclusion};
			echo "*iso" >> ${chroot_exclusion};
			echo 'Divers-Non-RSYNC' >> ${chroot_exclusion};
			echo '*Trash*' >> ${chroot_exclusion};
			echo '*mp3*' >> ${chroot_exclusion};


			# Backup
			BACKUP_TO=("${HDD_300_1_BCK}" "${HDD_300_2_BCK}" "${HDD_500_BCK}");
			sync_rsync "${BACKUP_FROM}" ${BACKUP_TO} ${chroot_exclusion} "${titre}"
		}| zenity --text-info  --title "Backup" --width=850 --height=500; "${SCRIPT_PATH}/gnome_sync_dossier.sh";
		break;
	;;
	#######################
	# Backup mes documents 
	#######################
	"Mes Docs" )
	{
		titre="Backup Mes Documents";
		BACKUP_FROM=("/media/RAID5/Mes Docs");
	
		# Exclusions
		chroot_exclusion='/tmp/exclusion_mes_docs.txt';

		# Backup
		BACKUP_TO=("${HDD_300_1_BCK}" "${HDD_300_2_BCK}" "${HDD_500_BCK}");
		sync_rsync "${BACKUP_FROM}" ${BACKUP_TO} ${chroot_exclusion} "${titre}"
	}| zenity --text-info  --title "Backup" --width=600 --height=500; "${SCRIPT_PATH}/gnome_sync_dossier.sh";
	break;
	;;

	##############
	# Backup APPS 
	##############
	"Apps")
	{
		titre="Backup APPS";
		BACKUP_FROM=(/media/RAID5/App);
	
		# Exclusions
		chroot_exclusion='/tmp/exclusion_apps.txt';
		echo 'Divers-Non-RSYNC' >> ${chroot_exclusion};

		# Backup
		BACKUP_TO=("${HDD_300_1_BCK}" "${HDD_300_2_BCK}" "${HDD_500_BCK}");
		sync_rsync "${BACKUP_FROM}" ${BACKUP_TO} ${chroot_exclusion} "${titre}"
		}| zenity --text-info  --title "Backup" --width=600 --height=500; "${SCRIPT_PATH}/gnome_sync_dossier.sh";
	break;
	;;
	* )
		kill $$
	;;
	esac
done

exit


#################
# Backup WWWROOT
#################
if [ ${1} == "wwwroot" ] || [ ${1} == "all" ]
then
	titre="Backup du WWWROOT (ubuntu)";
	BACKUP_FROM="/var/www";
	
	# Exclusions
	chroot_exclusion='/tmp/exclusion_wwwroot.txt';
	echo "chroot_upload" >> ${chroot_exclusion}

	# Backup
	BACKUP_TO=("${HDD_300_1_BCK}/wwwroot-Linux" "${HDD_300_2_BCK}/wwwroot-Linux" "${HDD_500_BCK}/wwwroot-Linux");
	sync_rsync "${BACKUP_FROM}" ${BACKUP_TO} ${chroot_exclusion} "${titre}"

fi

####################
# Backup SQL BCK120
####################
if [ ${1} == "sql" ] || [ ${1} == "all" ]
then
	titre="Backup du SQL (bck120)";
	BACKUP_FROM="/BCK120/120-HOME/SQL/METHODE_1";
	
	# Exclusions
	chroot_exclusion='/tmp/exclusion_wwwroot.txt';

	# Backup
	BACKUP_TO=("${HDD_300_1_BCK}/SQL_BCK120" "${HDD_300_2_BCK}/SQL_BCK120" "${HDD_500_BCK}/SQL_BCK120");
	sync_rsync "${BACKUP_FROM}" ${BACKUP_TO} ${chroot_exclusion} "${titre}"
	
fi

#################################
# Backup des soft_deja_installes 
#################################
if [ ${1} == "soft_deja_install" ] || [ ${1} == "all" ]
then
	titre="Backup des soft_deja_installes";
	BACKUP_FROM="/media/300.1/Soft deja install";
	
	# Exclusions
	chroot_exclusion='/tmp/exclusion_soft_deja_install.txt';

	# Backup
	BACKUP_TO=("${HDD_300_2_BCK}" "${HDD_500_BCK}");
	sync_rsync "${BACKUP_FROM}" ${BACKUP_TO} ${chroot_exclusion} "${titre}"
fi

exit ${RETURN_ERR};
