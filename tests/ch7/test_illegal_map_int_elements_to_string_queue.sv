/*
:name: test_illegal_map_int_elements_to_string_queue
:description: the elements of the result of map() have the type of the with expression, so a result of int elements cannot be assigned to a queue of strings (IEEE 1800-2023 Sections 7.12.5, 7.6)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.12.5 7.6 6.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the result of a.map() with (item + 1) has int elements, which are not equivalent to the string elements of the queue s
:expected_stderr_regex: test_illegal_map_int_elements_to_string_queue\.sv:32:
*/
// IEEE 1800-2023 §7.12.5: each element of the array that map() returns has
// the self-determined type of the with expression. §7.6: an unpacked array
// can be assigned to another one only if their element types are
// equivalent; besides, an integral value can be assigned to a string only
// with a cast (§6.16). The first call of map() gives strings made by
// $sformatf, which can be assigned to the queue of strings s, and the legal
// design prints them: 2 3 4. In the last call the with expression item + 1
// is an int, so the result is an array of int, which cannot be assigned to s.
// Icarus Verilog 13.0 does not support the with clause of array methods and
// reports syntax errors on both calls; the 5.052 release of Verilator
// accepts the design and then fails to compile the C++ code it generates.

module test_illegal_map_int_elements_to_string_queue;
  int a[3] = '{1, 2, 3};
  string s[$];
  initial begin
    s = a.map() with ($sformatf("%0d", item + 1));
    $display("%s %s %s", s[0], s[1], s[2]);
    s = a.map() with (item + 1);   // illegal: int elements for a queue of strings
  end
endmodule
