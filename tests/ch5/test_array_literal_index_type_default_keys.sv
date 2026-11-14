/*
:name: test_array_literal_index_type_default_keys
:description: An array literal can key its elements by index, by element or subarray type and by default; an index key wins over a type key, a type key wins over the default, and a type that only matches the elements of a subarray is applied inside each subarray (IEEE 1800-2023 Section 5.11)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.11 10.9.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_literal_index_type_default_keys.expected
*/
// IEEE 1800-2023 §5.11: an array literal can use an index or a type as a key
// and can give a default, with the rules of array assignment patterns
// (10.9.1). §10.9.1: an index key sets the element with that index; a type
// key sets every element (or subarray) of that type that no index key set,
// and when the type is not the element type of a multidimensional array the
// keys are applied again inside each subarray; the default sets what neither
// an index key nor a type key set.
// Each literal below has constant members and gets its type from the
// variable it initializes or from a cast:
//   q_id    index 2 and default: -1 -1 5 -1
//   q_ti    type byte and index 0, so index 0 keeps 1: 1 7 7 7
//   q_dt    default 3 and type byte, so the type key sets all: 4 4 4 4
//   g_sub   index 1 and the subarray type pair_t: 6 6 / 8 9 / 6 6
//   g_elem  the element type shortint, applied inside each subarray: 2 2 ...
//   cast    quad_t'{1: 2, byte: 9}, summed: 9 + 2 + 9 + 9 = 29
// A tool that let a type key override an index key would print 7 for q_ti[0]
// and 6 6 for g_sub[1]; one that let the default override a type key would
// print 3 3 3 3 for q_dt.
// Neither release runs the test: Icarus Verilog 13.0 gives a syntax error
// at every keyed literal, the first of them the one of q_id, which has only
// an index key and a default key, and the 5.054 release of Verilator does
// not support a type key in an array pattern.

module test_array_literal_index_type_default_keys;
  typedef byte quad_t [0:3];
  typedef shortint pair_t [0:1];
  typedef pair_t trio_t [0:2];

  quad_t q_id = '{2: 5, default: -1};
  quad_t q_ti = '{byte: 7, 0: 1};
  quad_t q_dt = '{default: 3, byte: 4};
  trio_t g_sub = '{1: '{8, 9}, pair_t: '{6, 6}};
  trio_t g_elem = '{shortint: 2};

  function automatic int total(quad_t q);
    return q[0] + q[1] + q[2] + q[3];
  endfunction

  initial begin
    $display("q_id: %0d %0d %0d %0d", q_id[0], q_id[1], q_id[2], q_id[3]);
    $display("q_ti: %0d %0d %0d %0d", q_ti[0], q_ti[1], q_ti[2], q_ti[3]);
    $display("q_dt: %0d %0d %0d %0d", q_dt[0], q_dt[1], q_dt[2], q_dt[3]);
    $display("g_sub: %0d %0d / %0d %0d / %0d %0d", g_sub[0][0], g_sub[0][1],
             g_sub[1][0], g_sub[1][1], g_sub[2][0], g_sub[2][1]);
    $display("g_elem: %0d %0d / %0d %0d / %0d %0d", g_elem[0][0], g_elem[0][1],
             g_elem[1][0], g_elem[1][1], g_elem[2][0], g_elem[2][1]);
    $display("cast: %0d", total(quad_t'{1: 2, byte: 9}));
  end
endmodule
