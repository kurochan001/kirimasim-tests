/*
:name: test_vpi_select_objects_event_arrays
:description: A var select of a two-dimensional array iterates its indices from its own outward and is a constant select, unlike a constant select of a dynamic array; bit-selects have an integer var, a parameter or a var select as parent and are constant selects only when their parent is; vpiUse of a vector and of a bit-select gives the uses the standard lists; a two-dimensional named event array gives its ranges and elements with their indices (IEEE 1800-2023 Sections 37.19, 37.58 and 37.27)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.19 37.58 37.27 37.17 37.22 7.4.2 15.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_select_objects_event_arrays.c
:expected_stdout: @test_vpi_select_objects_event_arrays.expected
*/
// IEEE 1800-2023 §37.19: the argument m2[1][2], an element selected from
// an array var, is a var select (37.17 detail 7) with m2 as vpiParent,
// vpiSize the bits of an element (37.17 detail 10), and vpi_iterate(vpiIndex)
// giving 2 then 1, from its own index outward (37.17 detail 5);
// vpiConstantSelect is TRUE for it, its parent being a static variable
// without parent (37.17 detail 27), but FALSE for dyn[1], whose parent, a
// dynamic array, has no static bounds (detail 1). §37.58: a bit-select has
// vpiIndex and as vpiParent an integer var (iv[3]), a parameter (P[2]) or a
// var select (mv[k][1][5]); its vpiConstantSelect is TRUE only if its index
// is constant and the property holds for its parent (detail 3), so FALSE for
// mv[k][1][5], where k is a variable. vpiUse of the vector u gives every use
// of it or of its selects (detail 1): the three continuous assignments that
// read it and the two gate terminals; for the bit-select u[2] it gives the
// uses of that bit, of u and of the part-select u[3:2] (detail 2): the three
// continuous assignments. §37.27: ea is a named event array; vpiRange
// returns its ranges from the leftmost (detail 3); its element ea[1][3], from
// vpi_handle_by_multi_index (38.20), is a named event with ea as vpiParent
// whose vpiIndex iteration gives 3 then 1, while that of ev, not in an
// array, is NULL (detail 2); the vpiTypespec of ev is an event typespec and
// that of ea an array typespec. Kinds of uses are sorted.

`timescale 1ns/1ns

module test_vpi_select_objects_event_arrays;
  logic [7:0] m2 [0:2][0:3];
  logic [7:0] dyn [];
  logic [7:0] mv [0:2][0:1];
  integer iv = 8;
  parameter logic [7:0] P = 8'b0000_0100;
  int k = 2;
  logic [3:0] u = 4'b0110;
  wire y1, y2, y3, y4;
  event ev;
  event ea [0:1][2:4];

  assign y1 = ^u;
  assign y2 = u[2];
  assign y4 = &u[3:2];
  and g (y3, u[0], u[1]);

  initial begin
    m2[1][2] = 8'd90;
    dyn = new[2];
    mv[2][1] = 8'b0010_0000;
    #1 $vt_selects(m2[1][2], dyn[1], iv[3], P[2], mv[k][1][5], mv[2][1][5]);
  end
endmodule
