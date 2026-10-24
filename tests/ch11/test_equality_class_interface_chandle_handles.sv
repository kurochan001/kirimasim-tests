/*
:name: test_equality_class_interface_chandle_handles
:description: == != === !== compare the values of class, interface class and chandle handles and null when one operand can be assigned to the other, and ==? !=? behave as == != for them (IEEE 1800-2023 Section 11.4.5)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.5 11.4.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_equality_class_interface_chandle_handles.c
:expected_stdout: @test_equality_class_interface_chandle_handles.expected
*/
// IEEE 1800-2023 §11.4.5: logical and case equality are legal when an
// operand is a class handle or null and one operand can be assigned to the
// other, and when an operand is a chandle or null; they compare the handle
// values, so two handles are equal when they refer to the same object, or
// hold the same pointer, or are both null. §11.4.6: for such operands, ==?
// and !=? are the same as == and !=.
// b1 and b2 refer to two objects of base_c, bd is a base_c handle to the
// object of the der_c handle d1 (a der_c handle can be assigned to base_c),
// bn is null. i1 and i2 are interface class handles to the object of s1, i3
// to another object; s1 is a class handle that can be assigned to them. The
// C function vt_cell_ptr returns the address of one of two cells, so c1 and
// c3 hold the same pointer, c2 another one, and cn is null. Every line
// compares an equal pair, a different pair and a pair with null.
// Icarus Verilog 13.0 does not parse interface classes. Verilator 5.052 gives
// 0 for !=? of handles to different objects or pointers (i1 !=? i3, c1 !=? c2).

interface class shape_ic;
  pure virtual function int id();
endclass

class sq_c implements shape_ic;
  int n;
  function new(int i); n = i; endfunction
  virtual function int id(); return n; endfunction
endclass

class base_c;
endclass

class der_c extends base_c;
endclass

module test_equality_class_interface_chandle_handles;
  import "DPI-C" function chandle vt_cell_ptr(input int which);

  base_c b1 = new, b2 = new, bd, bn;
  der_c d1 = new;
  sq_c s1 = new(1), s2 = new(2);
  shape_ic i1, i2, i3, in;
  chandle c1, c2, c3, cn;

  initial begin
    bd = d1;
    i1 = s1;
    i2 = s1;
    i3 = s2;
    c1 = vt_cell_ptr(0);
    c2 = vt_cell_ptr(1);
    c3 = vt_cell_ptr(0);
    $display("class ==: %b %b %b %b %b", b1 == b1, b1 == b2, bd == d1, bn == null, b1 == null);
    $display("class != === !==: %b %b %b %b", b1 != b2, null != b1, b1 === b1, b1 !== b2);
    $display("interface class: %b %b %b %b %b", i1 == i2, i1 == i3, s1 == i1, i1 != null,
             in === null);
    $display("chandle: %b %b %b %b %b %b", c1 == c3, c1 == c2, c1 != null, cn == null,
             c1 === c3, c1 !== c2);
    $display("wildcard: %b %b %b %b %b %b %b", b1 ==? b1, b1 ==? b2, bd ==? d1, bn ==? null,
             i1 !=? i3, c1 ==? c3, c1 !=? c2);
  end
endmodule
