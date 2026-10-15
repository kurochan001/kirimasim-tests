/*
:name: test_class_static_method
:description: Test: Static class methods
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.10 8.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_static_method.expected
*/
// Test: Static class methods
// IEEE 1800-2023 Section 8.10 - Static methods

module test_class_static_method;

  // Class with various static methods
  class MathUtils;
    static int call_count = 0;

    // Static method - no this pointer
    static function int add(int a, int b);
      call_count++;
      return a + b;
    endfunction

    static function int multiply(int a, int b);
      call_count++;
      return a * b;
    endfunction

    static function int max(int a, int b);
      call_count++;
      return (a > b) ? a : b;
    endfunction

    static function int min(int a, int b);
      call_count++;
      return (a < b) ? a : b;
    endfunction

    static function int abs_val(int a);
      call_count++;
      return (a < 0) ? -a : a;
    endfunction

    static function int get_call_count();
      return call_count;
    endfunction
  endclass

  // Item class (must be declared before ItemFactory uses it)
  class Item;
    int value;
    string name;

    function new(int v, string n);
      value = v;
      name = n;
    endfunction
  endclass

  // Factory class with static creation methods
  class ItemFactory;
    static int items_created = 0;

    static function Item create_default();
      Item i = new(0, "default");
      items_created++;
      return i;
    endfunction

    static function Item create_with_value(int v);
      Item i = new(v, "valued");
      items_created++;
      return i;
    endfunction

    static function Item create_named(string name);
      Item i = new(100, name);
      items_created++;
      return i;
    endfunction
  endclass

  // Static method calling other static methods
  class Calculator;
    static function int compute(int a, int b, string op);
      case (op)
        "add": return do_add(a, b);
        "sub": return do_sub(a, b);
        "mul": return do_mul(a, b);
        default: return 0;
      endcase
    endfunction

    static function int do_add(int a, int b);
      return a + b;
    endfunction

    static function int do_sub(int a, int b);
      return a - b;
    endfunction

    static function int do_mul(int a, int b);
      return a * b;
    endfunction
  endclass

  initial begin
    Item i1, i2, i3;
    int result;
    static int pass_count = 0;
    static int fail_count = 0;

    // Test 1: Basic static method calls
    result = MathUtils::add(5, 3);
    if (result == 8) begin
      $display("PASS: Test 1 - Static add() returns correct result");
      pass_count++;
    end else begin
      $display("FAIL: Test 1 - Static add() wrong: %0d", result);
      fail_count++;
    end

    // Test 2: Multiple static method calls
    result = MathUtils::max(MathUtils::abs_val(-10), MathUtils::multiply(2, 4));
    if (result == 10) begin
      $display("PASS: Test 2 - Nested static method calls work");
      pass_count++;
    end else begin
      $display("FAIL: Test 2 - Nested calls wrong: %0d", result);
      fail_count++;
    end

    // Test 3: Static method affects static member
    if (MathUtils::get_call_count() == 4) begin
      $display("PASS: Test 3 - Static method updates static member");
      pass_count++;
    end else begin
      $display("FAIL: Test 3 - Call count wrong: %0d", MathUtils::get_call_count());
      fail_count++;
    end

    // Test 4: Factory pattern with static methods
    i1 = ItemFactory::create_default();
    i2 = ItemFactory::create_with_value(42);
    i3 = ItemFactory::create_named("custom");
    if (i1.value == 0 && i2.value == 42 && i3.name == "custom" &&
        ItemFactory::items_created == 3) begin
      $display("PASS: Test 4 - Factory static methods create objects");
      pass_count++;
    end else begin
      $display("FAIL: Test 4 - Factory pattern failed");
      fail_count++;
    end

    // Test 5: Static method calling other static methods
    if (Calculator::compute(10, 3, "add") == 13 &&
        Calculator::compute(10, 3, "sub") == 7 &&
        Calculator::compute(10, 3, "mul") == 30) begin
      $display("PASS: Test 5 - Static method dispatching to other static methods");
      pass_count++;
    end else begin
      $display("FAIL: Test 5 - Static method dispatch failed");
      fail_count++;
    end

    // Summary
    $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
    if (fail_count == 0)
      $display("PASS: All static method tests passed");
    else
      $display("FAIL: Some tests failed");

    $finish;
  end

endmodule
