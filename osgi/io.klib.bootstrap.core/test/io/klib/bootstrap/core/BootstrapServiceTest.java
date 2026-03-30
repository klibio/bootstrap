package io.klib.bootstrap.core;

import static org.junit.jupiter.api.Assertions.assertAll;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import io.klib.bootstrap.api.ProvisionResult;

/**
 * JUnit 5 unit tests for {@link BootstrapServiceImpl}.
 *
 * <p>Uses test doubles assigned directly to package-private fields
 * — no OSGi framework required.
 */
class BootstrapServiceTest {

    private BootstrapServiceImpl svc;

    @BeforeEach
    void setUp() {
        svc = new BootstrapServiceImpl();
        // Inject test doubles via package-private fields
        svc.javaService    = new JavaProvisionServiceImpl();
        svc.eclipseService = new EclipseProvisionServiceImpl();
        svc.oomphService   = new OomphProvisionServiceImpl();
    }

    @Test
    void provisionJava_knownVersion_returnsSuccess() {
        ProvisionResult result = svc.provisionJava("21");

        assertAll(
            () -> assertTrue(result.success(),  "expected success"),
            () -> assertEquals("java", result.tool()),
            () -> assertEquals("21",  result.version()),
            () -> assertNotNull(result.message())
        );
    }

    @Test
    void provisionJava_unknownVersion_returnsFailure() {
        ProvisionResult result = svc.provisionJava("99");

        assertAll(
            () -> assertFalse(result.success(), "expected failure for unsupported version"),
            () -> assertEquals("java", result.tool()),
            () -> assertNull(result.version())
        );
    }

    @Test
    void provisionJava_nullVersion_returnsFailure() {
        ProvisionResult result = svc.provisionJava(null);

        assertFalse(result.success(), "null version must yield failure");
    }

    @Test
    void provisionEclipse_validProduct_returnsSuccess() {
        ProvisionResult result = svc.provisionEclipse("eclipse.platform.ide");

        assertAll(
            () -> assertTrue(result.success()),
            () -> assertEquals("eclipse", result.tool())
        );
    }

    @Test
    void provisionOomph_returnsSuccess() {
        ProvisionResult result = svc.provisionOomph();

        assertAll(
            () -> assertTrue(result.success()),
            () -> assertEquals("oomph", result.tool())
        );
    }
}
