/*
:name: test_class_extends
:description: Test class extends (IEEE 1800-2023 Sections 8.13, 8.20 and 8.22)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.13 8.20 8.22
:oracle: spec
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_extends.expected
*/
// Test class extends (IEEE 1800-2023 Sections 8.13, 8.20 and 8.22)

class BaseClass;
  int base_val;
  function new();
    base_val = 10;
  endfunction
  virtual function int get_val();
    return base_val;
  endfunction
endclass

class DerivedClass extends BaseClass;
  int derived_val;
  function new();
    super.new();
    derived_val = 20;
  endfunction
  function int get_val();
    return base_val + derived_val;
  endfunction
endclass

module test_class_extends;
  BaseClass b;
  DerivedClass d;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Base class
    b = new();
    if (b.get_val() == 10) pass_count++;

    // Test 2: Derived class
    d = new();
    if (d.get_val() == 30) pass_count++;

    // Test 3: Polymorphism
    b = d;
    if (b.get_val() == 30) pass_count++;

    $display("Class extends tests: %0d/3 passed", pass_count);
    if (pass_count == 3) begin
      $display("PASS: Class extends tests");
    end else begin
      $display("FAIL: Some class extends tests failed");
    end
  end
endmodule
