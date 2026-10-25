/*
:name: test_blocking_zero_delay_resumes_in_inactive
:description: A blocking assignment without delay updates its target before the next statement, and one with a zero intra-assignment delay computes its right-hand side at once, resumes in the Inactive region before the NBA updates, then updates the target chosen at resumption and wakes the processes sensitive to it (IEEE 1800-2023 Section 4.9.3)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.9.3 4.5 10.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_blocking_zero_delay_resumes_in_inactive.expected
*/
// IEEE 1800-2023 §4.9.3: a blocking assignment with an intra-assignment
// delay computes its right-hand side with the current values and suspends
// the process; with a zero delay the process is an Inactive event of the
// current time. When it resumes, or at once without a delay, it assigns the
// left-hand side, whose target is found with the values at that time, and
// enables the events sensitive to the update. §4.5: Inactive events run
// after the Active ones and before the NBA region.
// At time 1 the process main writes n <= 1 and b = 1, which it reads back at
// once, then c = #0 r + 10 with r = 1. The process woken by b runs in the
// Active region while main is suspended: it records c (still 0), and sets r
// to 5 and idx to 2. main resumes with c = 11, the value computed before it
// was suspended, and sees n still 0, as the NBA update comes later. The
// update of c wakes a process that records 11 and sets idx to 3. main then
// executes arr[idx] = #0 c: when it resumes, idx is 3, so arr[3] gets 11.
// The release 5.052 of Verilator computes the right-hand side after the
// delay (c=15) and prints c_woken=0 and arr=0 0 15 0.

module test_blocking_zero_delay_resumes_in_inactive;
  int b = 0, c = 0, r = 1, n = 0, idx = 0;
  int arr[4] = '{0, 0, 0, 0};
  int c_seen = -1, c_woken = -1, n_at_resume = -1;

  always @(b) begin
    c_seen = c;
    r = 5;
    idx = 2;
  end

  always @(c) begin
    c_woken = c;
    idx = 3;
  end

  initial begin : main
    #1;
    n <= 1;
    b = 1;
    $display("no delay: b=%0d", b);
    c = #0 r + 10;
    n_at_resume = n;
    arr[idx] = #0 c;
    #1;
    $display("c=%0d c_seen=%0d c_woken=%0d n_at_resume=%0d", c, c_seen, c_woken, n_at_resume);
    $display("arr=%0d %0d %0d %0d", arr[0], arr[1], arr[2], arr[3]);
  end
endmodule
