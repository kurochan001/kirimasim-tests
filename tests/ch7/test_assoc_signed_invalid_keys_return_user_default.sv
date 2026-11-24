/*
:name: test_assoc_signed_invalid_keys_return_user_default
:description: Signed integral associative keys with unknown bits return the user default and leave valid signed entries intact
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.4 7.8.6 7.9.11
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_assoc_signed_invalid_keys_return_user_default.expected
*/
module test_assoc_signed_invalid_keys_return_user_default;
  typedef logic signed [16:0] key_t;
  logic [15:0] entries[key_t] = '{default:16'hb5e7};
  key_t high_unknown, low_unknown;
  logic [15:0] read_x, read_z;

  initial begin
    entries[17'h00035] = 16'h4132;
    entries[-17'sd3] = 16'h6374;
    high_unknown = {1'bx, 16'h0035};
    low_unknown = {15'h7fff, 2'b0z};
    read_x = entries[high_unknown];
    read_z = entries[low_unknown];
    entries[high_unknown] = 16'hdb11;
    entries[low_unknown] = 16'hdb12;
    entries[17'h00075] = 16'hcb93;
    $display("missing=%h/%h/%h size=%0d", read_x, read_z, entries[17'h00025], entries.num());
    $display("known=%h/%h/%h", entries[17'h00035], entries[-17'sd3], entries[17'h00075]);
    $finish(0);
  end
endmodule
