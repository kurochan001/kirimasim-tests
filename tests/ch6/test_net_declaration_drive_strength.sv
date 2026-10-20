/*
:name: test_net_declaration_drive_strength
:description: A net declaration that assigns the net can give the drive strength of that continuous assignment, which then drives the net (IEEE 1800-2023 Section 6.3.2.2)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.3.2.2 10.3.1 10.3.4 21.2.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_net_declaration_drive_strength.expected
*/
// IEEE 1800-2023 §6.3.2.2: a drive strength in a net declaration belongs to the
// continuous assignment made in the same declaration (10.3.1, 10.3.4). w1
// drives 1 with pull strength and 0 with strong strength, w2 drives both with
// weak strength, and w3 has the default, strong for both. %v (21.2.1.4) shows
// the strengths for a = 1 and then a = 0.

module test_net_declaration_drive_strength;
  reg a = 1'b1;
  wire (pull1, strong0) w1 = a;
  wire (weak0, weak1) w2 = a;
  wire w3 = a;

  initial begin
    #1 $display("a=1: %v %v %v", w1, w2, w3);
    a = 1'b0;
    #1 $display("a=0: %v %v %v", w1, w2, w3);
  end
endmodule
