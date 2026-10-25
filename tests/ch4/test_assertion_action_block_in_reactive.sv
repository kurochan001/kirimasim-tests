/*
:name: test_assertion_action_block_in_reactive
:description: The pass and fail action blocks of a concurrent assertion run in the Reactive region of the time slot, after the NBA updates of the design and together with the program processes, before the active region set runs again (IEEE 1800-2023 Section 4.4.2.5)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.5 4.4.2.6 4.5 16.14.1 24.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assertion_action_block_in_reactive.expected
*/
// IEEE 1800-2023 §4.4.2.5: when a property is evaluated, its pass or fail code
// is scheduled in the Reactive region of the current time slot. §4.4.2.6: the
// action blocks of concurrent assertions run in the Reactive region, as the
// program processes do (§24.3.1). §4.5: the reactive region set is emptied
// before the active region set runs again.
// The assertion (§16.14.1) checks d < 2 on each rising edge of clk, at 5, 15
// and 25, with the value of d sampled before the edge: 0 and 1 pass and 2
// fails. A module process increments d with a nonblocking assignment on the
// same edges. Each action block prints d, which already holds the value
// after the NBA update (1, 2, 3), and increments act_count. That write wakes
// a program process, which runs in the Reactive region before the module
// process that copies act_count into module_count: the program process sees
// the module copy one behind. If the action blocks ran in the active region
// set, the module copy would be up to date.
// Icarus Verilog 13.0 does not support concurrent assertions, and the
// release 5.052 of Verilator does not support a program declared in a
// module.

module test_assertion_action_block_in_reactive;
  logic clk = 0;
  int d = 0, act_count = 0, module_count = 0;

  initial begin
    #5 clk = 1;
    #5 clk = 0;
    #5 clk = 1;
    #5 clk = 0;
    #5 clk = 1;
  end

  always @(posedge clk) d <= d + 1;
  always @(act_count) module_count = act_count;

  check_d: assert property (@(posedge clk) d < 2)
    begin
      $display("pass: d=%0d", d);
      act_count = act_count + 1;
    end
  else begin
    $display("fail: d=%0d", d);
    act_count = act_count + 1;
  end

  program p;
    initial begin
      repeat (3) begin
        @(act_count);
        $display("program: act_count=%0d module_count=%0d", act_count, module_count);
      end
    end
  endprogram
endmodule
