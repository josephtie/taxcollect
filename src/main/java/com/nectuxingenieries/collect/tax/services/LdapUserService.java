package com.nectuxingenieries.collect.tax.services;



import com.nectuxingenieries.collect.tax.models.dto.LdapUserDTO;
import com.nectuxingenieries.collect.tax.security.PasswordEncoder;
import com.unboundid.ldap.sdk.*;
import com.unboundid.ldap.sdk.ModificationType;
import com.unboundid.ldif.LDIFException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


@Service
public class LdapUserService {
    private static final Logger log = LoggerFactory.getLogger(LdapUserService.class);
    private static final String BASE_DN = "dc=nectux,dc=com";
    private static final String USERS_OU = "ou=users," + BASE_DN;
    private static final String GROUPS_OU = "ou=groups," + BASE_DN;

    private static final String LDAP_HOST = "localhost";
    private static final int LDAP_PORT = 389;
    private static final String LDAP_BIND_DN = "cn=admin,dc=nectux,dc=com";
    private static final String LDAP_PASSWORD = "admin";

    @Autowired KeycloakUserService  keycloakUserService;
    private LDAPConnection getConnection() throws LDAPException {
        return new LDAPConnection(LDAP_HOST, LDAP_PORT, LDAP_BIND_DN, LDAP_PASSWORD);
    }

    public void createUser(String matricule, String firstName, String lastName, String email, String password, List<String> roles) {
        String fullName = firstName + " " + lastName + " " + matricule;
        String userDN = "cn=" + fullName + "," + USERS_OU;

        if (matricule == null || firstName == null || lastName == null || email == null || password == null) {
            throw new IllegalArgumentException("Tous les champs requis doivent être renseignés");
        }

        if (roles == null) {
            roles = new ArrayList<>();
        }
        try (LDAPConnection conn = getConnection()) {

            // Vérifie si un utilisateur avec ce DN existe déjà
            if (entryExists(conn, userDN)) {
                log.warn("Utilisateur avec DN {} existe déjà", userDN);
                return;
            }

            // Vérifie si un UID ou mail existe déjà
            if (attributeExists(conn, USERS_OU, "(uid=" + matricule + ")") || attributeExists(conn, USERS_OU, "(mail=" + email + ")")) {
                log.warn("Utilisateur avec uid {} ou email {} existe déjà", matricule, email);
                return;
            }

            // Création de l'utilisateur
            Entry entry = new Entry(userDN);
            entry.addAttribute("objectClass", "inetOrgPerson", "organizationalPerson", "person", "top");
            entry.addAttribute("cn", fullName);
            entry.addAttribute("sn", lastName);
            entry.addAttribute("uid", matricule);
            entry.addAttribute("mail", email);
            String encodedPassword = PasswordEncoder.encodeSSHA(password);
            entry.addAttribute("userPassword", encodedPassword); // tu peux encoder ici en SSHA si nécessaire

            conn.add(entry);
            log.info("✅ Utilisateur LDAP créé: {}", userDN);

            for (String role : roles) {
                addUserToGroup(conn, userDN, role);
            }

            String userId = keycloakUserService.getUserIdByUsername(matricule);
          //  String clientId = keycloakUserService.getClientUUID("tax-backend");
           // keycloakUserService.assignRealmRoles(userId, roles);
        //    keycloakUserService.assignRolesClientAutoCreate(userId,roles ,clientId);

            String clientId1 = keycloakUserService.getClientUUID("tax-backend");
            String clientId2 = keycloakUserService.getClientUUID("web-app");
            String clientId3 = keycloakUserService.getClientUUID("mobile-app");

            keycloakUserService.assignRolesClientAutoCreate(userId, roles, "tax-backend");
            keycloakUserService.assignRolesClientAutoCreate(userId, roles, "web-app");
            keycloakUserService.assignRolesClientAutoCreate(userId, roles, "mobile-app");

        } catch (LDAPException e) {
            log.error("❌ Erreur création utilisateur LDAP: {}", e.getMessage(), e);
        }
    }


    public void resetPassword(String userDN, String newPassword) {
        try (LDAPConnection conn = getConnection()) {
            String encodedPassword = PasswordEncoder.encodeSSHA(newPassword);
            Modification mod = new Modification(ModificationType.REPLACE, "userPassword", encodedPassword);
            conn.modify(userDN, mod);
            log.info("Mot de passe mis à jour pour : {}", userDN);
        } catch (LDAPException e) {
            log.error("Erreur modification mot de passe : {}", e.getMessage(), e);
        }
    }

    public void deleteUser(String userDN) {
        try (LDAPConnection conn = getConnection()) {
            conn.delete(userDN);
            log.info("Utilisateur supprimé : {}", userDN);
        } catch (LDAPException e) {
            log.warn("Suppression utilisateur échouée : {}", e.getMessage(), e);
        }
    }

    public boolean userExists(String matricule) {
        String filter = "(uid=" + matricule + ")";
        try (LDAPConnection conn = getConnection()) {
            SearchResult result = conn.search(USERS_OU, SearchScope.SUB, filter);
            return result.getEntryCount() > 0;
        } catch (LDAPSearchException e) {
            return false;
        } catch (LDAPException e) {
            log.error("Erreur recherche utilisateur: {}", e.getMessage());
            return false;
        }
    }

    private boolean entryExists(LDAPConnection conn, String dn) {
        try {
            return conn.getEntry(dn) != null;
        } catch (LDAPException e) {
            log.warn("Erreur lors de la vérification du DN {}: {}", dn, e.getMessage());
            return false;
        }
    }

    private boolean attributeExists(LDAPConnection conn, String baseDN, String filter) {
        try {
            SearchResult result = conn.search(baseDN, SearchScope.SUB, filter);
            return result.getEntryCount() > 0;
        } catch (LDAPSearchException e) {
            return false;
        } catch (LDAPException e) {
            log.error("Erreur de recherche LDAP avec filtre {}: {}", filter, e.getMessage());
            return false;
        }
    }


    private void addUserToGroup(LDAPConnection conn, String userDn, String role) throws LDAPException {
        String groupDn = "cn=" + role.toUpperCase() + "," + GROUPS_OU;

        Modification mod = new Modification(ModificationType.ADD, "member", userDn);

        try {
            conn.modify(groupDn, mod);
            log.info("Ajouté à groupe : {}", groupDn);
        } catch (LDAPException e) {
            if (e.getResultCode() == ResultCode.ATTRIBUTE_OR_VALUE_EXISTS) {
                log.info("Déjà membre de : {}", groupDn);
            } else {
                throw e;
            }
        }
    }

    private String findUserDnByMatricule(LDAPConnection conn, String matricule) {
        String baseDn = USERS_OU; // ex: "ou=users,dc=sigemena,dc=com"
        String filter = "(uid=" + matricule + ")";

        try {
            SearchResult searchResult = conn.search(baseDn, SearchScope.SUB, filter);
            if (!searchResult.getSearchEntries().isEmpty()) {
                return searchResult.getSearchEntries().get(0).getDN();
            } else {
                log.warn("🔍 Aucun utilisateur trouvé pour le matricule {}", matricule);
                return null;
            }
        } catch (LDAPSearchException e) {
            log.error("❌ Erreur lors de la recherche du DN pour le matricule {}: {}", matricule, e.getMessage());
            return null;
        }
    }


    public void deleteUserByMatricule(String matricule) {
        try (LDAPConnection conn = getConnection()) {
            String userDn = findUserDnByMatricule(conn, matricule);
            if (userDn == null) {
                log.warn("❗ Utilisateur introuvable pour suppression (matricule={})", matricule);
                return;
            }
            removeUserFromAllGroups(conn, userDn); // 💡 Avant la suppression
            conn.delete(userDn);
            log.info("🗑️ Utilisateur supprimé du LDAP : {}", userDn);

        } catch (LDAPException e) {
            log.error("❌ Erreur lors de la suppression de l'utilisateur (matricule={}): {}", matricule, e.getMessage(), e);
        }
    }


    public void updateUser(String matricule, String newFirstName, String newLastName, String newEmail) {
        try (LDAPConnection conn = getConnection()) {
            String userDn = findUserDnByMatricule(conn, matricule);
            if (userDn == null) {
                log.warn("Utilisateur non trouvé pour mise à jour: {}", matricule);
                return;
            }

            List<Modification> mods = new ArrayList<>();
            mods.add(new Modification(ModificationType.REPLACE, "givenName", newFirstName));
            mods.add(new Modification(ModificationType.REPLACE, "sn", newLastName));
            mods.add(new Modification(ModificationType.REPLACE, "mail", newEmail));

            conn.modify(userDn, mods);
            log.info("🔁 Utilisateur mis à jour : {}", userDn);
        } catch (LDAPException e) {
            log.error("Erreur mise à jour LDAP : {}", e.getMessage(), e);
        }
    }

    private void removeUserFromAllGroups(LDAPConnection conn, String userDn) {
        String groupBaseDn = "ou=groups,dc=nectux,dc=com"; // adapte à ta config

        try {
            Filter filter = Filter.createEqualityFilter("member", userDn);
            SearchResult result = conn.search(groupBaseDn, SearchScope.SUB, filter);

            for (SearchResultEntry groupEntry : result.getSearchEntries()) {
                String groupDn = groupEntry.getDN();
                Modification mod = new Modification(ModificationType.DELETE, "member", userDn);
                conn.modify(groupDn, mod);
                log.info("👤 Retiré de groupe : {}", groupDn);
            }

        } catch (LDAPException e) {
            log.error("Erreur suppression des groupes pour {}: {}", userDn, e.getMessage());
        }
    }

    public void assignUserToGroup(String matricule, String groupName) {
        try (LDAPConnection conn = getConnection()) {
            String userDn = findUserDnByMatricule(conn, matricule);
            if (userDn == null) return;

            String groupDn = "cn=" + groupName + ",ou=groups,dc=sigemena,dc=com";
            conn.modify(groupDn, new Modification(ModificationType.ADD, "member", userDn));
            log.info("✅ {} ajouté au groupe {}", matricule, groupName);
        } catch (LDAPException e) {
            log.error("❌ assignUserToGroup: {}", e.getMessage());
        }
    }

    public void removeUserFromGroup(String matricule, String groupName) {
        try (LDAPConnection conn = getConnection()) {
            String userDn = findUserDnByMatricule(conn, matricule);
            if (userDn == null) return;

            String groupDn = "cn=" + groupName + ",ou=groups,dc=sigemena,dc=com";
            conn.modify(groupDn, new Modification(ModificationType.DELETE, "member", userDn));
            log.info("🧹 {} retiré du groupe {}", matricule, groupName);
        } catch (LDAPException e) {
            log.error("❌ removeUserFromGroup: {}", e.getMessage());
        }
    }

    public void removeAllUsersFromGroup(String groupName) {
        try (LDAPConnection conn = getConnection()) {
            String groupDn = "cn=" + groupName + ",ou=groups,dc=sigemena,dc=com";

            SearchResultEntry groupEntry = conn.getEntry(groupDn);
            if (groupEntry == null) {
                log.warn("Groupe non trouvé : {}", groupName);
                return;
            }

            String[] members = groupEntry.getAttributeValues("member");
            if (members == null) return;

            for (String userDn : members) {
                Modification mod = new Modification(ModificationType.DELETE, "member", userDn);
                conn.modify(groupDn, mod);
                log.info("🧹 Supprimé {} du groupe {}", userDn, groupName);
            }

        } catch (LDAPException e) {
            log.error("Erreur lors du nettoyage du groupe {}: {}", groupName, e.getMessage(), e);
        }
    }


    public List<LdapUserDTO> getGroupMembers(String groupName) {
        List<LdapUserDTO> users = new ArrayList<>();

        try (LDAPConnection conn = getConnection()) {
            String groupDn = "cn=" + groupName + ",ou=groups,dc=sigemena,dc=com"; // adapte si besoin

            SearchResultEntry groupEntry = conn.getEntry(groupDn);
            if (groupEntry == null) {
                log.warn("🔍 Groupe non trouvé : {}", groupName);
                return List.of();
            }

            List<String> memberDns = List.of(groupEntry.getAttributeValues("member"));
            if (memberDns != null) {
                for (String memberDn : memberDns) {
                    Entry userEntry = conn.getEntry(memberDn);
                    if (userEntry != null) {
                        LdapUserDTO dto = new LdapUserDTO();
                        dto.setDn(userEntry.getDN());
                        dto.setUid(userEntry.getAttributeValue("uid"));
                        dto.setCn(userEntry.getAttributeValue("cn"));
                        dto.setSn(userEntry.getAttributeValue("sn"));
                        dto.setGivenName(userEntry.getAttributeValue("givenName"));
                        dto.setMail(userEntry.getAttributeValue("mail"));
                        users.add(dto);
                    }
                }
            }

        } catch (LDAPException e) {
            log.error("❌ Erreur récupération membres du groupe {}: {}", groupName, e.getMessage());
        }

        return users;
    }


}

