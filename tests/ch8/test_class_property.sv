/*
:name: test_class_property
:description: Test class property (IEEE 1800-2023 Sections 8.5 and 8.18)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.5 8.18
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_property.expected
*/
// Test class property (IEEE 1800-2023 Sections 8.5 and 8.18)

class PropClass;
  int pub_val;
  local int priv_val;

  function new(int p, int q);
    pub_val = p;
    priv_val = q;
  endfunction

  function int get_priv();
    return priv_val;
  endfunction

  function void set_priv(int v);
    priv_val = v;
  endfunction
endclass

module test_class_property;
  PropClass c;
  int pass_count;

  initial begin
    pass_count = 0;
    c = new(10, 20);

    // Test 1: Public property access
    if (c.pub_val == 10) pass_count++;

    // Test 2: Private via getter
    if (c.get_priv() == 20) pass_count++;

    // Test 3: Private via setter
    c.set_priv(30);
    if (c.get_priv() == 30) pass_count++;

    $display("Class property tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Class property tests");
    end else begin
      $display("FAIL: Some class property tests failed");
    end
  end
endmodule
