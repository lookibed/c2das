# quakegeneric fixtures

The corpus reads the Quake 1.06 shareware game data at run time from `id1/pak0.pak` under the base
directory given as the program's last argument; the canonical cases pass this `fixtures/`
directory.  The pak is **not committed** (its licence terms are in `../UPSTREAM.md`); fetch it
before running the cases or the native build:

```sh
tests/manual/quakegeneric/tools/get_pak.sh
```

The script downloads id Software's `quake106.zip` from a mirror of id's FTP site, checks its sha1,
extracts `resource.1` (an LHA archive) with `lhasa`, checks the extracted pak's sha1 and puts it at
`fixtures/id1/pak0.pak`.  Rerunning it with the pak in place only checks the sha1.

| File | Bytes | sha1 | sha256 |
|---|---|---|---|
| `quake106.zip` | 9094045 | `f8a1a509b094ccdbed3c54b96f7d9b351c0898f5` | `ec6c9d34b1ae0252ac0066045b6611a7919c2a0d78a3a66d9387a8f597553239` |
| `id1/pak0.pak` | 18689235 | `36b42dc7b6313fd9cabc0be8b9e9864840929735` | `35a9c55e5e5a284a159ad2a62e0e8def23d829561fe2f54eb402dbc0a9a946af` |

The engine builds file paths in `MAX_OSPATH` (128-byte) buffers, so the base directory's path must
stay short: an absolute path of about 120 characters crashes the native build while it opens the pak.
The canonical runner's copy under the default `TMPDIR=/tmp` is well below that.

The engine never writes into this directory during a case: the entry exits without
`Host_Shutdown`, which is what writes `id1/config.cfg`.
