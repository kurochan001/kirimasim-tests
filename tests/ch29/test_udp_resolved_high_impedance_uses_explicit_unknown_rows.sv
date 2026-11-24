/*
:name: test_udp_resolved_high_impedance_uses_explicit_unknown_rows
:description: A resolved high-impedance input takes the same explicit unknown table rows as an unknown input
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.3.5 29.5 29.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_udp_resolved_high_impedance_uses_explicit_unknown_rows.expected
*/
`timescale 1ns/1ns
primitive udp_select_row(q, data, mode);
  output q;
  input data, mode;
  table
    0 0 : 0;
    1 0 : 0;
    x 0 : 1;
    0 1 : 1;
    1 1 : 1;
    x 1 : 0;
  endtable
endprimitive

module test_udp_resolved_high_impedance_uses_explicit_unknown_rows;
  logic enable_driver = 0, driven = 0, mode = 0;
  logic explicit_x = 1'bx;
  wire resolved, selected, reference_selected;
  assign resolved = enable_driver ? driven : 1'bz;
  udp_select_row by_resolution(selected, resolved, mode);
  udp_select_row by_unknown(reference_selected, explicit_x, mode);

  task automatic sample;
    $display("mode=%b data=%b selected=%b x-control=%b", mode, resolved,
             selected, reference_selected);
  endtask

  initial begin
    #1 sample();
    mode = 1;
    #1 sample();
    enable_driver = 1;
    #1 sample();
    driven = 1;
    mode = 0;
    #1 sample();
    enable_driver = 0;
    #1 sample();
    $finish(0);
  end
endmodule
