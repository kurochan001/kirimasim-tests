/*
:name: test_vpi_array_var
:description: An unpacked array of variables is an array var whose size is its number of elements and whose range is its leftmost unpacked dimension; its elements, by iteration or by index, are array members named with their index, with their index expressions and the array as parent, and can be written through VPI (IEEE 1800-2023 Sections 37.17 and 37.20)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.17 37.20 38.19 38.34
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_array_var.c
:expected_stdout: @test_vpi_array_var.expected
*/
// IEEE 1800-2023 §37.17: mem and q are array vars (detail 1). vpiSize gives the
// number of elements (detail 9), vpiScalar and vpiVector those of an element
// (detail 20), and vpiLeftRange and vpiRightRange the bounds of the unpacked
// dimension as written (detail 6). vpi_iterate(vpiReg) over mem gives its
// elements, and vpi_handle_by_index (38.19) one of them. An element is an array
// member (detail 2), named with its index in vpiName and vpiFullName (detail
// 28), with the array as vpiParent (detail 26), and its vpiIndex iteration
// gives the index (detail 18). The element q[3] of the int array is an int
// var. §37.20: the vpiMemory method gives arrays of variables, among them mem.
// vpi_put_value on mem[1] writes that element (38.34).

module test_vpi_array_var;
  logic [7:0] mem [0:3];
  int q [5:2];

  initial begin
    for (int k = 0; k < 4; k++) mem[k] = 8'h10 + k;
    foreach (q[k]) q[k] = k * 10;
    #1 $vt_array;
    #1 $display("mem[1] = %h", mem[1]);
  end
endmodule
