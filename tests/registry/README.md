# Frozen test registry

`catalog.json` is the canonical declaration of every c2das-managed C fixture,
its C graph and Clang facts, owning layer, entrypoint state, expected outcome,
runtime requirement, current truth status, and any sibling tracked `.das`
artifact.  `fixtures.json` is the deterministic, reviewable expansion of that
declaration.

Regenerate only after deliberately classifying a changed fixture or runner:

```sh
python3 scripts/check_test_registry.py --write
python3 scripts/check_test_registry.py --check
```

A fixture that is a canonical case's translation entry mirrors that case
(`canonical_case`, entrypoint, expected value, runtime, status).  One C graph
may back several canonical cases — different fixture-owned entries and
`program_args` over the same translation, as the corpus file cases do — and
then the fixture mirrors the first case in manifest order and lists every case
id in `canonical_cases`; the other cases keep their own entry and oracle in
`tests/canonical/cases.json`, which the runner reads directly.

`known-red`, `quarantined`, `historical`, and `inventory-only` are not passing
states.  They exist to make the boundary explicit.  No status may be promoted
to support merely because a generated `.das` exists; promotion requires a
fresh-output canonical runner, an exact expected result or structured
diagnostic, and the relevant real daScript gate.

The registry is intentionally a freeze layer.  It does not repair legacy
runners or turn a fixture green; subsequent migration replaces these entries
with canonical test-case declarations one semantic family at a time.
