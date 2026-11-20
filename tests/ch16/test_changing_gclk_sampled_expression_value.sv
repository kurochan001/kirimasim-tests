/*
:name: test_changing_gclk_sampled_expression_value
:description: $changing_gclk compares the sampled value of its whole expression at the current and the next global clock tick, so operand changes that keep the value, a pulse between two ticks and the assignment of the same value do not count, while a change of any bit does (IEEE 1800-2023 Section 16.9.4)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.4 14.14 16.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_changing_gclk_sampled_expression_value.expected
*/
// IEEE 1800-2023 §16.9.4: $changing_gclk(e) is !$steady_gclk(e), which is
// true when the sampled value of e at the next global clock tick differs
// from its sampled value at the current one. It is about the value of the
// whole expression, not of its operands or of its LSB alone, and it sees
// only sampled values. The action block of an assertion with a global
// clocking future function runs at the global clock tick after the attempt.
// §14.14: the global clocking event here is posedge clk, so $global_clock
// ticks at 5, 15, 25, ... . §16.14.3: a cover property runs its action each
// time the property holds.
// a ^ b: a and b both rise at 10 and both are 1 again at 40, so the value
// stays 0 across 5-15 and 35-45; it is 1 from 20 and 0 from 30, so it
// changes across 15-25 and 25-35. v: a pulse from 21 to 23 falls between
// the ticks 15 and 25; bit 2 rises at 42 (the LSB stays 0), so v changes
// across 35-45; the LSB rises at 50, so v changes across 45-55; at 60 v is
// assigned the value it has. The cover actions push the time at which they
// run, one tick after the attempt: 25 and 35 for a ^ b, 45 and 55 for v.
// Icarus Verilog 13.0 does not support global clocking. The 5.054 release
// of Verilator prints the first line, but for v only the action at 55, as if
// the change of bit 2 across 35-45 were not seen, so the expected output
// follows the clauses alone.

`timescale 1ns/1ns

module test_changing_gclk_sampled_expression_value;
  bit clk;
  bit a, b;
  bit [3:0] v;
  int t_xor[$], t_vec[$];

  global clocking gck @(posedge clk); endclocking

  always #5 clk = ~clk;   // global clock ticks at 5, 15, 25, ...

  c_xor: cover property (@($global_clock) $changing_gclk(a ^ b)) t_xor.push_back($time);
  c_vec: cover property (@($global_clock) $changing_gclk(v)) t_vec.push_back($time);

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    #10 a = 1; b = 1;      // 10: a ^ b stays 0
    #10 a = 0;             // 20: a ^ b becomes 1
    #1 v = 4'b1000;        // 21: pulse between two ticks
    #2 v = 4'b0000;        // 23
    #7 b = 0;              // 30: a ^ b becomes 0
    #10 a = 1; b = 1;      // 40: a ^ b stays 0
    #2 v = 4'b0100;        // 42: bit 2 rises, the LSB stays 0
    #8 v = 4'b0101;        // 50: the LSB rises
    #10 v = 4'b0101;       // 60: the same value again
    #20;
    $display("$changing_gclk(a ^ b), actions at:%s", times(t_xor));
    $display("$changing_gclk(v), actions at:%s", times(t_vec));
    $finish;
  end
endmodule
