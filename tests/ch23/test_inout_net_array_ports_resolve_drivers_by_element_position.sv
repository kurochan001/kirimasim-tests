/*
:name: test_inout_net_array_ports_resolve_drivers_by_element_position
:description: An inout array port resolves both drivers by element position even when the connected range has opposite orientation
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.3 23.3.3.1 7.6
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_inout_net_array_ports_resolve_drivers_by_element_position.expected
*/
`timescale 1ns/1ns
module position_inout(input bit enable_driver, inout wire [7:0] bus [3:2],
                      output wire [15:0] local_word);
  assign bus[3] = enable_driver ? 8'h00 : 8'hzz;
  assign bus[2] = enable_driver ? 8'ha4 : 8'hzz;
  assign local_word = {bus[3], bus[2]};
endmodule

module test_inout_net_array_ports_resolve_drivers_by_element_position;
  bit drive_outer = 1, drive_inner = 0;
  wire [7:0] matching [3:2], reversed [8:9];
  wire [15:0] matched_local, reversed_local;

  assign matching[3] = drive_outer ? 8'hff : 8'hzz;
  assign matching[2] = drive_outer ? 8'ha4 : 8'hzz;
  assign reversed[8] = drive_outer ? 8'hff : 8'hzz;
  assign reversed[9] = drive_outer ? 8'ha4 : 8'hzz;
  position_inout same(drive_inner, matching, matched_local);
  position_inout other(drive_inner, reversed, reversed_local);

  task automatic observe(input string label_text);
    $display("%s outer=%h%h/%h%h inner=%h/%h", label_text, matching[3], matching[2],
             reversed[8], reversed[9], matched_local, reversed_local);
  endtask

  initial begin
    #1 observe("outer");
    drive_inner = 1;
    #1 observe("conflict");
    drive_outer = 0;
    #1 observe("inner");
    drive_inner = 0;
    #1 observe("released");
    $finish(0);
  end
endmodule
