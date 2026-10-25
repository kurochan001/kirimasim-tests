/*
:name: test_program_zero_delay_resumes_in_reinactive
:description: A #0 in a program process resumes it in the Re-Inactive region, after the other Reactive events of the time slot and before the module processes that its blocking write woke (IEEE 1800-2023 Section 4.4.2.7)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.7 4.5 24.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_zero_delay_resumes_in_reinactive.expected
*/
// IEEE 1800-2023 §24.3.1: the processes of a program run in the Reactive
// region, and a program process woken by a design signal is scheduled there.
// §4.4.2.7: an explicit #0 in the reactive region set suspends the process
// into the Re-Inactive region of the current time slot, which holds events
// to run after all the Reactive events. §4.5: the reactive region set is
// emptied before the active region set runs again.
// At time 1 the program process main writes flag, which wakes the module
// process that copies it into module_seen (an Active event), triggers ev,
// which wakes the program process partner (a Reactive event), and executes
// #0. When main resumes, partner has already run (partner_seen=1), and the
// module process has not (module_seen=0): main resumed in Re-Inactive, not in
// the Inactive region of the active set and not before the Reactive events.
// At time 2 the module process has run.
// Icarus Verilog 13.0 resumes main after the module process (module_seen=1),
// and the release 5.052 of Verilator does not support a program declared in
// a module.

module test_program_zero_delay_resumes_in_reinactive;
  int flag = 0, module_seen = 0, partner_seen = 0;
  event ev;

  always @(flag) module_seen = flag;

  program p;
    initial begin : partner
      @(ev);
      partner_seen = 1;
    end

    initial begin : main
      #1;
      flag = 1;
      ->ev;
      #0;
      $display("after #0: partner_seen=%0d module_seen=%0d", partner_seen, module_seen);
      #1;
      $display("at 2: module_seen=%0d", module_seen);
    end
  endprogram
endmodule
