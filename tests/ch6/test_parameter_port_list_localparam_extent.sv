/*
:name: test_parameter_port_list_localparam_extent
:description: In a parameter port list, every declaration from a localparam keyword up to the next parameter keyword is local, a declaration with only a data type included, while the declarations before it, from the parameter keyword on and after it are nonlocal and take ordered, named and defparam overrides (IEEE 1800-2023 Section 6.20.4)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.4
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_parameter_port_list_localparam_extent.expected
*/
// IEEE 1800-2023 §6.20.4: in a parameter port list, each parameter
// declaration that comes after a localparam keyword is a local parameter,
// until the next parameter keyword or the end of the list; every other
// declaration of the list is a nonlocal parameter, which defparam and
// instance parameter value assignments may override (§23.10). A local
// parameter cannot be overridden that way, so the values of an ordered list
// go to the nonlocal parameters in the order of their declarations.
// The port list of the cell has, in this order:
//   A, with only a data type, before any keyword: nonlocal;
//   localparam B, and C in the same declaration: local;
//   F, with only a data type, still after the localparam keyword: local;
//   parameter D, and E in the same declaration: nonlocal;
//   G, with only a data type, after the parameter keyword: nonlocal.
// The local parameters follow A (B = 2A, C = 3A, F = 4A). The nonlocal
// parameters, in order, are A, D, E and G, so the ordered list (2, 41, 51, 61)
// of u1 gives them these values, and the shorter list (3, 42) of u2 leaves E
// and G at their defaults. u3 overrides E and G by name, and u4 overrides A
// and G with defparam. If F were nonlocal, u1 would give 41 to F and 61 to E;
// if G were local, the lists and overrides of G would not apply to it.

module test_parameter_port_list_localparam_extent_cell
  #(int A = 1,
    localparam int B = A * 2, C = A * 3,
    int F = A * 4,
    parameter int D = 40, E = 50,
    int G = 60) ();
endmodule

module test_parameter_port_list_localparam_extent;
  test_parameter_port_list_localparam_extent_cell u0();
  test_parameter_port_list_localparam_extent_cell #(2, 41, 51, 61) u1();
  test_parameter_port_list_localparam_extent_cell #(3, 42) u2();
  test_parameter_port_list_localparam_extent_cell #(.E(7), .G(9)) u3();
  test_parameter_port_list_localparam_extent_cell u4();
  defparam u4.A = 5, u4.G = 99;

  initial begin
    $display("u0: A=%0d B=%0d C=%0d F=%0d D=%0d E=%0d G=%0d",
             u0.A, u0.B, u0.C, u0.F, u0.D, u0.E, u0.G);
    $display("u1: A=%0d B=%0d C=%0d F=%0d D=%0d E=%0d G=%0d",
             u1.A, u1.B, u1.C, u1.F, u1.D, u1.E, u1.G);
    $display("u2: A=%0d B=%0d C=%0d F=%0d D=%0d E=%0d G=%0d",
             u2.A, u2.B, u2.C, u2.F, u2.D, u2.E, u2.G);
    $display("u3: A=%0d B=%0d C=%0d F=%0d D=%0d E=%0d G=%0d",
             u3.A, u3.B, u3.C, u3.F, u3.D, u3.E, u3.G);
    $display("u4: A=%0d B=%0d C=%0d F=%0d D=%0d E=%0d G=%0d",
             u4.A, u4.B, u4.C, u4.F, u4.D, u4.E, u4.G);
  end
endmodule
