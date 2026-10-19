/*
:name: test_unconnected_drive
:description: `unconnected_drive pull1 and pull0 pull up or down the unconnected input ports of the modules that follow, until `nounconnected_drive (IEEE 1800-2023 Section 22.9)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_unconnected_drive.expected
*/
// IEEE 1800-2023 §22.9: the unconnected input ports of the modules declared
// between `unconnected_drive and `nounconnected_drive are pulled up with pull1
// or pulled down with pull0, instead of floating. An input left open with
// empty parentheses and an input not named at all are both unconnected. A
// module declared outside such a region keeps the normal default, z.

`unconnected_drive pull1
module unconnected_drive_pull1_leaf(input wire a, output wire y);
  assign y = a;
endmodule
`nounconnected_drive

`unconnected_drive pull0
module unconnected_drive_pull0_leaf(input wire a, output wire y);
  assign y = a;
endmodule
`nounconnected_drive

module unconnected_drive_plain_leaf(input wire a, output wire y);
  assign y = a;
endmodule

module test_unconnected_drive;
  wire y1, y0, yn;
  unconnected_drive_pull1_leaf u1(.a(), .y(y1));
  unconnected_drive_pull0_leaf u0(.y(y0));
  unconnected_drive_plain_leaf un(.y(yn));

  initial #1 $display("pull1: %b  pull0: %b  none: %b", y1, y0, yn);
endmodule
