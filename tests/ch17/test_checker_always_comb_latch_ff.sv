/*
:name: test_checker_always_comb_latch_ff
:description: A checker body takes always_comb, always_latch and always_ff procedures, whose variables follow the combinational inputs, hold when the latch is closed, and take the value sampled at the clock edge (IEEE 1800-2023 Section 17.5, C.2.7)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.5 C.2.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_always_comb_latch_ff.expected
*/
// IEEE 1800-2023 §17.5: the always procedures allowed in a checker body are
// always_comb, always_latch and always_ff, and the general always procedure is
// no longer one of them (C.2.7). An always_comb procedure takes the current
// values of the expressions it reads, an always_latch procedure stores the
// value while its condition holds and keeps it afterwards, and the
// expressions of an always_ff procedure are sampled at its event.
//
// The checker has one variable for each of the three procedures and gives
// them to the test module through output formals. comb is a & b and follows
// both inputs; lat takes a while en is high and keeps its last value when en
// falls; ff takes a at each rising edge. The test module prints the three
// variables at times between the edges, so no value is read in the same time
// step as an update, and the first print comes after lat and ff have each
// been written once, so the value a variable has before its first write, which
// the standard leaves as x, does not enter.

checker chk(input logic clk, input logic en, input logic [7:0] a,
            input logic [7:0] b, output logic [7:0] comb,
            output logic [7:0] lat, output logic [7:0] ff);
  always_comb comb = a & b;
  always_latch if (en) lat = a;
  always_ff @(posedge clk) ff <= a;
endchecker

module test_checker_always_comb_latch_ff;
  logic clk = 0;
  logic en = 0;
  logic [7:0] a = 8'h0f;
  logic [7:0] b = 8'h33;
  logic [7:0] comb;
  logic [7:0] lat;
  logic [7:0] ff;

  always #5 clk = ~clk;

  chk c1(.clk(clk), .en(en), .a(a), .b(b), .comb(comb), .lat(lat), .ff(ff));

  initial begin
    #7 en = 1;
    #5 $display("t12 comb %02h lat %02h ff %02h", comb, lat, ff);
    #6 a = 8'hf0;
    #4 $display("t22 comb %02h lat %02h ff %02h", comb, lat, ff);
    #6 en = 0; a = 8'h55;
    #4 $display("t32 comb %02h lat %02h ff %02h", comb, lat, ff);
    #6 a = 8'h0f;
    #4 $display("t42 comb %02h lat %02h ff %02h", comb, lat, ff);
    #4 $finish;
  end
endmodule
