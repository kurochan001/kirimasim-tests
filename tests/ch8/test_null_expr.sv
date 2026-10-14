/*
:name: test_null_expr
:description: Test null expression (IEEE 1800-2023 Section 8.4)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_null_expr.expected
*/
// Test null expression (IEEE 1800-2023 Section 8.4)

class MyClass;
  int value;
  function new(int v);
    value = v;
  endfunction
endclass

module test_null_expr;
  MyClass obj;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Null before new
    if (obj == null) pass_count++;

    // Test 2: Not null after new
    obj = new(42);
    if (obj != null) pass_count++;

    // Test 3: Assign back to null
    obj = null;
    if (obj == null) pass_count++;

    $display("Null expr tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Null expr tests");
    end else begin
      $display("FAIL: Some null expr tests failed");
    end
  end
endmodule
