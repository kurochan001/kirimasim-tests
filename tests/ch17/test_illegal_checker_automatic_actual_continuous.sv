/*
:name: test_illegal_checker_automatic_actual_continuous
:description: A checker input whose actual argument is an automatic variable of the procedure that instantiates the checker cannot be used in a continuous assignment of the checker, while the same checker with a static variable as the actual is legal (IEEE 1800-2023 Section 17.3)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the procedural instance u_auto passes the automatic variable av to the formal a, which the checker uses in a continuous assignment
:expected_stderr_regex: test_illegal_checker_automatic_actual_continuous\.sv:(31|42):
*/
// IEEE 1800-2023 17.3: if an actual input argument of a checker instance
// contains an automatic value from procedural code, the corresponding formal
// shall not be used in a continuous assignment or in the procedural code of
// the checker. The checker auto_assign uses its formal a in a continuous
// assignment. The static instance u_static passes the module variable v,
// which is legal. The instance u_auto in the initial procedure passes av, an
// automatic variable of that procedure, so that instance is not legal. A
// tool can report the error at the continuous assignment or at the instance.
// Without u_auto the design is legal.
// Icarus Verilog 13.0 does not support checkers. The 5.054 release of
// the Verilator simulator reports a syntax error at the instance u_auto, as
// it does for any checker instance in a procedure, so its error does not
// count.

`timescale 1ns/1ns

checker auto_assign(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 4'd1;   // illegal for u_auto
endchecker : auto_assign

module test_illegal_checker_automatic_actual_continuous;
  logic [3:0] v = 4'd3;
  logic [3:0] y_static, y_auto;

  auto_assign u_static(v, y_static);

  initial begin
    automatic logic [3:0] av = 4'd5;
    auto_assign u_auto(av, y_auto);   // illegal: the actual is automatic
    #1 $display("y_static=%0d y_auto=%0d", y_static, y_auto);
  end
endmodule
