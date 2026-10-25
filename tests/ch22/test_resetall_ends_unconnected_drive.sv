/*
:name: test_resetall_ends_unconnected_drive
:description: `resetall has the effect of `nounconnected_drive, so after `unconnected_drive pull1 or pull0 and then `resetall, the unconnected input ports of the modules that follow float at z again (IEEE 1800-2023 Section 22.9)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.9 22.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_resetall_ends_unconnected_drive.expected
*/
// IEEE 1800-2023 §22.9: between `unconnected_drive pull1 or pull0 and
// `nounconnected_drive, unconnected input ports are pulled up or down, and
// `resetall includes the effects of `nounconnected_drive; §22.3: `resetall
// sets the directives to their defaults. p1 is declared after
// `unconnected_drive pull1 and r1 after the `resetall that follows it; p0
// after `unconnected_drive pull0 and r0 after the next `resetall. Each copies
// its unconnected 2-bit input to its output, so p1 and p0 show 11 and 00 and
// r1 and r0 show zz, the default. The values are printed at time 1.

`unconnected_drive pull1
module p1(input [1:0] a, output [1:0] y);
  assign y = a;
endmodule
`resetall
module r1(input [1:0] a, output [1:0] y);
  assign y = a;
endmodule
`unconnected_drive pull0
module p0(input [1:0] a, output [1:0] y);
  assign y = a;
endmodule
`resetall
module r0(input [1:0] a, output [1:0] y);
  assign y = a;
endmodule

module test_resetall_ends_unconnected_drive;
  wire [1:0] y_p1, y_r1, y_p0, y_r0;

  p1 u_p1(.a(), .y(y_p1));
  r1 u_r1(.a(), .y(y_r1));
  p0 u_p0(.y(y_p0));
  r0 u_r0(.y(y_r0));

  initial #1 $display("pull1=%b after resetall=%b pull0=%b after resetall=%b", y_p1, y_r1, y_p0,
                      y_r0);
endmodule
