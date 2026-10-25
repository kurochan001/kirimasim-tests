/*
:name: test_bits_empty_dynamic_is_zero
:description: $bits of a dynamic array, a queue, an associative array or a string is 0 while it is empty and the number of bits of its elements once it holds some (IEEE 1800-2023 Section 20.6.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.6.2 6.24.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bits_empty_dynamic_is_zero.expected
*/
// IEEE 1800-2023 §20.6.2: $bits of a dynamically sized expression that is
// currently empty returns 0; otherwise it returns the number of bits the
// expression holds as a bit stream (§6.24.3), one per data bit.
// A dynamic array of int, a queue of byte, an associative array of int and
// a string are printed empty, after holding three ints, two bytes, one int
// and three characters (96, 16, 32 and 24 bits), and after being emptied
// again with delete() and the empty string.
// Neither simulator follows the clause here: Icarus Verilog 13.0 rejects the
// associative array with an int index and gives 1 as $bits of the others,
// and release 5.052 of the Verilator tool does not support $bits of a
// dynamic array.

module test_bits_empty_dynamic_is_zero;
  int dyn [];
  byte q [$];
  int aa [int];
  string s;

  initial begin
    $display("empty: %0d %0d %0d %0d", $bits(dyn), $bits(q), $bits(aa), $bits(s));
    dyn = new[3];
    q.push_back(8'd1);
    q.push_back(8'd2);
    aa[5] = 1;
    s = "abc";
    $display("filled: %0d %0d %0d %0d", $bits(dyn), $bits(q), $bits(aa), $bits(s));
    dyn.delete();
    q.delete();
    aa.delete();
    s = "";
    $display("emptied: %0d %0d %0d %0d", $bits(dyn), $bits(q), $bits(aa), $bits(s));
  end
endmodule
