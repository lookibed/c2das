# Translator test architecture

Rust tests prove AST shape and rendered source.  A fixture is registered with its owning layer,
the C semantic distinction it exercises, and the real daScript gate when executable.  Negative
fixtures assert a precise `TranslationError`; they do not count as a supported lowering path.
