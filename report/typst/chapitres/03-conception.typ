// chapitre 03 - Conception
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
  number: 3,
  title: "Conception",
)
<chap3>

#pagebreak()

// ==============================================================================
// 1. INTRODUCTION
// ==============================================================================
== Introduction

Ce chapitre traduit les besoins du chapitre précédent en une
*architecture technique* précise. Il présente successivement :

- l'architecture globale du système ;
- l'infrastructure AWS et l'architecture Docker ;
- le modèle de données ;
- les scénarios d'interaction (diagrammes de séquence) ;
- la conception de la sécurité *en profondeur* (6 couches).

// ==============================================================================
// 2. ARCHITECTURE GLOBALE
// ==============================================================================
== Architecture globale

L'architecture cible est résumée par la Figure @fig-archi-globale.
Le navigateur du client résout le nom de domaine `webcyber.app` via
Route 53, qui retourne l'*Elastic IP* de l'instance EC2.

*Pourquoi ce choix ?* L'utilisation d'une Elastic IP garantit que
l'adresse publique reste stable même après un redémarrage de l'instance,
indispensable pour la configuration DNS et les certificats TLS.

La requête HTTPS traverse d'abord le *Security Group* (pare-feu au
niveau du cloud), puis atteint le conteneur Nginx. Ce dernier assure
la terminaison TLS (déchiffrement) et *proxifie* la requête vers
l'application Flask. Cette dernière interroge PostgreSQL sans jamais
exposer sa base directement.

#figure(
  image("../figures/img/fig01-architecture-globale.png", width: 77%),
  caption: [Architecture globale - vue d'ensemble.],
) <fig-archi-globale>

=== Limites de confiance (trust boundaries)

Le système définit trois limites de confiance distinctes :

1. *Frontière Internet* : entre le client et l'instance EC2.
   Tout trafic non HTTPS est rejeté.
2. *Frontière Docker* : entre Nginx (exposé) et les conteneurs
   internes (Flask, PostgreSQL). Seul Nginx peut initier des
   connexions vers Flask.
3. *Frontière base de données* : entre l'application et PostgreSQL.
   Les identifiants sont injectés via variables d'environnement.

=== Réduction de la surface d'attaque

La surface d'attaque est minimisée par trois décisions majeures :

- *Ports exposés* : seulement 22 (SSH), 80 (HTTP), 443 (HTTPS).
  Les ports 5000 (Flask) et 5432 (PostgreSQL) restent fermés.
- *Pas d'administration web* : aucun panneau d'administration
  exposé (phpMyAdmin, Adminer, etc.).
- *Conteneurs internes* : Flask et PostgreSQL ne publient aucun
  port sur l'hôte. Ils ne sont accessibles que via le réseau
  Docker privé.

=== Composants et responsabilités

#figure(
  table(
    columns: (5cm, 1fr),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*Composant*], [*Responsabilité*],
    [Route 53], [Résolution DNS : `webcyber.app` → Elastic IP],
    [Elastic IP], [Adresse IPv4 publique fixe associée à l'EC2],
    [EC2 (t2.micro)], [Hôte Ubuntu 22.04 exécutant Docker],
    [Security Group], [Pare-feu *stateful* au niveau de l'EC2],
    [Conteneur Nginx], [Proxy inverse, terminaison TLS, en-têtes de sécurité],
    [Conteneur Flask], [Logique applicative, authentification, CRUD],
    [Conteneur PostgreSQL], [Persistance des données utilisateur],
  ),
  caption: [Composants et responsabilités.],
) <tab-composants>

// ==============================================================================
// 3. INFRASTRUCTURE AWS
// ==============================================================================
== Infrastructure AWS

=== Choix de la région

La région `eu-west-3` (Paris) a été choisie pour :

- sa proximité géographique (latence réduite vers la Tunisie) ;
- la résidence des données (stockage en Europe, conformité RGPD) ;
- la disponibilité du *free tier* (gratuit pour 12 mois).

=== Composants AWS retenus

La Figure @fig-aws-infra détaille l'organisation interne au *cloud*.
Le choix du VPC par défaut simplifie le déploiement tout en offrant
l'isolation réseau nécessaire pour un projet de cette envergure.

#figure(
  image("../figures/img/fig02-aws-infrastructure.png", width: 80%),
  caption: [Infrastructure AWS détaillée.],
) <fig-aws-infra>

=== Règles du Security Group

Le Security Group agit comme un pare-feu *stateful* : si une requête
entrante est autorisée sur un port, la réponse correspondante est
automatiquement autorisée en sortie.

*Pourquoi ces ports uniquement ?*

- *Port 22 (SSH)* : administration nécessaire, mais protégé par clé
  (pas de mot de passe).
- *Port 80 (HTTP)* : redirige immédiatement vers HTTPS.
- *Port 443 (HTTPS)* : trafic légitime de l'application.
- *Ports 5000 et 5432 fermés* : même en cas de fuite de configuration,
  la base et l'application restent inaccessibles depuis Internet.

#figure(
  table(
    columns: (2cm, 2.5cm, 1.5cm, 2cm, 7cm),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*Type*], [*Protocole*], [*Port*], [*Source*], [*Justification*],
    [SSH], [TCP], [22], [`0.0.0.0/0`], [Administration distante (clé uniquement)],
    [HTTP], [TCP], [80], [`0.0.0.0/0`], [Redirection 301 vers HTTPS],
    [HTTPS], [TCP], [443], [`0.0.0.0/0`], [Trafic web chiffré],
  ),
  caption: [Règles entrantes du Security Group `webcyber-sg`.],
) <tab-sg-rules>

// ==============================================================================
// 4. ARCHITECTURE DOCKER
// ==============================================================================
== Architecture Docker

=== Vue d'ensemble

Trois conteneurs cohabitent sur l'instance, orchestrés par Docker
Compose et reliés par un réseau *bridge* privé (`webcyber-net`).

*Pourquoi un réseau bridge privé ?* Docker crée par défaut un réseau
bridge sur lequel tous les conteneurs peuvent communiquer. En créant
un réseau dédié, on évite que des conteneurs tiers (futurs ou
malveillants) n'accèdent à nos services.

*Pourquoi seul Nginx expose des ports ?* C'est le principe du
*reverse proxy* : une seule entrée publique, qui protège les services
internes. Même si un attaquant parvenait à exécuter du code dans
Flask ou PostgreSQL, il ne pourrait pas exposer ces services
directement car leurs ports ne sont pas publiés.

#figure(
  caption: [Architecture Docker - trois conteneurs sur réseau bridge.],
)[
  #include("../figures/fig03-docker-architecture.typ")
] <fig-docker-archi>

#pagebreak()

=== Spécifications des conteneurs

Le choix des images `-alpine` réduit la surface d'attaque : ces
distributions Linux minimalistes contiennent moins de paquets
(vulnérabilités potentielles) et pèsent 5 à 10 fois moins lourd.

#figure(
  table(
    columns: (3cm, 4.8cm, 3cm, 1fr),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*Service*], [*Image*], [*Ports*], [*Rôle*],
    [`nginx`], [`nginx:1.25-alpine`], [80, 443 (publiés)], [Proxy inverse, TLS, en-têtes],
    [`app`], [`python:3.11-slim` (build)], [5000 (interne)], [Application Flask + Gunicorn],
    [`db`], [`postgres:15-alpine`], [5432 (interne)], [Base de données PostgreSQL],
  ),
  caption: [Spécifications des conteneurs.],
) <tab-specs>

=== Justification des choix techniques

- *Nginx vs Apache* : Nginx consomme moins de mémoire et gère mieux
  les connexions simultanées (asynchrone). Idéal pour un `t2.micro`.
- *PostgreSQL vs MySQL* : PostgreSQL offre un meilleur respect des
  standards SQL et une réputation supérieure en matière d'intégrité
  des données.
- *Alpine Linux* : images minimalistes (~5 Mo pour Alpine vs
  ~200 Mo pour Debian), donc moins de vulnérabilités potentielles.

// ==============================================================================
// 5. MODÈLE DE DONNÉES
// ==============================================================================
== Modèle de données

Le modèle de données est volontairement réduit à deux entités,
comme le montre la Figure @fig-classes. Cette simplicité permet
de concentrer l'effort de conception sur les aspects de sécurité
et d'isolation.

#figure(
  image("../figures/img/fig05-diagramme-classes.png", width: 95%),
  caption: [Diagramme de classes - modèle de données.],
) <fig-classes>

#pagebreak()

=== Description des entités

*User* : représente un compte utilisateur.
- `id` : clé primaire, auto-générée
- `username` : unique, 3-80 caractères
- `email` : unique, format validé
- `password_hash` : hachage PBKDF2-SHA256 (jamais en clair)
- `created_at` : horodatage automatique

Un utilisateur peut posséder zéro à `n` notes (relation *one-to-many*).

*Note* : représente le contenu textuel.
- `id` : clé primaire
- `title` : titre (max 200 caractères)
- `content` : corps textuel
- `user_id` : clé étrangère vers `User.id`
- `is_archived` : archive douce (true/false)
- `is_trashed` : corbeille réversible (true/false)
- `created_at` / `updated_at` : horodatages automatiques

Une note appartient à exactement un utilisateur.

=== Considérations de sécurité

- *Hachage* : `password_hash` stocke uniquement l'empreinte du mot de passe (PBKDF2-SHA256), jamais le texte clair.
- *Unicité* : les contraintes `UNIQUE` sur `username` et `email` empêchent les doublons et limitent l'énumération.
- *Filtrage* : toute requête SQL sur `notes` inclut `WHERE user_id = current_user.id` (isolation stricte).
- *Intégrité* : la clé étrangère avec `ON DELETE CASCADE` évite les notes orphelines.

// ==============================================================================
// 6. DIAGRAMMES DE SÉQUENCE
// ==============================================================================

#pagebreak()
== Diagrammes de séquence

=== Authentification

Le scénario d'authentification (Figure @fig-seq-auth) met en jeu
cinq acteurs : utilisateur, navigateur, Nginx, Flask et PostgreSQL.

#figure(
  caption: [Diagramme de séquence - authentification.],
)[
  #include("../figures/fig06-sequence-authentification.typ")
] <fig-seq-auth>

*Points de sécurité :*

1. Le mot de passe ne quitte jamais le tunnel TLS
2. Comparaison *constant-time* via `check_password_hash`
3. Cookie de session signé (HMAC) avec attributs `Secure`, `HttpOnly`, `SameSite=Lax`


#pagebreak()

=== Création d'une note

Le scénario de création d'une note (Figure @fig-seq-note) montre
le contrôle de session (`@login_required`), la vérification CSRF,
et l'insertion en base avec association à l'utilisateur courant.

#figure(
  caption: [Diagramme de séquence - création d'une note.],
)[
  #include("../figures/fig07-sequence-note.typ")
] <fig-seq-note>

// ==============================================================================
// 7. CONCEPTION DE LA SÉCURITÉ - DÉFENSE EN PROFONDEUR
// ==============================================================================
// 
#pagebreak()
== Conception de la sécurité - défense en profondeur

La sécurité du système ne repose pas sur une mesure unique mais sur
*six couches empilées*, chacune apportant une garantie spécifique.
Si un attaquant compromet une couche, les cinq autres restent
opérationnelles pour bloquer l'attaque.

La Figure @fig-couches-securite illustre cette approche.

#figure(
  caption: [Six couches de sécurité (defense-in-depth).],
)[
  #include("../figures/fig09-couches-securite.typ")
] <fig-couches-securite>

=== Couche 1 - Security Group (AWS)

*Rôle* : Pare-feu périmétrique filtrant le trafic entrant au niveau de l'instance EC2.

*Pourquoi cette couche est essentielle ?* Elle bloque les attaques
au niveau du réseau, avant même qu'elles n'atteignent l'OS ou Docker.
Même si l'application a une faille, le port 5000 (Flask) reste
inaccessible.

#figure(
  table(
    columns: (5cm, 1fr),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*Règle*], [*Valeur*],
    [Ports ouverts], [22 (SSH), 80 (HTTP), 443 (HTTPS)],
    [Ports fermés], [5000 (Flask), 5432 (PostgreSQL)],
    [Nature], [Stateful (réponses auto-autorisées)],
  ),
  caption: [Configuration du Security Group.],
) <tab-sg-config>

=== Couche 2 - Système hôte (EC2)

*Rôle* : Configuration sécurisée de l'instance Ubuntu hébergeant Docker.

*Pourquoi ces configurations ?* `PermitRootLogin no` empêche
les attaques par force brute sur le compte `root`. L'authentification
par clé (pas de mot de passe) rend les attaques par dictionnaire
impossibles. Les mises à jour automatiques corrigent les vulnérabilités
connues sans intervention manuelle.

#figure(
  table(
    columns: (5cm, 1fr),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*Configuration*], [*Valeur*],
    [SSH root login], [`PermitRootLogin no`],
    [Authentification], [Clé SSH uniquement (pas de mot de passe)],
    [Mises à jour], [`unattended-upgrades` automatiques],
    [Utilisateur applicatif], [`ubuntu` (non-root)],
  ),
  caption: [Configuration du système hôte.],
) <tab-host-config>

=== Couche 3 - Isolation Docker

*Rôle* : Isolation réseau et processus entre les trois conteneurs.

*Principe clé* : "Un conteneur = un service". Si Flask est compromis,
l'attaquant ne peut pas accéder à PostgreSQL car les ports ne sont
pas publiés. Si PostgreSQL est compromis, l'attaquant ne peut pas
sortir du réseau Docker privé.

#figure(
  table(
    columns: (5cm, 1fr),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*Mesure*], [*Description*],
    [Réseau], [Bridge privé `webcyber-net` (isolation réseau)],
    [Exposition ports], [`app` et `db` sans port publié vers l'hôte],
    [Utilisateur], [`appuser` (UID 1000) non-privilégié dans le conteneur],
    [Volumes], [Données persistantes isolées du système hôte],
  ),
  caption: [Mesures d'isolation Docker.],
) <tab-docker-isol>

=== Couche 4 - Nginx + TLS

*Rôle* : Proxy inverse assurant la terminaison TLS et l'injection d'en-têtes de sécurité.

*Pourquoi TLS 1.2 et 1.3 uniquement ?* Les versions antérieures
(TLS 1.0, 1.1) ont des vulnérabilités connues (POODLE, BEAST).
Le profil *Mozilla Intermediate* garantit la compatibilité avec
99% des navigateurs tout en excluant les algorithmes faibles.

#figure(
  table(
    columns: (5cm, 1fr),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*Configuration*], [*Valeur*],
    [TLS versions], [1.2 et 1.3 uniquement (versions sécurisées)],
    [Certificat], [Let's Encrypt (renouvellement automatique)],
    [Redirection], [HTTP → HTTPS (301 permanent)],
    [En-têtes sécurité], [HSTS, CSP, X-Frame-Options, X-Content-Type-Options],
    [Version masking], [`server_tokens off` (masque la version Nginx)],
  ),
  caption: [Configuration Nginx et TLS.],
) <tab-nginx-config>

=== Couche 5 - Application Flask

*Rôle* : Logique métier, authentification et contrôle d'accès aux données.

*Pourquoi PBKDF2-SHA256 ?* C'est l'algorithme recommandé par l'OWASP
pour le stockage des mots de passe. Le sel automatique rend les
attaques par tables arc-en-ciel inefficaces.

#figure(
  table(
    columns: (5cm, 1fr),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*Protection*], [*Mécanisme*],
    [Mots de passe], [PBKDF2-SHA256 avec sel automatique],
    [Session], [Signée par `SECRET_KEY` (32 octets aléatoire)],
    [CSRF], [Flask-WTF sur tous les formulaires],
    [Validation], [WTForms (longueur, type, présence)],
    [Routes privées], [Décorateur `@login_required`],
    [Isolation données], [Filtre `user_id` sur 100% des requêtes],
  ),
  caption: [Mesures de sécurité de l'application Flask.],
) <tab-flask-sec>

=== Couche 6 - Base de données

*Rôle* : Persistance des données avec isolation réseau et requêtes paramétrées.

*Pourquoi des requêtes paramétrées ?* Elles sont la seule défense
fiable contre les attaques par injection SQL. La concaténation de
chaînes est totalement prohibée.

#figure(
  table(
    columns: (5cm, 1fr),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*Mesure*], [*Description*],
    [Utilisateur], [`webcyber_user` (non-superutilisateur)],
    [Mot de passe], [Long (>20 car.), aléatoire, injecté via `.env`],
    [Exposition], [Aucun port publié vers l'hôte (Docker interne)],
    [Requêtes], [Paramétrées (SQLAlchemy) - pas de concaténation SQL],
  ),
  caption: [Mesures de sécurité de la base de données.],
) <tab-db-sec>

// ==============================================================================
// 8. RÉCAPITULATIF DE LA CONCEPTION
// ==============================================================================
== Récapitulatif de la conception

#figure(
  table(
    columns: (4cm, 4cm, 1fr),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*Couche*], [*Technologie*], [*Éléments clés*],
    [DNS], [Route 53], [Zone hébergée, résolution],
    [Cloud], [AWS EC2], [t2.micro, Security Group],
    [Orchestration], [Docker Compose], [3 conteneurs, réseau bridge],
    [Proxy], [Nginx], [TLS, en-têtes, redirection],
    [Application], [Flask], [Authentification, CRUD, sessions],
    [Base de données], [PostgreSQL], [Persistance, isolation],
    [Sécurité], [6 couches], [Defense-in-depth],
  ),
  caption: [Synthèse de l'architecture technique.],
) <tab-synthese>


#pagebreak()

// ==============================================================================
// 9. CONCLUSION
// ==============================================================================
== Conclusion du chapitre

La conception ainsi décrite est volontairement *minimale mais complète* :

- un seul serveur (EC2 t2.micro)
- trois conteneurs (Nginx, Flask, PostgreSQL)
- deux entités (User, Note)
- six couches de sécurité empilées

L'approche *defense-in-depth* garantit que la compromission d'une
couche n'entraîne pas celle du système entier. Le choix d'exposer
uniquement Nginx, la création d'un réseau Docker privé, et le
filtrage systématique par `user_id` constituent les piliers de
cette sécurité.

Le chapitre suivant présente la réalisation concrète de cette conception
et les étapes de déploiement sur AWS.