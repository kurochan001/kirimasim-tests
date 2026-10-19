/*
:name: test_virtual_interface_modport
:description: A class drives interface instances through a virtual interface of a modport type, and can be pointed at another instance (IEEE 1800-2023 Section 25.9)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.9 25.9.2 25.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_virtual_interface_modport.expected
*/
// IEEE 1800-2023 §25.9: a virtual interface variable holds a reference to an
// interface instance, can be stored in a class, and can be assigned another
// instance later; its type can name a modport (25.9.2). §25.10: the members of
// the interface are reached through it with dot notation, and the writes land
// in the instance it refers to.

interface vim_bus;
  logic [7:0] d = 0;
  modport drv (output d);
endinterface

class vim_driver;
  virtual vim_bus.drv vif;
  function new(virtual vim_bus.drv v);
    vif = v;
  endfunction
  function void send(logic [7:0] x);
    vif.d = x;
  endfunction
endclass

module test_virtual_interface_modport;
  vim_bus b0();
  vim_bus b1();
  vim_driver d0, d1;

  initial begin
    d0 = new(b0);
    d1 = new(b1);
    d0.send(8'h01);
    d1.send(8'h02);
    #1 $display("b0.d=%h b1.d=%h", b0.d, b1.d);
    d0.vif = b1;
    d0.send(8'h03);
    #1 $display("after pointing d0 at b1: b0.d=%h b1.d=%h", b0.d, b1.d);
  end
endmodule
