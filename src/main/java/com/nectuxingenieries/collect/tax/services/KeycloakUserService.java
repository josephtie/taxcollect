package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.config.KeycloakProperties;
import jakarta.ws.rs.NotFoundException;
import jakarta.ws.rs.core.Response;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.keycloak.admin.client.Keycloak;
import org.keycloak.admin.client.resource.RealmResource;
import org.keycloak.admin.client.resource.RolesResource;
import org.keycloak.admin.client.resource.UserResource;

import org.keycloak.representations.idm.ClientRepresentation;
import org.keycloak.representations.idm.CredentialRepresentation;
import org.keycloak.representations.idm.RoleRepresentation;
import org.keycloak.representations.idm.UserRepresentation;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class KeycloakUserService {

    private final Keycloak keycloak;
    private final KeycloakProperties properties;



    private RealmResource realm() {
        return keycloak.realm(properties.getRealm());
    }

    // 1. Register a user (with roles)
    public String registerUser(String username, String email, String firstName, String lastName, String password, List<String> roles) {
        UserRepresentation user = new UserRepresentation();
        user.setUsername(username);
        user.setEmail(email);
        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setEnabled(false); // Must activate later
        user.setEmailVerified(false);

        CredentialRepresentation credential = new CredentialRepresentation();
        credential.setTemporary(false);
        credential.setType(CredentialRepresentation.PASSWORD);
        credential.setValue(password);
        user.setCredentials(List.of(credential));

        Response response = realm().users().create(user);
        if (response.getStatus() != 201) {
            throw new RuntimeException("Keycloak error - user not created. Status: " + response.getStatus());
        }

        String userId = extractUserIdFromResponse(response);
        //assignRoles(userId, roles);
        assignRolesClient(userId, roles);
        return userId;
    }

    // 2. Activate user
    public void activateUser(String userId) {
        UserResource userResource = realm().users().get(userId);
        UserRepresentation user = userResource.toRepresentation();
        user.setEnabled(true);
        user.setEmailVerified(true);
        userResource.update(user);
    }

    // 3. Request password reset (send email or temporary credential)
    public void requestPasswordReset(String userId, String tempPassword) {
        CredentialRepresentation credential = new CredentialRepresentation();
        credential.setTemporary(true);
        credential.setType(CredentialRepresentation.PASSWORD);
        credential.setValue(tempPassword);

        realm().users().get(userId).resetPassword(credential);
    }

    // 4. Complete password reset (user sets new password)
    public void completePasswordReset(String userId, String newPassword) {
        CredentialRepresentation credential = new CredentialRepresentation();
        credential.setTemporary(false);
        credential.setType(CredentialRepresentation.PASSWORD);
        credential.setValue(newPassword);

        realm().users().get(userId).resetPassword(credential);
    }

    // 5. Change password (admin-style, non-temporary)
    public void changePassword(String userId, String newPassword) {
        completePasswordReset(userId, newPassword);
    }

    // 6. Update user
    public void updateUser(String userId, String email, String firstName, String lastName) {
        UserResource userResource = realm().users().get(userId);
        UserRepresentation user = userResource.toRepresentation();
        user.setEmail(email);
        user.setFirstName(firstName);
        user.setLastName(lastName);
        userResource.update(user);
    }

    // 7. Delete user
    public void deleteUser(String userId) {
        realm().users().get(userId).remove();
    }

    // 8. Get all users
    public List<UserRepresentation> getAllUsers() {
        return realm().users().list();
    }

    // 9. Get only managed (enabled=true) users
    public List<UserRepresentation> getAllManagedUsers() {
        return realm().users().list().stream()
                .filter(UserRepresentation::isEnabled)
                .toList();
    }

    // 10. Remove non-activated users
    public void removeNonActivatedUsers() {
        List<UserRepresentation> nonActivated = realm().users().list().stream()
                .filter(u -> !u.isEnabled())
                .toList();
        nonActivated.forEach(u -> realm().users().get(u.getId()).remove());
    }

    // --- Helpers ---

    private String extractUserIdFromResponse(Response response) {
        String path = response.getLocation().getPath();
        return path.substring(path.lastIndexOf('/') + 1);
    }

    public void assignRoles(String userId, List<String> roles) {

        roles = roles.stream()
                .map(role -> role.trim().toUpperCase())
                .toList();
        List<ClientRepresentation> clients = realm().clients().findByClientId(properties.getClientId());
        if (clients.isEmpty()) throw new IllegalStateException("Client ID not found in Keycloak");

        String clientId = clients.get(0).getId();

        List<RoleRepresentation> clientRoles = roles.stream()
                .map(role -> realm().clients().get(clientId).roles().get(role).toRepresentation())
                .collect(Collectors.toList());

        realm().users().get(userId).roles().clientLevel(clientId).add(clientRoles);
    }

    public void assignRolesClient(String userId, List<String> roles) {

     //   RealmResource realm() = keycloak.realm("mairie");
        roles = roles.stream()
                .map(role -> role.trim().toUpperCase())
                .toList();

        Set<String> standardClientIds = Set.of(
                "account", "account-console", "admin-cli", "broker", "security-admin-console"
        );

        List<ClientRepresentation> allClients = realm().clients().findAll();
        log.info("🔎 Clients récupérés: {}", allClients.stream().map(ClientRepresentation::getClientId).toList());

        List<ClientRepresentation> customClients = allClients.stream()
                .filter(c -> !standardClientIds.contains(c.getClientId()))
                .toList();

        for (ClientRepresentation client : customClients) {
            String clientId = client.getId();
            RolesResource clientRolesResource = realm().clients().get(clientId).roles();

            List<RoleRepresentation> rolesToAssign = new ArrayList<>();
            for (String roleName : roles) {
                try {
                    RoleRepresentation role = clientRolesResource.get(roleName).toRepresentation();
                    rolesToAssign.add(role);
                } catch (NotFoundException e) {
                    log.warn("⚠️ Rôle '{}' introuvable pour le client '{}'", roleName, client.getClientId());
                }
            }

            if (!rolesToAssign.isEmpty()) {
                realm().users().get(userId).roles().clientLevel(clientId).add(rolesToAssign);
                log.info("✅ Rôles {} assignés à l’utilisateur {} pour le client {}",
                        rolesToAssign.stream().map(RoleRepresentation::getName).toList(),
                        userId, client.getClientId());
            }
        }
    }

    public void assignClientRoles(String userId, String clientIdReadable, List<String> roles) {
        if (roles == null || roles.isEmpty()) return;

        roles = roles.stream()
                .map(role -> role.trim().toUpperCase())
                .distinct()
                .toList();

        // Trouver le clientId technique (UUID)
        List<ClientRepresentation> clients = realm().clients().findByClientId("tax-backend");
        //  List<ClientRepresentation> clients = realm().clients().findByClientId(clientIdReadable);
        if (clients.isEmpty()) {
            log.warn("❌ Client '{}' non trouvé dans le realm", clientIdReadable);
            return;
        }

        String clientUuid = clients.get(0).getId();
        RolesResource clientRolesResource = realm().clients().get(clientUuid).roles();

        List<RoleRepresentation> rolesToAssign = new ArrayList<>();
        for (String roleName : roles) {
            try {
                RoleRepresentation role = clientRolesResource.get(roleName).toRepresentation();
                rolesToAssign.add(role);
            } catch (NotFoundException e) {
                log.warn("⚠️ Rôle '{}' introuvable pour le client '{}'", roleName, clientIdReadable);
            }
        }

        if (!rolesToAssign.isEmpty()) {
            realm().users().get(userId).roles().clientLevel(clientUuid).add(rolesToAssign);
            log.info("✅ Rôles client {} assignés à {} pour le client '{}'",
                    rolesToAssign.stream().map(RoleRepresentation::getName).toList(),
                    userId, clientIdReadable);
        } else {
            log.warn("⚠️ Aucun rôle valide trouvé à assigner pour le client '{}'", clientIdReadable);
        }
    }


    public void assignRolesClientAutoCreate(String userId, List<String> roles, String clientIdReadable) {
        roles = roles.stream()
                .map(role -> role.trim().toUpperCase())
                .distinct()
                .toList();

        // Récupérer le client par son clientId (lisible)
        //List<ClientRepresentation> clients = realm().clients().findByClientId(clientIdReadable);
        List<ClientRepresentation> clients = realm().clients().findByClientId(clientIdReadable);
        if (clients.isEmpty()) {
            log.warn("❌ Client '{}' introuvable dans le realm", clientIdReadable);
            return;
        }
        String clientUuid = clients.get(0).getId();
        RolesResource clientRolesResource = realm().clients().get(clientUuid).roles();

        List<RoleRepresentation> rolesToAssign = new ArrayList<>();

        for (String roleName : roles) {
            RoleRepresentation role;
            try {
                // Vérifie si le rôle existe déjà
                role = clientRolesResource.get(roleName).toRepresentation();
            } catch (NotFoundException e) {
                // Crée le rôle si non existant
                RoleRepresentation newRole = new RoleRepresentation();
                newRole.setName(roleName);
                newRole.setDescription("Rôle auto-créé : " + roleName);
                newRole.setComposite(false);

                clientRolesResource.create(newRole); // création
                log.info("➕ Rôle '{}' créé pour le client '{}'", roleName, clientIdReadable);

                // Recharge après création
                role = clientRolesResource.get(roleName).toRepresentation();
            }
            rolesToAssign.add(role);
        }

        // Assigner les rôles au user pour ce client
        if (!rolesToAssign.isEmpty()) {
            realm().users().get(userId).roles().clientLevel(clientUuid).add(rolesToAssign);
            log.info("✅ Rôles {} assignés à l’utilisateur {} pour le client {}",
                    rolesToAssign.stream().map(RoleRepresentation::getName).toList(),
                    userId, clientIdReadable);
        }
    }


    public String getUserIdByUsername(String username) {
        RealmResource realm = keycloak.realm("mairie");
        List<UserRepresentation> users = realm.users().search(username, 0, 1);

        if (!users.isEmpty()) {
            return users.get(0).getId();
        }

        throw new RuntimeException("Utilisateur introuvable dans Keycloak : " + username);
    }

    public String getClientUUID(String clientIdReadable) {
        List<ClientRepresentation> clients = keycloak.realm(properties.getRealm())
                .clients()
                .findByClientId(clientIdReadable);

        if (clients.isEmpty()) {
            throw new NotFoundException("Client non trouvé : " + clientIdReadable);
        }

        return clients.get(0).getId(); // Le premier est normalement celui recherché
    }

    public List<ClientRepresentation> getCustomClients() {
        List<ClientRepresentation> allClients = realm().clients().findAll();

        // Liste des clients standards qu'on souhaite ignorer
        Set<String> standardClientIds = Set.of(
                "account", "account-console", "admin-cli",
                "broker", "security-admin-console"
        );

        // Filtrage des clients créés manuellement
        return allClients.stream()
                .filter(client -> !standardClientIds.contains(client.getClientId()))
                .collect(Collectors.toList());
    }



    public void assignRealmRoles(String userId, List<String> roles) {
        if (roles == null || roles.isEmpty()) return;

        List<RoleRepresentation> rolesToAssign = roles.stream()
                .map(String::trim)
                .map(String::toUpperCase)
                .distinct()
                .map(roleName -> {
                    try {
                        return realm().roles().get(roleName).toRepresentation();
                    } catch (NotFoundException e) {
                        log.warn("⚠️ Rôle de realm '{}' introuvable", roleName);
                        return null;
                    }
                })
                .filter(Objects::nonNull)
                .toList();

        if (!rolesToAssign.isEmpty()) {
            realm().users().get(userId).roles().realmLevel().add(rolesToAssign);
            log.info("✅ Rôles de realm {} assignés à l’utilisateur {}", rolesToAssign.stream().map(RoleRepresentation::getName).toList(), userId);
        }
    }

}

