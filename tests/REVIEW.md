# Test-system review

Review test additions for registry ownership, negative controls, generated-output discipline, and
the narrowest executable command.  A test must not mutate a checked-in oracle as its setup.  Reject
an unregistered C fixture, graph wrapper, runner, or a status promotion without a fresh-output
runtime proof (or exact structured diagnostic for a negative fixture).

For an executable case, reject a runner that reads a `.das` from the checkout,
does not build the declared C reference, or compares only one side of the
stdout/exit oracle.
