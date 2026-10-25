/*
:name: test_virtual_interface_data_type_forms
:description: A virtual interface data type written with and without the keyword interface, with a modport selected, with an actual parameter value, as a class property, as a constructor argument and as a variable input port, and the assignments and writes that each form allows (IEEE 1800-2023 Sections 25.9 and 25.9.2)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.9 25.9.2 A.2.2.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_virtual_interface_data_type_forms.expected
*/
// IEEE 1800-2023 A.2.2.1: a data type may be virtual, an optional interface
// keyword, an interface identifier, an optional parameter value assignment
// and an optional dot and modport name. 25.9: a virtual interface may select
// a modport as part of its type, and an interface instance with no modport
// selected may be assigned to a virtual interface that selects one.
//   - vv has the form without the interface keyword and v2 the form with it,
//     both select no modport and both see the same interface instance,
//   - h.plain is a class property of the first form, assigned from the
//     constructor argument that also has the first form,
//   - h.wport selects the writer modport, so it may write data,
//   - h.par has the actual parameter value 8 and reads the 8-bit data of the
//     parameterized interface instance,
//   - vif_reader has a variable input port of the virtual interface type and
//     copies data to its output.
// The writes leave bus.data at 8'h11, so the parent prints 11 for bus, vv,
// v2, plain and the port output, and c3 for the parameterized interface.
//
// Icarus Verilog 13.0 does not compile virtual interfaces as a class
// property or port type; Verilator 5.052 does not accept every form here.

interface vif_bus;
  logic [7:0] data;
  modport writer (output data);
endinterface

interface vif_par #(parameter int W = 4);
  logic [W-1:0] d;
endinterface

class vif_holder;
  virtual vif_bus plain;
  virtual interface vif_bus.writer wport;
  virtual vif_par #(8) par;

  function new(virtual vif_bus p);
    plain = p;
  endfunction
endclass

module vif_reader (input var virtual vif_bus v, output logic [7:0] seen);
  always_comb seen = v.data;
endmodule

module test_virtual_interface_data_type_forms;
  vif_bus bus ();
  vif_par #(8) pb ();
  vif_holder h;
  virtual vif_bus vv;
  virtual interface vif_bus v2;
  logic [7:0] seen;

  vif_reader u_reader (.v(bus), .seen(seen));

  initial begin
    vv = bus;
    vv.data = 8'h5A;
    v2 = bus;
    h = new(bus);
    h.par = pb;
    h.par.d = 8'hC3;
    h.wport = bus;
    h.wport.data = 8'h11;
    #1 $display("data=%h vv=%h v2=%h plain=%h par=%h seen=%h",
                bus.data, vv.data, v2.data, h.plain.data, pb.d, seen);
  end
endmodule
