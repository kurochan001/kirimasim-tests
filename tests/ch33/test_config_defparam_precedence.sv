/*
:name: test_config_defparam_precedence
:description: A parameter set by a config wins over a defparam of the same parameter, and a defparam of another parameter still applies (IEEE 1800-2023 Section 33.4.3)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.4.3 23.10.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_config_defparam_precedence.expected
*/
// IEEE 1800-2023 §33.4.3: when a config and a defparam (23.10.1) set the same
// parameter at the same level of the hierarchy, the config takes precedence; in
// every other case defparam works as usual. The config sets m.P to 9, which
// replaces the defparam value 5. Nothing in the config sets m.c.Q, so the
// defparam value 6 is kept. Icarus Verilog 13.0 skips config declarations, and
// Verilator 5.052 does not support parameter assignments in a use clause.

module cfg_dp_leaf #(parameter int Q = 1) ();
endmodule

module cfg_dp_mid #(parameter int P = 1) ();
  cfg_dp_leaf c();
endmodule

module test_config_defparam_precedence;
  cfg_dp_mid m();

  defparam m.P = 5;
  defparam m.c.Q = 6;

  initial $display("m.P=%0d m.c.Q=%0d", m.P, m.c.Q);
endmodule

config cfg;
  design work.test_config_defparam_precedence;
  instance test_config_defparam_precedence.m use #(.P(9));
endconfig
