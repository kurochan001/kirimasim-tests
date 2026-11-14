/*
:name: test_cg_auto_denominator_enum_and_empty_bins
:description: The denominator of a coverpoint with automatic bins is the number of names of an enum, whatever auto_bin_max is, and MIN(auto_bin_max, 2**M) for other integral coverpoints, less the bins that ignored values leave empty; with no bin left, the coverage is 0.0 for a nonzero weight and 100.0 for a zero weight (IEEE 1800-2023 Section 19.11.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.11.1 19.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_auto_denominator_enum_and_empty_bins.expected
*/
// IEEE 1800-2023 §19.11.1: the coverage of a coverpoint with automatic bins is
// the number of covered bins over the number of automatic bins. §19.5.3 gives
// that number: the number of named values for an enum coverpoint, and
// MIN(auto_bin_max, 2**M) for any other integral coverpoint of M bits, whose
// 2**M values are shared out in order with the rest in the last bin.
// §19.11.1: a bin left with no value is excluded from the numerator and the
// denominator; when no bin has a value, get_coverage and get_inst_coverage
// return 0.0 if the weight of the coverpoint is not 0 and 100.0 if it is 0,
// and both counts of the two-argument form are 0. get_inst_coverage(c, t) on
// a coverpoint gives that numerator and denominator (19.8).
//
// color_t has 3 names on a 2-bit base type, so cs (auto_bin_max 64) and cl
// (auto_bin_max 2) both have 3 bins, not 4 or 2. hundred_t has 100 names on a
// 7-bit base type, so hb has 100 bins with the default auto_bin_max of 64,
// one per name: E5 and E6 are two covered bins. For the 3-bit a, qd keeps
// the default auto_bin_max of 64, so it has MIN(64, 2**3) = 8 bins, one per
// value; q4 (auto_bin_max 4) has <0,1>, <2,3>, <4,5>, <6,7> and q3
// (auto_bin_max 3) has <0,1>, <2,3>, <4,5,6,7>. ig is q4 with the values 2, 3
// and 4 ignored: <2,3> is left empty and <4,5> keeps 5, so it has 3 bins.
// none1 and none0 ignore all 8 values; none0 has the weight 0 (option and
// type_option).
// Icarus Verilog 13.0 does not compile covergroups. Neither the counts of
// get_inst_coverage on a coverpoint nor get_coverage of a coverpoint through
// the covergroup type is supported by the 5.054 release of Verilator.

module test_cg_auto_denominator_enum_and_empty_bins;
  typedef enum bit [1:0] {RED, GREEN, BLUE} color_t;
  typedef enum bit [6:0] {E[100]} hundred_t;

  color_t c;
  hundred_t h;
  bit [2:0] a;

  covergroup cg_enum;
    cs: coverpoint c;
    cl: coverpoint c { option.auto_bin_max = 2; }
    hb: coverpoint h;
  endgroup

  covergroup cg_int;
    qd: coverpoint a;
    q4: coverpoint a { option.auto_bin_max = 4; }
    q3: coverpoint a { option.auto_bin_max = 3; }
    ig: coverpoint a {
      option.auto_bin_max = 4;
      ignore_bins skip = {[2:3], 4};
    }
    none1: coverpoint a { ignore_bins all = {[0:7]}; }
    none0: coverpoint a {
      option.weight = 0;
      type_option.weight = 0;
      ignore_bins all = {[0:7]};
    }
  endgroup

  cg_enum ge = new;
  cg_int gi = new;

  task automatic show_enum(string tag);
    int c1, t1, c2, t2, c3, t3;
    real p1, p2, p3;
    p1 = ge.cs.get_inst_coverage(c1, t1);
    p2 = ge.cl.get_inst_coverage(c2, t2);
    p3 = ge.hb.get_inst_coverage(c3, t3);
    $display("%s: cs %0d/%0d %.2f, cl %0d/%0d %.2f, hb %0d/%0d %.2f", tag,
             c1, t1, p1, c2, t2, p2, c3, t3, p3);
  endtask

  task automatic put_int(bit [2:0] v);
    int c0, t0, c1, t1, c2, t2, c3, t3, c4, t4, c5, t5;
    real p0, p1, p2, p3, p4, p5;
    a = v;
    gi.sample();
    p0 = gi.qd.get_inst_coverage(c0, t0);
    p1 = gi.q4.get_inst_coverage(c1, t1);
    p2 = gi.q3.get_inst_coverage(c2, t2);
    p3 = gi.ig.get_inst_coverage(c3, t3);
    p4 = gi.none1.get_inst_coverage(c4, t4);
    p5 = gi.none0.get_inst_coverage(c5, t5);
    $display("a=%0d: q4 %0d/%0d %.2f, q3 %0d/%0d %.2f, ig %0d/%0d %.2f", v,
             c1, t1, p1, c2, t2, p2, c3, t3, p3);
    $display("  qd %0d/%0d %.2f, none1 %0d/%0d %.2f, none0 %0d/%0d %.2f", c0, t0, p0,
             c4, t4, p4, c5, t5, p5);
  endtask

  initial begin
    c = GREEN;
    h = E5;
    ge.sample();
    show_enum("GREEN, E5");
    c = BLUE;
    h = E6;
    ge.sample();
    show_enum("BLUE, E6");

    put_int(4);
    put_int(5);
    put_int(6);
    put_int(2);
    put_int(0);
    $display("type: none1 %.2f, none0 %.2f", cg_int::none1::get_coverage(),
             cg_int::none0::get_coverage());
  end
endmodule
