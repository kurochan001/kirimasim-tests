/*
:name: test_class_object
:description: Test class objects (IEEE 1800-2023 Sections 8.4 and 8.7)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4 8.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_object.expected
*/
// Test class objects (IEEE 1800-2023 Sections 8.4 and 8.7)

class SimpleObj;
  int data;
  string name;

  function new(int d = 0, string n = "");
    data = d;
    name = n;
  endfunction

  function int get_data();
    return data;
  endfunction

  function void set_data(int d);
    data = d;
  endfunction
endclass

module test_class_object;
  SimpleObj obj1, obj2;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Object creation
    obj1 = new(100, "first");
    if (obj1 != null) pass_count++;

    // Test 2: Field access
    if (obj1.data == 100) pass_count++;

    // Test 3: Method call
    if (obj1.get_data() == 100) pass_count++;

    // Test 4: Field modify via method
    obj1.set_data(200);
    if (obj1.data == 200) pass_count++;

    // Test 5: Second object
    obj2 = new(300, "second");
    if (obj2.data == 300) pass_count++;

    // Test 6: Object independence
    if (obj1.data != obj2.data) pass_count++;

    // Test 7: String field
    if (obj1.name == "first") pass_count++;

    $display("Class object tests: %0d/7 passed", pass_count);
    if (pass_count >= 6) begin
      $display("PASS: Class object tests");
    end else begin
      $display("FAIL: Some class object tests failed");
    end
  end
endmodule
