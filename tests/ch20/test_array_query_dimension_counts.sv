/*
:name: test_array_query_dimension_counts
:description: $dimensions counts all packed and unpacked, fixed and dynamic dimensions, is 1 for a string or a nonarray simple bit vector type and 0 for other types, and $unpacked_dimensions counts only the unpacked ones (IEEE 1800-2023 Section 20.7)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_query_dimension_counts.expected
*/
// IEEE 1800-2023 §20.7: $dimensions gives the total number of dimensions of
// an array, packed and unpacked, static or dynamic; 1 for the string type or
// another nonarray type equivalent to a simple bit vector; 0 for any other
// type. $unpacked_dimensions gives the number of unpacked dimensions, static
// or dynamic, and 0 for any other type. An integer type with a predefined
// width counts as one packed dimension.
// The lines print $dimensions and $unpacked_dimensions of: a 2-D unpacked
// array of a 2-D packed vector (4 and 2); a dynamic array and a queue of
// predefined-width integers (2 and 1); a string and an 8-bit vector (1 and
// 0); a 2-D packed vector (2 and 0) and a packed structure, a nonarray type
// equivalent to a simple bit vector (§6.11.1, 1 and 0); and real, shortreal
// and event variables (0 and 0).
// Icarus Verilog 13.0 gives 0 and 0 for the dynamic array and the queue.

module test_array_query_dimension_counts;
  typedef struct packed {
    logic [2:0] a;
    bit b;
  } ps_t;
  logic [3:0][1:0] m [2][3];
  int d [];
  byte q [$];
  string s;
  ps_t ps;
  bit [7:0] v8;
  logic [3:0][1:0] pk;
  real r;
  shortreal sr;
  event ev;

  initial begin
    $display("m %0d %0d", $dimensions(m), $unpacked_dimensions(m));
    $display("d %0d %0d q %0d %0d", $dimensions(d), $unpacked_dimensions(d), $dimensions(q),
             $unpacked_dimensions(q));
    $display("s %0d %0d v8 %0d %0d", $dimensions(s), $unpacked_dimensions(s), $dimensions(v8),
             $unpacked_dimensions(v8));
    $display("pk %0d %0d ps %0d %0d", $dimensions(pk), $unpacked_dimensions(pk), $dimensions(ps),
             $unpacked_dimensions(ps));
    $display("r %0d %0d sr %0d %0d ev %0d %0d", $dimensions(r), $unpacked_dimensions(r),
             $dimensions(sr), $unpacked_dimensions(sr), $dimensions(ev), $unpacked_dimensions(ev));
  end
endmodule
