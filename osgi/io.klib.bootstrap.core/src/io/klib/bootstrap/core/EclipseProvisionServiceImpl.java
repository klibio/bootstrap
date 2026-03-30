package io.klib.bootstrap.core;

import org.osgi.service.component.annotations.Component;

import io.klib.bootstrap.api.EclipseProvisionService;
import io.klib.bootstrap.api.ProvisionResult;

/**
 * DS implementation of {@link EclipseProvisionService}.
 */
@Component(service = EclipseProvisionService.class)
public class EclipseProvisionServiceImpl implements EclipseProvisionService {

    @Override
    public ProvisionResult install(String product) {
        if (product == null || product.isBlank()) {
            return ProvisionResult.failure("eclipse", "Product id must not be null or blank");
        }
        // TODO: delegate to Oomph-based installer
        return ProvisionResult.ok("eclipse", product);
    }

    @Override
    public String installedVersion() {
        // TODO: detect installed Eclipse version from the local installation
        return null;
    }
}
