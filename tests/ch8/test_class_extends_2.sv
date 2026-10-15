/*
:name: test_class_extends_2
:description: Test: Class inheritance extends
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.13 8.14 8.20 8.22
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_extends_2.expected
*/
// Test: Class inheritance extends
// IEEE 1800-2023 Section 8.13 - Inheritance

module test_class_extends_2;

  // Base class
  class Vehicle;
    string brand;
    int year;
    int speed;

    function new(string b, int y);
      brand = b;
      year = y;
      speed = 0;
    endfunction

    virtual function void accelerate(int amount);
      speed += amount;
    endfunction

    virtual function string get_type();
      return "Vehicle";
    endfunction

    function string info();
      return $sformatf("%s %s (%0d) - %0d mph", get_type(), brand, year, speed);
    endfunction
  endclass

  // Single inheritance
  class Car extends Vehicle;
    int num_doors;

    function new(string b, int y, int doors);
      super.new(b, y);
      num_doors = doors;
    endfunction

    virtual function string get_type();
      return "Car";
    endfunction
  endclass

  // Multi-level inheritance
  class SportsCar extends Car;
    int horsepower;

    function new(string b, int y, int hp);
      super.new(b, y, 2);  // Sports cars have 2 doors
      horsepower = hp;
    endfunction

    virtual function void accelerate(int amount);
      // Sports cars accelerate faster
      speed += amount * 2;
    endfunction

    virtual function string get_type();
      return "SportsCar";
    endfunction
  endclass

  // Another branch of inheritance
  class Truck extends Vehicle;
    int payload_capacity;

    function new(string b, int y, int capacity);
      super.new(b, y);
      payload_capacity = capacity;
    endfunction

    virtual function void accelerate(int amount);
      // Trucks accelerate slower
      speed += amount / 2;
    endfunction

    virtual function string get_type();
      return "Truck";
    endfunction
  endclass

  // Deep inheritance chain
  class ElectricCar extends Car;
    int battery_range;

    function new(string b, int y, int range);
      super.new(b, y, 4);
      battery_range = range;
    endfunction

    virtual function string get_type();
      return "ElectricCar";
    endfunction
  endclass

  initial begin
    Vehicle v;
    Car c;
    SportsCar sc;
    Truck t;
    ElectricCar ec;
    static int pass_count = 0;
    static int fail_count = 0;

    // Test 1: Basic inheritance
    c = new("Toyota", 2020, 4);
    if (c.brand == "Toyota" && c.num_doors == 4 && c.get_type() == "Car") begin
      $display("PASS: Test 1 - Basic inheritance works");
      pass_count++;
    end else begin
      $display("FAIL: Test 1 - Basic inheritance failed");
      fail_count++;
    end

    // Test 2: Multi-level inheritance
    sc = new("Ferrari", 2023, 600);
    if (sc.brand == "Ferrari" && sc.num_doors == 2 && sc.horsepower == 600) begin
      $display("PASS: Test 2 - Multi-level inheritance works");
      pass_count++;
    end else begin
      $display("FAIL: Test 2 - Multi-level inheritance failed");
      fail_count++;
    end

    // Test 3: Method override with different behavior
    sc.accelerate(10);
    c.accelerate(10);
    if (sc.speed == 20 && c.speed == 10) begin
      $display("PASS: Test 3 - Overridden methods have different behavior");
      pass_count++;
    end else begin
      $display("FAIL: Test 3 - Override behavior wrong: sc=%0d, c=%0d", sc.speed, c.speed);
      fail_count++;
    end

    // Test 4: Polymorphism - base reference to derived object
    v = sc;
    v.accelerate(10);
    if (v.speed == 40 && v.get_type() == "SportsCar") begin
      $display("PASS: Test 4 - Polymorphic method call works");
      pass_count++;
    end else begin
      $display("FAIL: Test 4 - Polymorphic call failed: speed=%0d, type=%s", v.speed, v.get_type());
      fail_count++;
    end

    // Test 5: Another inheritance branch
    t = new("Ford", 2019, 2000);
    t.accelerate(10);
    if (t.speed == 5 && t.payload_capacity == 2000) begin
      $display("PASS: Test 5 - Parallel inheritance branch works");
      pass_count++;
    end else begin
      $display("FAIL: Test 5 - Truck inheritance failed");
      fail_count++;
    end

    // Summary
    $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
    if (fail_count == 0)
      $display("PASS: All class extends tests passed");
    else
      $display("FAIL: Some tests failed");

    $finish;
  end

endmodule
