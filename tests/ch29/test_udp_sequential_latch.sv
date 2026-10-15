/*
:name: test_udp_sequential_latch
:description: Level-sensitive sequential UDP (latch) with an initial statement
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.5 29.3.4 29.7
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_udp_sequential_latch.expected
*/
// IEEE 1800-2023 §29.4: Sequential UDP
// Tests level-sensitive sequential UDP (latch behavior)
// When en=1, q follows d; when en=0, q holds previous value

primitive latch_udp(output reg q, input en, d);
  initial q = 0;
  table
    // en d : q : q'
       1  0 : ? : 0;
       1  1 : ? : 1;
       0  ? : ? : -;
     endtable
endprimitive

module test_udp_sequential_latch;
  reg clk, d;
  wire q;
  latch_udp u1(q, clk, d);

  initial begin
    clk = 0; d = 0; #1;
    // initial q=0
    assert(q==0) else $fatal(1, "q==0 failed");
    // Enable high: q follows d
    clk = 1; d = 1; #1; assert(q==1) else $fatal(1, "q should follow d when en=1");
    d = 0; #1; assert(q==0) else $fatal(1, "q==0 failed");
    // Disable: hold
    clk = 0; d = 1; #1; assert(q==0) else $fatal(1, "q should hold when en=0");
    $display("UDP sequential latch test PASSED");
    $finish;
  end
endmodule
