// chapitre 06 - Conclusion générale
#import "../variables.typ": *
#import "../standards/tables-standard.typ": *
#import "../standards/references-standard.typ": *
#import "../standards/chapter-opening.typ": *


// Page settings
#set page(numbering: "1")
#set text(size: 11pt)
#set par(justify: true, leading: 0.8em)

// ==============================================================================
// CHAPTER TITLE
// ==============================================================================
// 

#chapter-opening(
  number: 6,
  title: "Conclusion générale",
)
<chap7>

#pagebreak()

Ce projet WebCyber a permis de concevoir, de réaliser et de déployer une
application web sécurisée et conteneurisée, tout en respectant des objectifs
clairs de qualité, de reproductibilité et de sécurité.

// ==============================================================================
// 1. BILAN DU PROJET
// ==============================================================================
== Bilan du projet

Les principaux objectifs ont été atteints :

- une application de prise de notes fonctionnelle, avec authentification,
  gestion CRUD, archive, corbeille et recherche;
- une architecture conteneurisée composée de Nginx, Flask et PostgreSQL
  orchestrés par Docker Compose;
- un déploiement sur AWS avec EC2, Elastic IP, Security Group et Route 53;
- une chaîne HTTPS opérationnelle via Let's Encrypt, avec renouvellement
  automatisé;
- une approche de sécurité en profondeur fondée sur six couches : réseau,
  hôte, isolation Docker, proxy/TLS, application et base de données;
- une campagne de validation couvrant les tests fonctionnels et l'audit
  de sécurité (Nmap, Nikto, SSL Labs/testssl.sh).

Ce rapport montre que la solution développée est cohérente avec le
périmètre académique du PFE tout en conservant des pratiques proches de
l'industrie.

// ==============================================================================
// 2. APPORTS MÉTHODOLOGIQUES
// ==============================================================================
== Apports méthodologiques

Le travail réalisé a apporté plusieurs acquis importants :

- maîtrise des mécanismes de conteneurisation et des flux de données
  entre services Docker;
- compréhension de la sécurisation d'un déploiement web en production :
  gestion des certificats, configuration de Nginx, règles de pare-feu,
  isolation des services;
- capacité à documenter une architecture technique complète, de la
  conception à l'implémentation et au test;
- adoption d'une démarche d'audit pragmatique, fondée sur des outils
  standard et sur des conclusions actionnables.

=== Retour sur la démarche agile

L'approche agile adoptée a démontré sa pertinence pour un projet
académique individuel :

- *Visibilité* : le découpage en sprints a permis de montrer un
  avancement concret à chaque revue avec l'encadrant.
- *Adaptabilité* : les retours réguliers ont permis de corriger
  rapidement les choix techniques (configuration Docker, sécurité).
- *Qualité* : l'intégration précoce de la sécurité (DevSecOps) a
  réduit les corrections coûteuses en fin de projet.
- *Limites* : le travail individuel a restreint certaines pratiques
  agiles (absence de pair programming, daily remplacés par journal
  de bord personnel).

// ==============================================================================
// 3. LIMITES ET PERSPECTIVES D'ÉVOLUTION
// ==============================================================================
== Limites et perspectives d'évolution

Bien que la solution soit robuste pour un usage pédagogique et de démonstration,
plusieurs améliorations restent possibles :

- mise en place d'un pipeline CI/CD pour automatiser les tests et le
  déploiement;
- supervision et journalisation centralisées (Prometheus, Grafana,
  ELK/CloudWatch);
- audit de code statique (bandit, semgrep) et tests de sécurité
  automatisés plus poussés;
- renforcement de l'authentification par 2FA ou OAuth;
- migration vers une solution d'orchestration plus avancée (Kubernetes,
  ECS) pour améliorer la résilience et l'extensibilité;
- sauvegardes automatisées de la base PostgreSQL et procédure de
  restauration.

Ces pistes constituent des prolongements naturels pour transformer WebCyber
en une plateforme encore plus professionnelle et adaptée à un contexte de
production.

// ==============================================================================
// 4. CONCLUSION
// ==============================================================================
== Conclusion

WebCyber illustre qu'un projet de fin d'études peut être à la fois simple dans
son périmètre fonctionnel et ambitieux dans son approche architecturale et de
sécurité. La démarche adoptée, centrée sur la reproductibilité et la défense en
profondeur, offre une base solide pour évoluer vers des déploiements plus
complexes et des applications plus critiques.