/*
:name: test_class_static_members
:description: Static class properties test
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.9 8.10
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_static_members.expected
*/
// IEEE 1800-2023 Section 8.9: Static class properties test
// Tests static member variables shared across all instances

module test_static_members;

  // Test class with static members
  class Counter;
    // IEEE 1800-2023 §8.9: Static member - shared across all instances
    static int count = 0;

    // Instance member - unique per instance
    int instance_id;

    function new();
      instance_id = count;
      count++;  // Increment static counter
    endfunction

    static function int get_count();
      return count;
    endfunction

    static function void reset_count();
      count = 0;
    endfunction
  endclass

  // Test class with multiple static members
  class Config;
    static string prefix = "DEFAULT";
    static int max_value = 100;
    static bit initialized = 0;

    string name;

    function new(string n);
      name = n;
      if (!initialized) begin
        prefix = "INIT";
        initialized = 1;
      end
    endfunction
  endclass

  initial begin
    Counter c1, c2, c3;
    Config cfg1, cfg2;
    static int pass_count = 0;
    static int fail_count = 0;

    // Test 1: Static counter increments with each new instance
    c1 = new();
    if (c1.instance_id == 0) begin
      $display("TEST 1 PASS: First instance has id 0");
      pass_count++;
    end else begin
      $display("TEST 1 FAIL: Expected id 0, got %0d", c1.instance_id);
      fail_count++;
    end

    c2 = new();
    if (c2.instance_id == 1) begin
      $display("TEST 2 PASS: Second instance has id 1");
      pass_count++;
    end else begin
      $display("TEST 2 FAIL: Expected id 1, got %0d", c2.instance_id);
      fail_count++;
    end

    c3 = new();
    if (c3.instance_id == 2) begin
      $display("TEST 3 PASS: Third instance has id 2");
      pass_count++;
    end else begin
      $display("TEST 3 FAIL: Expected id 2, got %0d", c3.instance_id);
      fail_count++;
    end

    // Test 4: Static member accessible via any instance
    if (c1.count == 3 && c2.count == 3 && c3.count == 3) begin
      $display("TEST 4 PASS: Static count accessible via all instances (count=3)");
      pass_count++;
    end else begin
      $display("TEST 4 FAIL: c1.count=%0d, c2.count=%0d, c3.count=%0d", c1.count, c2.count, c3.count);
      fail_count++;
    end

    // Test 5: Modification through one instance affects all
    c1.count = 10;
    if (c2.count == 10 && c3.count == 10) begin
      $display("TEST 5 PASS: Static member modification shared across instances");
      pass_count++;
    end else begin
      $display("TEST 5 FAIL: c2.count=%0d, c3.count=%0d after c1.count=10", c2.count, c3.count);
      fail_count++;
    end

    // Test 6: Static member access through instance after modification
    if (c1.count == 10) begin
      $display("TEST 6 PASS: Static member value persists (count=10)");
      pass_count++;
    end else begin
      $display("TEST 6 FAIL: Expected count=10, got %0d", c1.count);
      fail_count++;
    end

    // Test 7: Multiple static members in Config class
    cfg1 = new("config1");
    // Access static members through instance (cfg1.initialized)
    // instead of direct class access (Config::initialized)
    if (cfg1.prefix == "INIT" && cfg1.initialized == 1) begin
      $display("TEST 7 PASS: Config static members initialized correctly");
      pass_count++;
    end else begin
      $display("TEST 7 FAIL: prefix=%s, initialized=%0d", cfg1.prefix, cfg1.initialized);
      fail_count++;
    end

    cfg2 = new("config2");
    // Second instance should see initialized already set
    if (cfg2.prefix == "INIT") begin
      $display("TEST 8 PASS: Second Config instance sees shared static state");
      pass_count++;
    end else begin
      $display("TEST 8 FAIL: prefix=%s", cfg2.prefix);
      fail_count++;
    end

    // Summary
    $display("========================================");
    $display("Static Members Test Summary:");
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
