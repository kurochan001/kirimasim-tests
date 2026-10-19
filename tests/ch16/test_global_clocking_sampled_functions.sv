/*
:name: test_global_clocking_sampled_functions
:description: the global clocking past functions compare with the previous global clock tick and the future functions with the next one, $rose_gclk, $fell_gclk, $rising_gclk and $falling_gclk look only at the LSB, $changing_gclk is the complement of $steady_gclk, and the action block of an assertion with a future function runs at the following global clock tick (IEEE 1800-2023 Section 16.9.4)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.4 16.9.3 14.14 16.14.1 16.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_global_clocking_sampled_functions.expected
*/
// IEEE 1800-2023 §16.9.4: $past_gclk, $rose_gclk, $fell_gclk and $changed_gclk
// are $past, $rose, $fell and $changed clocked by $global_clock (§14.14), so
// $rose and $fell look at the LSB only (§16.9.3). $future_gclk(v) is the
// sampled value of v at the next global clock tick; $rising_gclk and
// $falling_gclk tell whether the LSB rises or falls there, $steady_gclk whether
// v keeps its value, and $changing_gclk is !$steady_gclk. The action block of
// an assertion with a future function runs at the global clock tick after the
// attempt. The global clock ticks at 5, 15, 25, ... and v is sampled as 00,
// 10, 11, 01, 01, 00, 00, 00 there: the MSB changes at 15 and 35, the LSB
// rises at 25 and falls at 55. The cover statements (§16.14.3) record when
// the past functions are true; the fail actions (§16.14.1) of the assertions
// record when the future functions are true at the tick before.

`timescale 1ns/1ns

module test_global_clocking_sampled_functions;
  bit clk;
  bit [1:0] v;
  int m_rose[$], m_fell[$], m_changed[$], m_past[$];
  int f_rising[$], f_falling[$], f_changing[$], f_future[$];
  int not_complement = 0;

  global clocking gc @(posedge clk); endclocking

  always #5 clk = ~clk;   // global clock ticks at 5, 15, 25, ...

  c_rose: cover property (@($global_clock) $rose_gclk(v)) m_rose.push_back($time);
  c_fell: cover property (@($global_clock) $fell_gclk(v)) m_fell.push_back($time);
  c_changed: cover property (@($global_clock) $changed_gclk(v)) m_changed.push_back($time);
  c_past: cover property (@($global_clock) $past_gclk(v) == 2'b11) m_past.push_back($time);

  a_rising: assert property (@($global_clock) !$rising_gclk(v)) else f_rising.push_back($time);
  a_falling: assert property (@($global_clock) !$falling_gclk(v)) else f_falling.push_back($time);
  a_changing: assert property (@($global_clock) !$changing_gclk(v))
    else f_changing.push_back($time);
  a_future: assert property (@($global_clock) $future_gclk(v) != 2'b01)
    else f_future.push_back($time);
  a_complement: assert property (@($global_clock) $steady_gclk(v) != $changing_gclk(v))
    else not_complement++;

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    v = 2'b00; #10;
    v = 2'b10; #10;
    v = 2'b11; #10;
    v = 2'b01; #20;
    v = 2'b00; #30;
    $display("$rose_gclk:%s", times(m_rose));
    $display("$fell_gclk:%s", times(m_fell));
    $display("$changed_gclk:%s", times(m_changed));
    $display("$past_gclk(v) == 2'b11:%s", times(m_past));
    $display("$rising_gclk, actions at:%s", times(f_rising));
    $display("$falling_gclk, actions at:%s", times(f_falling));
    $display("$changing_gclk, actions at:%s", times(f_changing));
    $display("$future_gclk(v) == 2'b01, actions at:%s", times(f_future));
    $display("$steady_gclk == $changing_gclk: %0d", not_complement);
    $finish;
  end
endmodule
