# Additional Licenses

Place manually collected upstream license texts here when a bundled dependency
does not ship a usable `LICENSE*` or `COPYING*` file.

## Layout

Create one subdirectory per package:

```text
Resources/AdditionalLicenses/<PackageName>/LICENSE
Resources/AdditionalLicenses/<PackageName>/COPYING
```

## Rules

- Copy the full upstream license text into the file.
- Use the package display name you want to appear in
  `MuseAmp/Resources/OpenSourceLicenses.md`.
- When a package also has a bundled local license, the file in
  `Resources/AdditionalLicenses/` wins and the scanner skips the bundled copy.
- Keep only one manual license source per package to avoid duplicate sections.
