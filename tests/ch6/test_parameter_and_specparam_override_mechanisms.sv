/*
:name: test_parameter_and_specparam_override_mechanisms
:description: Parameters are overridden with an ordered parameter value list, a named one and a defparam statement, while a specparam takes a new value from the LABEL section of an SDF file, and the procedural delay that uses it follows (IEEE 1800-2023 Section 6.20.5)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.5 32.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_parameter_and_specparam_override_mechanisms.expected
*/
// IEEE 1800-2023 §6.20.5 (Table 6-11): parameters get other values through
// defparam statements and through the parameter values of an instance, while
// specparams get theirs through SDF annotation. §32.4.3: the LABEL section of
// an SDF file annotates specparams, and every expression that uses one is
// evaluated again.
// The cell has no parameter port list, so its parameters P and Q, declared
// in the body, can be overridden (6.20.1). It sets q to 0, waits 20 and then
// the specparam S, 3, and sets q to 1.
// - u1 gets P = 10 by an ordered list, and its S is annotated to 7 by the SDF
//   file written and read at time 0, so q1 rises at 20 + 7 = 27;
// - u2 gets Q = 20 by name, and keeps S = 3, so q2 rises at 23;
// - u3 gets P = 30 from a defparam statement.
// The parameters are printed at time 1 and each rising edge with its time.
// The SDF entry writes the value as in the example of 32.4.3.
// Oracle checks: Icarus Verilog 13.0 does not read the LABEL section, and the
// 5.054 release of Verilator ignores $sdf_annotate; both print the expected
// parameters but let q1 rise at 23.

`timescale 1ns/1ns

module test_parameter_and_specparam_override_mechanisms_cell(output reg q);
  parameter int P = 1;
  parameter int Q = 2;
  specparam S = 3;
  initial begin
    q = 0;
    #20;
    #S q = 1;
  end
endmodule

module test_parameter_and_specparam_override_mechanisms;
  wire q1, q2, q3;
  integer f;

  test_parameter_and_specparam_override_mechanisms_cell #(10) u1(q1);
  test_parameter_and_specparam_override_mechanisms_cell #(.Q(20)) u2(q2);
  test_parameter_and_specparam_override_mechanisms_cell u3(q3);
  defparam u3.P = 30;

  initial begin
    f = $fopen("test_parameter_and_specparam_override_mechanisms.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"test_parameter_and_specparam_override_mechanisms_cell\")");
    $fdisplay(f, "    (INSTANCE u1)");
    $fdisplay(f, "    (LABEL (ABSOLUTE (S 7)))))");
    $fclose(f);
    $sdf_annotate("test_parameter_and_specparam_override_mechanisms.sdf");
    #1;
    $display("u1: P=%0d Q=%0d", u1.P, u1.Q);
    $display("u2: P=%0d Q=%0d", u2.P, u2.Q);
    $display("u3: P=%0d Q=%0d", u3.P, u3.Q);
  end

  always @(posedge q1) $display("%0t: q1 rises", $time);
  always @(posedge q2) $display("%0t: q2 rises", $time);
endmodule
