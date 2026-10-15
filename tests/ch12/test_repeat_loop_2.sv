/*
:name: test_repeat_loop_2
:description: Test repeat loop (IEEE 1800-2023 Section 12.7.2)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_repeat_loop_2.expected
*/
// Test repeat loop (IEEE 1800-2023 Section 12.7.2)

module test_repeat_loop;
  int counter;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Basic repeat
    counter = 0;
    repeat(5) counter++;
    if (counter == 5) pass_count++;

    // Test 2: Repeat with block
    counter = 0;
    repeat(3) begin
      counter += 10;
    end
    if (counter == 30) pass_count++;

    // Test 3: Repeat 0 times
    counter = 100;
    repeat(0) counter++;
    if (counter == 100) pass_count++;

    // Test 4: Nested repeat
    counter = 0;
    repeat(2) begin
      repeat(3) counter++;
    end
    if (counter == 6) pass_count++;

    // Test 5: Repeat with timing
    counter = 0;
    repeat(4) begin
      #5;
      counter++;
    end
    if (counter == 4 && $time == 20) pass_count++;

    $display("Repeat loop tests: %0d/5 passed", pass_count);
    if (pass_count == 5) begin
      $display("PASS: Repeat loop tests");
    end else begin
      $display("FAIL: Some repeat tests failed");
    end
  end
endmodule
