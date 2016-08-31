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
# 22/05/2010 Ajout le support over ssh pour rsync
# 25/06/2010 Début d'ajout des diff version du dossier backup to rsync
VER='0.20';
#************************************************#
#                   BCK120 v1.0                  #
#           written by Candir Vincent            #
#           Contact : 120@caledonien.org         #
#                July 18, 2007                   #
#                                                #
#       Script Avancé de Sauvegarde Linux        #
#************************************************#
#120 18/05/2007
#
# -- > La documentation se trouve dans "INSTALL, DOC/README & DOC/FAQ"

#################################################################
#             VOICI LES TROIS ETAPES :                          #
# ------------------------------------------------------------- #
# > ETAPE 1 -- > Activation des modules.                        #
# > ETAPE 2 -- > Paramêtres globaux (nom du backup, ....)       #
# > ETAPE 3 -- > Configuration des modules.                     #
# ------------------------------------------------------------- #
#################################################################

					## C'est partie :) ##

#################################################################
# ------------ > ETAPE 1 -- > Activation des modules.           #
# --------------------------------------------------------------#
# Afin d'initialiser l'environnement de la sauvegarde,
# n'activez aucun module lors du premier lancement
# --------------------------------------------------------------#
# Si vous souhaitez activer un module, indiquez
# 				TRUE sinon FALSE
# - > Nom du Backup
BCK_NAME="WAM-OVH";

#-- MODULES
# - > Synchronisation avec RSYNC ('fichiers/dossiers')
RSYNC="TRUE";
# - > Sauvegarde de vos 'fichiers/dossiers'.
EXTRA="FALSE";
# - > Sauvegarde MySQL
SQL="TRUE";
# - > Choix de l'ordre de lancement des modules.
# - > Défaut : (RSYNC EXTRA SQL)

ORDRE_LOAD=(SQL RSYNC EXTRA ROTATION STATS_SERVER);

#-- OUTILS
# Permet d'afficher des logs complets
# Si FALSE : alors uniquement les logs des modules seront affichés
FULL_LOG="TRUE";
# - > Permet d'afficher les paramètres de la sauvegarde dans le log.
SHOW_STATUS="TRUE";

# - > Permet d'afficher le rapport (dans le shell) à la fin du traitement.
DEBUG="TRUE";

# Est-ce que le lancement du script doit comprendre un parametre ?
ARG_SCRIPT_1_OBLIGATOIRE="FALSE";
ARG_SCRIPT_1=;

# - > Notification par mail :
# - > TRUE : Envoi du mail automatiquement à la fin du traitement
# - > FALSE : Désactive la notification.
# - > ONLY_IF_ERROR : Envoi du mail uniquement en cas d'erreurs.
NOTIF_MAIL="TRUE"; # Défaut : TRUE

ROTATION="FALSE"; # - > Active la rotation/suppression des données après un certain délai.
STATS_SERVER="TRUE";   # - > Permet d'avoir des stats du serveur (HDD FREE, MEM FREE, ect ...)

# - > Permet de lancer un backup uniquement s'il y a suffisamment d'espace disque.
# - > Exemple : MIN_HDD_FREE=10, signifie que l'espace disque doit être supèrieur à 10% pour démarrer
MIN_HDD_FREE=3;

# - > Souhaitez-vous qu'apparaisse dans les logs les password ?
SHOW_PASSWORD_LOG="TRUE";

# Synchroniser l'horloge system.
# -- > Serveur NTP (exemple : 2.oceania.pool.ntp.org)
# -- > Pour trouver un serveur dans votre zone : http://www.pool.ntp.org/
# - Le binaire < ntpdate >, doit être installé
SRV_SYNC_NTP_TIME="cdns.ovh.net";



#####################################################################
# ------------ > ETAPE 2 -- > Init. des paramètres de la sauvegarde #
#####################################################################

# - > Répertoire racine des sauvegardes
# - > !!!  <> Les espaces seront automatiquement remplacés par des < _ >
# - > Ex : "/BCK120 TEST" devient "/BCK120_TEST"
VAR_CHROOT="/data/BCK120";

# - > Chroot de BCK120
VAR_BCK_CHROOT="/data/bck120";

# - > Est ce que < VAR_CHROOT >, est un lecteur réseau ?
# - > Très pratique lors de montage d'une source externe (SMB,NFS,...)
# - > Si le lecteur réseau n'est pas trouvé en tant que dossier monté la sauvegarde sera interrompu.
VAR_CHROOT_MOUNT="FALSE";
ARG_SCRIPT_MOUNT=;
# Script de montage des lecteurs réseaux
#MOUNT_SHARE_SCRIPT="${VAR_BCK_CHROOT}/plugins/mount/mount_nasnea01.sh"

# PRE/POST de traitement

# - > Indiquer ici l'emplacement de vos scripts, ils seront lancés avant et après le backup
#PRE_TRAITEMENT="/home/caledonien/Bureau/SCRIPT/bck120/plugins/sync_dossier.sh bureau";
POST_TRAITEMENT=(/root/sync_bck.sh);

# - > Interrompre le backup si la valeur de retour est différente de zéro
STOP_SI_RETURN_FALSE='TRUE' # Défaut : TRUE

# - > Permet de conserver x versions complètes des dossiers à sauvegarder
NBR_VERSION=1
PREFIX_VERSION="volume";

#ne pas modifier
source "${VAR_BCK_CHROOT}/lib-bash/function.sh"; if [ ${?} != 0 ]; then echo "DIE !! Probleme de chargement du fishier '${VAR_BCK_CHROOT}/lib-bash/function.sh'"; exit 1; fi; trap 'KILLBCK' 2; autoload_conf "${VAR_BCK_CHROOT}/init/init-start.sh";
#ne pas modifier

#########################################################
# ------------ > ETAPE 3 -- > Configuration des modules.#
#########################################################

#################################################################################
# ------------------------------------------------------------------------------#
# ~~~~~~~~ [ RSYNC ] ~~~~~~ > Synchronisation avec RSYNC ('fichiers/dossiers')  #
# ------------------------------------------------------------------------------#
#################################################################################

if [ "${RSYNC}" == "TRUE" ]
then
 # -- > Mode simulation (rien ne sera sauvegardé)
 SIMULATION_RSYNC="FALSE";

 # - > Source a sauvegarder
 # - > Exemple : BACKUP_FROM=(/home/ '/usr/mon dossier' /etc root@<IP>:/dossier/distant );
 BACKUP_FROM=(
    /var/www/
 );

 # -> Destination des sauvegardes SECONDAIRE
 # -> La destination par défaut est le dossier VAR_CHROOT (que vous avez renseigné plus haut)
 # -> Vous pouvez indiquer plusieurs destinations
 # -> Exemple : BACKUP_TO_BIS=(/home/usr '/mnt/ma_destination' root@< IP >:/dossier/distant)

 # - > Limiter la bande passante en kb/s
 BWLIMIT=;

 # Active ou désactive les fichiers d'exclusions
 INCLU_EXCLU="TRUE" # - > Défaut : TRUE
 # - > FICHIERS EXCLUSION / INCLUSION
 # - > Indiquez l'emplacement des fichiers
 # - > Ces fichiers seront automatiquement créés lors du premier lancement, dans < CONF-USER/NOM_DU_BACKUP-(exclusion/inclusion) >
 EXCLUSION_RSYNC="";
 INCLUSION_RSYNC="";

 # Permet d'exclure un fichier en tant qu'argument au script
 # Exemple : < ./bck120.sh *.pst >
 # EXCLUSION_PERSO='*.pst'
 EXCLUSION_PERSO='cache'

 # - > Option de la commande RSYNC (hors "in/exclusions")
 # - > D'autres options interessantes (pour plus d'info <  >)
 # --perms                 preserve permissions
 # --times                 preserve times
 # --size-only             skip files that match in size
 # --progress              show progress during transfer
 # --password-file=FILE    read password from FILE
 # --force                 force deletion of directories even if not empty
 # voir < man rsync >
 OPTION_RSYNC='-h -avz --stats';  # Défaut : --stats -rhuvzlO

 # - > Deux mécanismes de synchronisation
 # - > STANDARD = Comparaison de date
 # - > CHECKSUM = Exécute un checksum entre la source et la destination (plus lent)
 # - > !! ATTENTION !! Si vous passez d'un mode à un autre (Défaut ou CHECKSUM)
 # - > !! ATTENTION !! Léintégralité des fichiers seront à nouveau sauvegardés, car leurs intégrités n'est plus la même !!
 TYPE_ANALYSE_RSYNC="STANDARD"; # - > Défaut : STANDARD

 # - > Si TRUE les fichiers renseignés dans les exclusions seront supprimés du backup.
 # - > A noter que si < BACKUP_FROM_OVER_SSH > est TRUE
 # - > 	 < DELETE_EXCLUDED > sera automatiquement désactivé (sécurité)
 DELETE_EXCLUDED="TRUE"; # - > Défaut : FALSE

 # - > Permet de sauvegarder les éléments qui ne sont plus présents dans la source.
 BACKUP_DELETE_FILES="TRUE"; # - > Défaut : TRUE

 # - > Nom du dossier des éléments supprimés.
 ## !! Attention, le nom de ce dossier sera automatiquement exclu des sauvegardes
 BACKUP_DELETE_FILES_FOLDER_NAME=""; # - > Défaut : BCK120_RECYCLE_BIN

 # DEBUG
 # - > Permet d'afficher le détails des commandes exécutés.
 SHOW_OPTIONS_RSYNC="FALSE";
 DEBUG_RSYNC="FALSE"
fi

#######################################################################
# --------------------------------------------------------------------#
# ~~~~~~~~ [ EXTRA ] ~~~~~~ > Sauvegarde de vos 'fichiers/dossiers'.  #
# --------------------------------------------------------------------#
#######################################################################

if [ "${EXTRA}" == "TRUE" ]
then
	# exclure les fichiers cfv des archives
	# - > Indiquez les 'fichiers / dossiers' à sauvegarder.
	array_extra=(/home/bck120);

	# - > Défaut  : FALSE
 	COMPRESSION_EXTRA="TRUE";

	if [ "${COMPRESSION_EXTRA}" == "TRUE" ]
	then
		# Les formats supportés sont : TARGZ, BZIP2, P7ZIP
		# - > Défaut  : TARGZ
		FORMAT_COMPRESSION_EXTRA="TARGZ";

		# - > Permet de compresser les éléments de < array_extra > dans un même fichier d'archive.
		# - > Défaut  : TRUE
		EXTRA_COMPRESSION_COMMUN="FALSE";

		# Permet de protéger les archives avec un password
		# !! UNIQUEMENT COMPATIBLE AVEC 7ZIP !!
		PASSWORD_PROTECT='TRUE'
		if [ "${PASSWORD_PROTECT}" == "TRUE" ] && [ "${FORMAT_COMPRESSION_EXTRA}" == "TRUE" ]
		then
			SET_PASSWORD='< PASSWORD >';
		fi

		DEBUG_COMPRESSION="FALSE"
	fi

	# Permet de créer des fichiers de vérification d'intégrité.
	CREATION_CHECKSUM="TRUE"

	if [ "${CREATION_CHECKSUM}" == "TRUE" ]
	then

		# Afin de réaliser les checksum, vous devez installer le paquet < md5deep >
		# Pour cela, utiliser votre gestionnaire de paquet
		# ex : sudo apt-get install md5depp, yum install md5deep (depot rpmforge), ...
		# Plus d'info : http://md5deep.sourceforge.net/

		CHECKSUM_COMPRESSION="FALSE"; # - > Défaut  : FALSE

		# Les formats supportés sont : TARGZ, BZIP2, P7ZIP
		# - > Défaut  : TARGZ
		FORMAT_CHECKSUM_COMPRESSION="P7ZIP";

		DEBUG_CHECKSUM="FALSE"
	fi

	DEBUG_EXTRA="FALSE";
fi

#######################################################################
# --------------------------------------------------------------------#
# ~~~~~~~~ [ SQL ] ~~~~~~ > Sauvegarde des bases de données           #
# --------------------------------------------------------------------#
#######################################################################

if [ "${SQL}" == "TRUE" ]
then
	# - > Pour Sauvegarder MySQL, vous avez deux possibilités :
	# - > METHODE_1 -- > Création d'un fichier DUMP (.sql) personnalisé.
	# - > METHODE_2 -- > Sauvegarde du dossier '/var/lib/mysql'
	# 		!!! METHODE_2, ne fonctionne uniquement en local
	#     !!! Utilisez RSYNC pour synchroniser des dossiers distants (via ssh)

	# - > Les deux méthodes peuvent être utilisés en méme temps.

	METHODE_1="TRUE";
	METHODE_2="FALSE";

	if [ ${METHODE_1} == "TRUE" ]
	then

	  # - > Identification MySql
	  SQL_HOST="localhost"; # - > Défaut  : localhost
	  SQL_LOGIN="root";
	  SQL_PASSWORD="< SQL_PASSWORD >";
	  OPTION_MYSQLDUMP="--opt --compress --extended-insert --complete-insert --port=3306";

		# - > Comment sauvegarder entièrement MySQL ?
		# - > SQL_DATABASE=(all)
		# - > Comment sauvegarder uniquement certaine DB ?
		# - > SQL_DATABASE=(db1 db2 db3 ..);
		SQL_DATABASE=(wamblog 120db);

		# - > Comment obtenir un fichier dump unique ?
		# - > Exemple, si vous avez 5 DB et que vous souhaitez obtenir 5 fichiers SQL
		# - >  Indiquez FALSE à SQL_DUMP_COMMUN, sinon TRUE
		# - > ATTENTION,  si SQL_DUMP_COMMUN=TRUE et qu'une erreur est détectée, l'opération sera interrompu.

		SQL_DUMP_COMMUN="FALSE"; # - > Défaut  : FALSE
	fi

	if [ ${METHODE_2} == "TRUE" ]
	then
		# - > !!!! Permet d'étre certain que les bases soient disponible pour la sauvegarde.
		# - > !!!! ATTENTION LE SERVEUR MYSQL SERA MOMENATEMENT INTERROMPU!!!!

		STOPSQL="TRUE"; # - > Défaut  : FALSE

		# - > Path du fichier INIT Mysql
		SQL_PATH_INIT="/etc/init.d/mysqld";

		# - > Path du dossier LIB de MySQL
		PATH_LIB_SQL="/var/lib/mysql";
	fi

	# - > Compression des données SQL
	# - > Défaut  : TRUE
	COMPRESSION_METHODE_1="TRUE";
        COMPRESSION_METHODE_2="FALSE";

	# Les formats supportés sont : TARGZ, BZIP2, P7ZIP
	# P7ZIP doit étre installé (http://www.7-zip.org/download.html)
	# - > Défaut  : TARGZ
	FORMAT_COMPRESSION_SQL="TARGZ";

	# Permet de créer des fichiers de vérification d'intégrité.
	CREATION_CHECKSUM="TRUE"

	if [ "${CREATION_CHECKSUM}" == "TRUE" ]
	then

		CHECKSUM_COMPRESSION="FALSE"; # - > Défaut  : FALSE

		# Les formats supportés sont : TARGZ, BZIP2, P7ZIP
		FORMAT_CHECKSUM_COMPRESSION="P7ZIP"; # - > Défaut  : TARGZ

		DEBUG_CHECKSUM="FALSE"
	fi


	# - > Permet d'afficher le détail des commandes exécutées.
	DEBUG_SQL="FALSE"
fi

##########################################################################################
##########################################################################################
  		    ## CONFIGURATION DES STATS SERVEURS ##
##########################################################################################
##########################################################################################

if [ "${STATS_SERVER}" == "TRUE" ]
then
	SHOW_HOST_INFO="TRUE"
	SHOW_MEM_INFO="TRUE"
	SHOW_HDD_INFO="FALSE"
	SHOW_SPACE_INFO="FALSE"

	if [ ${SHOW_SPACE_INFO} == "TRUE" ]
	then
		SHOW_HDD_INFO=(${VAR_BCK_CHROOT} '/BCK120-NOUMEA' '/home');
		SHOW_HDD_INFO_ALARME=(20 30 60);

		SHOW_FOLDER_INFO=("${VAR_BCK_CHROOT}");
	fi
	# - > Génération de l'historique des sauvegardes en fonction des fichiers log
	NBR_JOURS_historique=(30 90);
fi

##########################################################################################
##########################################################################################
  		    ## CONFIGURATION DES NOTIFICATIONS ##
##########################################################################################
##########################################################################################

# - > !!! Si vous n'activez pas la notification
# - > !! Vous ne recevrez aucune notification en cas de probleme majeur !!
# - > !! Conseil, Activez l'option au minimum NOTIF_ONLY_IF_ERROR !!!

if [ "${NOTIF_MAIL}" != "FALSE" ]
then
  #MAIL_TO="120@caledonien.org";
 # MAIL_TO="log@sofinor.nc";
 	MAIL_TO="120@dev.nc";

	MAIL_SUJET="[BCK120] -> Rapport de la Sauvegarde ${BCK_NAME}";

	# - > SI TRUE, alors le log sera compressé et transmit comme une pièce jointe.
	# - > SINON il sera affiché dans le mail.
	PIECE_JOINTE_LOG="FALSE"

	COMPRESSION_PJ="FALSE"; # - > Défaut  : TRUE

	DEBUG_NOTIF_MAIL="FALSE"

fi

##########################################################################################
##########################################################################################
  		    ## CONFIGURATION ROTATION ##
##########################################################################################
##########################################################################################

if [ "${ROTATION}" == "TRUE" ]
then
	# - > Nombre de jour ou seront conservé les "fichiers / dossiers".
	NBR_JOUR_ROTATION=90;

	# - > Deux SOLUTIONS :
	# - >   SUPPRESSION = Supprime les 'fichiers/dossiers' sauvegardés de plus de n jours.
	# - >   ARCHIVAGE = Copie les 'fichiers/dossiers' vieux de plus de n jours dans un dossier d'archivage.

	TYPE_ROTATION="SUPPRESSION"; # - > Défaut  : ARCHIVAGE

	# - > Indiquez les modules que vous souhaitez intégrer lors de la rotation.
	# - > Si vous indiquez LOG dans array_rotation, vos historiques en seront faussés
  # - > Car il se base sur les fichiers log

	array_Rotation=("EXTRA" "SQL" "RSYNC");

	# Jusqu'a quel niveau voulez vous effectuer la recherche ?
	# Exemple  : /BCK120/NOM_DU_BACKUP/NOM_DU_MODULE/ANNEE/MOIS/JOUR
	# MAXDEPTH 1 = NOM_DU_MODULE/ANNEE
	# MAXDEPTH 2 = NOM_DU_MODULE/ANNEE/MOIS
	# MAXDEPTH 3 = NOM_DU_MODULE/ANNEE/MOIS/JOUR
	# - > Défaut  : 3
	MAXDEPTH=3

	if [ "${TYPE_ROTATION}" == "ARCHIVAGE" ]
	then
		# -> Destination des 'fichiers/dossiers' archivés
		DOSSIER_ROTATION_ARCHIVAGE="$VAR_ROOT/ARCHIVAGE";

		# -> Compression des archives ?
		# - > Défaut: FALSE
		COMPRESSION_ROTATION="TRUE";
		if [ "${COMPRESSION_ROTATION}" == "TRUE" ]
		then
			# - > Défaut  : TARGZ
			FORMAT_COMPRESSION_ROTATION="P7ZIP";
		fi

		# -> Si < COPIE >, les fichiers seront copié de la source (ATTENTION !!
		# -> Si < MOVE >, les fichiers seront déplacés de la source

		# - > Défaut  : COPIE
		TYPE_ARCHIVAGE="COPIE";
	fi

	# - > Permet d'afficher les commandes exécutés par la ROTATION.
	DEBUG_ROTATION="TRUE";
fi


######################################################
# 					!!! FIN DE LA CONFIGURATION !!					 #
######################################################
#ne pas modifier
autoload_conf "${VAR_BCK_CHROOT}/init/status.sh" || status 3 "Probleme de chargement du fichier < ${VAR_BCK_CHROOT}/init/status.sh >" ;
autoload_conf "${VAR_BCK_CHROOT}/init/init-end.sh"
