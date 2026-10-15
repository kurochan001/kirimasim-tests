/*
:name: test_cast_class
:description: Test class casting (IEEE 1800-2023 Section 8.16)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.16 6.24.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_class.expected
*/
// Test class casting (IEEE 1800-2023 Section 8.16)

class Animal;
  string name;
  function new(string n = "");
    name = n;
  endfunction
endclass

class Dog extends Animal;
  function new(string n = "");
    super.new(n);
  endfunction

  function string bark();
    return "Woof";
  endfunction
endclass

module test_cast_class;
  Animal a;
  Dog d;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Create Dog
    d = new("Rex");
    if (d.name == "Rex") pass_count++;

    // Test 2: Upcast to Animal
    a = d;
    if (a.name == "Rex") pass_count++;

    // Test 3: Downcast back
    if ($cast(d, a)) pass_count++;

    // Test 4: Dog method
    if (d.bark() == "Woof") pass_count++;

    // Test 5: Check cast result
    if (d != null && d.name == "Rex") pass_count++;

    $display("Cast class tests: %0d/5 passed", pass_count);
    if (pass_count == 5) begin
      $display("PASS: Cast class tests");
    end else begin
      $display("FAIL: Some cast tests failed");
    end
  end
endmodule
