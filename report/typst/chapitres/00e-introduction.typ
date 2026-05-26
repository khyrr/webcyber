// chapitre 00e - Introduction Générale
#import "../variables.typ": *
#import "../standards/chapter-opening.typ": *

// Page settings
#set page(numbering: "1")
#set text(size: 11pt)
#set par(leading: 0.8em, justify: true)

#special-chapter-opening(
  title: "Introduction Générale",
)
<intro-generale>

= Contexte

À l'ère du numérique, la plupart des services quotidiens — banque, communication, commerce, administration — reposent sur des applications web hébergées dans le *cloud*. Cette transformation s'accompagne d'une hausse constante des cyberattaques.

> Selon le *Verizon Data Breach Investigations Report 2023*, plus de 80% des compromissions exploitent des vulnérabilités applicatives ou des erreurs de configuration.

Développer une application web ne se limite donc plus à écrire du code fonctionnel. Il faut aussi maîtriser l'hébergement, le réseau, le cycle de déploiement et — surtout — la *surface d'attaque*.

Les pratiques *DevOps* et la conteneurisation (Docker) ont profondément changé le paysage technique. Docker offre une portabilité parfaite entre les environnements. Les fournisseurs cloud comme AWS permettent de provisionner des infrastructures complexes en quelques minutes.

*Mais la maîtrise isolée de ces outils ne suffit pas.* Leur intégration sécurisée reste un défi, même pour des applications simples.

= Problématique

Combien de bases de données sont exposées par erreur sur Internet ? Combien de certificats TLS expirés, d'APIs non authentifiées, de conteneurs tournant en `root`, de pare-feu mal configurés ?

La difficulté n'est pas technique — les solutions existent. Elle est *méthodologique* : comment articuler ces bonnes pratiques de manière cohérente, vérifiable et documentée ?

#quote(block: true)[
  *Comment concevoir, déployer et valider la sécurité d'une application web cloud-native, en appliquant systématiquement les bonnes pratiques — depuis la couche réseau jusqu'au code applicatif — dans un projet académique individuel ?*
]

Ce projet apporte une réponse concrète à cette question.

= Objectifs

Le projet *WebCyber* poursuit six objectifs principaux :

1. *Concevoir* une application réaliste (prise de notes, authentification, CRUD) et la conteneuriser intégralement avec Docker Compose.

2. *Déployer* sur une infrastructure cloud minimale mais professionnelle (AWS EC2, Security Group, Elastic IP, Route 53).

3. *Sécuriser en profondeur* : réseau, système hôte, conteneurs, proxy Nginx (TLS), application Flask (hachage, CSRF, isolation) et base de données.

4. *Automatiser* le déploiement via CI/CD (GitHub Actions) avec une gate de sécurité (tfsec).

5. *Auditer* la sécurité déployée avec des outils standards (Nmap, Nikto, testssl.sh).

6. *Documenter* l'ensemble pour permettre la reproductibilité par un tiers.

= Approche méthodologique

Le projet suit une *démarche agile adaptée au contexte académique individuel*. Trois pratiques agiles ont été retenues :

- *Sprints de 2-3 semaines* : chaque sprint livre un incrément tangible (chapitre, composant, déploiement).
- *Revues régulières* : points hebdomadaires avec l'encadrant pour ajuster les priorités.
- *Kanban personnel* : suivi visuel des tâches (À faire → En cours → Terminé).

La planification s'organise en cinq sprints :

#figure(
  table(
    columns: (1cm, 2cm, 3.5cm, 4cm, 4cm),
    align: (left,),
    stroke: (x, y) => {
      if y == 0 { return 1pt + black }
      if y == 1 { return 0.5pt + black }
      return 0.3pt + rgb(200, 200, 200)
    },
    inset: 6pt,
    [*Sprint*], [*Durée*], [*Phase*], [*Objectifs*], [*Livrables*],
    [1], [2 sem.], [Analyse], [État de l'art, cadrage], [Chapitres 1-2],
    [2], [3 sem.], [Conception], [Architecture, UML], [Chapitre 3],
    [3], [3 sem.], [Réalisation], [Développement, conteneurisation], [Chapitre 4],
    [4], [2 sem.], [Déploiement], [AWS, HTTPS, CI/CD], [Chapitre 4],
    [5], [2 sem.], [Validation], [Tests, audit sécurité], [Chapitre 5],
  ),
  caption: [Organisation des sprints du projet WebCyber.],
) <tab-sprints>

Cette organisation garantit une progression mesurable, des revues régulières et des ajustements en continu.

= Plan du rapport

Le mémoire s'articule autour de cinq chapitres :

- *Chapitre 1 — Contexte et état de l'art* : cloud computing, conteneurisation, architecture web, OWASP Top 10.

- *Chapitre 2 — Analyse des besoins* : acteurs, cas d'utilisation, besoins fonctionnels et non fonctionnels, user stories.

- *Chapitre 3 — Conception* : architecture globale (AWS + Docker), modèle de données, sécurité *en profondeur* (6 couches).

- *Chapitre 4 — Réalisation et déploiement* : infrastructure as code (Terraform), CI/CD (GitHub Actions), HTTPS (Let's Encrypt).

- *Chapitre 5 — Tests et audit de sécurité* : scans réseau, analyse applicative, évaluation TLS, synthèse des résultats.

Une *conclusion générale* dresse le bilan et propose des perspectives (Kubernetes, CI/CD complet, monitoring).