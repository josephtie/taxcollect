# TaxCollect — Personas

## 1. Agent de terrain — Joseph Kabasele

**Rôle** : `AGENT`

**Profil**
- Âge : 32 ans
- Poste : Agent de recensement et collecte de taxes
- Zone : Marché central de la commune
- Équipement : Smartphone Android (Samsung Galaxy A14), connexion 4G intermittente
- Expérience : 3 ans sur le terrain, connaît bien les commerçants de sa zone

**Objectifs**
- Recenser les contribuables de sa zone rapidement
- Encaisser les taxes sur le terrain (espèces et mobile money)
- Clôturer sa caisse en fin de journée
- Travailler en mode hors-ligne quand le réseau est indisponible

**Frustrations**
- La connexion réseau est instable sur le marché, il perd parfois ses saisies
- Les reçus papier s'abîment avec la pluie
- Il ne sait pas toujours quels contribuables ont déjà payé ce mois-ci
- Les files d'attente se forment quand la saisie est lente

**Scénarios clés**
- Recenser un nouveau commerçant avec photo de sa pièce d'identité
- Scanner le QR code d'un contribuable pour encaisser une taxe
- Travailler hors-ligne et synchroniser en fin de journée
- Soumettre sa clôture de caisse au trésorier

---

## 2. Trésorier — Marie Kalombo

**Rôle** : `TRESOR`

**Profil**
- Âge : 45 ans
- Poste : Trésorier de la mairie
- Équipement : Ordinateur de bureau, connexion fibre optique stable
- Expérience : 10 ans dans la gestion financière de la mairie

**Objectifs**
- Valider les clôtures de caisse des agents
- Suivre les recettes en temps réel (tableau de bord)
- Détecter les écarts entre montants déclarés et montants réels
- Confirmer les dépôts en banque

**Frustrations**
- Les agents soumettent parfois des clôtures incomplètes
- Les écarts de caisse sont difficiles à tracer sans horodatage
- Elle doit relancer manuellement les agents pour les justificatifs

**Scénarios clés**
- Consulter les clôtures en attente de validation
- Valider ou rejeter une clôture avec commentaire
- Visualiser les statistiques de collecte par zone et par période
- Confirmer un dépôt en banque avec référence bancaire

---

## 3. Administrateur — Patrick Mbumba

**Rôle** : `ADMIN`

**Profil**
- Âge : 38 ans
- Poste : Responsable informatique de la mairie
- Équipement : Ordinateur portable, accès VPN, droits administrateur
- Expérience : 15 ans en administration système

**Objectifs**
- Gérer les utilisateurs et leurs rôles (Keycloak + LDAP)
- Configurer les taxes, zones de collecte et communes
- Surveiller la santé du système (logs, performances)
- Gérer les migrations de base de données (Flyway)

**Frustrations**
- La configuration des rôles dans Keycloak est complexe
- Les pics de charge en fin de journée ralentissent le système
- Il doit intervenir manuellement pour les synchronisations bloquées

**Scénarios clés**
- Créer un nouvel agent et lui assigner une zone
- Configurer une nouvelle taxe (taux ou montant fixe)
- Exporter les données de transactions pour audit
- Désactiver un utilisateur suspendu

---

## 4. Superviseur — Esther Lukusa

**Rôle** : `SUPERVISEUR`

**Profil**
- Âge : 40 ans
- Poste : Chef de service recouvrement
- Équipement : Tablette + smartphone, connexion 4G
- Expérience : 8 ans en supervision d'équipes terrain

**Objectifs**
- Suivre la productivité des agents en temps réel
- Vérifier la conformité des recensements (GPS, photos, QR codes)
- Analyser les performances par zone et par agent
- Approuver les contribuables nécessitant une validation

**Frustrations**
- Elle ne voit pas où sont les agents en temps réel (GPS)
- Les recensements incomplets nécessitent des retours sur le terrain
- Les statistiques sont dispersées dans plusieurs exports

**Scénarios clés**
- Visualiser la carte des recensements du jour avec GPS
- Comparer les performances des agents par zone
- Valider un contribuable en attente de validation
- Générer un rapport de productivité hebdomadaire
- **Affecter un agent à une zone** de collecte (`POST /api/taxcollect/agent/{agentId}/zones/{zoneId}`)
- **Retirer un agent d'une zone** (réaffectation, congé) (`DELETE /api/taxcollect/agent/{agentId}/zones/{zoneId}`)
- **Consulter les agents par zone** pour rééquilibrer les affectations (`GET /api/taxcollect/agent/zone/{zoneId}`)
- **Suspendre ou réactiver un agent** selon son comportement (`PUT /api/taxcollect/agent/{id}/status`)

---

## 5. Contribuable — Augustin Mwamba

**Rôle** : Aucun (utilisateur indirect via QR code)

**Profil**
- Âge : 50 ans
- Activité : Commerçant au marché central, vente de tissus
- Équipement : Téléphone basique (feature phone)
- Expérience : Commerce depuis 20 ans, paie ses taxes mensuellement

**Objectifs**
- Payer ses taxes rapidement sans perdre de temps de vente
- Avoir un reçu fiable (QR code) qu'il peut présenter en cas de contrôle
- Comprendre ce qu'il paie et pourquoi

**Frustrations**
- Les agents passent à des moments irréguliers
- Il perd parfois ses reçus papier
- Il ne comprend pas toujours le détail des taxes

**Scénarios clés**
- Être recensé une première fois (photo, pièce d'identité, QR code généré)
- Présenter son QR code à l'agent pour un paiement rapide
- Vérifier la validité de son QR code lors d'un contrôle
