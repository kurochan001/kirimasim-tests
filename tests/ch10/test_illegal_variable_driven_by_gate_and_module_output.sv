/*
:name: test_illegal_variable_driven_by_gate_and_module_output
:description: a variable can be driven by only one primitive output or module output, so a gate output and a module output port cannot both drive it (IEEE 1800-2023 Section 10.3.2)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.3.2 6.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the variable v is driven by the output of the buf gate g_v and by the output port of the instance u_v
:expected_stderr_regex: test_illegal_variable_driven_by_gate_and_module_output\.sv:(33|34):
*/
// IEEE 1800-2023 §10.3.2: a variable can only be driven by one continuous
// assignment or by one primitive output or module output. g_p drives the
// variable p and u_q drives the variable q, each the only driver, which is
// legal; v is driven by the gate g_v and by the output of the instance u_v. A
// tool can report either driver.
// Icarus Verilog 13.0 also rejects the legal gate g_p that drives the
// variable p, so its error does not count; Verilator 5.052 accepts the
// design.

module drv_m (output logic o);
  assign o = 1'b1;
endmodule

module test_illegal_variable_driven_by_gate_and_module_output;
  logic a = 1'b1;
  logic p, q, v;

  buf g_p (p, a);
  drv_m u_q (.o(q));
  buf g_v (v, a);   // (or reported here)
  drv_m u_v (.o(v));   // illegal: a second driver of the variable v

  initial #1 $display("%b %b", p, q);
endmodule
