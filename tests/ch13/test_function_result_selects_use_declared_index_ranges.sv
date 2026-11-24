/*
:name: test_function_result_selects_use_declared_index_ranges
:description: Selections on implicit function results keep descending and ascending nonzero index ranges
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.1 11.5.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_result_selects_use_declared_index_ranges.expected
*/
module test_function_result_selects_use_declared_index_ranges;
  typedef struct packed {
    logic [13:8] descending;
    logic [4:9] ascending;
  } word_pair_t;

  function automatic word_pair_t returned_pair();
    return '{6'b101101, 6'b110010};
  endfunction

  int down_index = 10;
  int up_index = 6;

  initial begin
    word_pair_t saved;
    saved = returned_pair();
    $display("saved=%b%b %b%b %b %b", saved.descending[13], saved.descending[8],
             saved.ascending[4], saved.ascending[9], saved.descending[down_index +: 3],
             saved.ascending[up_index +: 3]);
    $display("edge=%b%b %b%b", returned_pair().descending[13], returned_pair().descending[8],
             returned_pair().ascending[4], returned_pair().ascending[9]);
    $display("indexed=%b %b", returned_pair().descending[down_index +: 3],
             returned_pair().ascending[up_index +: 3]);
  end
endmodule
