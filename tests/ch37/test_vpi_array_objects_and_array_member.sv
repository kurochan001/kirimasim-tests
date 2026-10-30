/*
:name: test_vpi_array_objects_and_array_member
:description: An unpacked array of variables is an array var object and not a memory object, its elements are variable objects and not memory words, vpiArrayMember is true for an element and false for the array, and the vpiMemory relationship of the module still gives the array of logic as an array var (IEEE 1800-2023 Section C.4.3, 37.17, 37.20)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.17 37.20 C.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_array_objects_and_array_member.c
:expected_stdout: @test_vpi_array_objects_and_array_member.expected
*/
// IEEE 1800-2023 §C.4.3: vpiMemory is no longer an object type, because
// vpiArrayVar (vpiRegArray) has been generalized to cover it and all other
// arrays of variables, though vpiMemory remains in use as a relationship.
// vpiMemoryWord is no longer an object type either, since variable object
// types such as vpiLogicVar (vpiReg) represent the elements of an array, and
// it too remains a relationship. §37.17: any variable declared as an array
// with one or more unpacked ranges is an array var, and vpiArrayMember is true
// for a variable that is a member of an array variable and false otherwise;
// the deprecated vpiArray property is not used.
//
// The design declares an array of 8-bit variables and an array of int
// variables. The application asks a handle obtained by name for its type, asks
// the element of each array for its type and for vpiArrayMember, and iterates
// the vpiMemory relationship of the module (37.20), checking that it gives
// mem and only array var objects. An element of an int array is an int var
// (vpiIntVar), not an integer var, which is the type of integer. Whether the
// relationship also gives the int array, which was not a memory in IEEE Std
// 1364, is not checked. The expected output follows the standard; the release
// used while the test was written still reports the memory object types here.

module test_vpi_array_objects_and_array_member;
  logic [7:0] mem [0:3];
  int ia [2];

  initial begin
    for (int k = 0; k < 4; k++) mem[k] = 8'h10 + k;
    ia[0] = 7;
    ia[1] = 8;
    #1 $vt_arrays;
    #1 $display("mem[2] %02h ia[1] %0d", mem[2], ia[1]);
  end
endmodule
