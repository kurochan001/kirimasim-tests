/*
:name: test_generate_recursive_module
:description: a conditional generate lets a module instantiate itself until a parameter ends the recursion, and a module that instantiates itself is not a top-level module (IEEE 1800-2023 Section 27.5)
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.5 23.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_recursive_module.expected
*/
// IEEE 1800-2023 §27.5: with a conditional generate a module can contain an
// instance of itself; a parameter that changes on each level can end the
// recursion, which gives a legal hierarchy. A module that contains an
// instance of itself is instantiated, so it is not a top-level module
// (§23.3.1: the top-level modules are those that are not instantiated).
// Module tri_sum adds N, N-1, ..., 1 through instances of itself with N-1,
// and the test instantiates it with N = 4 and N = 0, so its outputs are 10
// and 0; each level also prints its N at time N. Module self_only
// instantiates itself and nothing else instantiates it: it is not a
// top-level module, so it is not elaborated and its initial procedure, which
// would print at time 20, never runs. The 5.052 release of Verilator
// elaborates self_only as a top-level module and prints its line.

module tri_sum #(parameter int N = 1) (output int s);
  if (N > 0) begin : down
    int t;
    tri_sum #(.N(N - 1)) next (.s(t));
    assign s = N + t;
    initial #(N) $display("tri_sum level N=%0d", N);
  end else begin : bottom
    assign s = 0;
  end
endmodule

module self_only #(parameter int D = 2) ();
  if (D > 0) begin : more
    self_only #(.D(D - 1)) inner ();
  end
  initial #20 $display("self_only elaborated with D=%0d", D);
endmodule

module test_generate_recursive_module;
  int s4, s0;

  tri_sum #(.N(4)) top4 (.s(s4));
  tri_sum #(.N(0)) top0 (.s(s0));

  initial #10 $display("s4=%0d s0=%0d", s4, s0);
endmodule
