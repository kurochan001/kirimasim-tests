/*
:name: test_sched_nonblocking_overrides_later_blocking
:description: A nonblocking assignment updates its variable after the blocking assignments of the time step, also one that comes later in the process (IEEE 1800-2023 Section 4.4.2.4)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.4 10.4.2 10.4.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_nonblocking_overrides_later_blocking.expected
*/
// IEEE 1800-2023 §10.4.2: a nonblocking assignment evaluates its right-hand
// side when it runs and updates the variable in the NBA region (§4.4.2.4); a
// blocking assignment (§10.4.1) updates it at once. So the blocking write of 2
// after the nonblocking write of 1 is seen first and then replaced by 1.

module test_sched_nonblocking_overrides_later_blocking;
  int x = 0;
  initial begin
    x <= 1;
    x = 2;
    $display("same time step: x=%0d", x);
    #1 $display("next time step: x=%0d", x);
  end
endmodule
