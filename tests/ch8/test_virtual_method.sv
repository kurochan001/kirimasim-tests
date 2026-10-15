/*
:name: test_virtual_method
:description: Test virtual method (IEEE 1800-2023 Section 8.20)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.20
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_virtual_method.expected
*/
// Test virtual method (IEEE 1800-2023 Section 8.20)

class Animal;
  virtual function string speak();
    return "...";
  endfunction
endclass

class Dog extends Animal;
  function string speak();
    return "Woof";
  endfunction
endclass

class Cat extends Animal;
  function string speak();
    return "Meow";
  endfunction
endclass

module test_virtual_method;
  Animal a;
  Dog d;
  Cat c;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Dog virtual call
    d = new();
    a = d;
    if (a.speak() == "Woof") pass_count++;

    // Test 2: Cat virtual call
    c = new();
    a = c;
    if (a.speak() == "Meow") pass_count++;

    // Test 3: Base default
    a = new();
    if (a.speak() == "...") pass_count++;

    $display("Virtual method tests: %0d/3 passed", pass_count);
    if (pass_count == 3) begin
      $display("PASS: Virtual method tests");
    end else begin
      $display("FAIL: Some virtual method tests failed");
    end
  end
endmodule
