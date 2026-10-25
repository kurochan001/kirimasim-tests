/*
:name: test_checker_connection_modes
:description: Checker arguments connect by ordered position, by fully explicit names, by implicit names and by the .* wildcard, and an instance may have an empty argument list (IEEE 1800-2023 Section 17.3)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_connection_modes.expected
*/
// IEEE 1800-2023 17.3: checker formal arguments connect to actual arguments
// as module ports do (23.3.2), by ordered position, by fully explicit named
// connections, by implicit named connections that name only the formal, and by
// the .* wildcard that connects every formal whose name matches a variable of
// the instantiating scope. An instance may also have an empty argument list
// when the checker has no ports. The same checker is instantiated four ways
// with 9 and 3, so every instance must drive 12 and 6; the two scopes that
// use implicit names and the wildcard hold variables with the formals' names.

`timescale 1ns/1ns

checker conn_modes(input logic [3:0] a, input logic [3:0] b,
                   output logic [4:0] sum, output logic [3:0] diff);
  assign sum = a + b;
  assign diff = a - b;
endchecker : conn_modes

checker empty_list;
  int n = 4;
  final $display("empty list: n=%0d", n);
endchecker : empty_list

module test_checker_connection_modes;
  logic [3:0] a = 4'd9, b = 4'd3;
  logic [4:0] s_pos, s_named;
  logic [3:0] d_pos, d_named;

  // Ordered connections by port order.
  conn_modes u_pos(a, b, s_pos, d_pos);

  // Fully explicit named connections, in another order than the formals.
  conn_modes u_named(.diff(d_named), .sum(s_named), .b(b), .a(a));

  // Implicit named connections: each formal takes the variable of its name.
  if (1) begin : g_implicit
    logic [3:0] a = 4'd9, b = 4'd3;
    logic [4:0] sum;
    logic [3:0] diff;
    conn_modes u_implicit(.a, .b, .sum, .diff);
  end : g_implicit

  // Wildcard connection: every formal whose name matches a variable.
  if (1) begin : g_wild
    logic [3:0] a = 4'd9, b = 4'd3;
    logic [4:0] sum;
    logic [3:0] diff;
    conn_modes u_wild(.*);
  end : g_wild

  // A checker with no ports takes an empty list.
  empty_list u_empty();

  initial #1 $display("pos=%0d/%0d named=%0d/%0d implicit=%0d/%0d wild=%0d/%0d",
                      s_pos, d_pos, s_named, d_named,
                      g_implicit.sum, g_implicit.diff, g_wild.sum, g_wild.diff);
endmodule
