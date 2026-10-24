/*
:name: test_elaborated_parameters_generate_and_names_at_time_zero
:description: Before simulation starts, elaboration has given the overridden and derived parameters their values, expanded the generate loops into as many instances as the parameters say, and resolved hierarchical names into those instances, which an initial procedure reads at time 0 (IEEE 1800-2023 Section 3.12)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.12 23.10.4.1 27.4 23.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_elaborated_parameters_generate_and_names_at_time_zero.expected
*/
// IEEE 1800-2023 §3.12: elaboration takes place after the source is parsed
// and before simulation; it expands instantiations, computes parameter
// values and resolves hierarchical names. §23.10.4.1: parameters get their
// final values before the generate schemes that use them are evaluated, and
// the generate blocks are expanded from those values (§27.4).
// el_row has the parameter N and the derived localparam LAST = N - 1, and a
// generate loop that instantiates el_leaf N times with IDX = i + 1; el_leaf
// derives TAG = IDX * 10. The top module overrides N with 2 for r2 and 3
// for r3. Its initial procedure prints, at time 0 and before any delay, the
// parameters of both rows and TAG of the last leaf of each, named through
// the generate block names g[LAST].u (r2.g[1].u and r3.g[2].u), and the
// number of bits of the chain vectors whose width comes from N.

`timescale 1ns/1ns

module el_leaf #(parameter int IDX = 0);
  localparam int TAG = IDX * 10;
endmodule

module el_row #(parameter int N = 1);
  localparam int LAST = N - 1;
  logic [N:0] chain;

  for (genvar i = 0; i < N; i++) begin : g
    el_leaf #(.IDX(i + 1)) u();
  end
endmodule

module test_elaborated_parameters_generate_and_names_at_time_zero;
  el_row #(.N(2)) r2();
  el_row #(.N(3)) r3();

  initial begin
    $display("t=%0t r2: N=%0d LAST=%0d g[1].u: IDX=%0d TAG=%0d bits(chain)=%0d", $time, r2.N,
             r2.LAST, r2.g[1].u.IDX, r2.g[1].u.TAG, $bits(r2.chain));
    $display("t=%0t r3: N=%0d LAST=%0d g[2].u: IDX=%0d TAG=%0d bits(chain)=%0d", $time, r3.N,
             r3.LAST, r3.g[2].u.IDX, r3.g[2].u.TAG, $bits(r3.chain));
    $display("t=%0t r3: g[0].u.TAG=%0d g[1].u.TAG=%0d", $time, r3.g[0].u.TAG, r3.g[1].u.TAG);
  end
endmodule
