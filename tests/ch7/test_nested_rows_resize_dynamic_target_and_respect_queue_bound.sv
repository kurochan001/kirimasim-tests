/*
:name: test_nested_rows_resize_dynamic_target_and_respect_queue_bound
:description: Copying wide fixed rows to a dynamic array and bounded queue resizes only the outer dimension and keeps each copied row
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.6 7.10.5 6.22.2
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_nested_rows_resize_dynamic_target_and_respect_queue_bound.expected
*/
module test_nested_rows_resize_dynamic_target_and_respect_queue_bound;
  typedef logic signed [64:0] entry_t;
  typedef entry_t row_t [-2:-1];
  row_t original [7:5];
  row_t dynamic_rows [];
  row_t limited_rows [$:1];

  initial begin
    original[7][-2] = 65'h1_1000000000000001;
    original[7][-1] = 65'h0_2000000000000002;
    original[6][-2] = 65'h0_300000000000000x;
    original[6][-1] = 65'h1_400000000000000z;
    original[5][-2] = 65'h1_5000000000000005;
    original[5][-1] = 65'h0_6000000000000006;
    dynamic_rows = original;
    limited_rows = dynamic_rows;
    $display("sizes=%0d/%0d tail=%h", dynamic_rows.size(), limited_rows.size(),
             dynamic_rows[2][-1]);
    dynamic_rows[0][-2] = 65'h0_7000000000000007;
    $display("separate=%h/%h", dynamic_rows[0][-2], limited_rows[0][-2]);

    limited_rows = dynamic_rows[1:2];
    dynamic_rows = limited_rows;
    $display("resized=%0d heads=%h/%h", dynamic_rows.size(),
             dynamic_rows[0][-2], dynamic_rows[1][-2]);
    $finish(0);
  end
endmodule
