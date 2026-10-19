/*
:name: test_force_part_select_of_net
:description: force and release on constant bit-selects and part-selects of a net, including indexed part-selects (IEEE 1800-2023 Section 10.6.2)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.6.2 11.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_force_part_select_of_net.expected
*/
// IEEE 1800-2023 §10.6.2: a force can apply to a constant bit-select or a
// constant part-select of a vector net. Only those bits are forced; the
// other bits keep following the drivers of the net. An indexed part-select
// whose base is a constant (11.5.1), such as n[4+:4], is a constant
// part-select too. A release gives the forced bits back to the drivers.

module test_force_part_select_of_net;
  logic [7:0] src = 8'h00;
  wire [7:0] n1 = src, n2 = src, n3 = src, n4 = src;

  initial begin
    #1;
    force n1[3] = 1'b1;
    force n2[7:4] = 4'hf;
    force n3[4+:4] = 4'hf;
    force n4[3-:4] = 4'hf;
    #1 $display("forced: %h %h %h %h", n1, n2, n3, n4);
    src = 8'h81;
    #1 $display("src=81: %h %h %h %h", n1, n2, n3, n4);
    release n1[3];
    release n2[7:4];
    release n3[4+:4];
    release n4[3-:4];
    #1 $display("released: %h %h %h %h", n1, n2, n3, n4);
  end
endmodule
