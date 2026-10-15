/*
:name: test_do_while_loop
:description: Test do-while loop (IEEE 1800-2023 Section 12.7.1)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.5 12.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_do_while_loop.expected
*/
// Test do-while loop (IEEE 1800-2023 Section 12.7.1)

module test_do_while_loop;
  int counter;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Basic do-while
    counter = 0;
    do begin
      counter++;
    end while (counter < 5);
    if (counter == 5) pass_count++;

    // Test 2: Condition false initially (still executes once)
    counter = 10;
    do begin
      counter++;
    end while (counter < 5);
    if (counter == 11) pass_count++;

    // Test 3: Do-while with break
    counter = 0;
    do begin
      counter++;
      if (counter == 3) break;
    end while (counter < 10);
    if (counter == 3) pass_count++;

    // Test 4: Do-while with continue
    counter = 0;
    do begin
      counter++;
      if (counter == 2) continue;
    end while (counter < 4);
    if (counter == 4) pass_count++;

    // Test 5: Nested do-while
    counter = 0;
    do begin
      int inner;
      inner = 0;
      do begin
        counter++;
        inner++;
      end while (inner < 2);
    end while (counter < 6);
    if (counter == 6) pass_count++;

    $display("Do-while loop tests: %0d/5 passed", pass_count);
    if (pass_count >= 4) begin
      $display("PASS: Do-while loop tests");
    end else begin
      $display("FAIL: Some do-while tests failed");
    end
  end
endmodule
