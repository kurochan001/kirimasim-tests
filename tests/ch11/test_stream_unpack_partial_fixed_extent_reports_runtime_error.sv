/*
:name: test_stream_unpack_partial_fixed_extent_reports_runtime_error
:description: An unpack range crossing a fixed array's upper bound reports an error and writes only the in-range elements
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stream_unpack_partial_fixed_extent_reports_runtime_error.expected
:expected_stderr_regex: (?im)^(?=[^\n]*\b(?:error|fatal)\b)(?=[^\n]*(?:unpack|stream|range|array))(?=[^\n]*(?:out of|outside|bounds|extent))[^\n]+
*/
module test_stream_unpack_partial_fixed_extent_reports_runtime_error;
  byte out_of_range [0:3] = '{8'h11, 8'h22, 8'h33, 8'h44};
  byte in_range [0:3] = '{8'h11, 8'h22, 8'h33, 8'h44};
  int base;

  initial begin
    base = 1;
    {>>{in_range with [base+:3]}} = 24'h81_82_83;
    $display("inside=%h%h%h%h", in_range[0], in_range[1], in_range[2], in_range[3]);

    base = 2;
    {>>{out_of_range with [base+:3]}} = 24'ha1_a2_a3;
    $display("crossing=%h%h%h%h",
             out_of_range[0], out_of_range[1], out_of_range[2], out_of_range[3]);
    $finish(0);
  end
endmodule
