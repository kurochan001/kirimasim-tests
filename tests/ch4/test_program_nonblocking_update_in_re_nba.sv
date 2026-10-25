/*
:name: test_program_nonblocking_update_in_re_nba
:description: A nonblocking assignment in a program schedules its update in the Re-NBA region of the current time slot, or of a later one for a delayed assignment, so the update comes after the Reactive events of that slot and before the active region set runs again (IEEE 1800-2023 Section 4.4.2.8)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.8 4.5 24.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_nonblocking_update_in_re_nba.expected
*/
// IEEE 1800-2023 §4.4.2.8: a nonblocking assignment executed in the reactive
// region set creates an update event in the Re-NBA region, of the current
// time slot or of a later one. §24.3.1: the processes of a program run in
// the Reactive region. §4.5: an update in the Re-NBA region is applied
// within the reactive region set, and the program processes it wakes run
// before any module process, which waits for the active region set.
// At time 1 the program process main writes flag = 1, which wakes the module
// process that copies it into flag_copy, then pv <= 5, which is not seen at
// once, and pv <= #2 7. The update of pv at time 1 wakes the program process
// waiter and the module process that copies pv into module_seen. waiter
// runs before both module processes: it sees pv=5, flag_copy=0 and
// module_seen=0. An update in the NBA region of the active set would come
// after the module process woken by flag, so waiter would see flag_copy=1.
// At time 3 main resumes in the Reactive region before the Re-NBA update of
// that time slot, so it still sees pv=5; at time 4 the update to 7 has been
// made and has reached the module process.
// Icarus Verilog 13.0 does not schedule the nonblocking assignments of a
// program in the Re-NBA region (waiter sees flag_copy=1), and the release
// 5.052 of Verilator does not support a program declared in a module.

module test_program_nonblocking_update_in_re_nba;
  int pv = 0, module_seen = 0, flag = 0, flag_copy = 0;

  always @(pv) module_seen = pv;
  always @(flag) flag_copy = flag;

  program p;
    initial begin : waiter
      @(pv);
      $display("waiter: pv=%0d flag_copy=%0d module_seen=%0d", pv, flag_copy, module_seen);
    end

    initial begin : main
      #1;
      flag = 1;
      pv <= 5;
      $display("right after <=: pv=%0d", pv);
      pv <= #2 7;
      #1 $display("at 2: pv=%0d flag_copy=%0d module_seen=%0d", pv, flag_copy, module_seen);
      #1 $display("at 3: pv=%0d", pv);
      #1 $display("at 4: pv=%0d module_seen=%0d", pv, module_seen);
    end
  endprogram
endmodule
