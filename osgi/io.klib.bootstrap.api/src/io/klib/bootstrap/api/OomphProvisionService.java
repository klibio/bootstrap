package io.klib.bootstrap.api;

import org.osgi.annotation.versioning.ProviderType;

/**
 * Service for provisioning Oomph, the Eclipse installer / updater.
 */
@ProviderType
public interface OomphProvisionService {

    /**
     * Download and install the Oomph installer.
     *
     * @return the result of the provision operation
     */
    ProvisionResult install();

    /**
     * Return the currently installed Oomph version, or {@code null} if not installed.
     *
     * @return version string or {@code null}
     */
    String installedVersion();
}
