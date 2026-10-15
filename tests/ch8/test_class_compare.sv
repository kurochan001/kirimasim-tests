/*
:name: test_class_compare
:description: Test: Class comparison
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4 8.5 8.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_compare.expected
*/
// Test: Class comparison
// IEEE 1800-2023 - Object comparison methods

module test_class_compare;

  // Simple comparable class
  class Value;
    int data;

    function new(int d);
      data = d;
    endfunction

    // Value equality
    function bit equals(Value other);
      if (other == null) return 0;
      return (data == other.data);
    endfunction

    // Comparison for ordering
    function int compare(Value other);
      if (other == null) return 1;
      if (data < other.data) return -1;
      if (data > other.data) return 1;
      return 0;
    endfunction
  endclass

  // Class with multiple fields
  class Person;
    string name;
    int age;
    string city;

    function new(string n, int a, string c);
      name = n;
      age = a;
      city = c;
    endfunction

    // Full equality
    function bit equals(Person other);
      if (other == null) return 0;
      return (name == other.name && age == other.age && city == other.city);
    endfunction

    // Partial equality - just name and age
    function bit similar(Person other);
      if (other == null) return 0;
      return (name == other.name && age == other.age);
    endfunction

    // Compare by age
    function int compare_by_age(Person other);
      if (other == null) return 1;
      return age - other.age;
    endfunction

    // Compare by name (lexicographic)
    function int compare_by_name(Person other);
      if (other == null) return 1;
      if (name < other.name) return -1;
      if (name > other.name) return 1;
      return 0;
    endfunction
  endclass

  // Class with nested objects
  class Order;
    int order_id;
    Person customer;
    int total;

    function new(int id, Person c, int t);
      order_id = id;
      customer = c;
      total = t;
    endfunction

    // Reference equality - same object
    function bit is_same(Order other);
      return (this == other);
    endfunction

    // Value equality - same content
    function bit equals(Order other);
      if (other == null) return 0;
      if (order_id != other.order_id) return 0;
      if (total != other.total) return 0;
      if (customer == null && other.customer == null) return 1;
      if (customer == null || other.customer == null) return 0;
      return customer.equals(other.customer);
    endfunction
  endclass

  // Comparable with null handling
  class SafeValue;
    int value;
    bit valid;

    function new(int v, bit is_valid = 1);
      value = v;
      valid = is_valid;
    endfunction

    function bit equals(SafeValue other);
      if (other == null) return 0;
      if (!valid && !other.valid) return 1;  // Both invalid are equal
      if (!valid || !other.valid) return 0;  // One invalid
      return (value == other.value);
    endfunction

    function int compare(SafeValue other);
      if (other == null) return 1;
      if (!valid && !other.valid) return 0;
      if (!valid) return -1;  // Invalid is less than valid
      if (!other.valid) return 1;
      return value - other.value;
    endfunction
  endclass

  initial begin
    Value v1, v2, v3;
    Person p1, p2, p3;
    Order o1, o2, o3;
    SafeValue sv1, sv2, sv3;
    static int pass_count = 0;
    static int fail_count = 0;

    // Test 1: Simple value equality
    v1 = new(42);
    v2 = new(42);
    v3 = new(100);
    if (v1.equals(v2) && !v1.equals(v3)) begin
      $display("PASS: Test 1 - Value equality works");
      pass_count++;
    end else begin
      $display("FAIL: Test 1 - Value equality failed");
      fail_count++;
    end

    // Test 2: Value comparison
    if (v1.compare(v3) < 0 && v3.compare(v1) > 0 && v1.compare(v2) == 0) begin
      $display("PASS: Test 2 - Value comparison ordering works");
      pass_count++;
    end else begin
      $display("FAIL: Test 2 - Value comparison failed");
      fail_count++;
    end

    // Test 3: Multi-field comparison
    p1 = new("Alice", 30, "NYC");
    p2 = new("Alice", 30, "NYC");
    p3 = new("Alice", 30, "LA");
    if (p1.equals(p2) && !p1.equals(p3) && p1.similar(p3)) begin
      $display("PASS: Test 3 - Multi-field and partial equality work");
      pass_count++;
    end else begin
      $display("FAIL: Test 3 - Multi-field comparison failed");
      fail_count++;
    end

    // Test 4: Nested object comparison
    o1 = new(1, p1, 100);
    o2 = new(1, p2, 100);  // Same values, different objects
    o3 = o1;               // Same reference
    if (!o1.is_same(o2) && o1.is_same(o3) && o1.equals(o2)) begin
      $display("PASS: Test 4 - Reference vs value equality");
      pass_count++;
    end else begin
      $display("FAIL: Test 4 - Nested comparison failed");
      fail_count++;
    end

    // Test 5: Comparison with validity flag
    sv1 = new(10, 1);
    sv2 = new(10, 1);
    sv3 = new(0, 0);  // Invalid
    if (sv1.equals(sv2) && !sv1.equals(sv3) && sv1.compare(sv3) > 0) begin
      $display("PASS: Test 5 - Validity-aware comparison");
      pass_count++;
    end else begin
      $display("FAIL: Test 5 - Validity comparison failed");
      fail_count++;
    end

    // Summary
    $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
    if (fail_count == 0)
      $display("PASS: All class comparison tests passed");
    else
      $display("FAIL: Some tests failed");

    $finish;
  end

endmodule
