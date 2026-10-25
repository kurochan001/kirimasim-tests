/*
:name: test_postponed_strobe_monitor_after_reactive_writes
:description: $strobe and $monitor print in the Postponed region, so they show the value that a variable has after the NBA, Reactive and Re-NBA writes of the time slot, not a value in between (IEEE 1800-2023 Section 4.4.2.9)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.9 4.5 21.2.2 21.2.3 24.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_postponed_strobe_monitor_after_reactive_writes.expected
*/
// IEEE 1800-2023 §4.4.2.9: $monitor, $strobe and similar events are scheduled
// in the Postponed region, the last region of the time slot, after which no
// value changes. §4.5: the active region set, with its NBA region, and then
// the reactive region set, with its Re-NBA region, run before it.
// §24.3.1: program processes run in the Reactive region and their
// nonblocking assignments update in the Re-NBA region.
// At time 5 a module process writes a = 1, calls $strobe (§21.2.2) and
// writes a <= 2. The update to 2 wakes a program process waiting for it,
// which writes a = 3 and a <= 4. The strobe prints 4, not 1 (the value at
// the call), 2 (after the NBA region) or 3 (in the Reactive region). At time
// 8 a module process starts $monitor (§21.2.3), which prints a=4 at the end
// of that slot. At time 10 the same four writes give 5, 6, 7 and 8, and the
// monitor prints only the final 8.
// The two output tasks print in different time slots, since their order in
// one Postponed region is not fixed.
// The release 5.052 of Verilator does not support a program declared in a
// module.

module test_postponed_strobe_monitor_after_reactive_writes;
  int a = 0;

  initial begin
    #5;
    a = 1;
    $strobe("strobe at 5: a=%0d", a);
    a <= 2;
    #3 $monitor("monitor at %0d: a=%0d", $time, a);
    #2;
    a = 5;
    a <= 6;
  end

  program p;
    initial begin
      wait (a == 2);
      a = 3;
      a <= 4;
      wait (a == 6);
      a = 7;
      a <= 8;
      #10;
    end
  endprogram
endmodule
