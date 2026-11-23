/*
:name: test_rebound_input_handle_is_visible_to_next_call
:description: Rebinding an input handle before a nested call preserves the caller object (IEEE 1800-2023 Section 13.5.1)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5.1 13.5.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_rebound_input_handle_is_visible_to_next_call.expected
:expected_exit: 0
*/
// A copied input handle may be rebound locally. The nested call writes
// through the replacement, while the original object retains its value.

module test_rebound_input_handle_is_visible_to_next_call;
  class item;
    int value;
  endclass
  class endpoint;
    item slots[2];
    function new();
      foreach (slots[i]) slots[i] = new;
    endfunction
    function bit touch(item current, int index);
      current.value = 91;
      return current == slots[index];
    endfunction
    virtual function bit visit(input item value, ref int phase, input item other);
      item original = value;
      int index = phase;
      value = slots[index];
      other = slots[1-index];
      return touch(value, index) && other == slots[1-index] && original != value;
    endfunction
  endclass

  initial begin
    automatic endpoint e = new;
    automatic item a = new, b = new;
    automatic int phase = 0;
    bit ok;
    a.value = 17;
    ok = e.visit(a, phase, b);
    $display("CHECK ok=%0d original=%0d replacement=%0d", ok, a.value, e.slots[0].value);
    $finish;
  end
endmodule
