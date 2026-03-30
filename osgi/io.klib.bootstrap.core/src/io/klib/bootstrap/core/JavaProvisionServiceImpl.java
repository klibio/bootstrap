package io.klib.bootstrap.core;

import java.util.List;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Deactivate;

import io.klib.bootstrap.api.JavaProvisionService;
import io.klib.bootstrap.api.ProvisionResult;

/**
 * DS implementation of {@link JavaProvisionService}.
 *
 * <p>Fields are package-private to enable direct assignment in unit tests
 * without requiring a running OSGi framework.
 */
@Component(service = JavaProvisionService.class)
public class JavaProvisionServiceImpl implements JavaProvisionService {

    @Activate
    void activate() {
        // lifecycle hook — extend as needed
    }

    @Deactivate
    void deactivate() {
        // lifecycle hook — extend as needed
    }

    @Override
    public List<String> availableVersions() {
        return List.of("17", "21", "25");
    }

    @Override
    public ProvisionResult install(String version) {
        if (version == null || version.isBlank()) {
            return ProvisionResult.failure("java", "Version must not be null or blank");
        }
        if (!availableVersions().contains(version)) {
            return ProvisionResult.failure("java", "Unsupported version: " + version);
        }
        // TODO: delegate to actual JDK download/install logic
        return ProvisionResult.ok("java", version);
    }

    @Override
    public void setActive(String version) {
        // TODO: update PATH / JAVA_HOME for the given JDK version
    }
}
