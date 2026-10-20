# Clause 5: Lexical conventions

[All chapters](README.md). 33 tests. This page is written by `tools/suite_catalog.py` from the metadata of the tests; edit the tests, not this page.

| Test | What it checks | Clauses | Expected output recorded with | Notes |
| --- | --- | --- | --- | --- |
| [`test_free_format_layout`](../../tests/ch5/test_free_format_layout.sv) | Tokens can be laid out freely: spaces, tabs, newlines and formfeeds only separate them, while blanks and tabs inside a string literal are kept | 5.3 5.2 5.9 | Icarus Verilog 13.0 |  |
| [`test_comment_forms`](../../tests/ch5/test_comment_forms.sv) | One-line and block comments: a block comment ends at its first closing delimiter, and each form's delimiters mean nothing inside the other | 5.4 | Icarus Verilog 13.0 |  |
| [`test_operator_token_lengths`](../../tests/ch5/test_operator_token_lengths.sv) | Operators are tokens of one, two or three characters; unary operators come before their operand, binary ones between their operands, and the conditional operator uses two operator characters between three operands | 5.5 11.3 11.4.10 11.4.5 11.4.6 | Icarus Verilog 13.0 |  |
| [`test_identifier_forms`](../../tests/ch5/test_identifier_forms.sv) | Identifiers with underscores and mixed case, and generate block names | 5.6 27.4 | Icarus Verilog 13.0 |  |
| [`test_identifier_if_suffix`](../../tests/ch5/test_identifier_if_suffix.sv) | Identifiers ending in "if" followed by "(" are not the if keyword | 5.6 5.6.2 | Icarus Verilog 13.0 |  |
| [`test_identifier_leading_underscore`](../../tests/ch5/test_identifier_leading_underscore.sv) | Identifiers that start with an underscore and contain digits, such as _133_ and _1e5 | 5.6 5.7.1 | Icarus Verilog 13.0 |  |
| [`test_lexical_identifiers`](../../tests/ch5/test_lexical_identifiers.sv) | Test for IEEE 1800-2023 Chapter 5.6: Identifiers and keywords | 5.6 | Icarus Verilog 13.0 |  |
| [`test_escaped_identifier_comment_chars`](../../tests/ch5/test_escaped_identifier_comment_chars.sv) | Escaped identifiers that contain the characters of comment delimiters are names, not comments, also next to operators | 5.6.1 11.4.1 11.4.2 | Icarus Verilog 13.0 |  |
| [`test_escaped_identifier_with_dot`](../../tests/ch5/test_escaped_identifier_with_dot.sv) | An escaped identifier that contains a period is one simple name, distinct from the hierarchical name with the same characters | 5.6.1 23.6 | Icarus Verilog 13.0 |  |
| [`test_directive_effect_from_read_point`](../../tests/ch5/test_directive_effect_from_read_point.sv) | A compiler directive takes effect where it is read and holds for the rest of the compilation unit, across module boundaries, until another directive changes it | 5.6.4 22.5.1 22.5.2 | Icarus Verilog 13.0 |  |
| [`test_constants_edge_cases`](../../tests/ch5/test_constants_edge_cases.sv) | Test: Constants edge cases | 5.7 | Icarus Verilog 13.0 |  |
| [`test_ieee1800_2023_literal_edge`](../../tests/ch5/test_ieee1800_2023_literal_edge.sv) | Literal Edge Cases | 5.7 5.7.1 5.7.2 5.9 6.11 6.16 10.7 | Icarus Verilog 13.0 | x/z |
| [`test_boundary_values`](../../tests/ch5/test_boundary_values.sv) | Corner Cases - Boundary Values | 5.7.1 6.11 11.4.3 11.4.10 | Icarus Verilog 13.0 |  |
| [`test_format_hex`](../../tests/ch5/test_format_hex.sv) | Format Hex Tests | 5.7.1 11.5.1 | Icarus Verilog 13.0 |  |
| [`test_int_literal_edge_cases`](../../tests/ch5/test_int_literal_edge_cases.sv) | Test: Integer literal edge cases | 5.7.1 | Icarus Verilog 13.0 |  |
| [`test_lexical_numbers`](../../tests/ch5/test_lexical_numbers.sv) | Chapter 5.7: Numbers | 5.7.1 5.7.2 | Icarus Verilog 13.0 | x/z |
| [`test_literal_base`](../../tests/ch5/test_literal_base.sv) | Literal Base Formats Tests | 5.7.1 | Icarus Verilog 13.0 |  |
| [`test_literal_corner`](../../tests/ch5/test_literal_corner.sv) | Tests various literal formats and representations | 5.7.1 5.7.2 5.9 6.16 | Icarus Verilog 13.0 | x/z |
| [`test_literal_format`](../../tests/ch5/test_literal_format.sv) | Literal Format Tests | 5.7.1 21.2.1.1 | Icarus Verilog 13.0 |  |
| [`test_literals_macros_specify`](../../tests/ch5/test_literals_macros_specify.sv) | Based literals, underscores, real and string literals, macros and a specparam | 5.7.1 22.5.1 5.12 6.20.5 | Icarus Verilog 13.0 |  |
| [`test_logic_literal_edge_cases`](../../tests/ch5/test_logic_literal_edge_cases.sv) | Test: Logic literal edge cases | 5.7.1 | Icarus Verilog 13.0 |  |
| [`test_underscore_literal`](../../tests/ch5/test_underscore_literal.sv) | Underscores in binary, hex and decimal literals do not change their values | 5.7.1 | Icarus Verilog 13.0 |  |
| [`test_unsized_fill_wide_part_select_nba`](../../tests/ch5/test_unsized_fill_wide_part_select_nba.sv) | An unsized fill literal such as '1 fills the whole width of a part-select wider than 32 bits in a nonblocking assignment | 5.7.1 11.6.1 10.4.2 11.5.1 | Icarus Verilog 13.0 |  |
| [`test_real_literal_edge_cases`](../../tests/ch5/test_real_literal_edge_cases.sv) | Test: Real literal edge cases | 5.7.2 6.12 | Icarus Verilog 13.0 |  |
| [`test_time_literal_scaled_to_unit`](../../tests/ch5/test_time_literal_scaled_to_unit.sv) | A time literal in a delay is scaled to the module's time unit, and $time rounds the time to a whole number of units while $realtime keeps the fraction | 5.8 22.7 20.3.1 20.3.3 | Icarus Verilog 13.0 |  |
| [`test_time_literal_scaling`](../../tests/ch5/test_time_literal_scaling.sv) | Time literals are real values scaled to the current time unit, in expressions and in delays | 5.8 3.14.2.1 20.3.3 | Icarus Verilog 13.0 |  |
| [`test_lexical_strings`](../../tests/ch5/test_lexical_strings.sv) | Chapter 5.9: String literals | 5.9 5.9.1 6.16 | Verilator 5.052 |  |
| [`test_string_literal_to_unpacked_byte_array`](../../tests/ch5/test_string_literal_to_unpacked_byte_array.sv) | A string literal assigned to an unpacked array of bytes fills it from the left element, padding the rest with 0 | 5.9 7.4 | standard only |  |
| [`test_array_literal_nesting`](../../tests/ch5/test_array_literal_nesting.sv) | Array literals nest one level of braces per dimension, a replication acts within one dimension and can be nested, and a literal gets its type from a cast or from the assignment, with index and default keys | 5.11 10.9.1 10.8 | Verilator 5.052 |  |
| [`test_attrib_module`](../../tests/ch5/test_attrib_module.sv) | Test: Module attributes | 5.12 | Icarus Verilog 13.0 | x/z |
| [`test_attrib_signal`](../../tests/ch5/test_attrib_signal.sv) | Test: Signal attributes | 5.12 | Icarus Verilog 13.0 |  |
| [`test_attribute_latch_generate`](../../tests/ch5/test_attribute_latch_generate.sv) | An attribute on a variable, always_latch, and a variable in a generate loop | 5.12 9.2.2.3 27.4 | Icarus Verilog 13.0 |  |
| [`test_builtin_method_optional_parens`](../../tests/ch5/test_builtin_method_optional_parens.sv) | A built-in method called without arguments, or with only arguments that have defaults, can leave out the empty parentheses | 5.13 7.5.2 7.9.1 6.16.1 6.19.5.3 7.10.2.3 | Verilator 5.052 |  |
