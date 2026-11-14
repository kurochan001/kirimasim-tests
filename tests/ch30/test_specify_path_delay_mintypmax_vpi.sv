/*
:name: test_specify_path_delay_mintypmax_vpi
:description: A colon-separated path delay expression gives the minimum, typical and maximum delay in that order, and a single path delay value is the typical delay, as vpi_get_delays with mtm_flag reports them (IEEE 1800-2023 Section 30.5.1)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.5.1 38.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_specify_path_delay_mintypmax_vpi.c
:expected_stdout: @test_specify_path_delay_mintypmax_vpi.expected
*/
// IEEE 1800-2023 §30.5.1: each path delay expression is either one value,
// the typical delay, or three values separated by colons, the minimum, the
// typical and the maximum delay in that order. §38.10, Table 38-2: with
// mtm_flag set, vpi_get_delays fills three elements per delay, in source
// order, with its minimum, typical and maximum value.
//
// Which of the three values a run uses is a choice of the tool (11.11), so the
// test does not look at the run. A VPI application reads the delays of three
// paths in the time unit of their modules, 1 ns:
//   u1: (a => y) = (2:5:9)                one delay: min 2, typ 5, max 9
//   u2: (a => y) = (1:3:8, 2:6:7)         rise 1, 3, 8 and fall 2, 6, 7
//   u3: (a => y) = 4                      one value: its typical delay is 4
// For u3 only the typical element is printed: the clause does not say what
// the minimum and maximum of a single value are.
//
// Icarus Verilog 13.0 fills only one element per delay whatever mtm_flag
// says, with the typical value it runs with. The 5.054 release of Verilator
// rejects the call of the system task that the application registers. The
// expected output follows the clauses alone.

`timescale 1ns/1ns

module test_specify_path_delay_mintypmax_vpi_one (input a, output y);
  buf g (y, a);
  specify
    (a => y) = (2:5:9);
  endspecify
endmodule

module test_specify_path_delay_mintypmax_vpi_two (input a, output y);
  buf g (y, a);
  specify
    (a => y) = (1:3:8, 2:6:7);
  endspecify
endmodule

module test_specify_path_delay_mintypmax_vpi_single (input a, output y);
  buf g (y, a);
  specify
    (a => y) = 4;
  endspecify
endmodule

module test_specify_path_delay_mintypmax_vpi;
  logic a = 1'b0;
  wire y1, y2, y3;

  test_specify_path_delay_mintypmax_vpi_one u1 (a, y1);
  test_specify_path_delay_mintypmax_vpi_two u2 (a, y2);
  test_specify_path_delay_mintypmax_vpi_single u3 (a, y3);

  initial #1 $vt_mtm;
endmodule
