/*
:name: test_randomize_inherited_property_in_parameterized_subclass
:description: A derived method can name its inherited random property in randomize (IEEE 1800-2023 Section 18.11)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.11 8.13 18.4.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randomize_inherited_property_in_parameterized_subclass.expected
:expected_exit: 0
*/
// selected is an inherited random property. The call must succeed and choose
// a member of the allowed set, starting from a disallowed value. Eight bits
// is within the minimum supported randc width.

module test_randomize_inherited_property_in_parameterized_subclass;
  class base #(int WIDTH = 8);
    randc bit [WIDTH-1:0] selected;
  endclass
  class derived extends base #(8);
    constraint allowed { selected inside {0, 2}; }
    function bit draw();
      return randomize(selected);
    endfunction
  endclass

  initial begin
    automatic derived d = new;
    bit ok;
    d.selected = 1;
    ok = d.draw();
    $display("CHECK success=%0d allowed=%0d", ok, d.selected inside {0, 2});
    $finish;
  end
endmodule
