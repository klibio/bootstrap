package io.klib.bootstrap.core;

import org.osgi.service.component.annotations.Component;

import io.klib.bootstrap.api.OomphProvisionService;
import io.klib.bootstrap.api.ProvisionResult;

/**
 * DS implementation of {@link OomphProvisionService}.
 */
@Component(service = OomphProvisionService.class)
public class OomphProvisionServiceImpl implements OomphProvisionService {

    @Override
    public ProvisionResult install() {
        // TODO: download and install the Oomph bootstrap installer
        return ProvisionResult.ok("oomph", "latest");
    }

    @Override
    public String installedVersion() {
        // TODO: detect installed Oomph version from the local installation
        return null;
    }
}
