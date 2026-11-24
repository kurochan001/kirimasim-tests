/*
:name: test_partly_unknown_wide_delay_resumes_before_nonblocking_updates
:description: A high unknown bit in a 64-bit delay makes the whole runtime delay zero and resumes before nonblocking updates
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.1 4.4.2.3 4.4.2.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_partly_unknown_wide_delay_resumes_before_nonblocking_updates.expected
*/
`timescale 1ns/1ns
module test_partly_unknown_wide_delay_resumes_before_nonblocking_updates;
  int marker;

  task automatic show(input string label_text, input logic [63:0] delay_value);
    time started;
    marker = 3;
    marker <= 9;
    started = $time;
    #(delay_value);
    $display("%s elapsed=%0d marker=%0d", label_text, $time - started, marker);
    #1 $display("%s next marker=%0d", label_text, marker);
  endtask

  initial begin
    #2;
    show("x-high", 64'hx0000000_00000007);
    show("z-high", 64'h000000z0_00000007);
    show("x-low", 64'h00000000_000000x7);
    show("known", 64'd7);
    $finish(0);
  end
endmodule
