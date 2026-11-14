/*
:name: test_illegal_interface_handle_type_parameter
:description: A type parameter of an interface class cannot be selected through an interface class handle, while the class scope operator reaches it (IEEE 1800-2023 Section 8.26.3)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26.3
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: $bits(sh.T) selects the type parameter T through the interface class handle sh
:expected_stderr_regex: test_illegal_interface_handle_type_parameter\.sv:47:
*/
// IEEE 1800-2023 §8.26.3: the parameters of an interface class are static and
// can be reached with the class scope operator, and reaching them through an
// interface class handle has the restrictions of 8.5, one of which is that a
// data type cannot be accessed through a handle. sh is a slot_if#(byte)
// handle that holds a byte_slot_c object. The module calls get through sh and
// takes $bits of slot_if#(byte)::T, both legal, and then takes $bits of sh.T,
// which selects the type parameter T through the handle. Without the last
// $display the design prints 5 and 8.
// test_illegal_interface_handle_parameter_in_packed_dimension checks the
// other restriction, on constant expressions.
// Icarus Verilog 13.0 does not support interface classes, so its syntax
// error does not count. The 5.054 release of Verilator reports on the
// marked line that T is not a member that the handle can select.

interface class slot_if #(type T = int);
  pure virtual function T get();
endclass

class byte_slot_c implements slot_if #(byte);
  virtual function byte get();
    return 8'd5;
  endfunction
endclass

module test_illegal_interface_handle_type_parameter;
  byte_slot_c b;
  slot_if #(byte) sh;

  initial begin
    b = new;
    sh = b;
    $display("%0d", sh.get());
    $display("%0d", $bits(slot_if#(byte)::T));
    $display("%0d", $bits(sh.T));   // illegal: a type through an interface class handle
  end
endmodule
