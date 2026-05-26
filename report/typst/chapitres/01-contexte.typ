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

Ce premier chapitre présente les concepts technologiques utilisés dans
ce projet semestriel : _cloud computing_, conteneurisation, architecture
des applications web modernes et principes de cybersécurité. Ces bases
conceptuelles permettent de motiver les choix de conception et
d'implémentation dans les chapitres suivants.

// ==============================================================================
// 2. CLOUD COMPUTING
// ==============================================================================
== Cloud computing

=== Définition

Le *cloud computing* désigne la mise à disposition à la demande,
via Internet, de ressources informatiques (calcul, stockage, réseau,
bases de données). Cette technologie est utilisée dans ce projet pour
héberger l'application sur AWS.

=== Modèles de service

Trois modèles de service principaux sont distingués :

- *IaaS* (_Infrastructure as a Service_) : ressources
  virtualisées brutes (machines, réseaux, disques);
- *PaaS* (_Platform as a Service_) : infrastructure +
  environnement d'exécution;
- *SaaS* (_Software as a Service_) : application complète.

Pour ce projet, le modèle *IaaS* (AWS EC2) est retenu pour sa
flexibilité pédagogique.

=== Amazon Web Services (AWS)

*AWS* est le leader mondial du _cloud_ public. Les services
utilisés dans ce projet sont :

- *EC2* : instances de machines virtuelles;
- *Elastic IP* : adresse IPv4 publique fixe;
- *Security Group* : pare-feu _stateful_;
- *Route 53* : service DNS.

Le choix d'AWS se justifie par sa documentation complète et son _free tier_ adapté aux projets académiques.

// ==============================================================================
// 3. CONTENEURISATION
// ==============================================================================
== Conteneurisation

=== Docker

*Docker* est l'outil standard pour la conteneurisation. Deux concepts
clés :

- l'*image* : un instantané immuable;
- le *conteneur* : une instance d'exécution.

=== Docker Compose

*Docker Compose* permet de décrire une pile applicative complète
(services, réseaux, volumes) dans un fichier `docker-compose.yml`.

=== Bénéfices

- *Reproductibilité* : mêmes environnements partout;
- *Isolation* : chaque service (Nginx, Flask, PostgreSQL) tourne
  indépendamment;
- *Sécurité* : réseau interne exposant uniquement Nginx;
- *Portabilité* : déployable sur toute machine supportant Docker.

// ==============================================================================
// 4. ARCHITECTURE WEB
// ==============================================================================
== Architecture des applications web modernes

=== Modèle 3-tiers

Une application web suit un découpage en trois couches :

- *Présentation* : navigateur client;
- *Logique métier* : serveur applicatif;
- *Données* : base de données.

=== Proxy inverse (Nginx)

Un *proxy inverse* se place entre les clients et l'application. Ses
fonctions :

- *Terminaison TLS* : gestion HTTPS;
- *Routage* : distribution des requêtes;
- *Cache* et compression;
- *Sécurité* : en-têtes HTTP.

Nginx est choisi pour sa légèreté et sa robustesse.

// ==============================================================================
// 5. CYBERSÉCURITÉ APPLICATIVE
// ==============================================================================
== Cybersécurité applicative

=== Top 10 OWASP

L'*OWASP* publie la liste des dix risques applicatifs les plus critiques :

+ *Broken Access Control* : contournement des contrôles d'accès;
+ *Cryptographic Failures* : chiffrement inadéquat;
+ *Injection* : SQL, NoSQL;
+ *Security Misconfiguration* : configurations par défaut;
+ *Vulnerable Components* : bibliothèques non maintenues.

=== Défense en profondeur

La *défense en profondeur* empile plusieurs barrières de sécurité. Dans
ce projet, six couches sont implémentées :

1. Pare-feu AWS Security Group
2. Certificat TLS (Let's Encrypt)
3. Proxy inverse Nginx durci
4. Application Flask sécurisée
5. Conteneurs isolés
6. Base de données non exposée

=== TLS/HTTPS

*TLS* chiffre les communications. *HTTPS* = HTTP + TLS. *Let's Encrypt*
délivre des certificats gratuits valides 90 jours.

// ==============================================================================
// 6. CONCLUSION
// ==============================================================================
== Conclusion

Ce chapitre a présenté les concepts clés : cloud AWS, conteneurs Docker,
architecture web et sécurité. Le chapitre suivant formalise les besoins
fonctionnels de l'application WebCyber.