/*
:name: test_unconnected_drive_instances_restore
:description: Unconnected drive changes later module declarations and nounconnected_drive restores floating inputs (IEEE 1800-2023 Section 22.9)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_unconnected_drive_instances_restore.expected
*/
// IEEE 1800-2023 22.9: The directive acts at the source position of each
// module declaration. Three open inputs acquire pull-one, pull-zero, and
// high impedance respectively.
// Oracle checks: The 5.052 release is a two-state engine and is not used as the
// oracle here.

`unconnected_drive pull1
module vector_pull_one(input [2:0] a, output [2:0] y); assign y = a; endmodule
`unconnected_drive pull0
module vector_pull_zero(input [2:0] a, output [2:0] y); assign y = a; endmodule
`nounconnected_drive
module vector_floating(input [2:0] a, output [2:0] y); assign y = a; endmodule
module test_unconnected_drive_instances_restore;
  wire [2:0] a, b, c;
  vector_pull_one one(.a(), .y(a));
  vector_pull_zero zero(.y(b));
  vector_floating floating(.y(c));
  initial #1 $display("inputs=%b,%b,%b", a, b, c);
endmodule
