/*
:name: test_interface_ports_of_module_program_and_interface
:description: Two instances of one interface are each connected to interface ports of a module, a program and another interface; through its modport the module drives an output and calls an imported task, the program reads inputs and calls an imported function, and every access reaches the instance connected to that port (IEEE 1800-2023 Section 3.5)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.5 25.3 25.5 25.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_ports_of_module_program_and_interface.expected
*/
// IEEE 1800-2023 §3.5: an interface is a named bundle of nets or variables;
// an instance of it can be connected to interface ports of instantiated
// modules, programs and interfaces, which access it as one item and reach
// its members where needed. Its variables and subroutines are referenced
// relative to the instance, so a connected module calls the subroutines of
// the instance it is connected to. A modport gives the directions as seen
// from the module (§25.5) and lists the subroutines the module imports
// (§25.7).
// bus_a and bus_b are two instances of conn_bus_if:
// - the module conn_producer, through the modport producer (output valid,
//   import send), sets valid at time 1 and then calls send every 10 time
//   units; prod_a sends 8'h10 and 8'h11 to bus_a, prod_b sends 8'h20, 8'h21
//   and 8'h22 to bus_b; send writes data and counts the calls in sent;
// - the program conn_consumer has two ports with the modport consumer
//   (input data, input valid, import peek) connected to bus_a and bus_b and
//   prints both at times 5, 15 and 25, between the sends; the end of its
//   initial procedure at time 25 ends the simulation (§24.3);
// - mon_a and mon_b are instances of the interface conn_monitor_if whose
//   interface port is connected to bus_a and bus_b; each copies data with a
//   continuous assignment and returns sent from a function. The top module
//   reads them at time 24.
// Each value comes from one instance only, so a connection or member access
// that reached the other instance would print another value.
// Icarus Verilog 13.0 does not support subroutines in modports ("sorry:
// modport task/function ports are not yet supported").

`timescale 1ns/1ns

interface conn_bus_if;
  logic [7:0] data;
  logic valid = 1'b0;
  int sent = 0;

  task automatic send(input logic [7:0] v);
    data = v;
    sent++;
  endtask

  function automatic logic [7:0] peek();
    return data;
  endfunction

  modport producer (output valid, import send);
  modport consumer (input data, input valid, import peek);
endinterface

module conn_producer #(parameter logic [7:0] BASE = 8'h00, parameter int COUNT = 1)
                      (conn_bus_if.producer p);
  initial begin
    #1 p.valid = 1'b1;
    for (int i = 0; i < COUNT; i++) begin
      p.send(BASE + 8'(i));
      #10;
    end
  end
endmodule

program conn_consumer (conn_bus_if.consumer ca, conn_bus_if.consumer cb);
  function void show();
    $display("t=%0t a: valid=%b data=%h peek=%h | b: valid=%b data=%h peek=%h", $time,
             ca.valid, ca.data, ca.peek(), cb.valid, cb.data, cb.peek());
  endfunction

  initial begin
    #5 show();
    #10 show();
    #10 show();
  end
endprogram

interface conn_monitor_if (conn_bus_if b);
  logic [7:0] last;

  assign last = b.data;

  function automatic int seen();
    return b.sent;
  endfunction
endinterface

module test_interface_ports_of_module_program_and_interface;
  conn_bus_if bus_a();
  conn_bus_if bus_b();

  conn_producer #(.BASE(8'h10), .COUNT(2)) prod_a(.p(bus_a));
  conn_producer #(.BASE(8'h20), .COUNT(3)) prod_b(.p(bus_b));
  conn_consumer cons(.ca(bus_a), .cb(bus_b));
  conn_monitor_if mon_a(.b(bus_a));
  conn_monitor_if mon_b(.b(bus_b));

  initial #24 $display("t=%0t monitors: a sent=%0d last=%h | b sent=%0d last=%h", $time,
                       mon_a.seen(), mon_a.last, mon_b.seen(), mon_b.last);
endmodule
