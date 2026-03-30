package io.klib.bootstrap.core;

import static org.junit.jupiter.api.Assertions.assertAll;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import io.klib.bootstrap.api.ProvisionResult;

/**
 * JUnit 5 unit tests for {@link JavaProvisionServiceImpl}.
 */
class JavaProvisionServiceTest {

    private JavaProvisionServiceImpl svc;

    @BeforeEach
    void setUp() {
        svc = new JavaProvisionServiceImpl();
    }

    @Test
    void availableVersions_isNotEmpty() {
        List<String> versions = svc.availableVersions();
        assertNotNull(versions);
        assertFalse(versions.isEmpty(), "version list must not be empty");
    }

    @ParameterizedTest
    @ValueSource(strings = {"17", "21", "25"})
    void install_supportedVersion_returnsSuccess(String version) {
        ProvisionResult result = svc.install(version);

        assertAll(
            () -> assertTrue(result.success(),        "expected success for version " + version),
            () -> assertEquals("java", result.tool()),
            () -> assertEquals(version, result.version())
        );
    }

    @Test
    void install_unsupportedVersion_returnsFailure() {
        ProvisionResult result = svc.install("8");

        assertFalse(result.success(), "version 8 is not in the supported list");
    }

    @Test
    void install_blankVersion_returnsFailure() {
        ProvisionResult result = svc.install("  ");

        assertFalse(result.success(), "blank version must yield failure");
    }

    @Test
    void install_nullVersion_returnsFailure() {
        ProvisionResult result = svc.install(null);

        assertFalse(result.success(), "null version must yield failure");
    }
}
