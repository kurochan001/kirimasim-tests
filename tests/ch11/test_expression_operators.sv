/*
:name: test_expression_operators
:description: Test various expression operators (IEEE 1800-2023 Section 11)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11 11.4.13 11.4.12.1 11.5.1
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expression_operators.expected
*/
// Test various expression operators (IEEE 1800-2023 Section 11)

module test_expression_operators;
  logic [31:0] a, b, result;
  logic cond;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Conditional operator
    a = 100;
    b = 200;
    cond = 1;
    result = cond ? a : b;
    if (result == 100) pass_count++;

    // Test 2: Conditional with false
    cond = 0;
    result = cond ? a : b;
    if (result == 200) pass_count++;

    // Test 3: Nested conditional
    result = (a > b) ? a : (b > 150) ? b : 0;
    if (result == 200) pass_count++;

    // Test 4: Inside operator
    a = 5;
    if (a inside {1, 3, 5, 7, 9}) pass_count++;

    // Test 5: Inside with range
    a = 50;
    if (a inside {[1:100]}) pass_count++;

    // Test 6: Replication
    begin
      logic [15:0] rep;
      rep = {4{4'hA}};
      if (rep == 16'hAAAA) pass_count++;
    end

    // Test 7: Concatenation
    begin
      logic [15:0] cat;
      cat = {8'hAB, 8'hCD};
      if (cat == 16'hABCD) pass_count++;
    end

    // Test 8: Part select
    a = 32'h12345678;
    if (a[7:0] == 8'h78) pass_count++;
    if (a[31:24] == 8'h12) pass_count++;

    $display("Expression operator tests: %0d/9 passed", pass_count);
    if (pass_count == 9) begin
      $display("PASS: Expression operator tests");
    end else begin
      $display("FAIL: Some expression tests failed");
    end
  end
endmodule
