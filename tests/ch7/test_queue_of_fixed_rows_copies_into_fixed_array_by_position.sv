/*
:name: test_queue_of_fixed_rows_copies_into_fixed_array_by_position
:description: A queue and a fixed array with equal length and equivalent fixed row types copy values by position
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.6 6.22.2 7.10
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_queue_of_fixed_rows_copies_into_fixed_array_by_position.expected
*/
module test_queue_of_fixed_rows_copies_into_fixed_array_by_position;
  typedef logic [64:0] wide_t;
  typedef wide_t source_row_t [-2:-1];
  typedef wide_t target_row_t [8:7];
  source_row_t original [4:3];
  source_row_t rows [$];
  target_row_t fixed_result [21:20];
  target_row_t element_result [21:20];

  task automatic report();
    $display("element=%h/%h %h/%h", element_result[21][8], element_result[21][7],
             element_result[20][8], element_result[20][7]);
    $display("whole=%h/%h %h/%h", fixed_result[21][8], fixed_result[21][7],
             fixed_result[20][8], fixed_result[20][7]);
  endtask

  initial begin
    original[4][-2] = 65'h1_1000000000000001;
    original[4][-1] = 65'h0_2000000000000002;
    original[3][-2] = 65'h0_300000000000000x;
    original[3][-1] = 65'h1_400000000000000z;
    rows = original;
    $display("queue size=%0d", rows.size());
    for (int outer = 0; outer < 2; outer++)
      for (int inner = 0; inner < 2; inner++)
        element_result[21-outer][8-inner] = rows[outer][-2+inner];
    fixed_result = rows;
    report();
    $finish(0);
  end
endmodule
