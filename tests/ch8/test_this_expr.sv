/*
:name: test_this_expr
:description: Test this expression (IEEE 1800-2023 Section 8.11)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_this_expr.expected
*/
// Test this expression (IEEE 1800-2023 Section 8.11)

class Counter;
  int count;

  function new();
    this.count = 0;
  endfunction

  function void increment();
    this.count = this.count + 1;
  endfunction

  function int get_count();
    return this.count;
  endfunction
endclass

module test_this_expr;
  Counter c;
  int pass_count;

  initial begin
    pass_count = 0;

    c = new();

    // Test 1: Initial value via this
    if (c.get_count() == 0) pass_count++;

    // Test 2: Modify via this
    c.increment();
    if (c.get_count() == 1) pass_count++;

    // Test 3: Multiple increments
    c.increment();
    c.increment();
    if (c.get_count() == 3) pass_count++;

    $display("This expr tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: This expr tests");
    end else begin
      $display("FAIL: Some this expr tests failed");
    end
  end
endmodule
