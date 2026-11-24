/*
:name: test_vpi_resolved_net_type_strings_match_distinct_interconnect_merges
:description: VPI returns both the declared interconnect type and the distinct resolved wand and wor subtypes as integers and names
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3.2 37.16 23.3.3.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_resolved_net_type_strings_match_distinct_interconnect_merges.c
:expected_stdout: @test_vpi_resolved_net_type_strings_match_distinct_interconnect_merges.expected
*/
module resolved_wand_driver(input wire source, inout wand port_n);
  assign port_n = source;
endmodule

module resolved_wor_driver(input wire source, inout wor port_n);
  assign port_n = source;
endmodule

module resolved_wand_probe(inout wand port_n, output wire result);
  assign result = port_n;
endmodule

module resolved_wor_probe(inout wor port_n, output wire result);
  assign result = port_n;
endmodule

module test_vpi_resolved_net_type_strings_match_distinct_interconnect_merges;
  bit second = 0;
  interconnect and_link, or_link;
  wire result_and, result_or;
  resolved_wand_driver and_a(1'b1, and_link), and_b(second, and_link);
  resolved_wor_driver or_a(1'b1, or_link), or_b(second, or_link);
  resolved_wand_probe and_probe(and_link, result_and);
  resolved_wor_probe or_probe(or_link, result_or);

  initial begin
    #1;
    $display("resolved values=%b %b", result_and, result_or);
    $vt_resolved_net_names;
    second = 1;
    #1;
    $display("after update=%b %b", result_and, result_or);
  end
endmodule
