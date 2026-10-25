/*
:name: test_z_input_acts_as_x_except_mos
:description: A z at the input of a logic gate or in an expression has the same effect as an x, while a MOS switch passes the z and case equality tells z from x (IEEE 1800-2023 Section 6.3.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.3.1 28.4 28.5 28.7 11.4.3 11.4.5 11.4.8 11.4.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_z_input_acts_as_x_except_mos.expected
*/
// IEEE 1800-2023 §6.3.1: a z at the input of a gate or in an expression
// usually has the same effect as an x; the MOS primitives are exceptions and
// can pass the z value.
// Each line computes the same thing once with a z input and once with an x
// input. The and and or gates (§28.4), the buf gate (§28.5) and the
// operators &, |, ~ (§11.4.8), + (§11.4.3), == (§11.4.5) and ?: (§11.4.11)
// give x for both; ?: merges its two operands bit by bit. The nmos and pmos
// switches (§28.7), turned on, pass a z to their output as z and an x as x.
// The case equality === (§11.4.5) compares z and x as values, so it tells
// them apart.

module test_z_input_acts_as_x_except_mos;
  logic iz = 1'bz, ix = 1'bx, one = 1'b1, zero = 1'b0;
  wire and_z, and_x, or_z, or_x, buf_z, buf_x;
  wire nmos_z, nmos_x, pmos_z, pmos_x;

  and (and_z, iz, one);
  and (and_x, ix, one);
  or (or_z, iz, zero);
  or (or_x, ix, zero);
  buf (buf_z, iz);
  buf (buf_x, ix);
  nmos (nmos_z, iz, one);
  nmos (nmos_x, ix, one);
  pmos (pmos_z, iz, zero);
  pmos (pmos_x, ix, zero);

  initial begin
    #1;
    $display("gates z: and=%b or=%b buf=%b", and_z, or_z, buf_z);
    $display("gates x: and=%b or=%b buf=%b", and_x, or_x, buf_x);
    $display("operators z: &=%b |=%b ~=%b +=%b eq=%b ?:=%b", iz & one, iz | zero, ~iz, iz + 1'b0,
             iz == zero, iz ? 4'b1100 : 4'b1010);
    $display("operators x: &=%b |=%b ~=%b +=%b eq=%b ?:=%b", ix & one, ix | zero, ~ix, ix + 1'b0,
             ix == zero, ix ? 4'b1100 : 4'b1010);
    $display("mos z: nmos=%b pmos=%b", nmos_z, pmos_z);
    $display("mos x: nmos=%b pmos=%b", nmos_x, pmos_x);
    $display("case equality: z===z %b z===x %b", iz === 1'bz, iz === 1'bx);
  end
endmodule
