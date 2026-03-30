package io.klib.bootstrap.test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.osgi.framework.BundleContext;
import org.osgi.test.common.annotation.InjectBundleContext;
import org.osgi.test.common.annotation.InjectService;
import org.osgi.test.junit5.context.BundleContextExtension;
import org.osgi.test.junit5.service.ServiceExtension;

import io.klib.bootstrap.api.BootstrapService;
import io.klib.bootstrap.api.JavaProvisionService;
import io.klib.bootstrap.api.ProvisionResult;

/**
 * OSGi integration tests for the bootstrap service stack.
 *
 * <p>Uses <a href="https://github.com/eclipse-osgi-technology/osgi-test">
 * eclipse-osgi-technology/osgi-test</a> extensions to inject live OSGi
 * services directly into JUnit 5 test methods.
 *
 * <p>Run configuration is defined in {@code integration.bndrun}.
 */
@ExtendWith({BundleContextExtension.class, ServiceExtension.class})
class BootstrapIntegrationTest {

    @InjectBundleContext
    BundleContext context;

    @InjectService
    BootstrapService bootstrapService;

    @InjectService
    JavaProvisionService javaProvisionService;

    @Test
    void bundleContext_isInjected() {
        assertNotNull(context, "BundleContext must be injected by BundleContextExtension");
    }

    @Test
    void bootstrapService_isRegisteredInFramework() {
        assertNotNull(bootstrapService,
            "BootstrapService OSGi service must be registered by the core bundle");
    }

    @Test
    void javaProvisionService_isRegisteredInFramework() {
        assertNotNull(javaProvisionService,
            "JavaProvisionService OSGi service must be registered by the core bundle");
    }

    @Test
    void provisionJava21_returnsSuccess() {
        ProvisionResult result = bootstrapService.provisionJava("21");

        assertNotNull(result);
        assertTrue(result.success(), "provisionJava(21) must succeed: " + result.message());
    }

    @Test
    void provisionJava_unknownVersion_returnsFailure() {
        ProvisionResult result = bootstrapService.provisionJava("99");

        assertNotNull(result);
        assertFalse(result.success(), "provisionJava(99) must fail for unknown version");
    }

    @Test
    void javaProvisionService_availableVersions_containsJava21() {
        assertTrue(
            javaProvisionService.availableVersions().contains("21"),
            "Java 21 must be in the list of available versions"
        );
    }
}
