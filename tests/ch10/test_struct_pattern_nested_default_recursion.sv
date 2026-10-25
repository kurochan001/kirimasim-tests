/*
:name: test_struct_pattern_nested_default_recursion
:description: type and default keys of a structure assignment pattern reach the members of a nested structure and the elements of unpacked array members, unless a key matches the nested member as a whole (IEEE 1800-2023 Section 10.9.2)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.9.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_struct_pattern_nested_default_recursion.expected
*/
// IEEE 1800-2023 §10.9.2: for a member of structure type that no key has
// set, the type and default keys are applied again to each member of that
// substructure; for an unpacked array member, they are applied to the array
// by the rules of array patterns (10.9.1), element by element. A type key
// that matches the type of the nested structure itself sets it as a whole.
//
// outer_t has an int A, a nested inner_t BC (an int B and a byte C), an int
// array arr and a byte array barr:
//   '{default: 10}            every int and byte, nested or in an array, 10
//   '{A: 1, byte: 7, default: 2}
//                             A 1; BC.B and arr 2; BC.C and barr 7
//   '{int: 5, default: 0}     A, BC.B and arr 5; BC.C and barr 0
//   '{inner_t: '{B: 3, C: 4}, default: 1}
//                             BC is set as a whole to 3/4; the rest 1
//
// Icarus Verilog 13.0 does not support unpacked structures. Release 5.052
// of Verilator rejects a type key that names a structure type, and without
// the last pattern it leaves most nested members and array elements 0.

module test_struct_pattern_nested_default_recursion;
  typedef struct {
    int B;
    byte C;
  } inner_t;

  typedef struct {
    int A;
    inner_t BC;
    int arr[0:2];
    byte barr[0:1];
  } outer_t;

  outer_t o;

  function automatic void show(string tag);
    $display("%s: A=%0d B=%0d C=%0d arr=%0d,%0d,%0d barr=%0d,%0d", tag, o.A, o.BC.B, o.BC.C,
             o.arr[0], o.arr[1], o.arr[2], o.barr[0], o.barr[1]);
  endfunction

  initial begin
    o = '{default: 10};
    show("default");
    o = '{A: 1, byte: 7, default: 2};
    show("member+byte+default");
    o = '{int: 5, default: 0};
    show("int+default");
    o = '{inner_t: '{B: 3, C: 4}, default: 1};
    show("inner_t+default");
  end
endmodule
