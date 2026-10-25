/*
:name: test_syntax_parameter_port_list_forms
:description: A parameter port list in the form that starts with parameter assignments and continues with declarations, the form that holds only declarations, and the empty form, each with every kind of parameter port declaration, and the values the parameters take (IEEE 1800-2023 Section 23.2.3)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.2.3 6.20.1 A.1.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_parameter_port_list_forms.expected
*/
// IEEE 1800-2023 A.1.3, with 6.20.1 for what a parameter is: a parameter
// port list is # followed by one of
//   - a list of parameter assignments followed by parameter port
//     declarations (module first_alt),
//   - one or more parameter port declarations (module second_alt), or
//   - empty parentheses (module empty_param).
// A parameter port declaration is a parameter declaration, a localparam
// declaration, a data type with parameter assignments, or a type parameter
// declaration. first_alt starts with the bare assignment W = 4 and continues
// with `parameter int N`, `localparam int M` and `type T`; second_alt holds
// only declarations, with `parameter int`, a bare type `int C`, `type U`,
// `parameter type V` and `localparam int`.
//
// Each module computes a value from its parameters, so a parameter that is
// not declared, not overridden, or given the wrong type changes a number.
// u1 takes the defaults; u2 overrides W and N by name; u3 overrides the first
// parameter by position; u4 overrides A and the types U and V of the
// declaration-only list; u5 and u6 instantiate the empty list, with the
// parameter list omitted and written as #(). The parent prints the
// parameters and the computed values at one instance per time so that the
// order of the lines is fixed.
//
// Icarus Verilog 13.0 does not accept #() as a parameter port list. Verilator
// 5.052 treats a bare data type that follows a localparam in the list as a
// local parameter of that data type and refuses to override it, so the
// localparam is the last entry of the one list that has one.

module first_alt #(W = 4, parameter int N = 2, localparam int M = 3,
                   type T = logic [3:0])
                  (input T din, output logic [W-1:0] dout);
  assign dout = din + W + N + M;
endmodule

module second_alt #(parameter int A = 1, int C = 5, type U = bit [1:0],
                    parameter type V = int, localparam int B = A + 1)
                   (input U a, input V b, output logic [7:0] y);
  assign y = a + b + A + B + C;
endmodule

module empty_param #() (input logic a, output logic b);
  assign b = ~a;
endmodule

module test_syntax_parameter_port_list_forms;
  logic [7:0] y4;
  logic b5, b6;

  first_alt u1 (.din(4'h2), .dout());
  first_alt #(.W(6), .N(5)) u2 (.din(4'h1), .dout());
  first_alt #(7) u3 (.din(4'h1), .dout());
  second_alt #(.A(2), .U(logic [2:0]), .V(byte)) u4
      (.a(3'd1), .b(8'sd2), .y(y4));
  empty_param u5 (.a(1'b0), .b(b5));
  empty_param #() u6 (.a(1'b1), .b(b6));

  initial begin
    #1 $display("first: W=%0d N=%0d M=%0d bits=%0d dout=%0d",
                u1.W, u1.N, u1.M, $bits(u1.din), u1.dout);
    #1 $display("first: W=%0d N=%0d M=%0d bits=%0d dout=%0d",
                u2.W, u2.N, u2.M, $bits(u2.din), u2.dout);
    #1 $display("first: W=%0d N=%0d M=%0d bits=%0d dout=%0d",
                u3.W, u3.N, u3.M, $bits(u3.din), u3.dout);
    #1 $display("second: A=%0d B=%0d C=%0d U=%0d V=%0d y=%0d",
                u4.A, u4.B, u4.C, $bits(u4.a), $bits(u4.b), y4);
    #1 $display("empty: b5=%b b6=%b y4=%0d", b5, b6, y4);
  end
endmodule
