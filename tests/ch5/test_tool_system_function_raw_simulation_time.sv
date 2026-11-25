/*
:name: test_tool_system_function_raw_simulation_time
:description: Icarus simtime returns the same raw tick count in scopes with different time units while time scales to each scope
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.6.3 20.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_tool_system_function_raw_simulation_time.expected
*/
// The standard $time is the local-unit control. Icarus's $simtime()
// is a tool extension that reports ticks in the design precision.
`timescale 10ns/1ps
module extension_coarse_scope;
  task automatic report_clocks();
    $display("coarse local=%0d raw=%0d", $time, $simtime());
  endtask
endmodule

`timescale 1ns/1ps
module test_tool_system_function_raw_simulation_time;
  extension_coarse_scope u();
  initial begin
    #20;
    $display("fine local=%0d raw=%0d", $time, $simtime());
    u.report_clocks();
    #30;
    $display("fine local=%0d raw=%0d", $time, $simtime());
    u.report_clocks();
  end
endmodule
