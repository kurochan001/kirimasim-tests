/*
:name: test_static_const_initializer_sources
:description: a static const initializer may use literals, parameters, localparams, genvars, enum names, constant functions, other constants and hierarchical names
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_static_const_initializer_sources.expected
*/
// IEEE 1800-2023 6.20.6: the initializer of a static const may use a literal,
// a parameter or localparam, a genvar, an enum name, a constant function of
// those, another constant, and a hierarchical name, because it is evaluated
// after elaboration. Each of the seven constants below uses one of those
// sources, and the two constants declared in a generate block use the
// genvar. The printed values are fixed by the clause; a tool that rejects one
// source cannot elaborate the design, and one that evaluates a hierarchical
// name too early prints another value for C7.

module test_static_const_initializer_sources_sub;
  localparam int VALUE = 7;
endmodule

module test_static_const_initializer_sources;
  parameter int P = 2;
  localparam int L = 3;
  typedef enum int {A = 4, B} e_t;

  function automatic int twice(int x);
    return 2 * x;
  endfunction

  const int C1 = 5;
  const int C2 = P + 1;
  const int C3 = L * 2;
  const int C4 = A;
  const int C5 = twice(P);
  const int C6 = C1 + C2;
  const int C7 = u_sub.VALUE;

  test_static_const_initializer_sources_sub u_sub();

  generate
    for (genvar g = 0; g < 2; g++) begin : gb
      const int CG = g + 10;
    end
  endgenerate

  initial begin
    $display("c=%0d %0d %0d %0d %0d %0d %0d", C1, C2, C3, C4, C5, C6, C7);
    $display("cg=%0d %0d", gb[0].CG, gb[1].CG);
  end
endmodule
