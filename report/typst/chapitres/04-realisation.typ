// chapitre 04 - Réalisation et déploiement
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
  number: 4,
  title: "Réalisation et déploiement",
)
<chap4>

#pagebreak()

// ==============================================================================
// 1. INTRODUCTION
// ==============================================================================
== Introduction

Ce chapitre décrit comment la conception du chapitre 3 a été
*transformée en infrastructure opérationnelle*. L'accent est mis
sur l'automatisation, la reproductibilité et la sécurité opérationnelle,
plutôt que sur une liste d'étapes manuelles.

Quatre principes guident cette réalisation :

- *Infrastructure as Code (IaC)* : L'infrastructure AWS est
  décrite dans des fichiers Terraform versionnés.
- *Conteneurisation* : Chaque service tourne dans son propre
  conteneur Docker, isolé et reproductible.
- *CI/CD automatisé* : Un pipeline GitHub Actions déploie
  automatiquement à chaque `push`.
- *Sécurité par défaut* : HTTPS, pare-feu, isolation réseau,
  et secrets injectés (jamais versionnés).

// ==============================================================================
// 2. VUE D'ENSEMBLE DE L'INFRASTRUCTURE
// ==============================================================================
== Vue d'ensemble de l'infrastructure

La Figure @fig-deploiement présente l'architecture de déploiement
complète. Trois environnements distincts coexistent :

1. *Poste de développement* : Code Python, Dockerfile,
   docker-compose.yml, Terraform. Tout est versionné dans Git.

2. *CI/CD (GitHub Actions)* : Pipeline automatisé qui
   construit l'image Docker, la pousse vers GHCR, et se connecte
   à l'instance EC2 pour le déploiement.

3. *Production (AWS)* : Instance EC2 (Ubuntu 24.04) exécutant
   trois conteneurs (Nginx, Flask, PostgreSQL) orchestrés par
   Docker Compose.

#figure(
  image("../figures/img/fig10-deploiement.png", width: 100%),
  caption: [Diagramme de déploiement UML - artefacts physiques et logiques.],
) <fig-deploiement>

Le flux de déploiement suit une chaîne d'automatisation complète :
`git push` → GitHub Actions → build image → push GHCR →
SSH EC2 → docker compose pull → up. Aucune intervention
manuelle sur le serveur n'est nécessaire après l'initialisation.

// ==============================================================================
// 3. STACK TECHNOLOGIQUE
// ==============================================================================
== Stack technologique

Le choix des technologies privilégie la *robustesse* et la
*transparence pédagogique* plutôt que la surenchère technique.

#figure(
  table(
    columns: (3.4cm, 5cm, 1fr),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*Couche*], [*Choix*], [*Justification*],
    [Cloud / IaaS], [AWS EC2], [Standard du marché, free tier, documentation abondante],
    [IaC], [Terraform], [Déclaratif, reproductible, versionnable, auditable],
    [Conteneurs], [Docker + Compose], [Reproductibilité, isolation, portabilité],
    [CI/CD], [GitHub Actions], [Intégré au dépôt, gratuit pour open-source],
    [Sécurité IaC], [tfsec], [Analyse statique Terraform avant déploiement],
    [Proxy / TLS], [Nginx], [Léger, robuste, terminaison TLS éprouvée],
    [Application], [Flask + Gunicorn], [Léger, transparent, pédagogique],
    [Base de données], [PostgreSQL], [Robuste, respect des standards SQL],
    [Front-end], [Tailwind CSS], [Responsive, productif],
    [Registre images], [GHCR (GitHub Container Registry)], [Intégré à GitHub, pas de compte Docker Hub],
  ),
  caption: [Synthèse de la pile technologique.],
) <tab-stack>

// ==============================================================================
// 4. INFRASTRUCTURE AS CODE AVEC TERRAFORM
// ==============================================================================
== Infrastructure as Code avec Terraform

=== Philosophie

L'infrastructure AWS n'est pas créée manuellement via la console.
Elle est décrite *en code* dans des fichiers Terraform versionnés.
Cette approche apporte :

- *Reproductibilité* : `terraform apply` produit la même
  infrastructure partout (dev, prod, disaster recovery).
- *Auditabilité* : Toute modification passe par une Pull Request
  et laisse une trace dans Git.
- *Validation automatique* : `terraform plan` montre les
  changements avant application.
- *Analyse statique* : `tfsec` détecte les mauvaises
  configurations avant déploiement (chapitre 5).

=== Ressources provisionnées

Le module Terraform définit trois ressources clés :

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
    [*Ressource*], [*Configuration et justification*],
    [AMI], [Ubuntu 24.04 LTS (dernière version Canonical, supportée jusqu'en 2029)],
    [Instance EC2], [t2.micro (free tier), IMDSv2 obligatoire (`http_tokens = "required"`)],
    [Security Group], [Ports 22 (SSH), 80 (HTTP), 443 (HTTPS) ouverts ; ports 5000 et 5432 fermés],
    [Elastic IP], [Adresse fixe associée (nécessaire pour DNS et certificats TLS)],
    [Provisionnement], [Installation Docker via `remote-exec` (script bash idempotent)],
  ),
  caption: [Ressources Terraform provisionnées.],
) <tab-terraform>

*Pourquoi IMDSv2 obligatoire ?* IMDS (Instance Metadata Service)
permet de récupérer des informations sur l'instance. IMDSv1 est
vulnérable aux attaques SSRF. IMDSv2 ajoute une protection par
jeton (`PUT`), ce qui rend l'attaque beaucoup plus difficile.

*Pourquoi t2.micro et pas t3.micro ?* Le free tier AWS inclut
750h/mois de t2.micro. t3.micro n'est pas gratuit. Pour un
projet académique, le surcoût n'est pas justifié.

// ==============================================================================
// 5. CONTENEURISATION ET ORCHESTRATION
// ==============================================================================
== Conteneurisation et orchestration

=== Philosophie

Les trois services sont conteneurisés pour garantir :

- *Reproductibilité* : L'application s'exécute à l'identique
  sur le poste de développement, sur EC2, ou sur tout autre hôte.
- *Isolation* : Une compromission de l'application n'impacte
  pas l'hôte (et réciproquement).
- *Portabilité* : Le même `docker-compose.yml` fonctionne
  partout (local, cloud, autre fournisseur).

=== Structure des conteneurs

#figure(
  table(
    columns: (3cm, 6cm, 3cm, 1fr),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*Service*], [*Image*], [*Ports*], [*Rôle et sécurité*],
    [`nginx`], [`nginx:1.25-alpine`], [80, 443 (publiés)], [Proxy inverse, terminaison TLS, en-têtes sécurité],
    [`app`], [Build local → GHCR], [5000 (interne)], [Flask + Gunicorn, utilisateur non-root (UID 1000)],
    [`db`], [`postgres:15-alpine`], [5432 (interne)], [Base de données, volume persistant, mot de passe via `.env`],
  ),
  caption: [Spécifications des conteneurs.],
) <tab-specs>

=== Points de sécurité sur les conteneurs

- *Image Alpine* : Réduit la surface d'attaque (~5 Mo au lieu
  de ~200 Mo pour une Debian classique).
- *Utilisateur non-root* : Le conteneur `app` exécute les
  processus sous `appuser` (UID 1000), pas sous `root`.
- *Réseau bridge privé* : `webcyber-net` isole les conteneurs.
  Seul Nginx a des ports publiés sur l'hôte.
- *Secrets via `.env`* : Mots de passe injectés au runtime,
  jamais écrits en dur dans le code ou l'image.

=== Réseau : pourquoi seul Nginx est exposé ?

C'est le principe du *reverse proxy* et de l'*exposition
minimale* :

- Le navigateur ne parle qu'à Nginx (port 80/443).
- Nginx communique avec Flask via le réseau interne Docker.
- Flask communique avec PostgreSQL via le même réseau interne.

Si un attaquant compromet Flask ou PostgreSQL, il ne peut pas
exposer ces services directement car leurs ports ne sont pas publiés.
Pour sortir du réseau Docker, il devrait compromettre Nginx (qui est
l'unique passerelle).

// ==============================================================================
// 6. DÉPLOIEMENT CONTINU (CI/CD)
// ==============================================================================
== Déploiement continu (CI/CD)
<sec-cicd>

=== Philosophie

Le déploiement manuel (copier des fichiers via SCP, exécuter des
commandes SSH) est source d'erreurs et non reproductible.
L'automatisation complète via GitHub Actions garantit :

- *Rapidité* : Un `git push` suffit à livrer l'application.
- *Traçabilité* : Chaque déploiement est associé à un commit.
- *Gate de sécurité* : tfsec bloque les mauvaises configurations.
- *Rollback facile* : Repartir d'un commit antérieur.

=== Architecture du pipeline

Le pipeline GitHub Actions est déclenché sur chaque `push` sur
la branche `main`. Il comporte trois jobs séquentiels :

#figure(
  table(
    columns: (1.5cm, 4cm, 11cm),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*No*], [*Job*], [*Action et objectif*],
    [1], [`infra-scan`], [tfsec sur `terraform/`. Bloque si HIGH/CRITICAL (gate sécurité IaC)],
    [2], [`build-and-push`], [Docker build + push vers GHCR avec tags `latest` et `sha-$GITHUB_SHA`],
    [3], [`deploy`], [SSH vers EC2 → `docker compose pull` → `up -d` → nettoyage images anciennes],
  ),
  caption: [Jobs du pipeline GitHub Actions.],
) <tab-pipeline>

=== Gestion des secrets

Aucun secret n'est stocké dans le dépôt Git. Tous les secrets sont
injectés via GitHub Secrets :

#figure(
  table(
    columns: (4cm, 10cm),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*Secret*], [*Usage*],
    [`EC2_HOST`], [Adresse IP publique de l'instance (Elastic IP)],
    [`EC2_USER`], [`ubuntu` (utilisateur SSH standard sur AMI Ubuntu)],
    [`EC2_SSH_KEY`], [Clé privée `vockey.pem` (authentification SSH)],
    [`ENV_FILE`], [Fichier `.env` complet (SECRET_KEY, mots de passe PostgreSQL)],
  ),
  caption: [Secrets configurés dans GitHub Actions.],
) <tab-secrets>

*Pourquoi injecter le fichier `.env` entier ?* Le secret
`ENV_FILE` contient le contenu exact du fichier `.env`. Sur
l'EC2, le job `deploy` le recrée et le passe à
`docker compose`. Ainsi, aucune donnée sensible ne circule en
clair et rien n'est versionné.

// ==============================================================================
// 7. CONFIGURATION DNS ET HTTPS
// ==============================================================================
== Configuration DNS et HTTPS

=== DNS avec Route 53

Deux enregistrements A sont créés dans la zone hébergée
`webcyber.app` :

#figure(
  table(
    columns: (4cm, 1.5cm, 4cm, 1.5cm),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*Nom*], [*Type*], [*Valeur*], [*TTL*],
    [`webcyber.app`], [A], [Elastic IP (EC2)], [300],
    [`www.webcyber.app`], [A], [Elastic IP (EC2)], [300],
  ),
  caption: [Enregistrements DNS de la zone hébergée Route 53.],
) <tab-dns>

*Pourquoi l'Elastic IP est-elle nécessaire ?* Une instance EC2
redémarrée peut changer d'adresse IP publique. L'Elastic IP est fixe,
ce qui évite de devoir modifier les enregistrements DNS manuellement
à chaque redémarrage (sans quoi les certificats TLS deviendraient
invalides).

=== TLS avec Let's Encrypt

*Pourquoi Let's Encrypt plutôt qu'un certificat auto-signé ?*

- Un certificat auto-signé déclenche un avertissement rouge dans
  tous les navigateurs (le projet paraîtrait non sécurisé).
- Let's Encrypt est gratuit, reconnu par 100% des navigateurs,
  et s'intègre automatiquement via Certbot.

Le certificat est obtenu au premier déploiement via Certbot en mode
webroot. Une tâche cron quotidienne vérifie et renouvelle
automatiquement le certificat (valide 90 jours). Le proxy Nginx
est rechargé après renouvellement.

=== Configuration Nginx

Nginx joue trois rôles critiques :

1. *Terminaison TLS* : Nginx gère les certificats, déchiffre
   le trafic, et forwarde la requête en clair à Flask (uniquement
   sur le réseau Docker interne).
2. *Redirection HTTP → HTTPS* : Tout trafic sur port 80 reçoit
   une redirection 301 (permanente) vers la version HTTPS.
3. *Injection d'en-têtes de sécurité* : HSTS, CSP,
   X-Frame-Options, etc.

Les en-têtes de sécurité suivants sont ajoutés à toutes les réponses :

#figure(
  table(
    columns: (5.5cm, 11cm),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*En-tête*], [*Protection apportée*],
    [`Strict-Transport-Security`], [Force HTTPS pendant 1 an (HSTS) ; empêche le SSL stripping],
    [`Content-Security-Policy`], [Limite les sources autorisées (scripts, styles, polices) ; défense XSS],
    [`X-Frame-Options`], [Empêche le clickjacking (bloque l'iframe)],
    [`X-Content-Type-Options`], [Empêche le MIME sniffing (`nosniff`)],
    [`Referrer-Policy`], [Limite la fuite d'URL via l'en-tête Referer],
    [`server_tokens off`], [Masque la version de Nginx (moins d'informations pour l'attaquant)],
  ),
  caption: [En-têtes de sécurité HTTP injectés par Nginx.],
) <tab-headers>

// ==============================================================================
// 8. FLUX DE LA REQUÊTE HTTPS
// ==============================================================================
== Flux d'une requête HTTPS

La Figure @fig-flux-https synthétise le trajet d'une requête depuis
le navigateur jusqu'à la base de données, avec la distinction
fondamentale entre :

- *Partie chiffrée* : Navigateur → Nginx (TLS 1.3). Même un
  attaquant qui écoute le réseau ne peut pas lire la requête.
- *Partie en clair (mais isolée)* : Nginx → Flask → PostgreSQL
  (sur le réseau Docker interne, non accessible depuis Internet).

#figure(
  image("../figures/img/fig08-flux-https.png", width: 100%),
  caption: [Flux d'une requête HTTPS, des en-têtes au stockage.],
) <fig-flux-https>

Ce découpage suit le principe *security by design* : le chiffrement
est appliqué exactement là où il est nécessaire (trafic exposé à
Internet). À l'intérieur du réseau Docker, le trafic est considéré
comme confiance (mais reste isolé de l'extérieur).

// ==============================================================================
// 9. VÉRIFICATION POST-DÉPLOIEMENT
// ==============================================================================
== Vérification post-déploiement

Après un déploiement réussi, trois vérifications sont effectuées
automatiquement (et manuellement dans ce projet) :

1. *DNS* : `dig webcyber.app` confirme la résolution vers
   l'Elastic IP.
2. *Certificat* : `curl -v https://webcyber.app` montre un
   certificat Let's Encrypt valide (pas d'avertissement).
3. *Conteneurs* : `docker compose ps` sur l'EC2 confirme que
   les trois services sont `Up`.

Les résultats détaillés des tests fonctionnels et de sécurité
sont présentés au Chapitre 5.

// ==============================================================================
// 10. INTERFACES DE L'APPLICATION
// ==============================================================================
== Interfaces de l'application

Les figures suivantes illustrent l'interface utilisateur de
l'application déployée.

#figure(
  image("../figures/img/login.png", width: 85%),
  caption: [Interface de connexion / inscription (Tailwind CSS, responsive).],
) <fig-screenshot-login>

#figure(
  image("../figures/img/dash.png", width: 85%),
  caption: [Interface de gestion des notes (liste, création, édition, archive, corbeille).],
) <fig-screenshot-notes>

L'interface est responsive (mobile/desktop) et utilise Tailwind CSS
pour un rendu moderne sans surcharge de code CSS personnalisé.

// ==============================================================================
// 11. CONCLUSION
// ==============================================================================
== Conclusion du chapitre

La réalisation s'appuie sur quatre piliers d'automatisation :

- *Infrastructure as Code* (Terraform) : L'infrastructure AWS
  est versionnée, auditable et reproductible.
- *Conteneurisation* (Docker) : Chaque service est isolé,
  portabilité garantie.
- *CI/CD* (GitHub Actions) : Déploiement automatisé sur
  `git push`, avec gate de sécurité tfsec.
- *Configuration automatisée* (Certbot, cron) : Renouvellement
  TLS sans intervention humaine.

Le résultat est un déploiement *reproductible*, *sécurisé par
construction*, et accessible en HTTPS sur
`https://webcyber.app`. Le chapitre suivant valide
fonctionnellement et sécuritairement cette infrastructure.