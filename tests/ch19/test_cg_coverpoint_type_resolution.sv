/*
:name: test_cg_coverpoint_type_resolution
:description: With a data type given for the coverpoint, the sampled value is converted to that type and the bin values are resolved against it, so values it cannot express, and negative values for an unsigned type, are left out (IEEE 1800-2023 Section 19.5.7)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.7 19.5 19.11.1 19.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_coverpoint_type_resolution.expected
*/
// IEEE 1800-2023 §19.5.7: when the coverpoint has a data type, that type is
// the effective type of the coverpoint expression, and the values of the bins
// are cast to it. A singleton value that a warning is issued for, because the
// cast changes it or it is negative for an unsigned type, is not part of the
// bin; a range keeps the values the type can express, and a range with none of
// them is left out. §19.5: the value sampled is that of the int v assigned to
// the bit [1:0] of the coverpoint. So zero is {0}, one is {1}, three is {3},
// mid is {2, 3}, and none has no value and is not counted (19.11.1): 4 bins.
// The samples 4, 9, 6 and -5 give the coverpoint values 0, 1, 2 and 3; the
// test prints the coverage of the covergroup, that of its only coverpoint
// (19.11), after each.
//
// Version 5.052 of Verilator ignores the type of the coverpoint: it compares
// the int value with the bins, so 4 hits mid and none, and it keeps 6 in one
// and the empty bin none; Icarus Verilog 13.0 does not compile covergroups.

module test_cg_coverpoint_type_resolution;
  int v;

  covergroup cg;
    bit [1:0] cp: coverpoint v {
      bins zero = {0, 8};
      bins one = {1, 6};
      bins three = {-1, 3};
      bins mid = {[2:9]};
      bins none = {[4:7]};
    }
  endgroup

  cg inst = new();

  task automatic put(int x);
    v = x;
    inst.sample();
    $display("v=%0d: %.2f", x, inst.get_inst_coverage());
  endtask

  initial begin
    put(4);
    put(9);
    put(6);
    put(-5);
  end
endmodule
