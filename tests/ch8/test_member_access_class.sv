/*
:name: test_member_access_class
:description: Test for class member access (IEEE 1800-2023 §8)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4 8.5 8.6
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_member_access_class.expected
*/
// Test for class member access (IEEE 1800-2023 §8)

module test_member_access_class;
  int passed;

  class SimpleClass;
    int value;
    string name;

    function new(int v, string n);
      value = v;
      name = n;
    endfunction

    function int get_value();
      return value;
    endfunction

    function void set_value(int v);
      value = v;
    endfunction

    function string get_name();
      return name;
    endfunction
  endclass

  class NestedClass;
    int x, y;
    SimpleClass inner;

    function new(int a, int b);
      x = a;
      y = b;
      inner = new(100, "inner");
    endfunction

    function int sum();
      return x + y + inner.value;
    endfunction
  endclass

  initial begin
    passed = 0;

    // Test 1: Simple member access
    $display("Test 1: Simple member access");
    begin
      SimpleClass obj;
      obj = new(42, "test");
      if (obj.value == 42) begin
        $display("  PASS: obj.value = %0d", obj.value);
        passed++;
      end else begin
        $display("  FAIL: obj.value = %0d", obj.value);
      end
    end

    // Test 2: Member function call
    $display("Test 2: Member function call");
    begin
      SimpleClass obj;
      obj = new(100, "func_test");
      if (obj.get_value() == 100) begin
        $display("  PASS: obj.get_value() = %0d", obj.get_value());
        passed++;
      end else begin
        $display("  FAIL: obj.get_value() = %0d", obj.get_value());
      end
    end

    // Test 3: Member assignment
    $display("Test 3: Member assignment");
    begin
      SimpleClass obj;
      obj = new(0, "assign_test");
      obj.value = 999;
      if (obj.value == 999) begin
        $display("  PASS: assigned value = %0d", obj.value);
        passed++;
      end else begin
        $display("  FAIL: assigned value = %0d", obj.value);
      end
    end

    // Test 4: String member
    $display("Test 4: String member");
    begin
      SimpleClass obj;
      obj = new(1, "hello");
      if (obj.name == "hello") begin
        $display("  PASS: obj.name = %s", obj.name);
        passed++;
      end else begin
        $display("  FAIL: obj.name = %s", obj.name);
      end
    end

    // Test 5: Nested class access
    $display("Test 5: Nested class access");
    begin
      NestedClass obj;
      obj = new(10, 20);
      if (obj.inner.value == 100) begin
        $display("  PASS: obj.inner.value = %0d", obj.inner.value);
        passed++;
      end else begin
        $display("  FAIL: obj.inner.value = %0d", obj.inner.value);
      end
    end

    // Test 6: Nested function call
    $display("Test 6: Nested function call");
    begin
      NestedClass obj;
      obj = new(10, 20);
      if (obj.sum() == 130) begin
        $display("  PASS: obj.sum() = %0d", obj.sum());
        passed++;
      end else begin
        $display("  FAIL: obj.sum() = %0d", obj.sum());
      end
    end

    if (passed == 6) begin
      $display("TEST PASSED: %0d/6 tests passed", passed);
    end else begin
      $display("TEST FAILED: Only %0d/6 tests passed", passed);
    end
    $finish;
  end
endmodule
