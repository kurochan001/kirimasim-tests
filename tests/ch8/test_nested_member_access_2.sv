/*
:name: test_nested_member_access_2
:description: Test for nested member access (IEEE 1800-2023 §8)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4 8.5 8.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nested_member_access_2.expected
*/
// Test for nested member access (IEEE 1800-2023 §8)
// Tests chained member access and method calls

class InnerClass;
  int value;
  string name;

  function new(int v, string n);
    value = v;
    name = n;
  endfunction

  function int get_value();
    return value;
  endfunction

  function int double_value();
    return value * 2;
  endfunction
endclass

class OuterClass;
  InnerClass inner;
  int outer_value;
  int values[$];

  function new();
    outer_value = 100;
    inner = new(50, "inner_name");
    values.push_back(1);
    values.push_back(2);
    values.push_back(3);
  endfunction

  function InnerClass get_inner();
    return inner;
  endfunction

  function int get_inner_value();
    return inner.value;
  endfunction
endclass

module test_nested_member_access_2;
  int pass_count = 0;
  int test_count = 0;

  initial begin
    OuterClass outer;
    int result;
    string str_result;

    outer = new();

    // Test 1: Direct nested access obj.member.member
    test_count++;
    result = outer.inner.value;
    if (result == 50) begin
      $display("PASS: outer.inner.value = %0d", result);
      pass_count++;
    end else begin
      $display("FAIL: Expected 50, got %0d", result);
    end

    // Test 2: Nested string member
    test_count++;
    str_result = outer.inner.name;
    if (str_result == "inner_name") begin
      $display("PASS: outer.inner.name = %s", str_result);
      pass_count++;
    end else begin
      $display("FAIL: Expected inner_name, got %s", str_result);
    end

    // Test 3: Nested method call obj.member.method()
    test_count++;
    result = outer.inner.get_value();
    if (result == 50) begin
      $display("PASS: outer.inner.get_value() = %0d", result);
      pass_count++;
    end else begin
      $display("FAIL: Expected 50, got %0d", result);
    end

    // Test 4: Method returning object, then accessing member
    test_count++;
    result = outer.get_inner().value;
    if (result == 50) begin
      $display("PASS: outer.get_inner().value = %0d", result);
      pass_count++;
    end else begin
      $display("FAIL: Expected 50, got %0d", result);
    end

    // Test 5: Method returning object, then calling method
    test_count++;
    result = outer.get_inner().double_value();
    if (result == 100) begin
      $display("PASS: outer.get_inner().double_value() = %0d", result);
      pass_count++;
    end else begin
      $display("FAIL: Expected 100, got %0d", result);
    end

    // Test 6: Helper method accessing nested member
    test_count++;
    result = outer.get_inner_value();
    if (result == 50) begin
      $display("PASS: outer.get_inner_value() = %0d", result);
      pass_count++;
    end else begin
      $display("FAIL: Expected 50, got %0d", result);
    end

    // Test 7: Modify nested member
    test_count++;
    outer.inner.value = 75;
    result = outer.inner.value;
    if (result == 75) begin
      $display("PASS: Modified outer.inner.value = %0d", result);
      pass_count++;
    end else begin
      $display("FAIL: Expected 75, got %0d", result);
    end

    // Test 8: Queue method on nested member
    test_count++;
    result = outer.values.size();
    if (result == 3) begin
      $display("PASS: outer.values.size() = %0d", result);
      pass_count++;
    end else begin
      $display("FAIL: Expected 3, got %0d", result);
    end

    // Test 9: Queue access on nested member
    test_count++;
    result = outer.values[1];
    if (result == 2) begin
      $display("PASS: outer.values[1] = %0d", result);
      pass_count++;
    end else begin
      $display("FAIL: Expected 2, got %0d", result);
    end

    // Test 10: Queue push on nested member
    test_count++;
    outer.values.push_back(4);
    result = outer.values.size();
    if (result == 4) begin
      $display("PASS: After push_back, outer.values.size() = %0d", result);
      pass_count++;
    end else begin
      $display("FAIL: Expected 4, got %0d", result);
    end

    // Summary
    $display("");
    $display("=== Nested Member Access Test Summary ===");
    $display("Tests: %0d, Passed: %0d", test_count, pass_count);
    if (pass_count == test_count) begin
      $display("PASS: All nested member access tests passed");
    end else begin
      $display("FAIL: Some nested member access tests failed");
    end

    $finish;
  end

endmodule
