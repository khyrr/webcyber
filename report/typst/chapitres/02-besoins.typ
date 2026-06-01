// chapitre 02 - Analyse et spécification des besoins
#import "../variables.typ": *
#import "../standards/chapter-opening.typ": *

// Page settings
#set page(numbering: "1")
#set text(size: 11pt)
#set par(justify: true, leading: 0.8em)

// ==============================================================================
// CHAPTER OPENING
// ==============================================================================
#chapter-opening(
  number: 2,
  title: "Analyse et spécification des besoins",
)
<chap2>

#pagebreak()

// ==============================================================================
// 1. INTRODUCTION
// ==============================================================================
== Introduction

Ce chapitre formalise ce que l'application *WebCyber* doit accomplir
et dans quelles conditions. Il présente successivement :

- les acteurs du système ;
- les besoins fonctionnels (cas d'utilisation, user stories) ;
- le *Product Backlog* agile ;
- les besoins non fonctionnels (sécurité, performance, déploiement).

Cette analyse servira de cahier des charges pour les chapitres de
conception et de réalisation.

// ==============================================================================
// 2. ACTEURS DU SYSTÈME
// ==============================================================================
== Acteurs du système

Deux acteurs interagissent avec l'application :

*Visiteur*
: Tout internaute non authentifié. Il peut accéder uniquement aux
  pages publiques (accueil, connexion, inscription).

*Utilisateur authentifié*
: Un visiteur connecté avec succès. Il accède à son espace personnel
  et gère ses notes (création, consultation, modification, archivage,
  suppression, recherche).

L'application ne comporte pas d'acteur *Administrateur* : la gestion
des utilisateurs reste manuelle via un accès direct à la base de
données. Cette simplification est volontaire et cohérente avec le
périmètre d'un projet semestriel.

// ==============================================================================
// 3. BESOINS FONCTIONNELS
// ==============================================================================
== Besoins fonctionnels

Les besoins fonctionnels décrivent *ce que* le système doit faire.
Ils sont organisés en trois niveaux : besoins bruts, cas d'utilisation,
et user stories agiles.

=== Tableau des besoins

=== Tableau des besoins

#figure(
  table(
    columns: (1.2cm, 4cm, 10cm),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*ID*], [*Besoin*], [*Description*],
    [BF-01], [S'inscrire], [Le visiteur saisit username, email et mot de passe; le système crée un compte.],
    [BF-02], [Se connecter], [L'utilisateur saisit ses identifiants; le système ouvre une session.],
    [BF-03], [Se déconnecter], [La session est détruite; retour à la page de connexion.],
    [BF-04], [Créer une note], [L'utilisateur saisit titre + contenu; la note est associée à son compte.],
    [BF-05], [Consulter ses notes], [Affichage paginé par date décroissante, hors archive et corbeille.],
    [BF-06], [Voir une note], [Affichage du titre et du contenu complet d'une note.],
  ),
  caption: [Tableau des besoins fonctionnels 1/2.],
) <tab-besoins-1>


#figure(
  table(
    columns: (1.2cm, 5cm, 10cm),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*ID*], [*Besoin*], [*Description*],
    [BF-07], [Modifier une note], [Édition du titre/contenu; mise à jour de `updated_at`.],
    [BF-08], [Archiver une note], [Note masquée de la liste principale, réversible.],
    [BF-09], [Mettre à la corbeille], [Note masquée, restauration possible.],
    [BF-10], [Restaurer une note], [Retour de la note dans la liste principale.],
    [BF-11], [Supprimer définitivement], [Suppression DELETE en base, irréversible.],
    [BF-12], [Rechercher une note], [Filtre par titre/contenu, résultats limités au compte courant.],
    [BF-13], [Isolation des données], [Toute requête filtrée par `user_id` de la session.],
  ),
  caption: [Tableau des besoins fonctionnels 2/2.],
) <tab-besoins-2>

=== Diagramme de cas d'utilisation

La Figure @fig-cas-utilisation synthétise les cas d'utilisation et
leurs liens avec les acteurs. La relation « *include* » indique que
les opérations sur les notes nécessitent une authentification préalable
(BF-02).

#figure(
  image("../figures/img/fig04-cas-utilisation.png", width: 100%),
  caption: [Diagramme de cas d'utilisation de WebCyber.],
) <fig-cas-utilisation>

=== User Stories (approche agile)

Dans une démarche agile, les besoins sont reformulés en *user stories*
selon le format standard :

#quote(block: true)[
  *En tant que* `[acteur]`, *je veux* `[action]` *afin de* `[bénéfice]`.
]

Chaque story est accompagnée de *critères d'acceptation* mesurables.
Le Tableau @tab-user-stories1 @tab-user-stories2 présente l'ensemble des stories.

#figure(
  table(
    columns: (1.5cm, 2.5cm, 5cm, 7cm),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*ID*], [*Acteur*], [*Story*], [*Critères d'acceptation*],
    [US-01], [Visiteur], [Créer un compte avec username, email et mot de passe], [Username 3-80 car., email valide, mot de passe ≥ 8 car.],
    [US-02], [Visiteur], [Me connecter avec mes identifiants], [Session créée, cookie sécurisé, redirection /notes],
[US-03], [Utilisateur], [Créer une note avec titre et contenu], [Titre max 200 car., horodatage auto, user_id associé],
          ),
  caption: [User Stories du projet WebCyber.],
) <tab-user-stories1>

#figure(
  table(
    columns: (1.5cm, 2.5cm, 5cm, 7cm),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*ID*], [*Acteur*], [*Story*], [*Critères d'acceptation*],
        
    [US-04], [Utilisateur], [Consulter la liste de mes notes], [Pagination, ordre antéchronologique],
    [US-05], [Utilisateur], [Voir le détail d'une note], [Affichage complet, accès propriétaire uniquement],
    [US-06], [Utilisateur], [Modifier une note], [updated_at actualisé, validation des champs],



    [US-07], [Utilisateur], [Archiver une note], [Note masquée, accessible dans l'archive, réversible],
    [US-08], [Utilisateur], [Supprimer (corbeille)], [Note en corbeille, restaurable],
    [US-09], [Utilisateur], [Restaurer une note], [Retour dans liste principale, is_trashed = false],
    [US-10], [Utilisateur], [Supprimer définitivement], [Suppression DELETE irréversible],
    [US-11], [Utilisateur], [Rechercher parmi mes notes], [Filtre titre/contenu, résultats limités],
    [US-12], [Utilisateur], [Isolation des données], [Toute requête filtrée par user_id → 404 si accès direct],
  ),
  caption: [User Stories du projet WebCyber.],
) <tab-user-stories2>

=== Product Backlog

Le *Product Backlog* (Tableau @tab-backlog) priorise les user stories
selon leur valeur métier et leurs dépendances techniques. Les stories
critiques (sécurité, isolation) ont été traitées dès les premiers
sprints, conformément au principe *Security by Design*.

#figure(
  table(
    columns: (1.5cm, 6cm, 2cm, 1.5cm, 2cm),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*ID*], [*Story*], [*Priorité*], [*Sprint*], [*Statut*],
    [US-01], [Inscription], [Haute], [3], [Terminé],
    [US-02], [Connexion], [Haute], [3], [Terminé],
    [US-12], [Isolation données], [Critique], [3-5], [Terminé],
    [US-03], [Créer une note], [Haute], [3], [Terminé],
    [US-04], [Lister les notes], [Haute], [3], [Terminé],
    [US-05], [Voir une note], [Haute], [3], [Terminé],
    [US-06], [Modifier une note], [Moyenne], [4], [Terminé],
    [US-07], [Archiver une note], [Basse], [4], [Terminé],
    [US-08], [Supprimer (corbeille)], [Moyenne], [4], [Terminé],
    [US-09], [Restaurer une note], [Moyenne], [4], [Terminé],
    [US-10], [Suppression définitive], [Basse], [4], [Terminé],
    [US-11], [Rechercher], [Basse], [4], [Terminé],
  ),
  caption: [Product Backlog du projet WebCyber.],
) <tab-backlog>

#pagebreak()

La priorisation suit la méthode *MoSCoW* :

- *Critique* : indispensable (sécurité, isolation)
- *Haute* : nécessaire pour la démonstration
- *Moyenne* : améliore l'expérience utilisateur
- *Basse* : fonctionnalité de confort

// ==============================================================================
// 4. BESOINS NON FONCTIONNELS
// ==============================================================================
== Besoins non fonctionnels

Les besoins non fonctionnels traduisent les *qualités attendues* du
système, indépendamment des fonctionnalités.

=== Sécurité

#figure(
  table(
    columns: (4cm, 12cm),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*Exigence*], [*Description*],
    [Confidentialité], [Tout trafic client-serveur chiffré (HTTPS, TLS 1.2/1.3)],
    [Authentification], [Mots de passe hachés (PBKDF2-SHA256), jamais stockés en clair],
    [Protection OWASP], [Prévention des injections SQL, XSS, CSRF, contournement d'accès],
    [Isolation réseau], [Seuls les ports 22, 80, 443 exposés],
    [Isolation données], [Un utilisateur ne peut accéder aux notes d'un autre],
  ),
  caption: [Exigences de sécurité.],
) <tab-securite>

=== Performance et disponibilité

#figure(
  table(
    columns: (4cm, 12cm),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*Exigence*], [*Description*],
    [Disponibilité], [Redémarrage auto des conteneurs (`restart: unless-stopped`)],
    [Performance], [Support de ~10 utilisateurs simultanés sur `t2.micro` (1 vCPU, 1 Gio RAM)],
  ),
  caption: [Exigences de performance et disponibilité.],
) <tab-perf>

=== Déploiement et maintenabilité

#figure(
  table(
    columns: (4cm, 12cm),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*Exigence*], [*Description*],
    [Reproductibilité], [Déploiement *from scratch* en < 30 minutes depuis le dépôt Git],
    [Conteneurisation], [100% Docker Compose, rien installé directement sur l'hôte],
    [Documentation], [Architecture et sécurité documentées pour reprise],
    [Certificats TLS], [Renouvellement automatique via Certbot (cron quotidien)],
  ),
  caption: [Exigences de déploiement et maintenabilité.],
) <tab-deploiement>

=== Ergonomie

- Interface *responsive* (mobile/desktop) avec Tailwind CSS
- Navigation simple : barre latérale (liste, archive, corbeille)

=== Périmètre exclu

Pour rester fidèle au cadre d'un projet semestriel, ces éléments
sont *volontairement exclus* (mais mentionnés en perspectives) :

- Orchestration Kubernetes / auto-scaling
- Pipeline CI/CD complet
- WAF / services AWS avancés (GuardDuty)
- Centralisation des logs (CloudWatch, ELK)
- Monitoring (Prometheus, Grafana)

// ==============================================================================
// 5. SYNTHÈSE DES EXIGENCES
// ==============================================================================
== Synthèse des exigences

#figure(
  table(
    columns: (4cm, 12cm),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*Catégorie*], [*Éléments clés*],
    [Fonctionnel], [13 besoins, 12 user stories, priorisées en backlog],
    [Sécurité], [HTTPS, hachage, OWASP Top 10, isolation données],
    [Architecture], [IaaS (AWS EC2), Docker Compose, Nginx, Flask, PostgreSQL],
    [Qualité], [Déploiement reproductible, documentation, conteneurisation],
  ),
  caption: [Synthèse des exigences du projet.],
) <tab-synthese>

// ==============================================================================
// 6. CONCLUSION
// ==============================================================================
== Conclusion du chapitre

L'analyse des besoins fait ressortir un système fonctionnellement
simple mais soumis à des exigences non fonctionnelles nombreuses
(sécurité, déploiement reproductible, isolation, HTTPS).

La formalisation en user stories et le *Product Backlog* structurent
le développement en sprints cohérents. Le chapitre suivant traduit
ces exigences en une architecture concrète : AWS, Docker, modèle de
données et sécurité en profondeur.