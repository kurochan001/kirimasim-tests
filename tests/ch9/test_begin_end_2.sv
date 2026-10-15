/*
:name: test_begin_end_2
:description: Test begin-end block (IEEE 1800-2023 Section 9.3.1)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.3.1 9.3.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_begin_end_2.expected
*/
// Test begin-end block (IEEE 1800-2023 Section 9.3.1)

module test_begin_end;
  int a, b, c;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Simple block
    begin
      a = 10;
      b = 20;
    end
    if (a == 10 && b == 20) pass_count++;

    // Test 2: Nested blocks
    begin
      a = 1;
      begin
        b = 2;
        c = 3;
      end
    end
    if (a == 1 && b == 2 && c == 3) pass_count++;

    // Test 3: Named block
    begin : my_block
      a = 100;
    end
    if (a == 100) pass_count++;

    $display("Begin-end tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Begin-end tests");
    end else begin
      $display("FAIL: Some begin-end tests failed");
    end
  end
endmodule
