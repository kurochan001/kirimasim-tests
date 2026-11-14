/*
:name: test_vpi_attribute_default_bit_and_last_value
:description: An attribute written without a value is a bit with the value 1, while one written with a value takes the type of the value, and when an element has the same attribute name more than once, in one attribute instance or in two, it keeps the last value, also when the last one has no value (IEEE 1800-2023 Section 5.12)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.12 37.83
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_attribute_default_bit_and_last_value.c
:expected_stdout: @test_vpi_attribute_default_bit_and_last_value.expected
*/
// IEEE 1800-2023 §5.12: an attribute with no value has the type bit and the
// value 1; otherwise it takes the type of its value expression. When the
// same attribute name is given more than once for one language element, the
// last value is the one used (a tool may also warn, which the test does not
// look at). §37.83: the attributes of a variable are iterated with
// vpiAttribute; each has vpiName and a value read with vpi_get_value().
// §38.15: with vpiObjTypeVal the value comes back in the format of its type,
// vpiScalarVal (or vpiStrengthVal) for a scalar such as a bit and vpiIntVal
// for an integer such as the unsized constant 6.
// From a start-of-simulation callback the application prints, for each
// variable below, every attribute it finds, as "scalar" or "integer" with
// the value, and how many it found:
//   v_flag   (* flag *)                  flag is the bit 1
//   v_one    (* flag = 1 *)              flag is the integer 1
//   v_same   (* dup = 3, dup = 5 *)      one dup, the integer 5
//   v_two    (* dup = 4 *) (* dup = 7 *) one dup, the integer 7
//   v_to_bit (* sw = 6, sw *)            one sw, the bit 1
//   v_to_int (* sw, sw = 6 *)            one sw, the integer 6
// A tool that kept the first value would print 3, 4, 6 and the bit 1 for the
// last four; one that gave a valueless attribute the type of an integer
// would print "integer 1" for v_flag and v_to_bit.
// Neither release produces this output: Icarus Verilog 13.0 cannot build the
// application, as its headers lack vpiAttribute, and with the 5.054 release
// of Verilator the variables have no attributes.

module test_vpi_attribute_default_bit_and_last_value;
  (* flag *) int v_flag;
  (* flag = 1 *) int v_one;
  (* dup = 3, dup = 5 *) int v_same;
  (* dup = 4 *) (* dup = 7 *) int v_two;
  (* sw = 6, sw *) int v_to_bit;
  (* sw, sw = 6 *) int v_to_int;
endmodule
