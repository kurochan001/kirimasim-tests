/*
:name: test_sched_strobe_after_nba
:description: $strobe prints at the end of the time step, after nonblocking updates and the processes they wake (IEEE 1800-2023 Section 4.4.2.9)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.9 21.2.2 10.4.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_strobe_after_nba.expected
*/
// IEEE 1800-2023 §4.4.2.9, §21.2.2: $strobe evaluates and prints its arguments
// in the Postponed region, after every other event of the time step. So it
// sees the values written by nonblocking assignments (10.4.2) and by the
// processes those updates wake, while $display in the same place sees the
// values before the updates. A later blocking write in the same time step is
// seen too.

module test_sched_strobe_after_nba;
  int a, b, c;

  always @(b) c = b * 2;

  initial begin
    a = 1;
    a <= 2;
    $display("t0 display a=%0d", a);
    $strobe("t0 strobe a=%0d", a);
    #1;
    b <= 7;
    $display("t1 display b=%0d c=%0d", b, c);
    $strobe("t1 strobe b=%0d c=%0d", b, c);
    #1;
    a = 3;
    $strobe("t2 strobe a=%0d", a);
    a = 4;
    #1 $display("t3 display a=%0d", a);
  end
endmodule
