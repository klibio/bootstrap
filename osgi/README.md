# io.klib Bootstrap — OSGi Workspace

This directory contains the [bnd](https://bnd.bndtools.org/) Gradle workspace for the
`io.klib.bootstrap` OSGi application.  It uses **Java 21** and is built with the
**Gradle 8.13** wrapper included in this folder.

---

## Prerequisites

| Tool | Version | Notes |
|------|---------|-------|
| Java JDK | 21+ | Gradle will auto-provision via toolchain if not found |
| (Optional) Eclipse IDE | 2024-12+ | Import with [BNDTools 7+](https://bndtools.org/) plug-in |

> No Maven or `bnd` CLI installation is required — everything runs through `./gradlew`.

---

## Project structure

```
osgi/                                ← bnd workspace root (_root Eclipse project)
├── cnf/                             ← workspace configuration (Eclipse project: cnf)
│   ├── build.bnd                    ← workspace-wide bnd settings (Java 21, version, etc.)
│   ├── ext/
│   │   ├── repositories.bnd        ← repository plug-in definitions
│   │   └── junit5.bnd              ← JUnit 5 / osgi-test BSN macro variables
│   └── pom.xml                     ← Maven Central artifact list for BndPomRepository
├── io.klib.bootstrap.api/          ← public service interfaces + ProvisionResult record
├── io.klib.bootstrap.core/         ← DS @Component implementations + unit tests
├── io.klib.bootstrap.app/          ← application launcher bndrun files
│   ├── launch.bndrun               ← production launcher (Felix + SCR + bundles)
│   └── debug.bndrun                ← debug launcher (adds Gogo shell, -runtrace)
├── io.klib.bootstrap.test.integration/  ← OSGi integration tests (osgi-test)
│   └── integration.bndrun          ← integration test launcher
├── build.gradle                    ← workspace root Gradle build
├── settings.gradle                 ← Gradle settings (bnd workspace plug-in)
├── gradlew / gradlew.bat           ← Gradle 8.13 wrapper scripts
└── README.md                       ← this file
```

---

## Building

```bash
# From the osgi/ directory:
cd osgi

# Full workspace build (compile + unit tests + OSGi integration tests)
./gradlew build

# Compile only
./gradlew assemble

# Run only unit tests (io.klib.bootstrap.core)
./gradlew test

# Run only OSGi integration tests
./gradlew :io.klib.bootstrap.test.integration:testOSGi
```

> **Tip:** On Windows, replace `./gradlew` with `gradlew.bat`.

---

## Running the application

The application is launched via the `io.klib.bootstrap.app` bndrun files.

### Production launch

```bash
# Gradle task (recommended)
./gradlew :io.klib.bootstrap.app:run.launch

# Export a self-contained runnable JAR/directory first, then launch it
./gradlew :io.klib.bootstrap.app:export.launch
```

### Debug launch (with Felix Gogo interactive shell)

```bash
./gradlew :io.klib.bootstrap.app:run.debug
```

---

## Running the tests

### JUnit 5 unit tests (no OSGi framework required)

```bash
./gradlew :io.klib.bootstrap.core:test
```

### OSGi integration tests (full Felix container)

```bash
./gradlew :io.klib.bootstrap.test.integration:testOSGi
```

Test reports are written to:

```
io.klib.bootstrap.test.integration/generated/test-reports/testOSGi/
```

---

## Re-resolving bndrun files

The `-runbundles` list in each `.bndrun` file is pre-resolved and committed.
If you add new `-runrequires` entries or change dependency versions, re-resolve with:

```bash
# Resolve launch.bndrun
./gradlew :io.klib.bootstrap.app:resolve.launch

# Resolve debug.bndrun
./gradlew :io.klib.bootstrap.app:resolve.debug

# Resolve integration.bndrun
./gradlew :io.klib.bootstrap.test.integration:resolve
```

---

## Importing into Eclipse with BNDTools

1. Install **Eclipse IDE for Java Developers** (2024-12 or later).
2. Install the **BNDTools** plug-in via the Eclipse Marketplace.
3. In Eclipse: **File → Import → Existing Projects into Workspace**.
4. Set the root directory to this `osgi/` folder.
5. Select **all** projects found (including `_root` and `cnf`).
6. Click **Finish**.

Eclipse will resolve the workspace dependencies automatically via the
`BndPomRepository` configuration in `cnf/ext/repositories.bnd`.

> The `_root` project is configured with resource filters so that the Eclipse
> Project Explorer shows only workspace-level files (`build.gradle`,
> `settings.gradle`, `gradlew`, …) while hiding the bundle sub-project
> directories that are already visible as separate Eclipse projects.

---

## Eclipse Java compiler settings

Every Eclipse project in this workspace ships a
`.settings/org.eclipse.jdt.core.prefs` file that sets the JDT compiler to
**Java 21**:

```properties
eclipse.preferences.version=1
org.eclipse.jdt.core.compiler.codegen.targetPlatform=21
org.eclipse.jdt.core.compiler.compliance=21
org.eclipse.jdt.core.compiler.release=enabled
org.eclipse.jdt.core.compiler.source=21
```

These values mirror the `javac.source`/`javac.target` already declared in
`cnf/build.bnd`, so both the Gradle build and the Eclipse IDE use the same
compiler level.

### How the settings are applied automatically

Eclipse reads `.settings/org.eclipse.jdt.core.prefs` the moment a project is
imported — **no manual action is required**.  The table below lists all
available options ranked by how automatic they are:

| # | Mechanism | Automatic? | When it applies |
|---|-----------|-----------|-----------------|
| **1** | **Project-level `.settings/org.eclipse.jdt.core.prefs`** (used here) | ✅ **Yes** | As soon as *File → Import → Existing Projects* completes — Eclipse JDT reads the file for every imported project. |
| **2** | **BNDTools `build.bnd` (`javac.source` / `javac.target`)** | ✅ **Yes** | BNDTools reads the workspace `build.bnd` and configures each bnd project's JDT compiler settings automatically. This workspace already defines `javac.source=21` and `javac.target=21` in `cnf/build.bnd`. |
| **3** | **Oomph setup model (`.setup` file)** | ✅ **Yes** | An Oomph project model can run during Eclipse startup to import preferences, install plug-ins, and set workspace options. Most useful for distributing a fully-automated team workspace via the Eclipse Installer. Higher setup cost. |
| **4** | **Eclipse Preferences File (`.epf`) — manual import** | ❌ **No** | An `.epf` file holds workspace-level preferences but must be imported by the developer via *File → Import → General → Preferences*. Useful as a fallback or for workspace-scope settings (e.g. formatter, clean-up) that cannot live in a project folder. |

---

## Key version numbers

| Component | Version |
|-----------|---------|
| Java | 21 |
| Gradle wrapper | 8.13 |
| bnd / BNDTools | 7.1.0 |
| Apache Felix Framework | 7.0.5 |
| Apache Felix SCR | 2.2.6 |
| JUnit 5 | 5.11.4 |
| osgi-test | 1.3.0 |

---

## License

[MIT](https://opensource.org/licenses/MIT) — © klibio contributors
