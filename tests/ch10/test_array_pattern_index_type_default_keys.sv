/*
:name: test_array_pattern_index_type_default_keys
:description: in an array assignment pattern an index key beats a type key, the last matching type key wins, a type key that does not match the element type descends into subarrays and structure elements, and default fills only what is left (IEEE 1800-2023 Section 10.9.1)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.9.1 10.9.2 6.22.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_pattern_index_type_default_keys.expected
*/
// IEEE 1800-2023 §10.9.1: in an array assignment pattern, an index key sets
// that element. A type key sets every element or subarray whose type
// matches it and that no index key has set; if several type keys match the
// same element, the last one is used. If the element type does not match,
// the type key (with the default key) is applied again inside each subarray
// of a multidimensional array, or inside each structure element by the rules
// of structure patterns (10.9.2). The default key sets what neither an index
// nor a type key has set, applying the rules again inside unmatched
// subarrays and structure elements.
//
// arr is an array of the structure ab_t (an int a and a byte b), md an int
// array of two rows of three:
//   arr '{int: 7, default: 3}          in each element the int key reaches a
//                                      and the default b
//   arr '{1: '{100, 50}, default: 3}   index 1 keeps its value; the default
//                                      fills the members of the others
//   arr '{ab_t: '{1, 2}, 0: '{9, 9}}   index 0 wins over the type key
//   arr '{ab_t: ..., ab_alias_t: ...}  both keys match ab_t (6.22.1); the
//                                      last one wins
//   arr '{default: 5, byte: 1}         the byte key reaches b, default a
//   md  '{int: 6}                      the int key reaches every element
//                                      through the rows
//   md  '{0: '{7, 8, 9}, default: 2}   the default fills row 1 element-wise
//
// Icarus Verilog 13.0 does not support unpacked structures, and release
// 5.052 of Verilator does not support a type key in an array pattern.

module test_array_pattern_index_type_default_keys;
  typedef struct {
    int a;
    byte b;
  } ab_t;
  typedef ab_t ab_alias_t;

  ab_t arr[0:2];
  int md[0:1][0:2];

  function automatic void show_arr(string tag);
    $display("%s: {%0d,%0d} {%0d,%0d} {%0d,%0d}", tag, arr[0].a, arr[0].b,
             arr[1].a, arr[1].b, arr[2].a, arr[2].b);
  endfunction

  function automatic void show_md(string tag);
    $display("%s: %0d %0d %0d / %0d %0d %0d", tag, md[0][0], md[0][1], md[0][2],
             md[1][0], md[1][1], md[1][2]);
  endfunction

  initial begin
    arr = '{int: 7, default: 3};
    show_arr("int+default");
    arr = '{1: '{a: 100, b: 50}, default: 3};
    show_arr("index+default");
    arr = '{ab_t: '{1, 2}, 0: '{9, 9}};
    show_arr("type+index");
    arr = '{ab_t: '{1, 2}, ab_alias_t: '{3, 4}};
    show_arr("two matching types");
    arr = '{default: 5, byte: 1};
    show_arr("default+byte");
    md = '{int: 6};
    show_md("md int");
    md = '{0: '{7, 8, 9}, default: 2};
    show_md("md index+default");
  end
endmodule
