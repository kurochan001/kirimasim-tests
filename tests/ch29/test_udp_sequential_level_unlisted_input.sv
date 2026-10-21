/*
:name: test_udp_sequential_level_unlisted_input
:description: A level-sensitive sequential UDP whose table lists no entry for an unknown data input sets its output to x, and a later known input gives it a value again (IEEE 1800-2023 Section 29.6)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.6 29.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_udp_sequential_level_unlisted_input.expected
*/
// IEEE 1800-2023 §29.6: when the inputs of a sequential UDP change and no
// table entry matches them, the output becomes x, as for a combinational UDP
// (29.4). The latch lists 1 0 and 1 1, so setting d to x while en is 1
// matches no entry and makes q x; the next known d matches again. While en is
// 0 the hold entry ? ? : - with the current state ? keeps q.

primitive udp_latch_level (q, en, d);
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

module test_udp_sequential_level_unlisted_input;
  reg en, d;
  wire q;

  udp_latch_level u (q, en, d);

  initial begin
    en = 0;
    d = 0;
    #1 $display("en=%b d=%b: q=%b", en, d, q);
    en = 1;
    #1 $display("en=%b d=%b: q=%b", en, d, q);
    d = 1'bx;
    #1 $display("en=%b d=%b: q=%b", en, d, q);
    d = 1;
    #1 $display("en=%b d=%b: q=%b", en, d, q);
  end
endmodule
