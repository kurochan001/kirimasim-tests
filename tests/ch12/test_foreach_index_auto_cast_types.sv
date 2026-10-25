/*
:name: test_foreach_index_auto_cast_types
:description: Outside indexing of its own array, a foreach loop variable has type int for fixed-size and dynamic arrays and the index type for associative arrays with a specific index type, and an explicit cast gives another type (IEEE 1800-2023 Section 12.7.3)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_foreach_index_auto_cast_types.expected
*/
// IEEE 1800-2023 §12.7.3: when a foreach loop variable is used in an
// expression other than as an index of the loop's array, it is cast to a
// type consistent with the index: int for fixed-size and dynamic arrays,
// and for an associative array with a specific index type, that type. A
// cast gives another type.
//
// For the fixed-size array [7:5] and a dynamic array, $bits of the loop
// variable is 32 and i - 10 is negative, as for a signed int. For the
// associative array indexed by byte, $bits is 8 and the key -3 stays -3;
// for the one indexed by bit [3:0], $bits is 4 and k + 4'd1 is a 4-bit
// sum, so 15 + 1 wraps to 0; for the one indexed by string, the variable
// is a string with len(). shortint'(i) has 16 bits. Each associative array
// has one key, so the order of its iteration does not matter.

module test_foreach_index_auto_cast_types;
  int fixed_arr [7:5];
  int dyn [];
  int by_byte [byte];
  int by_nibble [bit [3:0]];
  int by_string [string];

  initial begin
    foreach (fixed_arr[i])
      $display("fixed [7:5]: i=%0d bits=%0d i-10=%0d cast bits=%0d", i, $bits(i), i - 10,
               $bits(shortint'(i)));
    dyn = new[2];
    foreach (dyn[i]) $display("dynamic: i=%0d bits=%0d i-10=%0d", i, $bits(i), i - 10);
    by_byte[-3] = 1;
    foreach (by_byte[k]) $display("assoc [byte]: k=%0d bits=%0d", k, $bits(k));
    by_nibble[4'd15] = 1;
    foreach (by_nibble[k])
      $display("assoc [bit [3:0]]: k=%0d bits=%0d k+4'd1=%0d", k, $bits(k), k + 4'd1);
    by_string["xyz"] = 1;
    foreach (by_string[k]) $display("assoc [string]: k=%s len=%0d", k, k.len());
  end
endmodule
