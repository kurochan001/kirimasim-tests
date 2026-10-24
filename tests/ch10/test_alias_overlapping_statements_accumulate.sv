/*
:name: test_alias_overlapping_statements_accumulate
:description: alias statements that share nets add up, so bits joined by different statements, and names linked only through a common name, are one net (IEEE 1800-2023 Section 10.11)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.11
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_alias_overlapping_statements_accumulate.expected
*/
// IEEE 1800-2023 §10.11: a net can be named in more than one alias statement,
// and the connections of all of them hold together.
// The lower six bits of big are joined to lo6 by one statement and its upper
// six bits to hi6 by another, so big[5:4] is both lo6[5:4] and hi6[1:0]: the
// value driven on lo6[5:4] is read through hi6[1:0], and big shows all three
// drivers. p is joined to q, and q to r by a second statement, so p reads the
// value driven on r; one alias statement can also name three nets, and s and
// t read the value driven on u. Each driven value is different, and a name
// that no alias joined to a driver would read z.
// Icarus Verilog 13.0 does not parse alias statements, and Verilator 5.052
// does not accept an alias of a part-select, so the expected output follows
// the clause alone.

module test_alias_overlapping_statements_accumulate;
  wire [9:0] big;
  wire [5:0] lo6, hi6;
  wire p, q, r, s, t, u;

  alias big[5:0] = lo6;
  alias big[9:4] = hi6;
  assign lo6[5:4] = 2'b10;
  assign lo6[3:0] = 4'b1001;
  assign hi6[5:2] = 4'b0110;

  alias p = q;
  alias q = r;
  assign r = 1'b1;

  alias s = t = u;
  assign u = 1'b0;

  initial begin
    #1;
    $display("hi6[1:0]=%b hi6=%b lo6=%b big=%b", hi6[1:0], hi6, lo6, big);
    $display("p=%b q=%b r=%b", p, q, r);
    $display("s=%b t=%b u=%b", s, t, u);
  end
endmodule
