/*
:name: test_parameter_port_list_without_defaults
:description: In a parameter port list a value parameter and a type parameter can be declared without a default, and every instantiation or specialization then gives them values; a localparam in the list still has its value expression (IEEE 1800-2023 Section 6.20.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.1 6.20.3 8.25 23.10 A.2.1.1 A.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_parameter_port_list_without_defaults.expected
*/
// IEEE 1800-2023 §6.20.1 with footnote 22 of A.10 (on param_assignment and
// type_assignment, A.2.1.1 and A.2.4): only in a parameter port list can the
// value of a parameter or the type of a type parameter be left out, and
// not for a localparam there. Such a parameter has no default, and each
// instantiation of the module (23.10) or specialization of the class (8.25)
// gives it a value.
//
// The module sized has the parameters W and T without defaults and the
// localparam W2 = W * 2 in its parameter port list. m1 gives W = 4 and
// T = byte, m2 gives W = 8 and T = shortint: the port o is W bits wide, the
// variable of type T has 8 and 16 bits, and W2 is 8 and 16.
// The class Box has the type parameter T and the value parameter N without
// defaults: Box #(byte, 3) holds 3 elements of 8 bits, and
// Box #(.T(int), .N(2)) 2 elements of 32 bits.
//
// Icarus Verilog 13.0 reports a syntax error for the parameter port list of
// the class Box.

module sized #(parameter int W, parameter type T, localparam int W2 = W * 2)
  (output logic [W-1:0] o);
  T t_val;
  assign o = '1;
endmodule

class Box #(type T, int N);
  T items[N];
endclass

module test_parameter_port_list_without_defaults;
  logic [3:0] o1;
  logic [7:0] o2;

  sized #(.W(4), .T(byte)) m1 (.o(o1));
  sized #(.W(8), .T(shortint)) m2 (.o(o2));

  initial begin
    Box #(byte, 3) b1;
    Box #(.T(int), .N(2)) b2;
    b1 = new;
    b2 = new;
    #1;
    $display("m1: o=%b W2=%0d bits(T)=%0d", o1, m1.W2, $bits(m1.t_val));
    $display("m2: o=%b W2=%0d bits(T)=%0d", o2, m2.W2, $bits(m2.t_val));
    $display("b1: size=%0d bits(T)=%0d", $size(b1.items), $bits(b1.items[0]));
    $display("b2: size=%0d bits(T)=%0d", $size(b2.items), $bits(b2.items[0]));
  end
endmodule
