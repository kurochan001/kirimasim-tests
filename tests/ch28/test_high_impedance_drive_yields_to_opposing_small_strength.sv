/*
:name: test_high_impedance_drive_yields_to_opposing_small_strength
:description: High-impedance drive for either logic value yields to an opposing small-strength driver, while strength above zero still drives
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.11 28.12.2 28.12.3 28.14 21.2.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_high_impedance_drive_yields_to_opposing_small_strength.expected
*/
module test_high_impedance_drive_yields_to_opposing_small_strength;
  logic source;
  wire weak_zero, weak_one, medium_zero, medium_one, small_zero, small_one;
  wire only_highz0, only_highz1, mixed_highz0, mixed_highz1;

  assign (weak0, weak1) weak_zero = 0;
  assign (weak0, weak1) weak_one = 1;
  rtran first_zero(weak_zero, medium_zero), first_one(weak_one, medium_one);
  rtran second_zero(medium_zero, small_zero), second_one(medium_one, small_one);

  assign (highz0, strong1) only_highz0 = source;
  assign (strong0, highz1) only_highz1 = source;
  assign (highz0, strong1) mixed_highz0 = source;
  assign (strong0, highz1) mixed_highz1 = source;
  nmos supply_small_one(mixed_highz0, small_one, 1'b1);
  nmos supply_small_zero(mixed_highz1, small_zero, 1'b1);

  task automatic sample(input logic value);
    source = value;
    #1;
    $display("source=%b only=%v %v mixed=%v %v",
             source, only_highz0, only_highz1, mixed_highz0, mixed_highz1);
  endtask

  initial begin
    sample(1'b0);
    sample(1'b1);
    sample(1'bx);
    sample(1'bz);
  end
endmodule
