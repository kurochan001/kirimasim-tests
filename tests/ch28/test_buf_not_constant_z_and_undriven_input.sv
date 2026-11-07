/*
:name: test_buf_not_constant_z_and_undriven_input
:description: buf and not gates whose input is the constant 1'bz or an undriven net drive x, and the nets they drive take that value (IEEE 1800-2023 Sections 28.5 and 6.7.1)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.5 6.7.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_buf_not_constant_z_and_undriven_input.expected
*/
// IEEE 1800-2023 §28.5, Table 28-4: a buf or not gate whose input is z
// drives x on each of its outputs. §6.7.1: a net without drivers has the
// value z, and a net with drivers takes the value that its drivers put out,
// so a net that only such a gate drives is x. The input does not have to
// change for this: here it is the constant 1'bz, or a net that nothing
// drives, which stays z.
// The values are printed at time 1, after the events of time 0.
// Icarus Verilog 13.0 leaves these outputs at z (see
// docs/simulator-differences.md); with an input variable that holds z it
// gives x, as tests/ch28/test_buf_not_x_z_input_outputs.sv shows.

module test_buf_not_constant_z_and_undriven_input;
  wire undriven;
  wire b_const, n_const, b_undriven1, b_undriven2, n_undriven;

  buf g_b_const (b_const, 1'bz);
  not g_n_const (n_const, 1'bz);
  buf g_b_undriven (b_undriven1, b_undriven2, undriven);
  not g_n_undriven (n_undriven, undriven);

  initial begin
    #1;
    $display("constant 1'bz: buf=%b not=%b", b_const, n_const);
    $display("undriven net %b: buf=%b%b not=%b", undriven, b_undriven1, b_undriven2, n_undriven);
  end
endmodule
