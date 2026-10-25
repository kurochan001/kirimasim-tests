/*
:name: test_interface_modport_forms
:description: One modport declaration with two modport items, each with simple ports, attributes, imported tasks and functions by prototype and by identifier, and a clocking declaration, with the directions and subroutines they give the connected modules (IEEE 1800-2023 Sections 25.5 and 25.7)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.5 25.5.4 25.7 A.2.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_modport_forms.expected
*/
// IEEE 1800-2023 25.5, 25.5.4, 25.7 and A.2.9: modport_declaration is
// modport, one or more comma-separated modport_items and a semicolon; a
// modport_item is an identifier and a parenthesized nonempty list of
// modport_ports_declarations, each with optional attributes, and each of
// those is a simple port declaration, a task/function port declaration or a
// clocking declaration. A simple port is a direction and one or more port
// identifiers or dot identifiers with an optional expression; a
// task/function port is import or export and method prototypes or
// subroutine identifiers; a clocking declaration is clocking and the
// clocking block name.
//   - master drives data and valid, imports bump and add by prototype and
//     names cb,
//   - slave reads data and valid, imports bump and add by identifier and
//     names cb.
// The master calls p.add(4), which returns 5, and p.bump(p.add(4)), so the
// interface count is 3 + 5 = 8.
// The parent drives data = 8'h0F, so valid is 1.
//
// Icarus Verilog 13.0 does not support these modports. Verilator 5.052 does
// not accept this design.

interface mp_bus (input logic clk);
  logic [7:0] data;
  logic valid;
  int count;

  clocking cb @(posedge clk);
    input data;
    output valid;
  endclocking

  function automatic int add(input int x);
    return x + 1;
  endfunction

  task automatic bump(input int x);
    count = count + x;
  endtask

  always_comb valid = (data != 8'h0);
  modport master (
    (* keep *) output data, output valid,
    import task bump(input int x),
    import function int add(input int x),
    clocking cb
  ), slave (
    input data, input valid,
    import bump, import add,
    clocking cb
  );
endinterface

module mp_master (mp_bus.master p, input logic [7:0] d);
  initial begin
    p.data = d;
    p.bump(3);
    p.bump(p.add(4));
  end
endmodule

module test_interface_modport_forms;
  logic clk = 1'b0;
  logic [7:0] d = 8'h0F;
  mp_bus bus (.clk(clk));

  mp_master m (.p(bus.master), .d(d));

  initial begin
    #1 $display("data=%h valid=%b count=%0d", bus.data, bus.valid, bus.count);
  end
endmodule
