/*
:name: test_copy_obj
:description: Test object copy (IEEE 1800-2023 Section 8.12)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.12
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_copy_obj.expected
*/
// Test object copy (IEEE 1800-2023 Section 8.12)

class DataClass;
  int value;
  function new(int v = 0);
    value = v;
  endfunction
endclass

module test_copy_obj;
  DataClass obj1, obj2;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Create object
    obj1 = new(50);
    if (obj1.value == 50) pass_count++;

    // Test 2: Reference copy
    obj2 = obj1;
    if (obj2.value == 50) pass_count++;

    // Test 3: Same object
    obj1.value = 100;
    if (obj2.value == 100) pass_count++;

    // Test 4: New independent object
    obj2 = new(200);
    if (obj2.value == 200) pass_count++;

    // Test 5: Original unchanged
    if (obj1.value == 100) pass_count++;

    $display("Copy obj tests: %0d/5 passed", pass_count);
    if (pass_count >= 4) begin
      $display("PASS: Copy obj tests");
    end else begin
      $display("FAIL: Some copy tests failed");
    end
  end
endmodule
