/*
:name: test_virtual_modport_handle_alias_and_null
:description: Two virtual modport handles can alias an interface and nulling one does not clear the other (IEEE 1800-2023 Section 25.9.2)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.9.2 25.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_virtual_modport_handle_alias_and_null.expected
*/
// IEEE 1800-2023 25.9.2 25.10: Member access through either valid handle
// reaches the same actual instance; virtual interface assignment copies the
// reference rather than interface data.
// Oracle checks: Icarus Verilog 13.0 does not build this case.

interface alias_bus;
  bit [7:0] data;
  modport writer(output data);
endinterface
module test_virtual_modport_handle_alias_and_null;
  alias_bus bus();
  virtual alias_bus.writer first_handle, second_handle;
  initial begin
    first_handle = bus; second_handle = first_handle;
    first_handle.data = 8'hc4; first_handle = null;
    $display("first_null=%0d second_value=%h", first_handle == null, second_handle.data);
  end
endmodule
