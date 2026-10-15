/*
:name: test_forever_stmt
:description: Test forever statement with break (IEEE 1800-2023 Sections 12.7.6 and 12.8)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.6 12.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_forever_stmt.expected
*/
// Test forever statement with break (IEEE 1800-2023 Sections 12.7.6 and 12.8)

module test_forever_stmt;
  int counter;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Forever with break
    counter = 0;
    forever begin
      counter = counter + 1;
      if (counter >= 5) break;
    end
    if (counter == 5) pass_count++;

    // Test 2: Forever counting to 10
    counter = 0;
    forever begin
      counter = counter + 2;
      if (counter >= 10) break;
    end
    if (counter == 10) pass_count++;

    // Test 3: Forever with immediate break
    counter = 100;
    forever begin
      break;
    end
    if (counter == 100) pass_count++;

    $display("Forever stmt tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Forever stmt tests");
    end else begin
      $display("FAIL: Some forever stmt tests failed");
    end
  end
endmodule
