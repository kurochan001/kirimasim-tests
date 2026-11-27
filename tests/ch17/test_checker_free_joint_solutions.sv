/*
:name: test_checker_free_joint_solutions
:description: Free checker choices use sampled inactive state and preserve a constant choice
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.7 17.7.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_checker_free_joint_solutions
:expected_stdout: @test_checker_free_joint_solutions.expected
*/
checker joint_free(input bit sample_clk, write_clk, impossible, input bit [1:0] next_held,
                   input bit [1:0] key_in, x_in, y_in,
                   output bit [1:0] key_out, held_out, x_out, y_out,
                   output int f0 = 0, f1 = 0, f2 = 0, f3 = 0);
  rand const bit [1:0] key;
  rand bit [1:0] x;
  rand bit [1:0] y;
  rand bit [1:0] held = 2;

  different: assume property (@(posedge sample_clk) x != held)
    else f0++;
  relation: assume property (@(posedge sample_clk) y == (x ^ held ^ key))
    else f1++;
  range_check: assume property (@(posedge sample_clk) y != 3)
    else f2++;
  contradiction: assume property (@(posedge sample_clk) !impossible || x == held)
    else f3++;

  always_ff @(posedge write_clk) held <= next_held;
  assign key_out = key;
  assign held_out = held;
  assign x_out = x;
  assign y_out = y;
endchecker

module test_checker_free_joint_solutions;
  timeunit 1ns;
  timeprecision 1ns;
  bit sample_clk, write_clk, impossible;
  bit [1:0] next_held = 1;
  bit [1:0] replay_key, replay_x, replay_y;
  wire [1:0] key, held, x, y;
  int f0, f1, f2, f3;
  int last_f0, last_f1, last_f2, last_f3;
  bit [1:0] initialized_key;
  int replay_x0, replay_y0, replay_x1, replay_y1;
  int key_argument;
  bit print_choices;

  joint_free u(sample_clk, write_clk, impossible, next_held, replay_key, replay_x, replay_y,
               key, held, x, y, f0, f1, f2, f3);

  task automatic report(input int step);
    bit [3:0] expected_mask, failed;
    expected_mask[0] = x == held;
    expected_mask[1] = y != (x ^ held ^ key);
    expected_mask[2] = y == 3;
    expected_mask[3] = impossible && x != held;
    $display("step=%0d held=%0d mask_ok=%0d constant=%0d", step, held,
             (f0 - last_f0) == int'(expected_mask[0])
                 && (f1 - last_f1) == int'(expected_mask[1])
                 && (f2 - last_f2) == int'(expected_mask[2])
                 && (f3 - last_f3) == int'(expected_mask[3]), key == initialized_key);
    if (print_choices) begin
      failed[0] = f0 > last_f0;
      failed[1] = f1 > last_f1;
      failed[2] = f2 > last_f2;
      failed[3] = f3 > last_f3;
      $display("choice step=%0d key=%0d held=%0d x=%0d y=%0d failed=%0d",
               step, key, held, x, y, failed);
    end
    last_f0 = f0;
    last_f1 = f1;
    last_f2 = f2;
    last_f3 = f3;
  endtask

  initial begin
    print_choices = $test$plusargs("print-choices");
    if ($value$plusargs("choice_key=%d", key_argument)) replay_key = 2'(key_argument);
    if ($value$plusargs("x0=%d", replay_x0)) replay_x = 2'(replay_x0);
    if ($value$plusargs("y0=%d", replay_y0)) replay_y = 2'(replay_y0);
    void'($value$plusargs("x1=%d", replay_x1));
    void'($value$plusargs("y1=%d", replay_y1));
    #1 initialized_key = key;
    if (print_choices) $display("seed control=%h", $urandom);
    #4 sample_clk = 1;
    #1 report(0);
    sample_clk = 0;
    #2 write_clk = 1;
    #1 write_clk = 0;
    replay_x = 2'(replay_x1);
    replay_y = 2'(replay_y1);
    impossible = $test$plusargs("impossible-second");
    #1 $display("between held=%0d no_new_failures=%0d", held,
               f0 == last_f0 && f1 == last_f1 && f2 == last_f2 && f3 == last_f3);
    #1 sample_clk = 1;
    #1 report(1);
    $finish(0);
  end
endmodule
