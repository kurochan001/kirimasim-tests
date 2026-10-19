/*
:name: test_modport_import_tasks
:description: Tasks and functions of an interface used through modports that import them (IEEE 1800-2023 Section 25.7.2)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.7.2 25.7.1 25.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_modport_import_tasks.expected
*/
// IEEE 1800-2023 §25.7.1: an interface can declare tasks and functions that work
// on its signals. §25.7.2, §25.5: a modport lists them with import, and a module
// connected through that modport calls them as port.name(). The calls act on
// the variables of the interface instance the port is connected to.

interface mit_bus;
  logic [7:0] data;
  int writes = 0;

  task automatic write(input logic [7:0] v);
    data = v;
    writes++;
  endtask

  function automatic logic [7:0] peek();
    return data;
  endfunction

  modport master (import write, import peek);
  modport slave (import peek);
endinterface

module mit_master(mit_bus.master m);
  initial begin
    #1 m.write(8'h11);
    #1 m.write(8'h22);
  end
endmodule

module mit_slave(mit_bus.slave s, output logic [7:0] seen);
  initial #3 seen = s.peek();
endmodule

module test_modport_import_tasks;
  mit_bus bus();
  logic [7:0] seen;

  mit_master u_m(.m(bus));
  mit_slave  u_s(.s(bus), .seen(seen));

  initial #4 $display("writes=%0d data=%h seen=%h", bus.writes, bus.data, seen);
endmodule
