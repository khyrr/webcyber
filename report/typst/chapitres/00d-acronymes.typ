// Liste des acronymes
#set page(numbering: "1")

#align(center)[
  #set text(size: 18pt, weight: "bold")
  #v(1cm)
  
  *Liste des acronymes*
  
  #v(1cm)
]

<acronyms>

// Tableau des acronymes - Version classique
#table(
  columns: (auto, 1fr),
  align: (left, left),
  stroke: (x, y) => if y == 0 { 0.5pt } else { 0.1pt },
  
  // En-tête
  [*Acronyme*], [*Signification*],
  
  // Entrées
  [ACME], [_Automatic Certificate Management Environment_ (protocole Let's Encrypt)],
  [AMI], [_Amazon Machine Image_],
  [API], [_Application Programming Interface_],
  [AWS], [_Amazon Web Services_],
  [CI/CD], [_Continuous Integration / Continuous Deployment_],
  [CIDR], [_Classless Inter-Domain Routing_],
  [CRUD], [_Create, Read, Update, Delete_],
  [CSP], [_Content Security Policy_],
  [CSRF], [_Cross-Site Request Forgery_],
  [DNS], [_Domain Name System_],
  [EBS], [_Elastic Block Store_],
  [EC2], [_Elastic Compute Cloud_],
  [EIP], [_Elastic IP Address_],
  [GHA], [_GitHub Actions_],
  [GHCR], [_GitHub Container Registry_],
  [HSTS], [_HTTP Strict Transport Security_],
  [HTTP], [_Hypertext Transfer Protocol_],
  [HTTPS], [_HTTP Secure_],
  [IaaS], [_Infrastructure as a Service_],
  [IaC], [_Infrastructure as Code_],
  [IGW], [_Internet Gateway_],
  [IDOR], [_Insecure Direct Object Reference_],
  [IMDSv2], [_Instance Metadata Service version 2_],
  [IP], [_Internet Protocol_],
  [LTS], [_Long-Term Support_],
  [MVC], [_Modèle-Vue-Contrôleur_],
  [NIST], [_National Institute of Standards and Technology_],
  [ORM], [_Object-Relational Mapping_],
  [OWASP], [_Open Web Application Security Project_],
  [PaaS], [_Platform as a Service_],
  [PBKDF2], [_Password-Based Key Derivation Function 2_],
  [PFE], [Projet de Fin d'Études],
  [SaaS], [_Software as a Service_],
  [SAST], [_Static Application Security Testing_],
  [SG], [_Security Group_],
  [SQL], [_Structured Query Language_],
  [SSH], [_Secure Shell_],
  [SSL], [_Secure Sockets Layer_],
  [TCP], [_Transmission Control Protocol_],
  [TLD], [_Top-Level Domain_],
  [TLS], [_Transport Layer Security_],
  [URL], [_Uniform Resource Locator_],
  [UML], [_Unified Modeling Language_],
  [VPC], [_Virtual Private Cloud_],
  [WSGI], [_Web Server Gateway Interface_],
  [XSS], [_Cross-Site Scripting_],
)