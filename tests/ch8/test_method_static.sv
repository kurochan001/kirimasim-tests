/*
:name: test_method_static
:description: Static methods test
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.10 8.9
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_method_static.expected
*/
// Static methods test
module test_method_static;

  class Counter;
    // Instance variable
    int instance_value;

    // Static class variable
    static int total_count = 0;
    static int instance_counter = 0;

    function new(int val = 0);
      instance_value = val;
      instance_counter++;
      total_count = total_count + val;
    endfunction

    // Instance method
    function int get_value();
      return instance_value;
    endfunction

    // Static method - can only access static members
    static function int get_total_count();
      return total_count;
    endfunction

    // Static method to get instance count
    static function int get_instance_count();
      return instance_counter;
    endfunction

    // Static method with parameters
    static function int add(int a, int b);
      return a + b;
    endfunction

    // Static method that modifies static variable
    static function void reset_counters();
      total_count = 0;
      instance_counter = 0;
    endfunction
  endclass

  class MathUtils;
    // Static utility methods
    static function int max(int a, int b);
      return (a > b) ? a : b;
    endfunction

    static function int min(int a, int b);
      return (a < b) ? a : b;
    endfunction

    static function int abs(int a);
      return (a < 0) ? -a : a;
    endfunction

    static function int clamp(int value, int min_val, int max_val);
      if (value < min_val) return min_val;
      if (value > max_val) return max_val;
      return value;
    endfunction
  endclass

  initial begin
    Counter c1, c2, c3;
    int result;
    int pass_count;

    pass_count = 0;

    // Reset any previous state
    Counter::reset_counters();

    // Test 1: Static method tracks instances
    c1 = new(10);
    c2 = new(20);
    c3 = new(30);
    result = Counter::get_instance_count();
    if (result == 3) begin
      $display("Test 1 PASS: get_instance_count() = %0d after creating 3 instances", result);
      pass_count++;
    end else begin
      $display("Test 1 FAIL: instance_count = %0d, expected 3", result);
    end

    // Test 2: Static method accumulates values
    result = Counter::get_total_count();
    if (result == 60) begin
      $display("Test 2 PASS: get_total_count() = %0d (10+20+30)", result);
      pass_count++;
    end else begin
      $display("Test 2 FAIL: total_count = %0d, expected 60", result);
    end

    // Test 3: Static method with parameters
    result = Counter::add(15, 25);
    if (result == 40) begin
      $display("Test 3 PASS: Counter::add(15, 25) = %0d", result);
      pass_count++;
    end else begin
      $display("Test 3 FAIL: result = %0d, expected 40", result);
    end

    // Test 4: Static utility class methods
    result = MathUtils::max(10, 20);
    if (result == 20) begin
      $display("Test 4 PASS: MathUtils::max(10, 20) = %0d", result);
      pass_count++;
    end else begin
      $display("Test 4 FAIL: result = %0d, expected 20", result);
    end

    // Test 5: Static method with logic
    result = MathUtils::clamp(150, 0, 100);
    if (result == 100) begin
      $display("Test 5 PASS: MathUtils::clamp(150, 0, 100) = %0d", result);
      pass_count++;
    end else begin
      $display("Test 5 FAIL: result = %0d, expected 100", result);
    end

    if (pass_count == 5)
      $display("PASS: All static method tests passed");
    else
      $display("FAIL: %0d/5 tests passed", pass_count);

    $finish;
  end

endmodule
