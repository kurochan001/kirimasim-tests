/*
:name: test_vpi_attribute_value_types
:description: An attribute with a value has the type of that value expression, so a negative int reads as vpiIntVal, a real literal as vpiRealVal, and a 4-bit and a quoted string as vpiVectorVal with their own widths, the quoted string also reading back as its characters (IEEE 1800-2023 Section 5.12)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.83 5.12 38.15
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_attribute_value_types.c
:expected_stdout: @test_vpi_attribute_value_types.expected
*/
// IEEE 1800-2023 §5.12: attr_spec ::= attr_name [ = constant_expression ], and
// "the default type of an attribute with no value is bit, with a value of 1.
// Otherwise, the attribute takes the type of the expression" (B007). The
// attribute object gives that value with vpi_get_value() (§37.83).
// §38.15: with vpiObjTypeVal, vpi_get_value() fills in the value in the format
// of the object type and changes the format field: vpiIntVal for an integer,
// vpiRealVal for a real, vpiVectorVal for a vector.
// §5.9 (B031): a string literal used as an operand is an unsigned integer
// constant of one 8-bit ASCII value per character, so "AB" is a 16-bit
// unsigned vector whose value is 16'h4142 and not an integer.
//
// One variable carries four attributes with four value expressions: an
// unsized decimal -3 has the type int, 2.5 the type real, 4'b1010 a 4-bit
// unsigned vector and "AB" a 16-bit unsigned vector. From a start of
// simulation callback the application reads each attribute with
// vpiObjTypeVal and prints the format it gets back with the value, and reads
// the string literal attribute once more with vpiStringVal. A tool that gave
// every attribute the default bit type, or an integral type, would reject this
// design or would report vpiIntVal and a lost fraction or a lost character.
// Neither release produces this output: Icarus Verilog 13.0 cannot build the
// application, as its headers lack vpiAttribute.

module test_vpi_attribute_value_types;
  (* num = -3, frac = 2.5, nib = 4'b1010, text = "AB" *)
  int iv;
endmodule
