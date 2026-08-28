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

`known-red`, `quarantined`, `historical`, and `inventory-only` are not passing
states.  They exist to make the boundary explicit.  No status may be promoted
to support merely because a generated `.das` exists; promotion requires a
fresh-output canonical runner, an exact expected result or structured
diagnostic, and the relevant real daScript gate.

The registry is intentionally a freeze layer.  It does not repair legacy
runners or turn a fixture green; subsequent migration replaces these entries
with canonical test-case declarations one semantic family at a time.
