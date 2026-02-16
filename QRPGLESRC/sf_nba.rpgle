     *******************************************************************************
     * Programme     : SF_NBA.RPGLE
     * Description   : Gestion des joueurs NBA avec sous-fichier (Subfile)
     * Auteur        : [À compléter]
     * Date création : [À compléter]
     *
     * Fonctionnalités principales:
     *   - Affichage de la liste des joueurs NBA dans un sous-fichier
     *   - Filtrage par équipe
     *   - Options disponibles dans le sous-fichier:
     *     2 = Modifier les informations d'un joueur
     *     4 = Supprimer un joueur de la base
     *     5 = Afficher les détails d'un joueur (consultation)
     *   - Touches de fonction:
     *     F3  = Quitter le programme
     *     F5  = Actualiser la liste (réinitialiser le filtre)
     *     F8  = Imprimer la liste complète des joueurs
     *     F22 = Valider la modification (dans l'écran de détail)
     *     F23 = Confirmer la suppression (dans l'écran de détail)
     *
     * Fichiers utilisés:
     *   - E_SFNBA    : Fichier d'affichage (workstation) avec sous-fichier
     *   - JOUEURSNBA : Fichier physique contenant les données des joueurs
     *   - NBAPRTF    : Fichier d'impression pour la liste des joueurs
     *
     * Structure de la base JOUEURSNBA:
     *   - ID          : Identifiant unique du joueur (clé primaire)
     *   - NOM         : Nom de famille du joueur
     *   - PRENOM      : Prénom du joueur
     *   - EQUIPE      : Équipe NBA du joueur
     *   - TAILLE      : Taille du joueur
     *   - AGE         : Âge du joueur
     *   - NOMBR00001  : Nombre de titres remportés
     *******************************************************************************

     ************   DÉCLARATIONS DES FICHIERS ****************
     
     * Fichier écran avec sous-fichier pour afficher la liste des joueurs
     * Le sous-fichier SF01 est contrôlé par le format CTL01
     Fe_sfnba   cf   e             workstn
     F                                     sfile(sf01:rang)
     
     * Fichier physique des joueurs NBA
     * Le format est renommé de JOUEURSNBA en FMTNBA pour faciliter l'utilisation
     Fjoueursnbauf a e           k disk    rename(joueursnba:fmtnba)
     
     * Fichier d'impression pour générer le rapport des joueurs
     fnbaprtf   O    E             PRINTER
     
     ************    PROGRAMME PRINCIPAL   ****************

     ************* DOCUMENTATION DES INDICATEURS ************
     * Les indicateurs (*INxx) sont utilisés pour contrôler l'affichage et le comportement
     *
     * *IN03 = F3 pressée : Sortie du programme
     * *IN05 = F5 pressée : Actualisation de la liste (réinitialisation du filtre)
     * *IN08 = F8 pressée : Impression de la liste
     * *IN22 = F22 pressée : Validation de la modification
     * *IN23 = F23 pressée : Confirmation de la suppression
     * *IN40 = Zones en mode protégé (non modifiables)
     * *IN41 = Affichage de F23 (option suppression active)
     * *IN42 = Affichage de F22 (option modification/affichage active)
     * *IN50 = Contrôle d'affichage du sous-fichier
     * *IN51 = Contrôle d'affichage du sous-fichier (contrôle)
     * *IN52 = Effacement du sous-fichier
     * *IN53 = Indicateur de fin du sous-fichier (*MORE)
     * *IN91 = Fin de fichier lors de l'impression
     * *IN98 = Lecture d'un enregistrement modifié dans le sous-fichier
     * *IN99 = Fin de fichier lors du chargement du sous-fichier
     * *LR   = Last Record : Fin du programme

     * Activation de l'indicateur LR pour indiquer la fin du programme
     c                   seton                                            lr

     * Initialisation de la variable RANG (numéro de ligne dans le sous-fichier)
     * RANG est utilisé pour numéroter les enregistrements dans le sous-fichier
     c                   z-add     *zero         rang              4 0

     ************* BOUCLE PRINCIPALE DU PROGRAMME ************
     * Cette boucle s'exécute tant que F3 n'est pas pressée (*IN03 = '0')
     c                   dow       *in03 = '0'
     
     * Chargement du sous-fichier avec les données des joueurs
     c                   exsr      trt_nba
     
     * Affichage des formats d'écran
     * FMT1 : En-tête avec titre, date, heure et options disponibles
     c                   write     fmt1
     * FMT2 : Pied d'écran avec les touches de fonction
     c                   write     fmt2
     * CTL01 : Format de contrôle du sous-fichier (affichage et saisie)
     c                   exfmt     ctl01
     
     ************* TRAITEMENT DES ENREGISTREMENTS MODIFIÉS ************
     * Lecture des enregistrements du sous-fichier qui ont été modifiés
     * (où l'utilisateur a saisi une option)
     c                   readc     sf01                                   98
     c                   dow       *in98 = '0'
     
     * Réinitialisation des indicateurs de contrôle d'affichage
     c                   setoff                                           40
     c                   setoff                                           41
     c                   setoff                                           42
     
     * Option 5 : Afficher les détails d'un joueur (consultation)
     c                   if        opt = '5'
     c                   seton                                            40
     c                   seton                                            42
     c                   exsr      trt_dsp
     c                   endif
     
     * Option 4 : Supprimer un joueur
     c                   if        opt = '4'
     c                   exsr      trt_del
     c                   endif
     
     * Option 2 : Modifier un joueur
     c                   if        opt = '2'
     c                   exsr      trt_modif
     c                   endif
     
     * Lecture de l'enregistrement modifié suivant dans le sous-fichier
     c                   readc     sf01                                   98
     c                   enddo
     
     * Gestion de la touche F5 : Réinitialisation du filtre
     c                   if        *in05 = '1'
     c                   eval      filtre = ' '
     c                   endif
     
     * Gestion de la touche F8 : Impression de la liste
     c                   if        *in08 = '1'
     c                   exsr      trt_prtf
     c                   endif
     
     * Fin de la boucle principale
     c                   enddo

     *******************************************************************************
     *                          SOUS-ROUTINES
     *******************************************************************************

     *******************************************************************************
     * Sous-routine : TRT_NBA
     * Description  : Chargement du sous-fichier avec la liste des joueurs
     * 
     * Fonctionnement:
     *   1. Efface le sous-fichier existant
     *   2. Lit tous les enregistrements de JOUEURSNBA
     *   3. Filtre par équipe si un filtre est actif
     *   4. Charge les enregistrements dans le sous-fichier SF01
     *   5. Active les indicateurs d'affichage appropriés
     *
     * Variables utilisées:
     *   - RANG    : Compteur pour numéroter les lignes du sous-fichier
     *   - FILTRE  : Nom de l'équipe pour filtrer (ou *BLANKS pour tout afficher)
     *   - ENOM    : Nom du joueur pour affichage dans le sous-fichier
     *   - EEQUIPE : Équipe du joueur pour affichage dans le sous-fichier
     *******************************************************************************
     c     trt_nba       begsr
     
     * Effacement du sous-fichier
     * L'indicateur 52 déclenche l'effacement du sous-fichier
     * Le WRITE sur CTL01 efface le sous-fichier car *IN52 est actif
     c                   seton                                            52
     c                   WRITE     CTL01
     c                   setoff                                           52

     * Réinitialisation du compteur de lignes
     c                   z-add     0             rang
     
     * Positionnement au début du fichier JOUEURSNBA (*LOVAL = valeur la plus basse)
     c     *loval        setll     fmtnba
     
     * Lecture du premier enregistrement
     c                   read      fmtnba                                 99
     
     * Boucle de lecture de tous les enregistrements du fichier
     * Continue tant que *IN99 = '0' (pas de fin de fichier)
     c                   dow       *in99 = '0'
     
     * Application du filtre par équipe
     * Si FILTRE correspond à l'équipe ou si FILTRE est vide (*BLANKS),
     * l'enregistrement est ajouté au sous-fichier
     c                   if        filtre = equipe or filtre = *blanks
     
     * Incrément du compteur de lignes
     c                   add       1             rang
     
     * Préparation des données pour le sous-fichier
     * MOVEL copie les données en alignant à gauche
     c                   movel     nom           enom
     c                   movel     equipe        eequipe
     
     * Écriture de l'enregistrement dans le sous-fichier
     c                   write     sf01
     c                   endif
     
     * Lecture de l'enregistrement suivant
     c                   read      fmtnba                                 99
     c                   enddo
     
     * Activation des indicateurs pour l'affichage du sous-fichier
     * *IN51 = Affichage du contrôle du sous-fichier
     c                   seton                                            51
     
     * Si au moins un enregistrement a été chargé
     c                   if        rang <> *zero
     * *IN50 = Affichage du sous-fichier
     c                   seton                                            50
     * *IN53 = Affichage de l'indicateur *MORE si nécessaire
     c                   seton                                            53
     c                   endif
     
     * Fin de la sous-routine
     c                   endsr

     *******************************************************************************
     * Sous-routine : TRT_DSP
     * Description  : Affichage des détails d'un joueur
     * 
     * Fonctionnement:
     *   1. Lit l'enregistrement du joueur à partir de son ID
     *   2. Charge les données dans les champs de l'écran FMT3
     *   3. Affiche l'écran de détail
     *   4. Permet la consultation ou la modification selon les indicateurs actifs
     *
     * Utilisation:
     *   - Appelée par l'option 2 (modification), 4 (suppression) ou 5 (affichage)
     *   - Les indicateurs *IN40, *IN41, *IN42 contrôlent le mode d'affichage
     *
     * Variables utilisées:
     *   - ID : Identifiant du joueur (clé de recherche)
     *   - E3xxx : Champs de l'écran FMT3 pour l'affichage/saisie
     *******************************************************************************
     c     trt_dsp       begsr
     
     * Lecture directe de l'enregistrement du joueur par son ID (clé primaire)
     * CHAIN : Opération de lecture par clé
     c     id            chain     fmtnba
     
     * Transfert des données du fichier vers les champs de l'écran
     * MOVE copie les données en alignant à droite
     c                   move      nom           e3nom
     c                   move      prenom        e3prenom
     c                   move      taille        e3taille
     c                   move      age           e3age
     c                   move      equipe        e3equipe
     c                   move      nombr00001    e3nbrt
     C                   MOVE      ID            E3ID
     
     * Affichage de l'écran de détail (FMT3)
     * EXFMT : Affiche l'écran et attend une interaction utilisateur
     c                   exfmt     fmt3
     
     * Réinitialisation du code option après traitement
     c                   eval      opt = ' '
     
     * Fin de la sous-routine
     c                   endsr

     *******************************************************************************
     * Sous-routine : TRT_DEL
     * Description  : Suppression d'un joueur de la base de données
     * 
     * Fonctionnement:
     *   1. Active les indicateurs pour mode suppression
     *   2. Affiche les détails du joueur (via TRT_DSP)
     *   3. Si F23 est pressée, supprime l'enregistrement
     *
     * Sécurité:
     *   - L'utilisateur doit confirmer avec F23 pour supprimer
     *   - Les champs sont affichés en mode protégé (*IN40)
     *   - F23 est rendue visible et F22 est masquée (voir fichier d'affichage)
     *******************************************************************************
     c     trt_del       begsr
     
     * Activation des indicateurs pour le mode suppression
     * *IN40 = Zones protégées (non modifiables)
     c                   seton                                            40
     * *IN41 = Affichage de F23 (suppression) - rend visible le bouton F23
     c                   seton                                            41
     * *IN42 = Contrôle affichage F22 - activé pour masquer F22 en mode suppression
     c                   seton                                            42
     
     * Affichage des détails du joueur à supprimer
     c                   exsr      trt_dsp
     
     * Si F23 est pressée (*IN23 = '1'), confirmation de la suppression
     c                   if        *in23 = '1'
     * Suppression de l'enregistrement identifié par E3ID
     c     e3id          delete    fmtnba
     c                   endif
     
     * Fin de la sous-routine
     c                   endsr
     
     *******************************************************************************
     * Sous-routine : TRT_MODIF
     * Description  : Modification des informations d'un joueur
     * 
     * Fonctionnement:
     *   1. Affiche les détails du joueur (via TRT_DSP)
     *   2. Permet la modification des champs
     *   3. Si F22 est pressée, enregistre les modifications
     *
     * Champs modifiables:
     *   - Nom, Prénom, Équipe, Taille, Âge, Nombre de titres
     *
     * Note:
     *   - L'ID n'est pas modifiable (clé primaire)
     *   - Les modifications sont validées avec F22
     *******************************************************************************
     c     trt_modif     begsr
     
     * Affichage de l'écran de détail en mode modification
     c                   exsr      trt_dsp
     
     * Si F22 est pressée (*IN22 = '1'), enregistrement des modifications
     c                   if        *in22 = '1'
     
     * Transfert des données de l'écran vers les champs du fichier
     c                   move      e3id          id
     c                   move      e3nom         nom
     c                   move      e3prenom      prenom
     c                   move      e3taille      taille
     c                   move      e3age         age
     c                   move      e3equipe      equipe
     c                   move      e3nbrt        nombr00001
     
     * Mise à jour de l'enregistrement dans le fichier
     * UPDATE : Modification de l'enregistrement courant
     c                   update    fmtnba
     c                   endif
     
     * Fin de la sous-routine
     c                   endsr

     *******************************************************************************
     * Sous-routine : TRT_PRTF
     * Description  : Impression de la liste complète des joueurs NBA
     * 
     * Fonctionnement:
     *   1. Imprime le titre du rapport
     *   2. Imprime les en-têtes de colonnes
     *   3. Parcourt tous les joueurs
     *   4. Imprime les détails de chaque joueur
     *
     * Format du rapport:
     *   - TITRE   : En-tête du rapport
     *   - COLONNE : Libellés des colonnes
     *   - LIGNE   : Ligne de séparation
     *   - DETAILS : Ligne de détail pour chaque joueur
     *
     * Note:
     *   - Imprime tous les joueurs sans filtre
     *   - Activée par la touche F8
     *******************************************************************************
     c     trt_prtf      begsr
     
     * Impression du titre du rapport
     c                   write     titre
     
     * Positionnement au début du fichier JOUEURSNBA
     c     *loval        setll     fmtnba
     
     * Lecture du premier enregistrement
     c                   read      fmtnba                                 91
     
     * Impression des en-têtes de colonnes
     c                   write     colonne
     
     * Impression de la ligne de séparation
     c                   write     ligne
     
     * Boucle d'impression de tous les joueurs
     * Continue tant que *IN91 = '0' (pas de fin de fichier)
     c                   dow       *in91 = '0'
     
     * Préparation des données pour l'impression
     * MOVEL : Copie les données en alignant à gauche
     c                   movel     nom           pnom
     c                   movel     prenom        pprenom
     c                   movel     equipe        pequipe
     
     * Impression de la ligne de détail
     c                   write     details
     
     * Lecture de l'enregistrement suivant
     c                   read      fmtnba                                 91
     c                   enddo
     
     * Fin de la sous-routine
     c                   endsr
