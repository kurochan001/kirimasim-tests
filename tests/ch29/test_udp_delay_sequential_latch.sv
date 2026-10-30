/*
:name: test_udp_delay_sequential_latch
:description: A level-sensitive sequential UDP with one delay changes its output that much later, keeps the old value until then, and does not start a delay when it holds (IEEE 1800-2023 Section 29.8)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.8 29.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_udp_delay_sequential_latch.expected
*/
// IEEE 1800-2023 §29.8: the delay of a sequential UDP instance (29.5) applies
// to each change of its output, which keeps its old value until the delay has
// passed. The output starts at x; enabling the latch at 1 with d = 0 gives 0
// at 4. Then d = 1 at 5 gives 1 at 8, so the output is still 0 at 7. Disabling
// the latch at 9 holds the value at once, and the change of d at 10 schedules
// nothing, so the output is still 1 at 13.5, after the delay a change at 10
// would have taken. The test samples half a nanosecond before and after each
// due change: a sample in the time step of a change could run before or after
// the change (4.7).

`timescale 1ns/100ps

primitive udp_latch_d (q, en, d);
  output q;
  reg q;
  input en, d;
  table
  // en d : q : q+
    1 0 : ? : 0;
    1 1 : ? : 1;
    0 ? : ? : -;
  endtable
endprimitive

module test_udp_delay_sequential_latch;
  reg en, d;
  wire q;

  udp_latch_d #(3) u (q, en, d);

  initial begin
    en = 0;
    d = 0;
    #1 $display("t=%0.1f: q=%b", $realtime, q);
    en = 1;
    #2.5 $display("t=%0.1f: q=%b", $realtime, q);
    #1 $display("t=%0.1f: q=%b", $realtime, q);
    #0.5 d = 1;
    #2.5 $display("t=%0.1f: q=%b", $realtime, q);
    #1 $display("t=%0.1f: q=%b", $realtime, q);
    #0.5 en = 0;
    #1 d = 0;
    #3.5 $display("t=%0.1f: q=%b", $realtime, q);
  end
endmodule
