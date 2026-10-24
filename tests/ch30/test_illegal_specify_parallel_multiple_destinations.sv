/*
:name: test_illegal_specify_parallel_multiple_destinations
:description: A module path declaration with a list of destinations has to be a full connection; a parallel connection takes a single destination (IEEE 1800-2023 Section 30.4.5)
:tags: ch30
:type: elaboration
:lrm: 1800-2023 30.4.5 30.4.2 30.4.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the parallel connection (b => y, z) has the two destinations y and z
:expected_stderr_regex: test_illegal_specify_parallel_multiple_destinations\.sv:28:
*/
// IEEE 1800-2023 §30.4.5, §30.4.6: a declaration with more than one source or
// destination needs a full connection (*>); in Syntax 30-3 (30.4.2) a
// parallel connection (=>) has one input terminal and one output terminal,
// while a full connection has lists of them. (a *> u, v) is legal,
// (b => y, z) is not. Icarus Verilog 13.0 and Verilator 5.052 accept the
// design.

module test_illegal_specify_parallel_multiple_destinations_cell (output u, output v,
                                                                output y, output z,
                                                                input a, input b);
  buf (u, v, a);
  buf (y, z, b);
  specify
    (a *> u, v) = 1;
    (b => y, z) = 2;   // illegal: two destinations in a parallel connection
  endspecify
endmodule

module test_illegal_specify_parallel_multiple_destinations;
  reg a = 0, b = 0;
  wire u, v, y, z;

  test_illegal_specify_parallel_multiple_destinations_cell c (u, v, y, z, a, b);
endmodule
