/*
:name: test_program_blocking_zero_delay_reinactive
:description: A blocking assignment with a zero intra-assignment delay in a program process resumes the process in the Re-Inactive region, before the module processes that the program woke earlier in the time step (IEEE 1800-2023 Section 4.9.3)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.9.3 4.4.2.7 4.5 24.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_blocking_zero_delay_reinactive.expected
*/
// IEEE 1800-2023 §4.9.3: when a blocking assignment with a zero
// intra-assignment delay is executed from the Reactive region, the process
// is scheduled as a Re-Inactive event. §24.3.1: program processes run in the
// Reactive region. §4.4.2.7 and §4.5: the Re-Inactive events run within the
// reactive region set, before the active region set runs again.
// At time 1 the program process writes pm = 1, which wakes the module
// process that copies it into pm_copy (an Active event), and then executes
// q = #0 pm + 1. When it resumes, q is 2 and pm_copy is still 0: it resumed
// from Re-Inactive. Had it been scheduled in the Inactive region, the module
// process would have run first. At time 2 the module process has run.
// Icarus Verilog 13.0 does not schedule program code in the Reactive region,
// and the release 5.052 of Verilator does not support a program declared in
// a module.

module test_program_blocking_zero_delay_reinactive;
  int pm = 0, pm_copy = 0, q = 0;

  always @(pm) pm_copy = pm;

  program p;
    initial begin
      #1;
      pm = 1;
      q = #0 pm + 1;
      $display("after q = #0: q=%0d pm_copy=%0d", q, pm_copy);
      #1 $display("at 2: pm_copy=%0d", pm_copy);
    end
  endprogram
endmodule
