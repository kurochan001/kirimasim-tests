/*
:name: test_sched_nonblocking_reads_old_values
:description: Nonblocking assignments in one time step all read the values from before any of their updates (IEEE 1800-2023 Section 4.4.2.4)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.4 10.4.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_nonblocking_reads_old_values.expected
*/
// IEEE 1800-2023 §10.4.2: each nonblocking assignment evaluates its right-hand
// side when it runs, before the NBA region (§4.4.2.4) updates any target. So
// the three assignments rotate the values of a, b and c instead of copying one
// value into all of them.

module test_sched_nonblocking_reads_old_values;
  int a = 1, b = 2, c = 3;
  initial begin
    a <= b;
    b <= c;
    c <= a;
    #1 $display("a=%0d b=%0d c=%0d", a, b, c);
  end
endmodule
