package io.klib.bootstrap.api;

import org.osgi.annotation.versioning.ProviderType;

/**
 * Service for provisioning an Eclipse IDE installation.
 */
@ProviderType
public interface EclipseProvisionService {

    /**
     * Install or update the Eclipse product identified by {@code product}.
     *
     * @param product the Eclipse product id (e.g. {@code "eclipse.platform.ide"})
     * @return the result of the provision operation
     */
    ProvisionResult install(String product);

    /**
     * Return the currently installed Eclipse version, or {@code null} if not installed.
     *
     * @return version string or {@code null}
     */
    String installedVersion();
}
