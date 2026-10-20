/*
:name: test_program_end_kills_descendants
:description: Nested programs without ports are instantiated once and share the variables of their module; when the initial procedures of a program end, its forked threads end too, and the simulation ends when every program is done (IEEE 1800-2023 Section 24.3)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.3 9.2.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_end_kills_descendants.expected
*/
// IEEE 1800-2023 §24.3: programs nested in a module and without ports are
// implicitly instantiated once, and both p_short and p_long see the module's
// shared. When all initial procedures of a program have ended, the program
// ends their descendant threads at once: p_short's initial procedure ends at
// 10, so the thread it forked, which would set shared to 99 at 15, never
// runs on. When the initial procedures of all programs have ended, at 20 when
// p_long ends, the simulation ends by an implicit $finish: the module's own
// message at 30 never appears, and its final procedure (9.2.3) runs at 20.

module test_program_end_kills_descendants;
  int shared = 0;

  initial #30 $display("%0d: module still running", $time);
  final $display("%0d: final, shared = %0d", $time, shared);

  program p_short;
    initial begin
      fork
        #15 begin
          shared = 99;
          $display("%0d: forked thread of p_short", $time);
        end
      join_none
      #10 shared = 1;
      $display("%0d: p_short ends", $time);
    end
  endprogram

  program p_long;
    initial begin
      #20 $display("%0d: p_long sees shared = %0d", $time, shared);
    end
  endprogram
endmodule
