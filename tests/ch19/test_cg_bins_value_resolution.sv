/*
:name: test_cg_bins_value_resolution
:description: Bin values that the type of the coverpoint cannot express are left out of the bin, also when a range is partly outside, for an unsigned and a signed coverpoint (IEEE 1800-2023 Section 19.5.7)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.7 19.5 19.11.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_bins_value_resolution.expected
*/
// IEEE 1800-2023 §19.5.7: bin values are cast to the type of the coverpoint
// expression, and a value that does not survive the cast is not part of the
// bin; a range keeps only the values that the type can express. For the
// unsigned 3-bit p1, b1 = {1, [6:10]} is {1, 6, 7}, so p1 = 0 hits no bin,
// although 8 would become 0 by the cast. For the signed 3-bit p2, b3 = {1,
// [2:5]} is {1, 2, 3}, so p2 = -4 hits no bin, and b4 = {-1, 15} is {-1}. Each
// coverpoint has two bins (19.11.1) and is the only item of its covergroup.

module test_cg_bins_value_resolution;
  bit [2:0] p1;
  bit signed [2:0] p2;

  covergroup cg1;
    cp1: coverpoint p1 {
      bins b1 = {1, [6:10]};
      bins b2 = {[2:3]};
    }
  endgroup

  covergroup cg2;
    cp2: coverpoint p2 {
      bins b3 = {1, [2:5]};
      bins b4 = {-1, 15};
    }
  endgroup

  cg1 g1 = new();
  cg2 g2 = new();

  task automatic put(bit [2:0] a, bit signed [2:0] b);
    p1 = a;
    p2 = b;
    g1.sample();
    g2.sample();
    $display("p1=%0d p2=%0d: cp1 %0.2f, cp2 %0.2f", p1, p2, g1.get_inst_coverage(),
             g2.get_inst_coverage());
  endtask

  initial begin
    put(0, -4);
    put(7, 3);
    put(2, -1);
  end
endmodule
