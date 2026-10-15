/*
:name: test_class_scope_access
:description: Static class properties test
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.9 8.10 8.23
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_scope_access.expected
*/
// IEEE 1800-2023 Section 8.9: Static class properties test
// Tests ClassName::static_member direct access syntax

module test_class_scope_access;

  class Counter;
    static int count = 0;
    int instance_id;

    function new();
      instance_id = count;
      count++;
    endfunction

    static function int get_count();
      return count;
    endfunction

    static function void reset();
      count = 0;
    endfunction
  endclass

  initial begin
    Counter c1, c2;
    static int pass_count = 0;
    static int fail_count = 0;

    // Test 1: Direct class scope access to read static member
    // Note: Counter::count should access the static member directly
    if (Counter::count == 0) begin
      $display("TEST 1 PASS: Counter::count read before any instance (0)");
      pass_count++;
    end else begin
      $display("TEST 1 FAIL: Expected Counter::count=0, got %0d", Counter::count);
      fail_count++;
    end

    // Test 2: Create instance and check Counter::count via class scope
    c1 = new();
    if (Counter::count == 1) begin
      $display("TEST 2 PASS: Counter::count=1 after first instance");
      pass_count++;
    end else begin
      $display("TEST 2 FAIL: Expected Counter::count=1, got %0d", Counter::count);
      fail_count++;
    end

    // Test 3: Modify via class scope
    Counter::count = 100;
    if (c1.count == 100) begin
      $display("TEST 3 PASS: c1.count sees Counter::count modification (100)");
      pass_count++;
    end else begin
      $display("TEST 3 FAIL: Expected c1.count=100, got %0d", c1.count);
      fail_count++;
    end

    // Test 4: Static function call via class scope
    Counter::reset();
    if (Counter::count == 0) begin
      $display("TEST 4 PASS: Counter::reset() worked, count=0");
      pass_count++;
    end else begin
      $display("TEST 4 FAIL: Expected Counter::count=0 after reset, got %0d", Counter::count);
      fail_count++;
    end

    // Test 5: Static function return value
    c2 = new();
    c2 = new();  // Create two more instances
    if (Counter::get_count() == 2) begin
      $display("TEST 5 PASS: Counter::get_count()=2");
      pass_count++;
    end else begin
      $display("TEST 5 FAIL: Expected Counter::get_count()=2, got %0d", Counter::get_count());
      fail_count++;
    end

    // Summary
    $display("========================================");
    $display("Class Scope Access Test Summary:");
    $display("  PASS: %0d", pass_count);
    $display("  FAIL: %0d", fail_count);
    $display("========================================");

    if (fail_count == 0) begin
      $display("All tests PASSED!");
    end else begin
      $display("Some tests FAILED!");
    end

    $finish;
  end

endmodule
