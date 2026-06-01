// chapitre 01 - Contexte général et état de l'art
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
  number: 1,
  title: "Contexte général et état de l'art",
)
<chap1>

#pagebreak()

// ==============================================================================
// 1. INTRODUCTION
// ==============================================================================
== Introduction

Ce chapitre pose les fondations conceptuelles du projet. Il présente
les quatre piliers technologiques mobilisés :

- le *cloud computing* et AWS ;
- la *conteneurisation* avec Docker ;
- l'*architecture des applications web modernes* ;
- les *principes de cybersécurité* applicative.

Ces bases permettent de comprendre et de justifier les choix de
conception et d'implémentation détaillés dans les chapitres suivants.

// ==============================================================================
// 2. CLOUD COMPUTING
// ==============================================================================
== Cloud computing

=== Définition et enjeux

Le *cloud computing* désigne la mise à disposition à la demande, via
Internet, de ressources informatiques (calcul, stockage, réseau,
bases de données). Cinq caractéristiques le définissent selon le NIST :

- *libre-service* : l'utilisateur provisionne des ressources sans
  intervention humaine ;
- *accès réseau large* : accessible depuis tout type de terminal ;
- *mutualisation* : plusieurs clients partagent l'infrastructure ;
- *élasticité* : les ressources s'ajustent automatiquement à la charge ;
- *facturation à l'usage* : paiement uniquement pour les ressources
  consommées.

*Pourquoi cette technologie est-elle centrale ?* Le cloud permet de
louer une infrastructure à la demande, sans investissement matériel
initial. Pour un projet académique, c'est un atout majeur : il donne
accès à des ressources professionnelles à coût quasi nul (via le
*free tier* des fournisseurs).

===  Modèles de service

Trois modèles se distinguent par leur niveau d'abstraction :

#figure(
  table(
    columns: (2cm, 7cm, 8cm),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*Modèle*], [*Fournisseur gère*], [*Client gère*],
    [*IaaS*], [Réseau, stockage, serveurs, virtualisation], [OS, middleware, runtime, données, application],
    [*PaaS*], [Réseau, stockage, serveurs, virtualisation, OS, middleware], [Données, application],
    [*SaaS*], [Tout (y compris l'application)], [Rien (l'application est utilisée directement)],
  ),
  caption: [Niveaux d'abstraction des modèles cloud.],
) <tab-cloud-models>

*Choix du projet* : Le modèle *IaaS* (AWS EC2) est retenu. Il offre
le meilleur équilibre entre maîtrise pédagogique (configuration du
système, installation de Docker, gestion réseau) et simplicité.
Les modèles PaaS ou SaaS auraient masqué des couches essentielles
à la compréhension.

#pagebreak()

=== Amazon Web Services (AWS)

AWS est le leader mondial du cloud public (>30% de parts de marché).
Ses atouts pour ce projet :

- *Free tier* : 750h/mois d'EC2 t2.micro gratuites pendant 12 mois ;
- *Documentation exhaustive* : ressources techniques abondantes ;
- *Écosystème mature* : outils, communautés, formations.

Les services AWS utilisés dans ce projet :

#figure(
  table(
    columns: (3.5cm, 1fr),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*Service*], [*Rôle dans le projet*],
    [EC2], [Instance virtuelle hébergeant Docker et les conteneurs],
    [Elastic IP], [Adresse IPv4 publique fixe (essentielle pour DNS et TLS)],
    [Security Group], [Pare-feu stateful filtrant le trafic entrant],
    [Route 53], [Service DNS : résolution de webcyber.app],
  ),
  caption: [Services AWS mobilisés.],
) <tab-aws-services>

// ==============================================================================
// 3. CONTENEURISATION
// ==============================================================================
== Conteneurisation

=== Problématique : de l'environnement de développement à la production

"Ça marche sur ma machine" est un problème classique : les différences
de bibliothèques, versions d'OS, variables d'environnement entre le
poste de développement et le serveur de production génèrent des bugs
difficiles à reproduire. La *conteneurisation* répond à ce problème.

=== Docker : concepts clés

*Docker* est l'outil standard de conteneurisation. Deux concepts
fondamentaux :

- l'*image* : un instantané immuable contenant tout le nécessaire
  pour exécuter une application (code, bibliothèques, configuration) ;
- le *conteneur* : une instance d'exécution d'une image, isolée des
  autres conteneurs et de l'hôte.

*Pourquoi Docker plutôt qu'une machine virtuelle classique ?*

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
    [*Critère*], [*Conteneur Docker*],
    [Démarrage], [Quelques millisecondes],
    [Empreinte disque], [Quelques Mo (image Alpine)],
    [Isolation], [Niveau OS (namespaces, cgroups)],
    [Portabilité], [Identique sur tout hôte Linux],
  ),
  caption: [Avantages des conteneurs Docker par rapport aux VMs.],
) <tab-docker-vs-vm>


#pagebreak()

=== Docker Compose

*Docker Compose* permet de décrire une pile applicative multi-conteneurs
dans un fichier YAML (`docker-compose.yml`). Une seule commande
suffit à démarrer ou arrêter l'ensemble.

=== Bénéfices pour ce projet

- *Reproductibilité* : Le même `docker-compose.yml` fonctionne à
  l'identique sur le poste de développement et sur l'EC2.
- *Isolation* : Chaque service (Nginx, Flask, PostgreSQL) tourne
  dans son propre conteneur, avec ses dépendances précises.
- *Sécurité* : Le réseau interne Docker permet de n'exposer que
  Nginx, en gardant l'application Flask et la base PostgreSQL
  invisibles depuis Internet.
- *Portabilité* : La migration vers un autre fournisseur cloud
  ne nécessite que de relancer la même pile sur une nouvelle machine.

// ==============================================================================
// 4. ARCHITECTURE DES APPLICATIONS WEB MODERNES
// ==============================================================================
== Architecture des applications web modernes

=== Le modèle 3-tiers

Une application web suit classiquement un découpage en trois couches :

#figure(
  table(
    columns: (5.5cm, 1fr),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*Couche*], [*Rôle*],
    [Présentation (front-end)], [Interface utilisateur (navigateur client)],
    [Logique métier (back-end)], [Serveur applicatif (Flask)],
    [Données], [Base de données (PostgreSQL)],
  ),
  caption: [Les trois couches d'une application web.],
) <tab-3tiers>

=== Le proxy inverse : pourquoi Nginx ?

Un *proxy inverse* se place entre les clients et l'application. Il
assure plusieurs fonctions essentielles :

- *Terminaison TLS* : déchiffre le trafic HTTPS, évitant à
  l'application Flask de gérer elle-même les certificats ;
- *Routage* : dirige les requêtes vers le bon back-end ;
- *Cache* et compression (réduction de la bande passante) ;
- *Sécurité périmétrique* : ajout d'en-têtes HTTP sécurisés,
  limitation de débit, filtrage.

*Pourquoi Nginx plutôt qu'Apache ?* Nginx consomme moins de mémoire,
gère mieux les connexions simultanées (modèle asynchrone), et est
particulièrement adapté aux petites instances comme le `t2.micro`.

// ==============================================================================
// 5. CYBERSÉCURITÉ APPLICATIVE
// ==============================================================================
// 
#pagebreak()
== Cybersécurité applicative

=== Le Top 10 OWASP

L'*OWASP* (Open Web Application Security Project) publie périodiquement
la liste des dix risques applicatifs les plus critiques. La version
2021 sert de référence à ce projet :

#figure(
  table(
    columns: (6.5cm, 1fr),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*Risque*], [*Description*],
    [A01 - Broken Access Control], [Contournement des contrôles d'accès (ex: IDOR)],
    [A02 - Cryptographic Failures], [Chiffrement inadéquat ou absent],
    [A03 - Injection], [SQL, NoSQL, OS command injection],
    [A05 - Security Misconfiguration], [Configurations par défaut dangereuses],
    [A06 - Vulnerable Components], [Bibliothèques non maintenues],
  ),
  caption: [Risques OWASP Top 10 les plus pertinents pour ce projet.],
) <tab-owasp>

=== Défense en profondeur (defense-in-depth)

La *défense en profondeur* est un principe militaire appliqué à la
cybersécurité : empiler plusieurs barrières indépendantes, de sorte
que la compromission d'une couche ne suffise pas à compromettre le
système entier.

Dans ce projet, six couches sont implémentées :

1. *Security Group AWS* : Pare-feu périmétrique bloque les ports non nécessaires.
2. *Système hôte EC2* : Configurations sécurisées (SSH par clé, mises à jour auto).
3. *Isolation Docker* : Réseau privé, conteneurs non-root.
4. *Nginx + TLS* : Terminaison TLS, en-têtes HTTP sécurisés, HSTS.
5. *Application Flask* : Hachage PBKDF2-SHA256, CSRF, isolation user_id.
6. *Base de données* : Non exposée, requêtes paramétrées.

=== TLS et HTTPS

*TLS* (Transport Layer Security) est le protocole standard pour
chiffrer les communications sur Internet. *HTTPS* désigne HTTP
encapsulé dans TLS. Trois propriétés sont garanties :

- *Confidentialité* : Le contenu des échanges ne peut être lu
  par un tiers (attaque passive).
- *Intégrité* : Le contenu ne peut être modifié sans détection
  (attaque active).
- *Authenticité* : Le client peut vérifier l'identité du serveur
  grâce à un certificat signé.

*Let's Encrypt* est une autorité de certification gratuite qui
émet des certificats TLS valides 90 jours, renouvelables
automatiquement via le protocole *ACME*. Le domaine `.app`
étant préchargé HSTS, le navigateur *refuse* toute connexion
non-HTTPS, rendant Let's Encrypt indispensable.

// ==============================================================================
// 6. SYNTHÈSE DES CONCEPTS
// ==============================================================================
== Synthèse des concepts

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
    [*Concept*], [*Application dans WebCyber*],
    [Cloud IaaS], [Instance EC2 (t2.micro, free tier)],
    [Conteneurisation], [Docker Compose (Nginx, Flask, PostgreSQL)],
    [Proxy inverse], [Nginx (TLS, redirection, en-têtes)],
    [OWASP Top 10], [Référentiel des risques à mitiger],
    [Defense-in-depth], [6 couches de sécurité empilées],
    [TLS/HTTPS], [Let's Encrypt (certificat gratuit, renouvellement auto)],
  ),
  caption: [Synthèse des concepts technologiques et leur application.],
) <tab-synthese>

// ==============================================================================
// 7. CONCLUSION
// ==============================================================================
== Conclusion

Ce chapitre a posé les quatre piliers conceptuels du projet :

- Le *cloud AWS* fournit l'infrastructure (EC2, Elastic IP, Security Group).
- La *conteneurisation Docker* garantit reproductibilité et isolation.
- L'*architecture web moderne* s'appuie sur le modèle 3-tiers et le proxy Nginx.
- La *cybersécurité applicative* guide la conception (OWASP, defense-in-depth, TLS).

Le chapitre suivant formalise les besoins fonctionnels et non
fonctionnels de l'application WebCyber, en s'appuyant sur ces bases.