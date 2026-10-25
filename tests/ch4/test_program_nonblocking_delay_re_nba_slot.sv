/*
:name: test_program_nonblocking_delay_re_nba_slot
:description: A nonblocking assignment in a program updates in the Re-NBA region, of the current time slot without a delay and of the later slot with a nonzero delay, after the Reactive events of that slot and before the active region set runs again (IEEE 1800-2023 Section 4.9.4)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.9.4 4.4.2.8 4.5 24.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_nonblocking_delay_re_nba_slot.expected
*/
// IEEE 1800-2023 §4.9.4: a nonblocking assignment schedules its update in the
// current time step when its delay is zero, and as a future event when it is
// not. §4.4.2.8: from the reactive region set the update goes to the Re-NBA
// region of that time step. §24.3.1: a program process runs in the Reactive
// region. §4.5: the Re-NBA region follows the Reactive and Re-Inactive
// regions of the slot, and the reactive region set is emptied before the
// active region set runs again.
// At time 1 the program process writes u <= 4 and u2 <= #2 6. After #0 (in
// Re-Inactive) u is still 0, and at 2 it is 4. At 3 the process resumes in
// the Reactive region, writes g = 1, which wakes a module process that
// copies g (Active work), and waits for u2. The update of u2 in the Re-NBA
// region of slot 3 wakes it before that module process has run: it sees
// u2 = 6 and g_copy = 0. An update in the NBA region of the active set would
// come before the program process resumed at 3, so it would wait for u2 in
// vain. At 4 both module processes have run.
// Icarus Verilog 13.0 does not schedule program code in the reactive region
// set, and the release 5.052 of Verilator does not support a program
// declared in a module.

module test_program_nonblocking_delay_re_nba_slot;
  int u = 0, u2 = 0, u2_copy = -1, g = 0, g_copy = 0;

  always @(u2) u2_copy = u2;
  always @(g) g_copy = g;

  program p;
    initial begin
      #1;
      u <= 4;
      u2 <= #2 6;
      #0 $display("at 1 after #0: u=%0d", u);
      #1 $display("at 2: u=%0d", u);
      #1;
      g = 1;
      @(u2);
      $display("at 3: u2=%0d g_copy=%0d", u2, g_copy);
      #1 $display("at 4: u2_copy=%0d g_copy=%0d", u2_copy, g_copy);
    end
  endprogram
endmodule
