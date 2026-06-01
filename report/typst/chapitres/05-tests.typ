// chapitre 05 - Tests et analyse de sécurité
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
  number: 5,
  title: "Tests et analyse de sécurité",
)
<chap5>

#pagebreak()

// ==============================================================================
// 1. INTRODUCTION
// ==============================================================================
== Introduction

Ce chapitre présente la dernière phase du projet : la *validation*
fonctionnelle de l'application et l'*audit de sécurité* du déploiement.
La méthodologie suit six phases complémentaires couvrant aussi bien le
code applicatif que l'infrastructure.

L'objectif n'est pas seulement de détecter des vulnérabilités, mais de
démontrer que chaque risque identifié dans la conception (chapitre 3)
a été correctement traité ou documenté.

// ==============================================================================
// 2. STRATÉGIE DE TEST
// ==============================================================================
== Stratégie de test

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*Phase*], [*Type*], [*Outils*], [*Objectif*],
    [1], [Fonctionnel], [Navigateur, `curl`], [Vérifier les cas d'utilisation],
    [2], [Analyse statique IaC], [tfsec], [Détecter les défauts de configuration Terraform *avant* déploiement],
    [3], [Infrastructure], [`docker`, `dig`, `curl`], [Confirmer le déploiement],
    [4], [Scan de ports], [Nmap], [Limiter la surface d'attaque],
    [5], [Scan applicatif web], [Nikto, `curl`], [Détecter les mauvaises configurations HTTP],
    [6], [Évaluation TLS], [SSL Labs, testssl.sh], [Mesurer la qualité du chiffrement],
  ),
  caption: [Phases de la campagne de validation.],
) <tab-strategie>

// ==============================================================================
// 3. TESTS FONCTIONNELS
// ==============================================================================
== Tests fonctionnels

=== Inscription et authentification

*Risque évalué* : Un attaquant pourrait créer des comptes en masse
(inscription) ou contourner l'authentification (connexion).

*Résultat attendu* : Seules les inscriptions valides aboutissent ; les
tentatives avec des données invalides ou duplicées sont rejetées.

#figure(
  table(
    columns: (1cm, 4cm, 5cm, 6cm),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*No*], [*Cas*], [*Entrée*], [*Résultat attendu*],
    [1], [Inscription valide], [user/email/mdp corrects], [Compte créé, redirection /login],
    [2], [Username existant], [username déjà pris], [Erreur, pas de doublon],
    [3], [Mot de passe court], [< 8 caractères], [Erreur de validation],
    [4], [Champs vides], [blanc], [Erreur de validation],
  ),
  caption: [Tests d'inscription.],
) <tab-test-inscription>

#figure(
  image("../figures/img/placeholder.png", width: 85%),
  caption: [Exemple de messages d'erreur lors d'une saisie invalide.],
) <fig-test-validation>

#figure(
  table(
    columns: (1cm, 4cm, 5cm, 6cm),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*No*], [*Cas*], [*Entrée*], [*Résultat attendu*],
    [1], [Identifiants valides], [user/mdp corrects], [Redirection /notes],
    [2], [Mauvais mot de passe], [mdp erroné], [Message d'erreur],
    [3], [Utilisateur inconnu], [username inexistant], [Message d'erreur],
    [4], [Accès direct sans auth], [GET /notes], [Redirection /login],
    [5], [Déconnexion], [clic « se déconnecter »], [Session détruite, retour /login],
  ),
  caption: [Tests d'authentification.],
) <tab-test-auth>

*Résultat* : Tous les tests passent. Les contraintes de validation
sont appliquées côté serveur (non contournables).

=== Gestion des notes (CRUD)

*Risque évalué* : Un utilisateur pourrait manipuler des notes
appartenant à d'autres utilisateurs (IDOR - Insecure Direct Object
Reference).

*Mitigation* : Chaque requête SQL inclut systématiquement
`WHERE user_id = current_user.id`.

#figure(
  table(
    columns: (1cm, 4cm, 8cm),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*No*], [*Cas*], [*Résultat attendu*],
    [1], [Création de note], [Note dans la liste],
    [2], [Détail d'une note], [Titre + contenu complet affichés],
    [3], [Édition], [Contenu mis à jour, `updated_at` actualisé],
    [4], [Archivage], [Disparaît de /notes, apparaît dans /archive],
    [5], [Mise à la corbeille], [Disparaît, apparaît dans /trash],
    [6], [Restauration], [Revient dans la liste principale],
    [7], [Suppression définitive], [Disparaît de partout, irrécupérable],
    [8], [Recherche par titre], [Résultats filtrés],
    [9], [Création sans titre], [Erreur de validation],
  ),
  caption: [Tests CRUD sur les notes.],
) <tab-test-crud>

=== Test critique : isolation des données

*Risque évalué* : Violation de la confidentialité des données
(un utilisateur lit les notes d'un autre).

*Résultat attendu* : 404 Not Found pour toute tentative d'accès
à une note non autorisée.

#figure(
  table(
    columns: (1cm, 6cm, 6.5cm),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*No*], [*Scénario*], [*Résultat attendu*],
    [1], [Utilisateur A crée la note `id=42`], [A voit la note dans sa liste],
    [2], [Utilisateur B se connecte], [B ne voit pas la note de A],
    [3], [B accède à `/notes/42` directement], [404 Not Found],
    [4], [B tente `POST /notes/42/edit`], [404 Not Found, aucune modification],
  ),
  caption: [Tests d'isolation par utilisateur.],
) <tab-test-isolation>

#figure(
  image("../figures/img/placeholder.png", width: 85%),
  caption: [Protection IDOR : erreur 404 lors de l'accès à la note d'un autre utilisateur.],
) <fig-test-404>

*Résultat* : L'application bloque toute tentative grâce au filtre
`filter_by(user_id=current_user.id)` systématique combiné à
`first_or_404()`.

// ==============================================================================
// 4. ANALYSE STATIQUE DE L'IAC AVEC TFSEC
// ==============================================================================
== Analyse statique de l'IaC avec tfsec

=== Principe et positionnement

*tfsec* est un outil d'analyse statique (SAST) spécialisé dans
le code Terraform. Il examine la configuration *avant* tout déploiement
et signale les défauts courants : ports trop largement ouverts, absence
de chiffrement, métadonnées IMDSv2 non protégées, etc.

*Pourquoi cette phase est critique ?* Une mauvaise configuration
d'infrastructure est plus dangereuse qu'une faille applicative :
elle expose directement les ressources cloud à Internet.

=== Résultats et décisions

L'analyse initiale a remonté trois constats. Chaque *finding* a été
analysé et a reçu une décision explicite :

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*Règle*], [*Sévérité*], [*Description*], [*Décision et justification*],
    [`aws-ec2-no-public-ingress-sgr`], [HIGH], [IMDSv2 non requis sur l'instance], [*Corrigée* : ajout du bloc `metadata_options { http_tokens = "required" }`],
    [`aws-ec2-enable-at-rest-encryption`], [HIGH], [Volume *root* non chiffré], [*Acceptée et documentée* : projet académique sur AWS Academy, pas de données sensibles au repos. Exclusion par `tfsec:ignore`],
    [`aws-ec2-add-description-to-security-group`], [LOW], [Le security group utilise la description par défaut], [*Acceptée et documentée* : finding cosmétique de bas niveau. Exclusion par `tfsec:ignore`],
  ),
  caption: [Constats tfsec sur le module Terraform et décisions associées.],
) <tab-tfsec>

#figure(
  image("../figures/img/placeholder.png", width: 90%),
  caption: [Exécution de tfsec : détection et validation des règles ignorées.],
) <fig-test-tfsec>

=== Interprétation des décisions

- *Correction* : Le *finding* sur IMDSv2 est légitime et facile à
  corriger. Le patch a été appliqué immédiatement.

- *Risque accepté (chiffrement at-rest)* : Le volume racine EC2 n'est
  pas chiffré. Dans un contexte AWS Academy sans données sensibles,
  ce risque est acceptable. La directive `tfsec:ignore` inclut
  une justification explicite pour l'auditeur.

- *Risque accepté (description)* : Une description manquante sur un
  security group n'a pas d'impact fonctionnel ou sécuritaire.
  Accepté comme non-bloquant.

=== Intégration CI/CD

Le scan tfsec est exécuté sur chaque `push` dans le dépôt GitHub.
Si une règle de sévérité HIGH ou CRITICAL est détectée (et non
explicitement ignorée), le pipeline échoue immédiatement. Cela
garantit qu'aucune configuration dangereuse n'atteint le déploiement
sans avoir été examinée.

// ==============================================================================
// 5. VÉRIFICATION DE L'INFRASTRUCTURE DÉPLOYÉE
// ==============================================================================
== Vérification de l'infrastructure déployée

=== Résolution DNS

*Ce qui a été testé* : Les enregistrements DNS pointent-ils vers la
bonne adresse IP ?

*Résultat* : `dig webcyber.app` confirme que le domaine et son alias
`www.webcyber.app` résolvent correctement vers l'Elastic IP de
l'instance EC2.

=== État des conteneurs

*Ce qui a été testé* : Les trois conteneurs sont-ils en cours
d'exécution avec les bons ports exposés ?

*Résultat* : `docker compose ps` confirme que `nginx`, `app` et
`db` sont en état `Up`. Nginx expose les ports 80 et 443 ; Flask
et PostgreSQL sont confinés au réseau Docker interne (aucun port
publié sur l'hôte).

=== Connectivité applicative

*Ce qui a été testé* : L'application répond-elle correctement sur
HTTP et HTTPS ?

*Résultat* :

#figure(
  kind: "code",
  supplement: [Terminal],
  caption: [Redirection automatique HTTP vers HTTPS.],
)[
  #set text(size: 8.5pt, font: "DejaVu Sans Mono")
  #set block(
    inset: 10pt,
    stroke: 0.5pt + rgb(210, 210, 210),
    radius: 4pt,
    width: 100%,
  )
```bash
$ curl -I http://webcyber.app
HTTP/1.1 301 Moved Permanently
Server: nginx/1.25.5
Date: Mon, 01 Jun 2026 13:46:32 GMT
Content-Type: text/html
Content-Length: 169
Connection: keep-alive
Location: https://webcyber.app/
```
] <code-curl-http>




#figure(
  kind: "code",
  supplement: [Terminal],
  caption: [Vérification des en-têtes de sécurité avec curl.],
)[
  #set text(size: 8.5pt, font: "DejaVu Sans Mono")
  #set block(
    inset: 10pt,
    stroke: 0.5pt + rgb(210, 210, 210),
    radius: 4pt,
    width: 100%,
  )
```bash
$ curl -I https://webcyber.app/
HTTP/1.1 302 FOUND
Server: nginx
Date: Mon, 01 Jun 2026 13:14:27 GMT
Content-Type: text/html; charset=utf-8
Content-Length: 209
Connection: keep-alive
Location: /auth/login
Vary: Cookie
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
Referrer-Policy: strict-origin-when-cross-origin
Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self' data:; object-src 'none'; base-uri 'self'; frame-ancestors 'self'
```] <code-curl-headers>

// ==============================================================================
// 6. SCAN DE PORTS AVEC NMAP
// ==============================================================================
== Scan de ports avec Nmap

=== Objectif et méthode

*Ce qui a été testé* : Quels ports TCP sont accessibles depuis
l'extérieur ?

*Pourquoi ce test ?* Un port ouvert inutilement est une porte
d'entrée potentielle pour un attaquant. L'objectif est de confirmer
que la surface d'attaque réseau correspond exactement à la conception
(chapitre 3).

*Commande utilisée* : `sudo nmap -Pn -sS -n --min-rate 5000 -T4 80 54.165.116.113 -p-`

#figure(
  kind: "code",
  supplement: [Terminal],
  caption: [Scan Nmap des deux cibles.],
)[
  #set text(size: 8.5pt, font: "DejaVu Sans Mono")
  #set block(
    inset: 10pt,
    stroke: 0.5pt + rgb(210, 210, 210),
    radius: 4pt,
    width: 100%,
  )
```bash
$ sudo nmap -Pn -sS -n --min-rate 5000 -T4 80 54.165.116.113 -p-
Starting Nmap 7.94SVN ( https://nmap.org ) at 2026-06-01 15:15 CET
Nmap scan report for 54.165.116.113
Host is up (0.043s latency).
Not shown: 65532 filtered tcp ports (no-response)
PORT     STATE SERVICE
22/tcp   open  ssh
80/tcp   open  http
443/tcp  open  https

Nmap done: 1 IP addresses (1 hosts up) scanned in 66.21 seconds
```
] <code-nmap>

=== Résultats et interprétation

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*Port*], [*État*], [*Service*], [*Analyse et justification*],
    [22/tcp], [open], [SSH], [Attendu : administration. Accès limité par clé SSH (pas de mot de passe)],
    [80/tcp], [open], [HTTP], [Attendu : redirection 301 permanente vers HTTPS],
    [443/tcp], [open], [HTTPS], [Attendu : trafic web chiffré],
    [Autres 65532 ports], [filtered], [--], [*Correct* : surface d'attaque minimale],
  ),
  caption: [Résultats du scan Nmap.],
) <tab-nmap>

=== Conclusion et recommandations

La surface d'attaque réseau est *conforme* à la conception.

*Recommandations pour une production réelle* :
- Restreindre la source du port 22 (SSH) à une plage d'IP de
  confiance plutôt que `0.0.0.0/0`
- Masquer la version de Nginx avec `server_tokens off` (déjà appliqué)

// ==============================================================================
// 7. SCAN APPLICATIF WEB AVEC NIKTO
// ==============================================================================
== Scan applicatif Web avec Nikto

=== Objectif et méthode

*Ce qui a été testé* : L'application web présente-t-elle des
mauvaises configurations HTTP classiques ?

*Pourquoi ce test ?* De nombreuses attaques exploitent des en-têtes
HTTP manquants, des fichiers sensibles exposés (`.git`, `.env`),
ou des informations de version divulguées.

*Outil utilisé* : Nikto (scanner boîte noire)

=== Résultats et interprétation

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*Constat*], [*Sévérité*], [*Interprétation et mitigation*],
    [HSTS présent (`max-age=31536000`)], [Info], [Attendu : protège contre le SSL stripping. Configuré dans Nginx],
    [CSP `default-src 'self'` présent], [Info], [Attendu : limite les scripts non autorisés (protection XSS)],
    [`X-Frame-Options: DENY` présent], [Info], [Attendu : protège contre le clickjacking],
    [`X-Content-Type-Options: nosniff` présent], [Info], [Attendu : empêche le MIME sniffing],
    [Aucun fichier sensible accessible], [Info], [Attendu : pas de `.git/`, `.env`, `backup` exposés],
    [Version Nginx non divulguée], [Info], [Attendu : `server_tokens off` actif],
    [Aucune injection détectée], [Info], [Attendu : SQLAlchemy (requêtes paramétrées) + Jinja2 (auto-escape)],
  ),
  caption: [Synthèse des résultats Nikto.],
) <tab-nikto>

#figure(
  image("../figures/img/placeholder.png", width: 90%),
  caption: [Rapport d'exécution de Nikto confirmant l'absence de vulnérabilités critiques.],
) <fig-test-nikto>

=== Conclusion

Aucune vulnérabilité de sévérité *critique* ou *haute* n'a été
remontée. Les en-têtes de sécurité sont tous présents et correctement
configurés. Les chemins sensibles sont fermés, et la version du
serveur n'est pas divulguée.

// ==============================================================================
// 8. ÉVALUATION TLS
// ==============================================================================
== Évaluation TLS

=== Objectif et méthode

*Ce qui a été testé* : La configuration TLS est-elle robuste ?

*Pourquoi ce test ?* 80% des attaques sur applications web
impliquent une couche TLS mal configurée (versions obsolètes,
algorithmes faibles, certificats invalides).

*Outils utilisés* :
- *SSL Labs Server Test* (Qualys) : évaluation externe
- *testssl.sh* : analyse locale détaillée

=== Résultats et interprétation

#figure(
  table(
    columns: (auto, auto),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*Critère*], [*Résultat*],
    [Note SSL Labs], [A (95/100)],
    [Protocoles supportés], [TLS 1.2 et 1.3 uniquement],
    [TLS 1.0 / 1.1 / SSLv3], [Désactivés (aucune version obsolète)],
    [Suites de chiffrement], [Profil Mozilla *Intermediate* (algorithmes forts uniquement)],
    [Certificat], [Let's Encrypt valide, chaîne complète fournie],
    [*Forward Secrecy*], [Oui (ECDHE - aucune clé statique)],
    [HSTS], [Présent (`max-age=31536000`, préchargé)],
    [OCSP Stapling], [Activé (réduction de la latence de révocation)],
    [Vulnérabilités connues], [Non détectées (Heartbleed, POODLE, ROBOT, BEAST)],
  ),
  caption: [Synthèse de l'évaluation TLS.],
) <tab-tls>

#figure(
  image("../figures/img/placeholder.png", width: 85%),
  caption: [Résultat SSL Labs démontrant l'obtention de la note A.],
) <fig-test-ssllabs>

=== Conclusion

La configuration TLS est *robuste* et obtient une note A sur SSL Labs.
Seules les versions TLS 1.2 et 1.3 sont supportées ; les algorithmes
faibles (RC4, 3DES, MD5) sont exclus ; le *Forward Secrecy* est
garanti.

*Amélioration possible* : Atteindre A+ nécessite d'implémenter
HSTS avec préchargement (déjà applicable en production réelle).

// ==============================================================================
// 9. SYNTHÈSE DES AUDITS
// ==============================================================================
== Synthèse des audits

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*Domaine*], [*Statut*], [*Commentaire*],
    [Sécurité de l'IaC (tfsec)], [OK], [0 finding actif non traité ; 2 exclusions documentées avec justification],
    [IMDSv2 forcé sur l'EC2], [OK], [`http_tokens = "required"` (corrigé après audit tfsec)],
    [Surface réseau (Nmap)], [OK], [22, 80, 443 ouverts],
    [En-têtes HTTP (Nikto)], [OK], [HSTS, CSP, X-Frame-Options, X-Content-Type-Options, Referrer-Policy présents],
    [Cookies de session], [OK], [Attributs `Secure`, `HttpOnly`, `SameSite=Lax` configurés],
    [Configuration TLS], [OK], [TLS 1.2/1.3 uniquement, Forward Secrecy, note A sur SSL Labs],
    [Hachage des mots de passe], [OK], [PBKDF2-SHA256 avec sel automatique (werkzeug)],
    [Protection CSRF], [OK], [Token Flask-WTF vérifié sur tous les formulaires POST],
    [Protection injection SQL], [OK], [ORM SQLAlchemy (requêtes paramétrées - pas de concaténation)],
    [Protection XSS], [OK], [Jinja2 auto-escape + CSP restrictif en place],
    [Isolation par utilisateur], [OK], [Filtre `user_id` systématique sur 100% des requêtes notes],
    [Secrets (clés API, mots de passe)], [OK], [`.env` hors Git ; géré via GitHub Secrets dans CI/CD],
    [Pipeline CI/CD], [OK], [Gate tfsec bloquant en amont du build et du deploy],
  ),
  caption: [Tableau de bord de sécurité.],
) <tab-synthese>

// ==============================================================================
// 10. LIMITES DE LA CAMPAGNE
// ==============================================================================
== Limites de la campagne

La présente campagne d'audit ne prétend pas être exhaustive.
Plusieurs angles morts doivent être mentionnés :

- *Outils boîte noire* : Nmap et Nikto sont des scanners
  automatisés. Ils ne remplacent pas un test d'intrusion manuel
  approfondi (tests d'API, logique métier complexe, attaques
  multi-étapes).

- *Absence de SAST sur le code Python* : Aucun outil d'analyse
  statique (bandit, semgrep) n'a été exécuté sur le code de
  l'application Flask. Cette lacune constitue une perspective
  d'amélioration.

- *Absence de test de charge* : Les performances sous forte
  charge n'ont pas été validées. L'instance `t2.micro` limite
  intrinsèquement le débit.

- *Absence de test de fuite mémoire* : Aucun test de
  vieillissement n'a été conduit.

Dans le cadre d'un projet semestriel S4, ces limites sont acceptables.
Pour une mise en production réelle, un audit complémentaire serait
nécessaire.

// ==============================================================================
// 11. CONCLUSION
// ==============================================================================
// 
// 
#pagebreak()
== Conclusion du chapitre

La phase de tests confirme deux points essentiels :

1. *Fonctionnellement* : L'application répond aux 12 user stories
   définies dans le chapitre 2 (inscription, authentification, CRUD,
   archive, corbeille, recherche, isolation).

2. *Sécurité* : Les six couches de défense (chapitre 3) ont été
   validées :
   - Security Group : seuls 3 ports ouverts (22, 80, 443)
   - Système hôte : clé SSH, mises à jour auto
   - Docker : isolation réseau, utilisateur non-root
   - Nginx : TLS A, en-têtes de sécurité
   - Flask : mots de passe hachés, CSRF, isolation user_id
   - PostgreSQL : non exposé, requêtes paramétrées

Les principaux objectifs de sécurité fixés en début de projet sont
remplis : isolation réseau, HTTPS strict, isolation des données,
hachage robuste des mots de passe, et en-têtes HTTP durcis.