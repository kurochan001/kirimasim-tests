/*
:name: test_annex_set_expression_construction
:description: Set bins capture constructor values while a reference stays live
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.1.2 A.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_annex_set_expression_construction
:expected_stdout: @test_annex_set_expression_construction.expected
*/
`timescale 1ns/1ns
module test_annex_set_expression_construction;
  int sample_value;
  byte source_values[] = '{2, 5};
  typedef string incompatible_t[2];

  covergroup cg(ref byte choices[]);
    point: coverpoint sample_value {
      bins selected[] = choices;
      ignore_bins local_bin = {31};
    }
    live: coverpoint choices[0] { bins updates[] = {42, 44}; }
  endgroup

  cg first, second;

  task automatic take(int value);
    int first_hit, first_total, second_hit, second_total;
    int first_live, first_live_total, second_live, second_live_total;
    sample_value = value;
    first.sample();
    second.sample();
    void'(first.point.get_inst_coverage(first_hit, first_total));
    void'(second.point.get_inst_coverage(second_hit, second_total));
    void'(first.live.get_inst_coverage(first_live, first_live_total));
    void'(second.live.get_inst_coverage(second_live, second_live_total));
    $display("sample=%0d first=%0d/%0d second=%0d/%0d live=%0d,%0d",
             value, first_hit, first_total, second_hit, second_total,
             first_live, second_live);
  endtask

  initial begin
    first = new(source_values);
    source_values[0] = 7;
    source_values[1] = 9;
    second = new(source_values);
    source_values[0] = 42;
    source_values[1] = 43;
    take(42);
    source_values[0] = 44;
    take(2);
    take(7);
    take(5);
    take(9);
    $finish(0);
  end
endmodule
