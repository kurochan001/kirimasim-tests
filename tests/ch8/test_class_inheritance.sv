/*
:name: test_class_inheritance
:description: Test class inheritance (IEEE 1800-2023 Sections 8.13, 8.20 and 8.22)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.13 8.20 8.22
:oracle: spec
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_inheritance.expected
*/
// Test class inheritance (IEEE 1800-2023 Sections 8.13, 8.20 and 8.22)

class Base;
  int base_val;
  
  function new(int v);
    base_val = v;
  endfunction
  
  virtual function int get_val();
    return base_val;
  endfunction
  
  function void set_val(int v);
    base_val = v;
  endfunction
endclass

class Derived extends Base;
  int derived_val;
  
  function new(int b, int d);
    super.new(b);
    derived_val = d;
  endfunction
  
  virtual function int get_val();
    return base_val + derived_val;
  endfunction
endclass

module test_class_inheritance;
  Base b;
  Derived d;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Base class instantiation
    b = new(10);
    if (b.base_val == 10) pass_count++;

    // Test 2: Base class method
    if (b.get_val() == 10) pass_count++;

    // Test 3: Derived class instantiation
    d = new(20, 5);
    if (d.base_val == 20) pass_count++;
    if (d.derived_val == 5) pass_count++;

    // Test 4: Overridden virtual method
    if (d.get_val() == 25) pass_count++;

    // Test 5: Inherited method
    d.set_val(30);
    if (d.base_val == 30) pass_count++;

    // Test 6: Polymorphism
    b = d;  // Base reference to Derived object
    if (b.get_val() == 35) pass_count++;  // Should call Derived::get_val

    $display("Class inheritance tests: %0d/7 passed", pass_count);
    if (pass_count == 7) begin
      $display("PASS: Class inheritance tests");
    end else begin
      $display("FAIL: Some inheritance tests failed");
    end
  end
endmodule
