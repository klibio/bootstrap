# Hierarchy

index                   -> io.klib.setup

  catalog-product       -> io.klib.products.setup
    product             -> io.klib.osgi-dev.setup

  catalog-project       -> io.klib.project.setup
    project empty       -> io.klib.empty.setup
    project bootstrap   -> io.klib.bootstrap.setup

## Windows Launch of Eclipse Installer

```bat
set config_url=http://git.eclipse.org/c/emf/org.eclipse.emf.git/plain/releng/org.eclipse.emf.releng/EMFDevelopmentEnvironmentConfiguration.setup

:: %USERPROFILE%\.klibio\tool\archives\eclipse-inst-jre-win64.exe ^

%USERPROFILE%\.klibio\tool\eclipse-installer\eclipse-inst.exe
  -vm "%USERPROFILE%\.klibio\java\ee\JAVA17" ^
  %config_url% ^
  -vmargs ^
    -Duser.home=x:/oomph_dev_home ^
    -Doomph.setup.user.home.redirect=true
```