/*
:name: test_class_virtual
:description: Test: Virtual class declaration
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.21 8.20
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_virtual.expected
*/
// Test: Virtual class declaration
// IEEE 1800-2023 Section 8.21 - Abstract classes

module test_class_virtual;

  // Virtual (abstract) class - cannot be instantiated directly
  virtual class Animal;
    string name;

    function new(string n);
      name = n;
    endfunction

    // Pure virtual method - must be overridden
    pure virtual function string speak();

    // Virtual method with default implementation
    virtual function string get_info();
      return {"Animal: ", name};
    endfunction
  endclass

  // Concrete class extending virtual class
  class Dog extends Animal;
    function new(string n);
      super.new(n);
    endfunction

    // Must implement pure virtual method
    virtual function string speak();
      return "Woof!";
    endfunction
  endclass

  // Another concrete class
  class Cat extends Animal;
    function new(string n);
      super.new(n);
    endfunction

    virtual function string speak();
      return "Meow!";
    endfunction

    // Override virtual method
    virtual function string get_info();
      return {"Cat: ", name};
    endfunction
  endclass

  // Virtual class with only virtual methods (no pure virtual)
  virtual class Shape;
    virtual function int area();
      return 0;
    endfunction
  endclass

  class Rectangle extends Shape;
    int width, height;

    function new(int w, int h);
      width = w;
      height = h;
    endfunction

    virtual function int area();
      return width * height;
    endfunction
  endclass

  initial begin
    Dog d;
    Cat c;
    Animal a;
    Rectangle r;
    static int pass_count = 0;
    static int fail_count = 0;

    // Test 1: Create concrete class from virtual base
    d = new("Buddy");
    if (d.speak() == "Woof!" && d.name == "Buddy") begin
      $display("PASS: Test 1 - Dog created from virtual Animal");
      pass_count++;
    end else begin
      $display("FAIL: Test 1 - Dog creation failed");
      fail_count++;
    end

    // Test 2: Another concrete class
    c = new("Whiskers");
    if (c.speak() == "Meow!") begin
      $display("PASS: Test 2 - Cat implements speak()");
      pass_count++;
    end else begin
      $display("FAIL: Test 2 - Cat speak() failed");
      fail_count++;
    end

    // Test 3: Polymorphism with virtual class reference
    a = d;
    if (a.speak() == "Woof!") begin
      $display("PASS: Test 3 - Polymorphic call through Animal reference");
      pass_count++;
    end else begin
      $display("FAIL: Test 3 - Polymorphic call failed");
      fail_count++;
    end

    // Test 4: Overridden virtual method
    a = c;
    if (a.get_info() == "Cat: Whiskers") begin
      $display("PASS: Test 4 - Overridden get_info() called");
      pass_count++;
    end else begin
      $display("FAIL: Test 4 - get_info() override failed, got: %s", a.get_info());
      fail_count++;
    end

    // Test 5: Another virtual class hierarchy
    r = new(5, 3);
    if (r.area() == 15) begin
      $display("PASS: Test 5 - Rectangle area from Shape virtual class");
      pass_count++;
    end else begin
      $display("FAIL: Test 5 - Rectangle area failed");
      fail_count++;
    end

    // Summary
    $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
    if (fail_count == 0)
      $display("PASS: All virtual class tests passed");
    else
      $display("FAIL: Some tests failed");

    $finish;
  end

endmodule
