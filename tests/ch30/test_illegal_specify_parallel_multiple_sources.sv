/*
:name: test_illegal_specify_parallel_multiple_sources
:description: A module path declaration with a list of sources has to be a full connection; a parallel connection takes a single source (IEEE 1800-2023 Section 30.4.5)
:tags: ch30
:type: elaboration
:lrm: 1800-2023 30.4.5 30.4.2 30.4.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the parallel connection (a, b => y) has the two sources a and b
:expected_stderr_regex: test_illegal_specify_parallel_multiple_sources\.sv:25:
*/
// IEEE 1800-2023 §30.4.5, §30.4.6: a declaration with more than one source or
// destination needs a full connection (*>); in Syntax 30-3 (30.4.2) a
// parallel connection (=>) has one input terminal and one output terminal,
// while a full connection has lists of them. (a, b *> z) is legal, (a, b => y)
// is not. Icarus Verilog 13.0 and Verilator 5.052 accept the design.

module test_illegal_specify_parallel_multiple_sources_cell (output y, output z, input a, input b);
  and (y, a, b);
  or (z, a, b);
  specify
    (a, b *> z) = 1;
    (a, b => y) = 2;   // illegal: two sources in a parallel connection
  endspecify
endmodule

module test_illegal_specify_parallel_multiple_sources;
  reg a = 0, b = 0;
  wire y, z;

  test_illegal_specify_parallel_multiple_sources_cell c (y, z, a, b);
endmodule
