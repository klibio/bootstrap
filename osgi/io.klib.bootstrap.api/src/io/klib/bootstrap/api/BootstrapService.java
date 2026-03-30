package io.klib.bootstrap.api;

import org.osgi.annotation.versioning.ProviderType;

/**
 * Orchestrates the full developer-environment bootstrap.
 *
 * <p>Implementations are registered as OSGi DS components and wired
 * with the individual provision services.
 */
@ProviderType
public interface BootstrapService {

    /**
     * Provision a specific Java version (e.g. {@code "21"}).
     *
     * @param version the JDK version string
     * @return the result of the provision operation
     */
    ProvisionResult provisionJava(String version);

    /**
     * Provision the Eclipse IDE using Oomph.
     *
     * @param product the Eclipse product id (e.g. {@code "eclipse.platform.ide"})
     * @return the result of the provision operation
     */
    ProvisionResult provisionEclipse(String product);

    /**
     * Provision the Oomph installer / updater.
     *
     * @return the result of the provision operation
     */
    ProvisionResult provisionOomph();
}
