/*
:name: test_vpi_force_release_fixed_memory_word_keeps_other_words_independent
:description: Force and release of a complete fixed-array word overrides writes to it, holds the released value until the next write, and leaves its neighbors independent
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.34 10.6.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @vpi_force_release_target.c
:expected_stdout: @test_vpi_force_release_fixed_memory_word_keeps_other_words_independent.expected
*/
module test_vpi_force_release_fixed_memory_word_keeps_other_words_independent;
  int memory_vpi[2:4];
  int memory_sv[2:4];

  task automatic sample(input string phase_name);
    $display("%s: vpi=%0d %0d %0d sv=%0d %0d %0d", phase_name,
             memory_vpi[2], memory_vpi[3], memory_vpi[4],
             memory_sv[2], memory_sv[3], memory_sv[4]);
  endtask

  task automatic write_words(input int first, middle, last);
    memory_vpi[2] = first;
    memory_vpi[3] = middle;
    memory_vpi[4] = last;
    memory_sv[2] = first;
    memory_sv[3] = middle;
    memory_sv[4] = last;
  endtask

  initial begin
    write_words(10, 20, 30);
    #1;
    sample("initial");
    $vt_force_target(memory_vpi[3]);
    force memory_sv[3] = 32'h6a5;
    #1;
    sample("forced");
    write_words(11, 77, 33);
    #1;
    sample("written while forced");
    $vt_release_target(memory_vpi[3]);
    release memory_sv[3];
    sample("released");
    write_words(12, 88, 36);
    #1;
    sample("written after release");
  end
endmodule
