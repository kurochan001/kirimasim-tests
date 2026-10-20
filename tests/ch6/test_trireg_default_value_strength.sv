/*
:name: test_trireg_default_value_strength
:description: Before any driver drives them, a trireg net holds x with the charge strength of its size, medium by default, while other nets hold z (IEEE 1800-2023 Section 6.7.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.7.1 6.3.2.1 21.2.1.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_trireg_default_value_strength.expected
*/
// IEEE 1800-2023 §6.7.1: the default value of a net is z, except for trireg
// nets, which start as x with the charge strength of their declaration.
// §6.3.2.1: that strength is small, medium or large, and medium when none is
// given. None of the nets here has a driver, so %v (21.2.1.4) shows x with the
// three charge strengths, and HiZ for the wire.

module test_trireg_default_value_strength;
  trireg t_default;
  trireg (small) t_small;
  trireg (large) t_large;
  wire w;

  initial #1 $display("trireg: %v %v %v, wire: %v", t_default, t_small, t_large, w);
endmodule
