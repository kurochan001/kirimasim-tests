/*
:name: test_stream_unpack_dynamic_width_into_descending_fixed_array
:description: A run-time descending streaming range replaces just the selected fixed array entries
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stream_unpack_dynamic_width_into_descending_fixed_array.expected
*/
module test_stream_unpack_dynamic_width_into_descending_fixed_array;
  byte values [4:1];
  int start_index, count;
  initial begin
    values[4] = 8'h11;
    values[3] = 8'h22;
    values[2] = 8'h33;
    values[1] = 8'h44;
    if (!$value$plusargs("stream_count=%d", count)) count = 2;
    start_index = 3;
    {>>{values with [start_index -: count]}} = 16'ha1b2;
    $display("bytes=%02h/%02h/%02h/%02h", values[4], values[3], values[2], values[1]);
  end
endmodule
