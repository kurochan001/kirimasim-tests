/*
:name: test_vpi_routines_object_properties
:description: the routines of Table 36-4 do what it lists: vpi_get gives integer and Boolean properties, vpi_get64 gives the 64-bit property vpiObjId of class variables, and vpi_get_str gives string properties of variables and of a module instance (IEEE 1800-2023 Section 36.11)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.11 38.6 38.7 38.11 37.17 37.10 37.33
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_routines_object_properties.c
:expected_stdout: @test_vpi_routines_object_properties.expected
*/
// IEEE 1800-2023 §36.11, Table 36-4: vpi_get gets the value of integer and
// Boolean properties, vpi_get64 of a 64-bit integer property, and vpi_get_str
// of string properties. §38.6: vpi_get returns a PLI_INT32, 1 or 0 for a
// Boolean property. §38.7: vpi_get64 returns a 64-bit integer property as a
// PLI_INT64; §37.33: vpiObjId is such a property, which for a class variable
// is the identifier of the object it refers to, unique among live objects,
// or 0 when it refers to none. §38.11: vpi_get_str returns a string, in a
// buffer that the next call reuses, so the application copies each one.
// §37.17: vpiSize of a packed variable is its number of
// bits (detail 9), a variable without a packed dimension is a scalar and one
// with a packed dimension a vector (detail 20), and vpiSigned tells whether
// it is signed. §37.10: an instance has the names vpiName, vpiFullName and
// vpiDefName, the name of its module.
// At time 1, after the class objects are made, the application prints these
// properties of the signed 70-bit variable sv, of the bit u, and of the
// instance u1, and compares vpiObjId of the class variables a and b, which
// refer to one object, c, which refers to another, and n, which is null; the
// identifiers themselves are not printed.
// Icarus Verilog 13.0 has no vpiObjId in its sv_vpi_user.h, and its vpi_get64
// stops the run; Verilator 5.052 does not support vpi_get64. Both give the
// other lines.

module test_vpi_routines_object_properties_leaf;
  logic q;

  initial q = 1'b0;
endmodule

module test_vpi_routines_object_properties;
  class item;
    int v;
  endclass

  logic signed [69:0] sv;
  bit u;
  item a, b, c, n;

  test_vpi_routines_object_properties_leaf u1();

  initial begin
    sv = -70'sd5;
    u = 1'b1;
    a = new();
    b = a;
    c = new();
    #2 $display("design: sv=%0d u=%0d", sv, u);
  end
endmodule
