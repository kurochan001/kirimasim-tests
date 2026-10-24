/*
:name: test_first_match_items_and_boolean_or
:description: match items written inside first_match after its operand run only for the first match, while items attached to the operand itself run for every match, and or of two Boolean expressions matches at every tick where at least one of them is true (IEEE 1800-2023 Sections 16.9.8, 16.9.7)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.8 16.9.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_first_match_items_and_boolean_or.expected
*/
// IEEE 1800-2023 §16.9.8: first_match keeps only the earliest-ending match of
// its operand, and sequence match items can follow the operand inside the
// parentheses of first_match; they belong to the matches of first_match.
// The same items attached to the operand sequence itself run at each of its
// matches (§16.10, §16.11). §16.9.7: when both operands of or are Boolean
// expressions, the sequence matches at each tick where at least one of them
// is true.
// Tick k is at 10 * k + 5. p is high at ticks 1 and 3, q at 2 and 3, so
// p or q holds at 15, 25 and 35 and not at 45. a is high at tick 5 and b at
// ticks 6 and 7, with d = 60, 70 and 80 at ticks 6 to 8. first_match
// (a ##[1:3] b) ends only at tick 6: its local variable gets 60 and its
// call runs once; the items on a ##[1:3] b itself run at 65 and 75. The calls
// record time:value; the lists are printed at the end.
// Icarus Verilog 13.0 does not support these assertions; Verilator 5.052
// rejects match items in first_match and the call attached to a ##[1:3] b
// (p or q alone agrees with the standard).

`timescale 1ns/1ns

module test_first_match_items_and_boolean_or;
  logic clk = 0, p = 0, q = 0, a = 0, b = 0;
  int d = 0;
  string m[string];
  string order[] = '{"p or q", "first_match call", "first_match local", "operand call"};

  function automatic void rec(string name, int v);
    string t = $sformatf(" %0t:%0d", $time, v);
    if (m.exists(name)) m[name] = {m[name], t};
    else m[name] = t;
  endfunction

  function automatic string ends(string name);
    return m.exists(name) ? m[name] : "";
  endfunction

  always #5 clk = ~clk;   // tick k at 10 * k + 5

  sequence s_fm_local;
    int v;
    first_match(a ##[1:3] b, v = d) ##1 (1'b1, rec("first_match local", v));
  endsequence

  c_or: cover property (@(posedge clk) p or q) rec("p or q", 1);
  c_fm: cover sequence (@(posedge clk) first_match(a ##[1:3] b, rec("first_match call", d)));
  c_fm_local: cover sequence (@(posedge clk) s_fm_local);
  c_all: cover sequence (@(posedge clk) (a ##[1:3] b, rec("operand call", d)));

  initial begin
    #10 p = 1;                // tick 1
    #10 p = 0; q = 1;         // tick 2
    #10 p = 1;                // tick 3
    #10 p = 0; q = 0;         // tick 4
    #10 a = 1;                // tick 5
    #10 a = 0; b = 1; d = 60; // tick 6
    #10 d = 70;               // tick 7
    #10 b = 0; d = 80;        // tick 8
    #10 d = 0;                // tick 9
    #20;
    foreach (order[i]) $display("%s: [%s ]", order[i], ends(order[i]));
    $finish;
  end
endmodule
