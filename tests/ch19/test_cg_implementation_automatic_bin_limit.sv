/*
:name: test_cg_implementation_automatic_bin_limit
:description: An implementation limit reduces automatic bins while keeping the whole domain covered
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.3
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_implementation_automatic_bin_limit.expected
*/
module test_cg_implementation_automatic_bin_limit;
  bit [3:0] word;
  bit [1:0] narrow_word;
  covergroup measurement;
    option.per_instance = 1;
    wide_point: coverpoint word { option.auto_bin_max = 13; }
    narrow_point: coverpoint narrow_word { option.auto_bin_max = 13; }
  endgroup
  measurement probe;

  task automatic report(input string stage);
    $display("%s wide=%0.6f narrow=%0.6f", stage,
             probe.wide_point.get_inst_coverage(), probe.narrow_point.get_inst_coverage());
  endtask

  initial begin
    probe = new;
    word = 0;
    narrow_word = 0;
    probe.sample();
    word = 3;
    narrow_word = 1;
    probe.sample();
    word = 15;
    narrow_word = 3;
    probe.sample();
    report("selected");

    for (int i = 0; i < 16; ++i) begin
      word = 4'(i);
      narrow_word = 2'(i);
      probe.sample();
    end
    report("sweep");
    $finish(0);
  end
endmodule
