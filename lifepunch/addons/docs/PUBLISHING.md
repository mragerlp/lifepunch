# DXRP Publish Staging

Publish staging is generated output. It is not the source of truth.

The source folders are:

```text
Assets/addons/lifepunch/<ident>/
Code/Addons/lifepunch/<ident>/
```

The generated upload root must preserve the DXRP game project shape:

```text
.dxrp-publish/upload/
  Assets/addons/lifepunch/<ident>/
  Code/Addons/lifepunch/<ident>/
```

Do not create or upload old flat folders:

```text
upload-assets/
upload-code/
```

## Generate Staging

```powershell
.\scripts\prepare-publish.ps1 -Addon ak47
```

The script reads `config/addons.json`, validates the repo, creates `.dxrp-publish/upload`, and copies only the selected addon's mounted asset/code folders.

For `hasCode=false` addons, publish assets and reuse the previous code revision on DXRP if the portal asks for code.

For `hasAssets=false` addons, publish code only.

## Portal Separation

Publishing an addon package revision is not the same thing as attaching it to a gamemode.

Review `../../docs/DXRP_DOCS_REFERENCE.md` and the DXRP `Launching Server with Addons` documentation before changing publish/server assumptions.

Keep these steps separate:

1. Publish addon package revision from generated staging.
2. Add or update content rows from the manifest/exported content data.
3. Attach/pin the addon revision on the LifePunch gamemode.
4. Add equipment, market, or job rows only in the gamemode layer.
5. Sync the development server before assuming runtime behavior.
