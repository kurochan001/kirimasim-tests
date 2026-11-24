/*
:name: test_nested_dynamic_array_resize_preserves_rows_and_four_state_contents
:description: A wide dynamic subarray extent resizes only the selected row and preserves four-state values independently of a copied sibling row
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5.1 6.11.2
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_nested_dynamic_array_resize_preserves_rows_and_four_state_contents.expected
*/
module test_nested_dynamic_array_resize_preserves_rows_and_four_state_contents;
  typedef logic [3:0] value_t;
  value_t rows[2][];
  bit [79:0] requested;

  initial begin
    rows[0] = new[2];
    rows[0][0] = 4'b10xz;
    rows[0][1] = 4'b0101;
    rows[1] = new[1];
    rows[1][0] = 4'b0110;

    requested = {16'h8421, 64'd3};
    rows[0] = new[requested](rows[0]);
    $display("grow=%0d %b %b %b sibling=%0d %b",
             rows[0].size(), rows[0][0], rows[0][1], rows[0][2], rows[1].size(), rows[1][0]);

    requested = {16'h3377, 64'd2};
    rows[1] = new[requested](rows[0]);
    rows[0][0] = 4'b1010;
    $display("after copy=%0d %b %b original=%0d %b",
             rows[1].size(), rows[1][0], rows[1][1], rows[0].size(), rows[0][0]);

    requested = {16'h7050, 64'd0};
    rows[0] = new[requested](rows[0]);
    $display("empty=%0d sibling=%0d %b %b",
             rows[0].size(), rows[1].size(), rows[1][0], rows[1][1]);
  end
endmodule
