/*
:name: test_dollar_cycle_delay_and_actual
:description: A dollar actual argument forwarded to a property and used as the upper bound of a cycle-delay range is accepted and the range waits for an event several cycles later (IEEE 1800-2023 Section 6.20.7)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dollar_cycle_delay_and_actual.expected
*/
// IEEE 1800-2023 §6.20.7: $ may be passed as an actual argument to a
// sequence, property or checker when it is forwarded to such an instance or
// used as the upper bound of a cycle-delay range, where it denotes a finite
// but unbounded maximum. The property inq receives $ for its upper bound and
// the second property writes the range directly. start is raised one time
// unit after the clock starts and stop only 25 time units later, so the
// overlap must be found several posedges after start. The assertion action
// block counts failures, which stays zero only when $ is treated as an
// unbounded maximum and not as a small finite bound.
//
// Neither release compiles this form: Icarus Verilog 13.0 rejects the
// property header and the 5.052 Verilator requires an elaboration-time
// constant range maximum. The expectation follows 6.20.7.

module test_dollar_cycle_delay_and_actual;
  bit clk = 0, start = 0, stop = 0;
  int fails = 0;

  always #5 clk = ~clk;

  property bounded(s, e, maxd);
    @(posedge clk) s |-> ##[1:maxd] e;
  endproperty

  property unbounded(s, e);
    @(posedge clk) s |-> ##[1:$] e;
  endproperty

  a1: assert property (bounded(start, stop, $)) else fails++;
  a2: assert property (unbounded(start, stop)) else fails++;

  initial begin
    #1 start = 1;
    #25 stop = 1;
    #24 $display("fails=%0d", fails);
    $finish;
  end
endmodule
