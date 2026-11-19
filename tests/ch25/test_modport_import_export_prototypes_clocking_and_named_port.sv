/*
:name: test_modport_import_export_prototypes_clocking_and_named_port
:description: modports with attributed simple ports, an explicitly named port expression, imported and exported subroutines by name and by prototype and a clocking block, where one subroutine is defined in the interface and two in a connected module (IEEE 1800-2023 Section 25.3)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.3 25.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_modport_import_export_prototypes_clocking_and_named_port.expected
*/
// IEEE 1800-2023 §25.3: a modport lists ports with a direction, either simple
// names or explicitly named expressions .name(expression), subroutines that
// are imported or exported, each given by its name or by its prototype, and
// clocking blocks; each item may carry attributes. §25.7: a subroutine used
// through an interface may be defined in the interface itself or in a module
// connected to it; a modport that imports a subroutine from another module
// gives its full prototype.
//
// The interface bus_if defines the function twice. Its modport target exports
// the task store, by prototype, and the function get_stored, by name; both are
// defined in the module tgt connected to that modport. Its modport initiator
// has the attributed simple ports clk and data, imports twice by name and
// store and get_stored by prototype, and lists the clocking block cb. The
// modport target has the explicitly named port low, the low four bits of
// data.
//
// At time 0 the module ini sets data to 8'h5a, calls store(twice(21)), which
// runs in tgt and stores 42, and reads it back with get_stored(). At the
// posedge at 5 it reads data through cb, sampled just before the edge
// (5a). At 10 tgt prints the value it stored and b.low, which is 4'ha.
//
// Icarus Verilog 13.0 does not support these modports. Verilator 5.054
// rejects the export of get_stored by name, which 25.7 allows; with a
// prototype there and with .low(data) in a copy, it still resolves the name
// stored in the body of b.store in the interface instead of in tgt, as the
// example of 25.7.2 does, and stops.

`timescale 1ns/1ns

interface bus_if (input logic clk);
  logic [7:0] data;

  function automatic int twice(int v);
    return 2 * v;
  endfunction

  clocking cb @(posedge clk);
    input data;
  endclocking

  modport initiator ((* role = "clock" *) input clk, (* role = "bus" *) output data,
                     import twice,
                     import task store(input int v),
                     import function int get_stored(),
                     clocking cb);
  modport target (input .low(data[3:0]),
                  export task store(input int v),
                  export get_stored);
endinterface

module tgt (bus_if.target b);
  int stored = -1;

  task b.store(input int v);
    stored = v;
  endtask

  function int b.get_stored();
    return stored;
  endfunction

  initial #10 $display("tgt: stored %0d, low %h", stored, b.low);
endmodule

module ini (bus_if.initiator b);
  initial begin
    b.data = 8'h5a;
    b.store(b.twice(21));
    $display("ini: get_stored() = %0d", b.get_stored());
    @(b.cb);
    $display("ini: cb.data at %0t = %h", $time, b.cb.data);
  end
endmodule

module test_modport_import_export_prototypes_clocking_and_named_port;
  logic clk = 0;
  always #5 clk = ~clk;

  bus_if bi (clk);
  ini i0 (bi);
  tgt t0 (bi);

  initial #20 $finish;
endmodule
