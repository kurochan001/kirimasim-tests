/*
:name: test_always_comb_independent_element_writers
:description: one element of an unpacked array and one part of a vector may be written by an always_comb while other elements and parts are written by a continuous assignment or by another always_comb, since their longest static prefixes do not overlap (IEEE 1800-2023 Section 9.2.2.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2 11.5.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_comb_independent_element_writers.expected
*/
// IEEE 1800-2023 §9.2.2.2: a variable written by an always_comb shall not
// be written by any other process, but independent elements of a variable
// may be written by different processes as long as the longest static
// prefixes (11.5.3) of the writes do not overlap. So arr[0] can come from an
// always_comb and arr[1] from a continuous assignment, and v[3:0] and
// v[7:4] from two always_comb procedures.
//
// The design is legal and each written part follows its own source: the
// values are printed after the sources change.

module test_always_comb_independent_element_writers;
  logic [7:0] s0 = 8'd1, s1 = 8'd2;
  logic [7:0] arr [0:1];
  logic [7:0] v;

  always_comb arr[0] = s0 + 8'd1;
  assign arr[1] = s1 * 8'd2;

  always_comb v[3:0] = s0[3:0];
  always_comb v[7:4] = s1[3:0];

  initial begin
    #1 $display("arr=%0d,%0d v=%h", arr[0], arr[1], v);
    s0 = 8'd5;
    #1 $display("arr=%0d,%0d v=%h", arr[0], arr[1], v);
    s1 = 8'd9;
    #1 $display("arr=%0d,%0d v=%h", arr[0], arr[1], v);
  end
endmodule
