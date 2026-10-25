/*
:name: test_parameter_override_type_and_range
:description: An override gives an untyped parameter the type and width of the final value, is converted to the range and unsignedness of a ranged parameter, to the type of a typed parameter (a signed one taking the width of the value) and to the sign and range of a signed ranged parameter, with defparam values winning over instance assignments (IEEE 1800-2023 Section 23.10)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10 6.20.2 6.12.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_parameter_override_type_and_range.expected
*/
// IEEE 1800-2023 §23.10 (and §6.20.2) give the type and range of a value
// parameter after overrides:
//   U, no type or range: the type and range of the final value assigned;
//   R, a range but no type: the declared range, unsigned, and the value is
//      converted to it;
//   T, a type (int) but no range: the declared type, with the value
//      converted to it; S, the type signed alone: signed, with the width of
//      the final value;
//   SR, signed with a range: signed with the declared range, with the value
//      converted to it.
// Real values convert to integers by rounding (§6.12.1). If a defparam and
// an instance parameter assignment both set a parameter, the defparam
// value is the one used (§23.10). The defaults and override values are all
// sized where the width of the parameter follows the value. Each line shows
// value/$bits for the parameters of one instance:
//   u0 keeps the defaults; u1 uses named assignments: U 8'hF0 (8 bits), R -1
//   (4'b1111 unsigned, 15), T 8'hFF (255), S 8'hF0 (signed 8 bits, -16), SR
//   4'hF (signed, -1); u2 uses ordered assignments in declaration order: U
//   16'h1234 (16 bits), R 8'h3C (low four bits, 12), T 3.6 (rounded, 4), S
//   16'h8001 (signed 16 bits, -32767), SR 9 (4'b1001 signed, -7); u3 has
//   named assignments U 8'hF0 and R 4'h1 and defparams U 2.5 and R 2.7, so U
//   is the real 2.5 and R is 3.
// Icarus Verilog 13.0 prints this output, while Verilator 5.052 stops with
// an error at the defparam of a parameter that the instance also assigns.

module parameter_override_type_and_range_m;
  parameter U = 4'h5;
  parameter [3:0] R = 4'h2;
  parameter int T = 1;
  parameter signed S = 4'sd1;
  parameter signed [3:0] SR = 4'sd1;
endmodule

module test_parameter_override_type_and_range;
  parameter_override_type_and_range_m u0();
  parameter_override_type_and_range_m #(.U(8'hF0), .R(-1), .T(8'hFF), .S(8'hF0), .SR(4'hF)) u1();
  parameter_override_type_and_range_m #(16'h1234, 8'h3C, 3.6, 16'h8001, 9) u2();
  parameter_override_type_and_range_m #(.U(8'hF0), .R(4'h1)) u3();
  defparam u3.U = 2.5;
  defparam u3.R = 2.7;

  initial begin
    $display("u0: U=%0d/%0d R=%0d/%0d T=%0d/%0d S=%0d/%0d SR=%0d/%0d",
             u0.U, $bits(u0.U), u0.R, $bits(u0.R), u0.T, $bits(u0.T),
             u0.S, $bits(u0.S), u0.SR, $bits(u0.SR));
    $display("u1: U=%0d/%0d R=%0d/%0d T=%0d/%0d S=%0d/%0d SR=%0d/%0d",
             u1.U, $bits(u1.U), u1.R, $bits(u1.R), u1.T, $bits(u1.T),
             u1.S, $bits(u1.S), u1.SR, $bits(u1.SR));
    $display("u2: U=%0d/%0d R=%0d/%0d T=%0d/%0d S=%0d/%0d SR=%0d/%0d",
             u2.U, $bits(u2.U), u2.R, $bits(u2.R), u2.T, $bits(u2.T),
             u2.S, $bits(u2.S), u2.SR, $bits(u2.SR));
    $display("u3: U is 2.5: %0d, R=%0d/%0d", u3.U == 2.5, u3.R, $bits(u3.R));
  end
endmodule
