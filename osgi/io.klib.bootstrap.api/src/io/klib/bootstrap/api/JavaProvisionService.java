package io.klib.bootstrap.api;

import java.util.List;

import org.osgi.annotation.versioning.ProviderType;

/**
 * Service for discovering and installing JDK distributions.
 */
@ProviderType
public interface JavaProvisionService {

    /**
     * List JDK versions available for installation.
     *
     * @return immutable list of version strings (e.g. {@code ["17", "21", "25"]})
     */
    List<String> availableVersions();

    /**
     * Install a JDK of the given version.
     *
     * @param version the version to install (e.g. {@code "21"})
     * @return the result of the install operation
     */
    ProvisionResult install(String version);

    /**
     * Make the given version the active/default JDK on the system.
     *
     * @param version the version to activate
     */
    void setActive(String version);
}
