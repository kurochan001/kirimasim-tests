/*
:name: test_interface_port_default_ref_and_inout_access
:description: Through an interface port without a modport, modules write and read a variable of the interface by reference and drive and read a net of it as an inout (IEEE 1800-2023 Section 25.3.2)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_port_default_ref_and_inout_access.expected
*/
// IEEE 1800-2023 §25.3.2: when an interface is referenced as a port, its
// variables are accessed as ref and its nets as inout. The interface rdi_bus
// has the variable v and the wor net w, and every module below takes it as a
// port with no modport.
//   Variable: p1 writes v = 5 at time 1 and p2 writes v = 9 at time 3, each
//   reading v back at once. The top reads bus.v at 2 and 4 (5, then 9), and
//   p1 reads v again at 5 and sees the value p2 wrote (9): all of them access
//   the one variable of the interface.
//   Net: d1 and d0 each drive w with a continuous assignment from their
//   input en, and w is the wired OR of the two. The top sets the enables at
//   10, 20, 30 and 40 and reads w one step later (0, 1, 1, 1 for d1 = 0, 1,
//   0, 1 and d0 = 0, 0, 1, 1); d0 reads w through its port at 22, while only
//   d1 drives it (1).
// Oracle checks: Icarus Verilog 13.0 does not support interface ports; the
// 5.052 release of Verilator prints 0 at 31, keeping only the driver of d1 on
// the wor net w.

interface rdi_bus;
  logic [7:0] v;
  wor w;
endinterface

module rdi_put #(parameter logic [7:0] VAL = 8'd0, parameter int AT = 0, parameter int AGAIN = 0)
                (rdi_bus b);
  initial begin
    #AT b.v = VAL;
    $display("%0d: wrote v=%0d, reads v=%0d", AT, VAL, b.v);
    if (AGAIN > 0) begin
      #(AGAIN - AT) $display("%0d: reads v=%0d", AGAIN, b.v);
    end
  end
endmodule

module rdi_drive #(parameter int SHOW = 0) (rdi_bus b, input logic en);
  assign b.w = en;
  initial if (SHOW > 0) #SHOW $display("%0d: driver reads w=%0d", SHOW, b.w);
endmodule

module test_interface_port_default_ref_and_inout_access;
  rdi_bus bus ();
  logic en1 = 1'b0, en0 = 1'b0;
  rdi_put #(.VAL(8'd5), .AT(1), .AGAIN(5)) p1 (.b(bus));
  rdi_put #(.VAL(8'd9), .AT(3)) p2 (.b(bus));
  rdi_drive d1 (.b(bus), .en(en1));
  rdi_drive #(.SHOW(22)) d0 (.b(bus), .en(en0));
  initial begin
    #2 $display("2: top reads v=%0d", bus.v);
    #2 $display("4: top reads v=%0d", bus.v);
    #7 $display("11: w=%0d", bus.w);
    #9 en1 = 1'b1;
    #1 $display("21: w=%0d", bus.w);
    #9 en1 = 1'b0;
    en0 = 1'b1;
    #1 $display("31: w=%0d", bus.w);
    #9 en1 = 1'b1;
    #1 $display("41: w=%0d", bus.w);
  end
endmodule
