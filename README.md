BCK120 a été penser de manière entièrement modulaire, vous pouvez les actives selon vos besoins.
Tous les modules fonctionnent de manière indépendante.

- > Ce script permet :

 - > RSYNC
 - >  - Sauvegarde et Synchronise des 'dossiers/fichiers'
 - >  - Sauvegarde des 'dossiers/fichiers' supprimé de la source dans un répertoire incrémentielle.
 - >  - L'exclusion ou l'inclusion de 'dossiers/fichiers'
 - > SQL
 - >  - Création de dump :
 - >     METHODE 1
 - >   		- Création de fichier dump (.sql) des bases de données (pouvant être définis).
 - >   		- Création d'un fichier unique contenant l'ensemble des bases de données (pouvant être définis).
 - >      METHODE 2 
 - >        - Sauvegarde du dossier 'lib' de MySQL, afin d'optimiser la restauration du system MySQL
 - >
 - >   - Possibilité de compresser les données SQL dans divers format (TARGZ, BZIP2, ..)
 - > EXTRA
 - >   - Destiné à faire des sauvegardes des 'dossiers/fichiers' en dehors de la sauvegarde general.
 - >     	Très pratique pour faire une copie des fichiers de configuration.
 - > NOTIFICATION
 - >   - Envoi d'un mail de notification avec en copie le rapport.
 - >   - Possibilité d'envoyer le rapport uniquement en cas d'erreur.
 - > ROTATION
 - >   - Choix du type de Rotation :
 - >   -  - Suppression ou Archivage des sauvegardes
 - >   - Choix de la durée de la rotation
 - >   - Choix du ou des modules (RSYNC,SQL,ect ..), devant être prit en compte lors de la rotation.
 - > NETTOYAGE 
 - > 	 - Suppression des dossiers vides genrer par BCK120.
 - > 	    le nettoyage sera automatiquement appliqué aux modules activé (RSYNC, SQL, EXTRA).
 - >	 Explication :
 - >	A chaque lancement du script et suivant les modules que vous avez activez, le script genère des dossiers
 - >   ou seront entreposé les fichiers supprimés, etc. ...
 - >  Si ces dossiers nouvellement créé ne sont pas utilisé (exemple : vous n'avez supprimé aucun 'fichier/dossier'),
 - >	 ces mêmes dossiers ne seront pas automatiquement supprimés, donc au bout de n mois,
 - >   vous risquerez vite d'être encombré de dossier qui vous ne vous serviront peux être jamais ....
 - > 	Activé, par Défaut (et bien pratique !!)

----------------------------------------------------------------------
Documentation sur l'exclusion et l'inclusion de fichier via Rsync

IMPORTANT !!! :

	 - > Lors du premier lancement du backup les fichiers personnalisé d'exclusion n'existe pas encore.
	 - > Cependant vous pouvez inserer vos INCLU/EXCLU dans les fichiers
	 - > < sample_exclusion && sample_inclusion >
	 - > Les infos renseignées dans les fichiers samples seront automatiquement transféré dans des fichiers
	 - > qui porteront le nom de la sauvegarde. 
		
	Fichier concerné : sample_exlusion & sample_inclusion
	
	Exemple pour insérer des exclusions/inclusions dans '/var/www/home/120'
	
	Voici un exemple de syntaxe : (vous trouvez exemple de fichier dans 'sample_exlusion'
	
	/image : inclure n'importe quel répertoire nommé image, a la RACINE de /var/www/home/120
	**/image : inclure n'importe quel répertoire nommé 'image' hors RACINE de /var/www/home/120/
	/image/**/tmp : inclure n'importe quel répertoire nommé 'tmp' situé dans le sous répertoire /tmp
	*.tmp : inclure tous les fichiers se terminant par '.tmp'
	Thumbs.db : inclure tous les fichiers nommé 'Thumbs.db'
	
	!! Sautez une ligne aprés chaque exclusion !!
