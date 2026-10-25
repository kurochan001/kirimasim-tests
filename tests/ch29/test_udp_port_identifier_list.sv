/*
:name: test_udp_port_identifier_list
:description: A combinational UDP declares three inputs in one udp_input_declaration, so the list of UDP port identifiers has three comma-separated entries, and the table selects the output from those three inputs (IEEE 1800-2023 Section 29.3.2)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.3.2 A.2.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_udp_port_identifier_list.expected
*/
// IEEE 1800-2023 A.2.3: list_of_udp_port_identifiers is one or more
// comma-separated port identifiers. 29.3.2: a UDP input declaration is input
// followed by that list, so one declaration can name all three inputs of the
// UDP, and the port list of the UDP header names the output first and the
// three inputs in the same order.
// udp_nand3 drives 0 only when all three inputs are 1 and 1 otherwise; the
// three printed groups set the inputs with a concatenation assignment and
// print the output after a delay.
//
// Icarus Verilog 13.0 produces these values. Verilator 5.052 does not
// support UDPs.

primitive udp_nand3 (y, a, b, c);
  output y;
  input a, b, c;
  table
    0 ? ? : 1;
    ? 0 ? : 1;
    ? ? 0 : 1;
    1 1 1 : 0;
  endtable
endprimitive

module test_udp_port_identifier_list;
  reg a, b, c;
  wire y;

  udp_nand3 u_nand (y, a, b, c);

  initial begin
    {a, b, c} = 3'b111;
    #1 $display("111: y=%b", y);
    {a, b, c} = 3'b110;
    #1 $display("110: y=%b", y);
    {a, b, c} = 3'b000;
    #1 $display("000: y=%b", y);
  end
endmodule
