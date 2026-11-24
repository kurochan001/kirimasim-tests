/*
:name: test_bind_scope_list_resolves_indexed_generate_hierarchies
:description: A scope bind reaches every instance while its indexed target list reaches only the selected generate branches
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.11 A.1.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_bind_scope_list_resolves_indexed_generate_hierarchies.expected
*/
module scoped_monitor #(int DELTA = 0)(input wire [7:0] source, output wire [7:0] result);
  assign result = source + 8'(DELTA);
endmodule

module indexed_bind_target #(int ID = 0);
  wire [7:0] data = 8'(ID);
  wire [7:0] all_value, selected;
endmodule

module test_bind_scope_list_resolves_indexed_generate_hierarchies;
  for (genvar i = 0; i < 3; ++i) begin : bank
    indexed_bind_target #(11 * (i + 1)) device();
  end

  bind indexed_bind_target
      scoped_monitor #(1) every_instance(.source(data), .result(all_value));
  bind indexed_bind_target:
      test_bind_scope_list_resolves_indexed_generate_hierarchies.bank[0].device,
      test_bind_scope_list_resolves_indexed_generate_hierarchies.bank[2].device
      scoped_monitor #(40) listed_only(.source(data), .result(selected));

  initial begin
    #1;
    $display("every=%0d %0d %0d", bank[0].device.all_value,
             bank[1].device.all_value, bank[2].device.all_value);
    $display("listed=%0d middle-undriven=%b %0d", bank[0].device.selected,
             bank[1].device.selected === 'z, bank[2].device.selected);
  end
endmodule
