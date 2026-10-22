/*
:name: test_timeunit_program
:description: A delay in a program is in the time unit of the program, not in that of the module that instantiates it (IEEE 1800-2023 Section 3.14.2.3)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.14.2.3 3.14.2.2 3.14.1 24.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timeunit_program.expected
*/
// IEEE 1800-2023 §3.14.2.3: a design element takes the time unit and precision
// of the scope that encloses it. The program declares 10 ns and 1 ns, so its
// #1 waits 10 ns before it drives q. §24.3: the program is instantiated in the
// module. The module declares 1 ns and 1 ps (§3.14.2.2), so at 10.5 (§3.14.1)
// it sees q high and prints its own $realtime as 10.500.
// The program keeps a second initial procedure waiting at 20 ns, so it is
// still alive when the module observes q at 10.5 ns.

`timescale 1ns/1ps

program p_time(output logic q);
  timeunit 10ns;
  timeprecision 1ns;

  initial begin
    #1 q = 1;
  end

  // Keep the program alive past the module observation at 10.5 ns.
  initial #2;
endprogram

module test_timeunit_program;
  logic q;

  p_time p(.q(q));

  initial begin
    #10.5 $display("%0.3f q=%b", $realtime, q);
    #1 $finish;
  end
endmodule
