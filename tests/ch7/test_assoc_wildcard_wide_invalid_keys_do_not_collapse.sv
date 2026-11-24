/*
:name: test_assoc_wildcard_wide_invalid_keys_do_not_collapse
:description: Wide wildcard keys with unknown high and low bits cannot read or overwrite the corresponding binary keys
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.1 7.8.6 7.9.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_assoc_wildcard_wide_invalid_keys_do_not_collapse.expected
*/
module test_assoc_wildcard_wide_invalid_keys_do_not_collapse;
  logic [15:0] entries[*];
  logic [95:0] high_key, bad_high, bad_low;
  logic [15:0] read_high, read_low;

  initial begin
    high_key = {1'b1, 87'b0, 8'h25};
    bad_high = {1'bx, 87'b0, 8'h25};
    bad_low = {1'b1, 87'b0, 8'b0010010z};
    entries[8'h25] = 16'h4132;
    entries[high_key] = 16'h6374;
    read_high = entries[bad_high];
    read_low = entries[bad_low];
    entries[bad_high] = 16'ha1b2;
    entries[bad_low] = 16'hc3d4;
    $display("invalid=%h/%h exists=%0d/%0d size=%0d",
             read_high, read_low, entries.exists(bad_high), entries.exists(bad_low), entries.num());
    $display("known=%h/%h resized=%h", entries[8'h25], entries[high_key], entries[24'h000025]);
    $finish(0);
  end
endmodule
