<a id="clauses-33-and-40-testability"></a>

# Clauses 33 and 40: what the standard fixes, what it leaves to tools, what can be tested (2026-11-09)

[English](clauses-33-40-testability-20261109.en.md) / [日本語](clauses-33-40-testability-20261109.md)

[Behavior coverage summary](behavior-coverage-summary.en.md) / [Test format](../README.md#test-format)

An external review found low design coverage for clause 33 (configuring the contents of a design) and clause 40 (code coverage control and API): 47.6% and 64.1%.
For both clauses, this record separates what the standard defines from what it leaves to tools, and lists the requirements that this suite's format can test.
An AI (Claude) checked the 33 unmapped requirements of clause 33 and the 46 of clause 40 against the text of the standard; this is not an independent human review.

<a id="constraints-of-the-test-format"></a>

## Constraints of the test format

- A test is one or more SystemVerilog files compiled together, plus C files for DPI and VPI. There is no field for a library map file or for library options.
- Without a map file, every cell is in the library `work` (33.3.1). A configuration can name other libraries, but they hold no cell.
- Which parts of a design have coverage is left to the tool (40.3.2.1), so clause 40 tests print relations that hold for every conforming answer, and check exact values only after a call returned OK.
- None of the compared simulators implements `$coverage_*` or the VPI coverage properties of 40.5, so the expectations of clause 40 tests rest on the standard alone for now.

<a id="clause-33"></a>

## Clause 33: configuring the contents of a design

### Defined by the standard

- 33.2, 33.2.1: binding instances to source descriptions; the notation `library.cell[:config]`.
- 33.3.1: the grammar of the map file, path wildcards, paths relative to the map file, and the default library `work` for files that match no library.
- 33.3.1.1 to 33.3.3: the priority of matches, the error for a file matching several libraries, same-named cells, map-file includes, and the library of each source file's cells.
- 33.4 to 33.4.3: configuration syntax and meaning (the design statement, default, instance and cell selection, the order and inheritance of liblists, the empty liblist, use), hierarchical configurations, and parameter overrides from a configuration.
- The part of 33.5.4 by which a configuration with a design statement, given with the sources, chooses the top-level cells.
- 33.7: `%l` and `%L`, and the VPI properties `vpiLibrary`, `vpiCell` and `vpiConfig`.

### Left to tools

- The name of the map file and how a tool reads it (33.3.1); a command-line option choosing a file's library (the note in 33.3.1.1).
- Use models such as precompiling and where compiled cells are kept (33.5 to 33.5.3); 33.5 calls itself explanatory.
- Giving a configuration or a library search order on the command line (the separate-compilation part of 33.5.4, and 33.8.1, where `-L` is only recommended).
- Every behavior that distinguishes two real libraries assumes a map file.

### Testable requirements

- Six requirements are now mapped to existing tests: the grammar of 33.4.1, one design statement (33.4.1.1), resetting parameters, the scope of identifiers and non-literal localparams in 33.4.3, and choosing the top by a design statement (33.5.4).
- New tests cover 33.4.1.5 (the empty liblist, the order and inheritance of a liblist), 33.4.1.6 (a use rule and a liblist rule together) and 33.4.3 (an override may use only a name that a bind statement could use in the parent; the legal control uses a hierarchical name, which both readings of Example 4 accept).
- One more requirement can be observed by the existing `tests/ch33/test_illegal_config_default_use.sv` once it cites `33.4.1.6` (left for later).

### Not testable in this format (21 requirements)

- Needing a map file: five rows of 33.3.1 (grammar, relative paths, wildcards), the ambiguity error and priority of 33.3.1.1, the two include rows and the content limit of 33.3.2, the cell mapping of 33.3.3, and the library order without a configuration of 33.6.1.
- Tool interface or command-line mechanism: when map files are read (33.3.1) and `-L` (33.8.1).
- Use-model descriptions with no observable output: 33.5, two rows of 33.5.1, 33.5.2 and 33.5.3.

A runner field for a map file (for example `:libmap: @lib.map`) would make most of the first group testable, checked with `%l` output as in 33.8.2 and 33.8.3.

<a id="clause-40"></a>

## Clause 40: code coverage control and API

### Defined by the standard

- 40.2.1: one API for all coverage types, the minimum types (statement, toggle, FSM states and transitions, assertion), and subhierarchy queries.
- 40.2.2: what counts for each type (a statement executed once, a bit that has been 0 and 1, a reached FSM state, an assertion with a success) and sums over instances.
- 40.3.1: the `SV_COV_*` macros and their values.
- 40.3.2.1 to 40.3.2.5: control actions and their return values (Table 40-1), scopes by definition or instance and by module or hierarchy (Table 40-2), maximum and current values, and the names and status of merge and save.
- 40.4 to 40.4.7: the FSM pragmas (state vector, part-select and FSM name, concatenation, next state, several signals in one declaration, state parameters, both comment styles) and their priority over automatic extraction.
- 40.5.1 to 40.5.3: the VPI constants, coverage properties on each kind of handle, and `vpi_control` for start, stop, reset, check, save and merge.

### Left to tools

- Which parts of a design have coverage and which options enable it (40.3.2.1).
- The granularity of statement coverage, partial toggle coverage and counts, automatic FSM extraction, and the database format (40.2.2, 40.4, 40.3.2.5).
- Display names in reports, such as the FSM name of 40.4.2.
- Not defined at all: an API constant for the FSM transition coverage that 40.2.1 requires (neither 40.3.1 nor 40.5.1 gives one), and the result of a pragma that breaks 40.4.3.

### Testable requirements

- 27 requirements are now mapped to existing tests: the common API and minimum types, sums over instances, control return values and scopes, maximum and current values, merge and save, the FSM pragmas, and VPI coverage control.
- New tests cover the toggle, statement and assertion definitions of 40.2.2, combined checks in 40.3.2.1, the next-state pragmas of 40.4.4 and 40.4.5, and the VPI properties, save and merge of 40.5.2 and 40.5.3. Execution counts (`vpiCoveredCount`) are not checked, because 40.2.2 makes them optional.
- One more requirement can be observed by the existing `tests/ch40/test_coverage_fsm_pragma_states.sv` once it cites `40.4.1` (left for later).

### Not testable in this format (3 requirements)

- FSM transition coverage in 40.2.1: there is no API constant or VPI property to query it (a gap in the standard).
- The database representation in 40.3.2.5: implementation-defined by the standard.
- No selects in a concatenation pragma in 40.4.3: the restriction is on text inside a comment and states no consequence, so no diagnostic can be required.
