# Translator test review

For each changed semantic branch, verify that disabling or restoring the old branch would fail a
test.  Reject assertions that only match incidental formatting, a generated `.das` updated
without a C source assertion, or a green result that hides a known-red corpus failure.
