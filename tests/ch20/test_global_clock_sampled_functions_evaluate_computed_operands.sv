/*
:name: test_global_clock_sampled_functions_evaluate_computed_operands
:description: All global clock sampled functions evaluate computed operands in the correct previous or next tick
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.12 16.9.4 14.14
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_global_clock_sampled_functions_evaluate_computed_operands.expected
*/
`timescale 1ns/1ns

module test_global_clock_sampled_functions_evaluate_computed_operands;
  bit clk;
  bit [3:0] left, right;
  wire [3:0] named_sum = left + right;
  wire sum_lsb = left[0] ^ right[0];
  int future_value[$], rising[$], falling[$], steady[$], changing[$];

  global clocking history_clock @(posedge clk); endclocking
  always #5 clk = !clk;

  always @(posedge clk)
    if ($time >= 15 && $time <= 45)
      $display("t=%0d past=%0d edge=%b%b stable-change=%b%b named=%0d/%b%b",
               $time, $past_gclk(left + right), $rose_gclk(sum_lsb), $fell_gclk(sum_lsb),
               $stable_gclk(left + right), $changed_gclk(left + right),
               $past_gclk(named_sum), $stable_gclk(named_sum), $changed_gclk(named_sum));

  cover property (@($global_clock) $future_gclk(left + right) == 2)
    future_value.push_back($time);
  cover property (@($global_clock) $rising_gclk(sum_lsb)) rising.push_back($time);
  cover property (@($global_clock) $falling_gclk(sum_lsb)) falling.push_back($time);
  cover property (@($global_clock) $steady_gclk(left + right)) steady.push_back($time);
  cover property (@($global_clock) $changing_gclk(left + right)) changing.push_back($time);

  function automatic string ticks(int values[$]);
    string result = "";
    foreach (values[i]) result = {result, $sformatf(" %0d", values[i])};
    return result;
  endfunction

  initial begin
    left = 1; right = 0;
    #10 left = 0; right = 2;
    #10 left = 1; right = 1;
    #10 left = 2; right = 1;
    #10 left = 0; right = 0;
    #19;
    $display("future sum 2:%s", ticks(future_value));
    $display("rising:%s", ticks(rising));
    $display("falling:%s", ticks(falling));
    $display("steady:%s", ticks(steady));
    $display("changing:%s", ticks(changing));
    $finish;
  end
endmodule
