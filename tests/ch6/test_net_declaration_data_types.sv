/*
:name: test_net_declaration_data_types
:description: A net can have any 4-state integral data type, a typedef or a packed structure, a net without one is logic, and undriven nets hold z in every bit (IEEE 1800-2023 Section 6.7.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.7.1 6.11.1 7.2.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_net_declaration_data_types.expected
*/
// IEEE 1800-2023 §6.7.1: a net may be declared with any 4-state integral data
// type, such as a typedef of logic or a packed structure (7.2.1), whose members
// can be selected; a net declared without a data type, or with only a range,
// is logic. The default value of a net is z. wn and ws are driven; w1 and w8
// are not.

module test_net_declaration_data_types;
  typedef logic [3:0] nibble_t;
  wire nibble_t wn;
  wire struct packed {logic ok; logic [2:0] count;} ws;
  wire w1;
  wire [7:0] w8;

  assign wn = 4'hc;
  assign ws = {1'b1, 3'd5};

  initial
    #1 $display("wn=%h ws.ok=%b ws.count=%0d w1=%b w8=%b bits=%0d,%0d,%0d", wn, ws.ok,
                ws.count, w1, w8, $bits(ws), $bits(w1), $bits(w8));
endmodule
