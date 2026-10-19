/*
:name: test_monitor_end_of_step
:description: $monitor prints once at the end of each time step in which an argument changed, and $monitoroff and $monitoron turn it off and on (IEEE 1800-2023 Section 21.2.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_monitor_end_of_step.expected
*/
// IEEE 1800-2023 §21.2.3: after $monitor is called, its argument list is
// printed at the end of every time step in which one of the arguments changed,
// once per time step and with the final values, however many changes there
// were. $monitoroff stops the printing; $monitoron starts it again and prints
// the current values at once, even if nothing changed. Verilator 5.052 prints
// nothing when $monitoron is called.

module test_monitor_end_of_step;
  int a, b;

  initial begin
    $monitor("a=%0d b=%0d", a, b);
    a = 1;
    b = 2;
    #1 a = 3;
    #1 a = 4; b = 5; a = 6;
    #1 $monitoroff;
    a = 7;
    #1 b = 8;
    #1 $monitoron;
    #1 b = 9;
  end
endmodule
