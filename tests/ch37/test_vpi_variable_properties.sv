/*
:name: test_vpi_variable_properties
:description: Variables of each kind give their type, size, sign and whether they are scalars or vectors; a variable bit is a scalar of size 1 with its index and its variable as parent; an initialized variable gives its initialization expression (IEEE 1800-2023 Section 37.17)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.17 6.11 6.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_variable_properties.c
:expected_stdout: @test_vpi_variable_properties.expected
*/
// IEEE 1800-2023 §37.17: vpiSize gives the width in bits of a variable of an
// integer data type (detail 9; widths and signs in 6.11); vpiSigned gives its
// sign. A logic or bit variable without a packed dimension is a scalar, with
// one it is a vector, and integer, time, int, shortint, longint and byte
// variables are vectors; for other variables, here real, both vpiScalar and
// vpiVector are false (detail 20). vpiLeftRange and vpiRightRange give the
// bounds of the packed dimension as written (detail 6). The bit rv[3] is a
// scalar of size 1 with index 3 (detail 13) and rv as its vpiParent (detail
// 26). vpiExpr of init gives its initialization expression (detail 8; 6.8).
// The type of a logic variable may be named vpiReg or vpiLogicVar, the same
// constant (detail 19).

module test_vpi_variable_properties;
  logic r;
  logic [7:0] rv;
  logic signed [3:0] rs;
  logic [0:2] la;
  integer i;
  time t;
  int ii;
  shortint si;
  longint li;
  byte by;
  bit b;
  bit [5:0] bv;
  real re;
  logic [7:0] init = 8'h3c;

  initial begin
    r = 1'b1;
    rv = 8'ha5;
    rs = -4'sd2;
    la = 3'b101;
    i = -5;
    t = 64'd7;
    ii = 9;
    si = 16'sd3;
    li = 64'sd4;
    by = 8'sd6;
    b = 1'b1;
    bv = 6'h2a;
    re = 2.5;
    #1 $vt_variables;
  end
endmodule
