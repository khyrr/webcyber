# Guide d'Intégration de l'Approche Agile - Rapport WebCyber

## 📋 Où intégrer l'Approche Agile dans le rapport

### 1. Introduction Générale (chapitres/00e-introduction.typ)
Ajouter une section après le plan du rapport :

```typst
= Approche méthodologique

Le projet a été conduit selon une *démarche agile adaptée au
contexte académique individuel*. Bien que les méthodologies agiles
(Scrum, Kanban) soient traditionnellement conçues pour des équipes,
leurs principes fondamentaux — itérations courtes, livraison
incrémentale, amélioration continue — ont structuré l'ensemble du
travail.

Trois pratiques agiles ont été retenues et adaptées :

+ *Sprints de 2-3 semaines* : chaque chapitre du rapport
  correspond à un sprint avec des objectifs précis et des
  livrables identifiés (spécifications, architecture, code,
  déploiement, tests).
+ *Revues avec l'encadrant* : des points réguliers ont
  permis de valider les orientations techniques, d'identifier
  les corrections nécessaires et d'ajuster les priorités en
  fonction des retours.
+ *Tableau Kanban personnel* : un suivi visuel des tâches
  (À faire, En cours, Terminé) a permis de limiter le travail
  en cours et de maintenir une progression régulière.

Cette approche a favorisé une *amélioration continue* tout au
long du projet, chaque sprint enrichissant la solution des
enseignements du sprint précédent, notamment en matière de
sécurité.
```

### 2. Organisation des Sprints (chapitres/00e-introduction.typ)
Tableau récapitulatif après la section méthodologie :

```typst
#standard-table(
  columns: (1cm, 1.5cm, 3cm, 4cm, 4cm),
  header: ([Sprint], [Durée], [Phase], [Objectifs], [Livrables]),
  caption: "Organisation des sprints du projet WebCyber.",
  label: <tab-sprints>,
  data: (
    ([1], [2 sem.], [Analyse], [État de l'art, cadrage], [Chapitres 1-2, spécifications]),
    ([2], [3 sem.], [Conception], [Architecture, maquettes], [Chapitre 3, schémas UML]),
    ([3], [3 sem.], [Réalisation], [Développement, Docker], [Chapitre 4, code source]),
    ([4], [2 sem.], [Déploiement], [AWS, HTTPS, CI/CD], [Chapitre 4, infra déployée]),
    ([5], [2 sem.], [Validation], [Tests, audit sécurité], [Chapitre 5, rapport d'audit]),
  ),
)
```

### 3. Dans Chaque Chapitre
Ajouter un encadré de contexte agile au début :

```typst
// Exemple pour chapitres/03-conception.typ
= Conception du Système

#text(size: 9pt, style: "italic")[
  Sprint 2 — Durée : 3 semaines — Objectif : Traduire les besoins 
  en architecture technique détaillée.
]

Ce chapitre traduit les besoins du chapitre précédent...
```

### 4. Rétrospective par Chapitre (fin de chaque chapitre)
Ajouter une mini-rétrospective :

```typst
== Bilan du sprint

*Objectifs atteints :*
- Architecture 3-tiers documentée et validée
- Schémas UML produits pour tous les cas d'utilisation
- Choix technologiques justifiés et approuvés

*Difficultés rencontrées :*
- Complexité de la configuration Docker multi-services
- Équilibrage entre simplicité pédagogique et réalisme industriel

*Améliorations pour le sprint suivant :*
- Automatiser la génération des diagrammes
- Documenter les alternatives écartées
```

### 5. Conclusion Générale (chapitres/06-conclusion.typ)
Ajouter un bilan de la méthodologie :

```typst
= Retour sur la démarche agile

L'approche agile adoptée a démontré sa pertinence pour un projet
académique individuel :

- *Visibilité* : le découpage en sprints a permis de présenter
  un avancement concret à chaque revue avec l'encadrant.
- *Adaptabilité* : les retours réguliers ont permis de
  corriger rapidement les choix inadaptés (notamment sur la
  configuration Docker et les règles de sécurité).
- *Qualité* : l'intégration continue de la sécurité dès les
  premiers sprints (Security by Design) a évité des corrections
  coûteuses en fin de projet.
- *Limites* : le travail individuel a réduit certaines
  pratiques agiles (pas de pair programming, daily stand-ups
  remplacés par un journal de bord personnel).

Cette expérience confirme que les *principes agiles* (itération,
feedback, amélioration continue) sont applicables et bénéfiques
même hors du cadre collectif pour lequel ils ont été conçus.
```

## 📊 User Stories pour WebCyber

### Format standard
```
En tant que [acteur],
je veux [fonctionnalité],
afin de [bénéfice/besoin].

Critères d'acceptation :
- [Condition mesurable 1]
- [Condition mesurable 2]
```

### Exemples pour votre projet

**US-01 : Inscription**
```
En tant que visiteur,
je veux créer un compte avec username, email et mot de passe,
afin d'accéder à l'application.

Critères d'acceptation :
- Username unique (3-80 caractères)
- Email valide et unique
- Mot de passe ≥ 8 caractères
- Redirection vers /login après inscription
```

**US-02 : Création de note**
```
En tant qu'utilisateur authentifié,
je veux créer une note avec titre et contenu,
afin de sauvegarder mes informations personnelles.

Critères d'acceptation :
- Titre obligatoire (max 200 caractères)
- Note associée à mon user_id
- Apparition dans ma liste de notes
- Horodatage automatique (created_at)
```

**US-03 : Isolation des données**
```
En tant qu'utilisateur authentifié,
je veux que mes notes soient inaccessibles aux autres utilisateurs,
afin de garantir la confidentialité de mes données.

Critères d'acceptation :
- Accès à /notes/42 d'un autre utilisateur → 404
- Liste des notes filtrée par user_id
- Modification impossible sur les notes d'autrui
```

## 🎯 Product Backlog (Priorisé)

| ID | User Story | Priorité | Sprint | Statut |
|----|-----------|----------|--------|--------|
| US-01 | Inscription | Haute | 3 | ✅ Fait |
| US-02 | Connexion/Déconnexion | Haute | 3 | ✅ Fait |
| US-03 | Créer une note | Haute | 3 | ✅ Fait |
| US-04 | Liste des notes | Haute | 3 | ✅ Fait |
| US-05 | Modifier une note | Moyenne | 3 | ✅ Fait |
| US-06 | Supprimer une note | Moyenne | 3 | ✅ Fait |
| US-07 | Archiver/Désarchiver | Basse | 4 | ✅ Fait |
| US-08 | Corbeille/Restauration | Basse | 4 | ✅ Fait |
| US-09 | Recherche de notes | Basse | 4 | ✅ Fait |
| US-10 | Isolation par utilisateur | Critique | 3-5 | ✅ Fait |
| US-11 | HTTPS + Let's Encrypt | Critique | 4 | ✅ Fait |
| US-12 | Pipeline CI/CD | Moyenne | 4 | ✅ Fait |
| US-13 | Audit sécurité (Nmap, Nikto) | Haute | 5 | ✅ Fait |

## 📈 Indicateurs de Suivi

### Burndown Chart (optionnel)
À intégrer comme figure si vous avez suivi votre progression :

```typst
#standard-figure(
  image-path: "../figures/img/burndown-chart.png",
  caption: "Graphique d'avancement des sprints.",
  label: <fig-burndown>,
  width: 90%,
)
```

### Définition of Done (DoD)
```typst
#standard-table(
  columns: (1fr),
  header: ([Critères "Definition of Done" pour chaque livrable]),
  caption: "Définition of Done du projet.",
  label: <tab-dod>,
  data: (
    ([✅ Code fonctionnel et testé]),
    ([✅ Documentation associée rédigée]),
    ([✅ Revue par l'encadrant effectuée]),
    ([✅ Intégration validée (composants, sécurité)]),
    ([✅ Commit Git avec message descriptif]),
  ),
)
```

## 🔧 Kanban Personnel (Workflow)

```typst
= Workflow de développement

Le suivi quotidien s'est appuyé sur un *tableau Kanban simplifié*
organisé en quatre colonnes :

- *Backlog* : ensemble des tâches identifiées pour le sprint
  en cours.
- *En cours* : tâche active (limité à 2 maximum pour éviter
  la dispersion).
- *En revue* : tâche terminée, en attente de validation par
  l'encadrant ou de tests complémentaires.
- *Terminé* : tâche validée, documentation associée complète.

Cette visualisation a permis de *limiter le travail en cours*
et de *prioriser efficacement*, en concentrant l'effort sur
les fonctionnalités à plus forte valeur ajoutée (sécurité,
déploiement) avant les améliorations secondaires.
```

## 🛡️ DevSecOps dans l'Agile

```typst
= Intégration de la sécurité dans le cycle agile

Le projet a appliqué une démarche *DevSecOps* en intégrant la
sécurité à chaque phase du cycle de développement :

- *Sprint 1* : identification des risques OWASP Top 10
  applicables au périmètre fonctionnel.
- *Sprint 2* : conception de la sécurité en profondeur
  (6 couches) comme exigence non fonctionnelle prioritaire.
- *Sprint 3* : implémentation des contrôles de sécurité
  dans le code (hachage, CSRF, isolation).
- *Sprint 4* : sécurisation de l'infrastructure (Security
  Group, TLS, en-têtes HTTP).
- *Sprint 5* : validation par des tests de sécurité
  automatisés (tfsec, Nmap, Nikto, testssl.sh).

Cette approche *shift-left* a permis de détecter et de corriger
les vulnérabilités au fil du développement, évitant ainsi des
corrections coûteuses en fin de projet.
```

## 📝 Checklist d'Intégration Finale

- [ ] Ajouter la section "Approche méthodologique" dans l'introduction
- [ ] Insérer le tableau des sprints dans l'introduction
- [ ] Ajouter un contexte de sprint au début de chaque chapitre (optionnel)
- [ ] Ajouter une mini-rétrospective à la fin de chaque chapitre
- [ ] Ajouter le bilan méthodologique dans la conclusion
- [ ] Créer un diagramme de burndown (optionnel, si données disponibles)
- [ ] Vérifier la cohérence entre les user stories et les besoins fonctionnels
- [ ] Ajouter la section DevSecOps si pertinente

---

## 🎨 Exemple Complet : Introduction avec Approche Agile

```typst
// Extrait pour chapitres/00e-introduction.typ

= Approche méthodologique

== Une démarche agile adaptée au travail individuel

Le projet a été mené selon les principes des *méthodologies agiles*,
adaptés au contexte d'un travail académique individuel. Cette approche
repose sur trois piliers :

+ *Itérations courtes* : le projet a été découpé en 5 sprints
  de 2 à 3 semaines, chaque sprint correspondant à un chapitre
  du présent rapport.
+ *Amélioration continue* : chaque sprint s'est conclu par
  une revue avec l'encadrant et une rétrospective personnelle,
  permettant d'ajuster les priorités et les choix techniques.
+ *Limitation du travail en cours* : un tableau Kanban
  personnel a permis de suivre les tâches et de se concentrer
  sur un nombre réduit d'objectifs simultanés.

== Organisation des sprints

#standard-table(
  columns: (1cm, 1.5cm, 3cm, 4cm, 4cm),
  header: ([S], [Durée], [Phase], [Objectifs], [Livrables]),
  caption: "Organisation des sprints du projet WebCyber.",
  label: <tab-sprints>,
  data: (
    ([1], [2 sem.], [Analyse], [État de l'art, spécifications], [Chapitres 1-2]),
    ([2], [3 sem.], [Conception], [Architecture, UML], [Chapitre 3]),
    ([3], [3 sem.], [Réalisation], [Code, conteneurisation], [Chapitre 4]),
    ([4], [2 sem.], [Déploiement], [AWS, HTTPS, CI/CD], [Chapitre 4]),
    ([5], [2 sem.], [Validation], [Tests, audit sécurité], [Chapitre 5]),
  ),
)

Cette organisation a permis une progression régulière et mesurable,
chaque sprint produisant un livrable concret (chapitre du rapport,
code fonctionnel, infrastructure déployée) tout en maintenant la
flexibilité nécessaire à un projet exploratoire combinant développement
logiciel et analyse de cybersécurité.
```