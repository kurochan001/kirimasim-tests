/*
:name: test_ch9_extra_procedure_count
:description: 128 initial procedures and 128 always procedures all begin at time zero, so the language imposes no small fixed limit on the number of module procedures (IEEE 1800-2023 Section 9.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ch9_extra_procedure_count.expected
*/
// IEEE 1800-2023 §9.2: the language sets no count limit on the initial and
// always procedures of a module, and all of them begin execution at time
// zero. This module declares 128 initial procedures and 128 always
// procedures. Each initial procedure increments init_count once; each always
// procedure increments always_count and then blocks on the named event e, so
// it starts exactly once and does not loop in zero time.
//
// At time 1 the observer prints both counts. Every procedure must have run
// by then, so both counts are 128. A tool with a fixed limit below 128
// procedures would reject the design or leave one of the counts short. The
// limit is not made observable by any finite design, so this shows only that
// 128 procedures are accepted, not that no limit exists at all.

`timescale 1ns/1ns

module test_ch9_extra_procedure_count;
  event e;
  int init_count = 0;
  int always_count = 0;

  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial init_count++;
  always begin always_count++; @e; end
  initial begin
    #1;
    $display("init=%0d always=%0d", init_count, always_count);
    $display("all_128_started=%0d",
             (init_count == 128) && (always_count == 128));
    $finish;
  end
endmodule
