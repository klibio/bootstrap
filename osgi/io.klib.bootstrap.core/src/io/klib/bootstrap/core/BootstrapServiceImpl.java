package io.klib.bootstrap.core;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Deactivate;
import org.osgi.service.component.annotations.Reference;

import io.klib.bootstrap.api.BootstrapService;
import io.klib.bootstrap.api.EclipseProvisionService;
import io.klib.bootstrap.api.JavaProvisionService;
import io.klib.bootstrap.api.OomphProvisionService;
import io.klib.bootstrap.api.ProvisionResult;

/**
 * DS implementation of {@link BootstrapService}.
 *
 * <p>Wires the individual provision services together and exposes a
 * unified bootstrap facade.
 *
 * <p>The {@code @Reference}-injected fields are package-private so that
 * unit tests can supply test doubles without a running OSGi framework.
 */
@Component(service = BootstrapService.class, immediate = true)
public class BootstrapServiceImpl implements BootstrapService {

    @Reference
    JavaProvisionService javaService;

    @Reference
    EclipseProvisionService eclipseService;

    @Reference
    OomphProvisionService oomphService;

    @Activate
    void activate() {
        // lifecycle hook — extend as needed
    }

    @Deactivate
    void deactivate() {
        // lifecycle hook — extend as needed
    }

    @Override
    public ProvisionResult provisionJava(String version) {
        return javaService.install(version);
    }

    @Override
    public ProvisionResult provisionEclipse(String product) {
        return eclipseService.install(product);
    }

    @Override
    public ProvisionResult provisionOomph() {
        return oomphService.install();
    }
}
