/*
:name: test_property_operator_precedence_temporal
:description: temporal property operators group by the precedence of Table 16-3: nexttime and s_nexttime over and, the four until operators below iff, |=> and #=# below implies, and always, s_always, eventually and s_eventually below and and or, shown by the number of successes of each assertion (IEEE 1800-2023 Section 16.12)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_operator_precedence_temporal.expected
*/
// IEEE 1800-2023 §16.12, Table 16-3: nexttime and s_nexttime bind tighter
// than and; until, s_until, until_with and s_until_with are below iff;
// |=> and #=# are below implies; always, s_always, eventually and
// s_eventually are the lowest, below and and or. So nexttime a and b is
// (nexttime a) and b, a until b iff c is a until (b iff c), a |=> b implies
// c is a |=> (b implies c), and always [0:1] a or b is always [0:1] (a or
// b). The covers start their attempts with st #-#, which is below all of
// these but the lowest level, so st #-# p checks p at the ticks where st is
// high, and count their successes; the two assertions count their passes
// and failures over all ticks. a, b, c and st take the values of the table
// in the initial procedure at the ticks 5, 15, ..., 135. Each grouping that
// another precedence would give has a different count.
// Icarus Verilog 13.0 does not support these assertions and Verilator
// 5.052 rejects nexttime.

`timescale 1ns/1ns

module test_property_operator_precedence_temporal;
  logic clk = 0, a = 0, b = 0, c = 0, st = 0;
  int n[string];
  string order[] = '{"nexttime a and b", "s_nexttime a and b", "always [0:1] a or b",
                      "s_always [0:1] a or b", "eventually [0:1] a and b",
                      "s_eventually [0:1] a and b", "a until b iff c", "a s_until b iff c",
                      "a until_with b iff c", "a s_until_with b iff c", "a |=> b implies c P",
                      "a |=> b implies c F", "a #=# b implies c P", "a #=# b implies c F"};

  function automatic void inc(string name);
    n[name] = n.exists(name) ? n[name] + 1 : 1;
  endfunction

  always #5 clk = ~clk;   // ticks at 5, 15, ..., 135

  c1: cover property (@(posedge clk) st #-# nexttime a and b) inc("nexttime a and b");
  c2: cover property (@(posedge clk) st #-# s_nexttime a and b) inc("s_nexttime a and b");
  c3: cover property (@(posedge clk) st #-# always [0:1] a or b) inc("always [0:1] a or b");
  c4: cover property (@(posedge clk) st #-# s_always [0:1] a or b) inc("s_always [0:1] a or b");
  c5: cover property (@(posedge clk) st #-# eventually [0:1] a and b)
    inc("eventually [0:1] a and b");
  c6: cover property (@(posedge clk) st #-# s_eventually [0:1] a and b)
    inc("s_eventually [0:1] a and b");
  c7: cover property (@(posedge clk) st #-# a until b iff c) inc("a until b iff c");
  c8: cover property (@(posedge clk) st #-# a s_until b iff c) inc("a s_until b iff c");
  c9: cover property (@(posedge clk) st #-# a until_with b iff c) inc("a until_with b iff c");
  c10: cover property (@(posedge clk) st #-# a s_until_with b iff c)
    inc("a s_until_with b iff c");
  p11: assert property (@(posedge clk) a |=> b implies c)
    inc("a |=> b implies c P"); else inc("a |=> b implies c F");
  p12: assert property (@(posedge clk) a #=# b implies c)
    inc("a #=# b implies c P"); else inc("a #=# b implies c F");

  // a, b, c, st sampled at the ticks 0 to 13
  bit [3:0] table_abcs[14] = '{4'b1111, 4'b0110, 4'b0110, 4'b1110, 4'b1011, 4'b0011, 4'b0100,
                               4'b0000, 4'b0011, 4'b1101, 4'b1101, 4'b0001, 4'b0000, 4'b0000};

  initial begin
    foreach (table_abcs[k]) begin
      {a, b, c, st} = table_abcs[k];
      #10;
    end
    foreach (order[i]) $display("%s: %0d", order[i], n.exists(order[i]) ? n[order[i]] : 0);
    $finish;
  end
endmodule
