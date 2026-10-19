/*
:name: test_net_declaration_delay
:description: A net delay delays every change applied to the net, and adds to the delay of a continuous assignment that drives it (IEEE 1800-2023 Section 10.3.3)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_net_declaration_delay.expected
*/
// IEEE 1800-2023 §10.3.3: "wire #3 n;" declares a net delay: every value
// change that another statement applies to n takes effect 3 time units
// later. A continuous assignment with its own delay, assign #4 n = a, first
// waits its 4 units, and the net delay adds 3 more. A delay written in the
// declaration of a net with an assignment, wire #2 m = a, belongs to that
// continuous assignment and is not a net delay.

module test_net_declaration_delay;
  logic a = 0;
  wire #3 n1;
  wire #3 n2;
  wire #2 m = a;

  assign n1 = a;
  assign #4 n2 = a;

  initial begin
    #10 a = 1;
    #1 $display("t=%0d n1=%b n2=%b m=%b", $time, n1, n2, m);
    #2 $display("t=%0d n1=%b n2=%b m=%b", $time, n1, n2, m);
    #3 $display("t=%0d n1=%b n2=%b m=%b", $time, n1, n2, m);
    #2 $display("t=%0d n1=%b n2=%b m=%b", $time, n1, n2, m);
  end
endmodule
