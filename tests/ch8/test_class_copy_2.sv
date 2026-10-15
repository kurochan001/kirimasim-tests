/*
:name: test_class_copy_2
:description: Test: Class copy method
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.12 8.7
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_copy_2.expected
*/
// Test: Class copy method
// IEEE 1800-2023 Section 8.12 - Copying objects

module test_class_copy_2;

  // Simple class with copy method
  class Point;
    int x, y;

    function new(int x_val = 0, int y_val = 0);
      x = x_val;
      y = y_val;
    endfunction

    function Point copy();
      Point p = new(x, y);
      return p;
    endfunction

    function bit equals(Point other);
      return (x == other.x && y == other.y);
    endfunction
  endclass

  // Class with nested object - shallow vs deep copy
  class Rectangle;
    Point top_left;
    Point bottom_right;
    string name;

    function new(string n, int x1, int y1, int x2, int y2);
      name = n;
      top_left = new(x1, y1);
      bottom_right = new(x2, y2);
    endfunction

    // Shallow copy - nested objects shared
    function Rectangle shallow_copy();
      Rectangle r = new(name, 0, 0, 0, 0);
      r.top_left = top_left;        // Share reference
      r.bottom_right = bottom_right; // Share reference
      return r;
    endfunction

    // Deep copy - nested objects copied
    function Rectangle deep_copy();
      Rectangle r = new(name, 0, 0, 0, 0);
      r.top_left = top_left.copy();        // Copy nested object
      r.bottom_right = bottom_right.copy(); // Copy nested object
      return r;
    endfunction

    function int width();
      return bottom_right.x - top_left.x;
    endfunction

    function int height();
      return bottom_right.y - top_left.y;
    endfunction
  endclass

  // Class with array - copy considerations
  class DataHolder;
    int values[$];
    string label;

    function new(string l);
      label = l;
    endfunction

    function void add(int v);
      values.push_back(v);
    endfunction

    // Shallow copy - queue shared
    function DataHolder shallow_copy();
      DataHolder d = new(label);
      d.values = values;
      return d;
    endfunction

    // Deep copy - queue copied
    function DataHolder deep_copy();
      DataHolder d = new(label);
      foreach (values[i])
        d.values.push_back(values[i]);
      return d;
    endfunction

    function int sum();
      int s = 0;
      foreach (values[i]) s += values[i];
      return s;
    endfunction
  endclass

  // Class hierarchy with virtual copy
  class Animal;
    string name;
    int age;

    function new(string n, int a);
      name = n;
      age = a;
    endfunction

    virtual function Animal copy();
      Animal a = new(name, age);
      return a;
    endfunction
  endclass

  class Dog extends Animal;
    string breed;

    function new(string n, int a, string b);
      super.new(n, a);
      breed = b;
    endfunction

    virtual function Animal copy();
      Dog d = new(name, age, breed);
      return d;
    endfunction
  endclass

  initial begin
    Point p1, p2;
    Rectangle r1, r2, r3;
    DataHolder d1, d2, d3;
    Animal a1, a2;
    Dog dog1;
    static int pass_count = 0;
    static int fail_count = 0;

    // Test 1: Simple object copy
    p1 = new(10, 20);
    p2 = p1.copy();
    p2.x = 100;  // Modify copy
    if (p1.x == 10 && p2.x == 100) begin
      $display("PASS: Test 1 - Simple copy creates independent object");
      pass_count++;
    end else begin
      $display("FAIL: Test 1 - Copy not independent");
      fail_count++;
    end

    // Test 2: Shallow copy shares nested objects
    r1 = new("rect1", 0, 0, 10, 10);
    r2 = r1.shallow_copy();
    r2.top_left.x = 5;  // Modify shared nested object
    if (r1.top_left.x == 5) begin  // Original affected
      $display("PASS: Test 2 - Shallow copy shares nested objects");
      pass_count++;
    end else begin
      $display("FAIL: Test 2 - Shallow copy didn't share nested");
      fail_count++;
    end

    // Test 3: Deep copy creates independent nested objects
    r1 = new("rect2", 0, 0, 10, 10);
    r3 = r1.deep_copy();
    r3.top_left.x = 5;  // Modify copy's nested object
    if (r1.top_left.x == 0 && r3.top_left.x == 5) begin  // Original unaffected
      $display("PASS: Test 3 - Deep copy creates independent nested objects");
      pass_count++;
    end else begin
      $display("FAIL: Test 3 - Deep copy didn't create independent nested");
      fail_count++;
    end

    // Test 4: Deep copy of queue
    d1 = new("data1");
    d1.add(10);
    d1.add(20);
    d1.add(30);
    d3 = d1.deep_copy();
    d3.add(40);
    if (d1.sum() == 60 && d3.sum() == 100) begin
      $display("PASS: Test 4 - Deep copy of queue creates independent copy");
      pass_count++;
    end else begin
      $display("FAIL: Test 4 - Queue copy not independent: d1=%0d, d3=%0d", d1.sum(), d3.sum());
      fail_count++;
    end

    // Test 5: Virtual copy in class hierarchy
    dog1 = new("Rex", 5, "Labrador");
    a1 = dog1;
    a2 = a1.copy();  // Should create Dog, not Animal
    if ($cast(dog1, a2) && dog1.breed == "Labrador") begin
      $display("PASS: Test 5 - Virtual copy preserves derived type");
      pass_count++;
    end else begin
      $display("FAIL: Test 5 - Virtual copy lost derived type");
      fail_count++;
    end

    // Summary
    $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
    if (fail_count == 0)
      $display("PASS: All class copy tests passed");
    else
      $display("FAIL: Some tests failed");

    $finish;
  end

endmodule
