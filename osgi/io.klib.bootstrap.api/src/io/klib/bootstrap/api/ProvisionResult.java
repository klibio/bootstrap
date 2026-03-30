package io.klib.bootstrap.api;

/**
 * Result of a provisioning operation.
 *
 * @param success whether the operation completed without errors
 * @param message human-readable description of the outcome
 * @param tool    the tool that was provisioned (e.g. "java", "eclipse")
 * @param version the version that was installed, or {@code null} on failure
 */
public record ProvisionResult(boolean success, String message, String tool, String version) {

    /** Convenience factory for a successful provisioning result. */
    public static ProvisionResult ok(String tool, String version) {
        return new ProvisionResult(true, "Provisioned " + tool + " " + version + " successfully", tool, version);
    }

    /** Convenience factory for a failed provisioning result. */
    public static ProvisionResult failure(String tool, String message) {
        return new ProvisionResult(false, message, tool, null);
    }
}
