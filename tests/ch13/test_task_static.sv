/*
:name: test_task_static
:description: Static task variables test
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3.1 6.21
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_task_static.expected
*/
// Static task variables test
module test_task_static;

  // Task with static counter
  task automatic count_calls(output int count);
    static int call_count = 0;
    call_count++;
    count = call_count;
  endtask

  // Task with static accumulator
  task automatic accumulate(input int value, output int total);
    static int sum = 0;
    sum = sum + value;
    total = sum;
  endtask

  // Task with static state machine
  task automatic state_machine(output int current_state);
    static int state = 0;
    case (state)
      0: state = 1;
      1: state = 2;
      2: state = 3;
      3: state = 0;
    endcase
    current_state = state;
  endtask

  // Task with multiple static variables
  task automatic min_max_tracker(input int value, output int min_val, output int max_val);
    static int first_call = 1;
    static int min_seen = 0;
    static int max_seen = 0;

    if (first_call) begin
      min_seen = value;
      max_seen = value;
      first_call = 0;
    end else begin
      if (value < min_seen) min_seen = value;
      if (value > max_seen) max_seen = value;
    end

    min_val = min_seen;
    max_val = max_seen;
  endtask

  // Task with static array for history
  task automatic record_history(input int value, output int last_three[3]);
    static int history[3] = '{0, 0, 0};
    static int idx = 0;

    history[idx] = value;
    idx = (idx + 1) % 3;

    // Return current history
    for (int i = 0; i < 3; i++) begin
      last_three[i] = history[i];
    end
  endtask

  initial begin
    int count, total, state;
    int min_v, max_v;
    int hist[3];
    int pass_count;

    pass_count = 0;

    // Test 1: Static counter persists
    count_calls(count);
    count_calls(count);
    count_calls(count);
    if (count == 3) begin
      $display("Test 1 PASS: count_calls() called 3 times, count = %0d", count);
      pass_count++;
    end else begin
      $display("Test 1 FAIL: count = %0d, expected 3", count);
    end

    // Test 2: Static accumulator
    accumulate(10, total);
    accumulate(20, total);
    accumulate(30, total);
    if (total == 60) begin
      $display("Test 2 PASS: accumulate(10,20,30) total = %0d", total);
      pass_count++;
    end else begin
      $display("Test 2 FAIL: total = %0d, expected 60", total);
    end

    // Test 3: Static state machine
    state_machine(state);  // 0 -> 1
    state_machine(state);  // 1 -> 2
    state_machine(state);  // 2 -> 3
    if (state == 3) begin
      $display("Test 3 PASS: state_machine() after 3 calls, state = %0d", state);
      pass_count++;
    end else begin
      $display("Test 3 FAIL: state = %0d, expected 3", state);
    end

    // Test 4: Min/max tracker with multiple static vars
    min_max_tracker(50, min_v, max_v);
    min_max_tracker(30, min_v, max_v);
    min_max_tracker(70, min_v, max_v);
    min_max_tracker(40, min_v, max_v);
    if (min_v == 30 && max_v == 70) begin
      $display("Test 4 PASS: min_max_tracker min=%0d, max=%0d", min_v, max_v);
      pass_count++;
    end else begin
      $display("Test 4 FAIL: min=%0d (exp 30), max=%0d (exp 70)", min_v, max_v);
    end

    // Test 5: Static array history
    record_history(100, hist);
    record_history(200, hist);
    record_history(300, hist);
    // History should now contain 100, 200, 300 (circular buffer at idx 0)
    if (hist[0] == 100 && hist[1] == 200 && hist[2] == 300) begin
      $display("Test 5 PASS: record_history = [%0d, %0d, %0d]", hist[0], hist[1], hist[2]);
      pass_count++;
    end else begin
      $display("Test 5 FAIL: history = [%0d, %0d, %0d]", hist[0], hist[1], hist[2]);
    end

    if (pass_count == 5)
      $display("PASS: All static task variable tests passed");
    else
      $display("FAIL: %0d/5 tests passed", pass_count);

    $finish;
  end

endmodule
