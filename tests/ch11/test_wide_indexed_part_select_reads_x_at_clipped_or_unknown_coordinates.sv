/*
:name: test_wide_indexed_part_select_reads_x_at_clipped_or_unknown_coordinates
:description: Indexed part-selects on nonzero packed bounds fill missing bits with x and ignore writes through an unknown base
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_wide_indexed_part_select_reads_x_at_clipped_or_unknown_coordinates.expected
*/
module test_wide_indexed_part_select_reads_x_at_clipped_or_unknown_coordinates;
  localparam logic [96:0] SEED = 97'h1_1234_5678_9abc_def0_1020_3040;
  logic [81:-15] descending;
  logic [-15:81] ascending;

  task automatic read_at(input string label_text, input logic signed [8:0] base);
    $display("%s down=%b/%b up=%b/%b", label_text,
             descending[base+:9], descending[base-:9],
             ascending[base+:9], ascending[base-:9]);
  endtask

  task automatic bad_write(input string label_text, input logic signed [8:0] base);
    read_at(label_text, base);
    descending[base+:9] = 9'h0ab;
    ascending[base-:9] = 9'h127;
    $display("%s preserved=%b/%b", label_text, descending === SEED, ascending === SEED);
  endtask

  initial begin
    descending = SEED;
    ascending = SEED;
    read_at("below", -16);
    read_at("above", 83);
    read_at("inside", 22);
    bad_write("unknown", 9'bx_0000_0000);
    bad_write("floating", 9'bz_0000_0111);
    bad_write("outside", -30);
    $finish(0);
  end
endmodule
