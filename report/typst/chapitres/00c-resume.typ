// chapitre 00c - Résumé / Abstract

// Page settings
#set page(numbering: none)
#set text(size: 11pt)
#set par(leading: 0.8em, justify: true)

// ==============================================================================
// FRENCH RÉSUMÉ
// ==============================================================================
#align(center)[
  #v(1cm)
  #set text(size: 16pt, weight: "bold")
  *Résumé*
  #v(1.5cm)
]

Ce projet de fin d'études porte sur la conception, le développement,
le déploiement et l'analyse de sécurité d'une application web de prise
de notes personnelle, baptisée *WebCyber*. L'application repose
sur le _framework_ Python *Flask* pour la couche métier,
sur *PostgreSQL* pour la persistance des données, et sur
*Nginx* comme proxy inverse assurant la terminaison TLS.
L'ensemble est *conteneurisé* avec Docker et orchestré via Docker
Compose, puis *déployé sur AWS* (instance EC2 `t2.micro`
sous Ubuntu Server 22.04 LTS), avec une résolution de nom de domaine
gérée par *Route 53* et un certificat HTTPS automatique fourni
par *Let's Encrypt*.

#v(0.6em)

Une attention particulière a été portée à la sécurité, organisée
en *six couches* : pare-feu réseau (_Security Group_ AWS),
durcissement du système, isolation Docker, configuration TLS et
en-têtes de sécurité Nginx, contrôles applicatifs (authentification,
hachage `PBKDF2-SHA256`, protection CSRF, validation des
entrées, isolation des données par utilisateur) et sécurité de la
base de données. La solution déployée a ensuite été soumise à une
campagne d'évaluation à l'aide de *Nmap*, *Nikto* et
*testssl.sh*, dont les résultats sont analysés et discutés.

// #v(0.8em)

// *Mots-clés :* application web, sécurité, cybersécurité, AWS,
// EC2, Docker, conteneurs, Nginx, Flask, PostgreSQL, HTTPS, TLS,
// Let's Encrypt, Nmap, Nikto, défense en profondeur, DevOps.

#v(2em)

#line(length: 100%)

#v(2em)

// ==============================================================================
// ENGLISH ABSTRACT
// ==============================================================================
#align(center)[
  #set text(size: 16pt, weight: "bold")
  *Abstract*
  #v(1.5cm)
]

This end-of-studies project covers the design, development, deployment
and security assessment of a personal note-taking web application named
*WebCyber*. The application is built on the Python
*Flask* framework for business logic, *PostgreSQL* for
data persistence, and *Nginx* as a reverse proxy handling TLS
termination. The whole stack is *containerised* with Docker and
orchestrated through Docker Compose, then *deployed on AWS*
(EC2 `t2.micro` instance running Ubuntu Server 22.04 LTS), with
DNS resolution provided by *Route 53* and HTTPS certificates
automatically issued by *Let's Encrypt*.

#v(0.6em)

Security has been treated as a first-class concern and structured into
*six layers*: AWS Security Group network firewall, host
hardening, Docker isolation, Nginx TLS and security headers,
application-level controls (authentication, `PBKDF2-SHA256`
password hashing, CSRF protection, input validation, per-user data
isolation) and database security. The deployed solution was then
assessed using *Nmap*, *Nikto* and *testssl.sh*,
and the results are analysed and discussed.

// #v(0.8em)

// *Keywords:* web application, security, cybersecurity, AWS, EC2,
// Docker, containers, Nginx, Flask, PostgreSQL, HTTPS, TLS, Let's Encrypt,
// Nmap, Nikto, defense-in-depth, DevOps.