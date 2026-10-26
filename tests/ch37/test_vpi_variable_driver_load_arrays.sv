/*
:name: test_vpi_variable_driver_load_arrays
:description: Driver and load iteration of an array variable includes the drivers and loads of its elements, of a struct variable includes the forces on the whole variable, a member and a bit-select, and of a variable bit gives the continuous assignment bit as its driver and load (IEEE 1800-2023 Section 37.21)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.21 37.47 10.3.1 10.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_variable_driver_load_arrays.c
:expected_stdout: @test_vpi_variable_driver_load_arrays.expected
*/
// IEEE 1800-2023 §37.21 detail 1: the driver and load iteration of a
// structure, union or class variable includes the driver or load of the whole
// variable, of any bit-select or part-select of it, and of any member nested
// inside it. Detail 2: for a variable array it includes the driver or load of
// any portion of the array to which a handle can be obtained. A continuous
// assignment and a continuous assignment bit are members of both groups
// (§37.21 diagram, §37.47). The test drives the elements of av and reads them,
// forces svw as a whole, svm.x and svb.y[0], and drives the vector v as a
// whole and reads v[2]; the application prints the left-hand side of each
// driver and the right-hand side of each load, and the type and vpiOffset of
// the continuous assignment bits that drive and load v[2].

module test_vpi_variable_driver_load_arrays;
  logic a = 1'b1, b = 1'b0;
  logic av [0:1];
  struct packed { int x; logic [1:0] y; } svw, svm, svb;
  logic [3:0] v;
  wire o0, o1, ov;

  assign av[0] = a;
  assign av[1] = b;
  assign o0 = av[0];
  assign o1 = av[1];
  assign v = {2'b00, a, b};
  assign ov = v[2];

  initial begin
    force svw = 32'h0000000A;
    force svm.x = 32'sd4;
    force svb.y[0] = 1'b1;
    #1 $vt_vl;
    release svw;
    release svm.x;
    release svb.y[0];
  end
endmodule
