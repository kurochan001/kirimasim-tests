/*
:name: test_interface_port_parameter_per_instance
:description: Two instances of a module whose interface ports are connected to differently parameterized interfaces each see their own widths and types (IEEE 1800-2023 Section 25.3)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.3 25.5 6.18
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_port_parameter_per_instance.expected
*/
// IEEE 1800-2023 §25.3: a generic interface port takes the interface instance
// connected to it, with that instance's parameter values. Two instances of
// one module connected to ifc #(8) and to ifc #(32) therefore see members of
// 8 and of 32 bits, also through a type of the interface named by the port,
// typedef p.s_t loc_t (6.18), and '1 written to p.d fills the width of the
// instance's own member.

interface ifc #(int W = 1);
  logic [W-1:0] d;
  typedef struct packed {
    logic [W-1:0] f;
  } s_t;
  s_t s;
endinterface

module width_user (ifc p);
  typedef p.s_t loc_t;
  loc_t lv;
  int bd, bs, bl;
  initial begin
    bd = $bits(p.d);
    bs = $bits(p.s.f);
    bl = $bits(lv);
    p.d = '1;
  end
endmodule

module test_interface_port_parameter_per_instance;
  ifc #(8) i8 ();
  ifc #(32) i32 ();
  width_user a (i8);
  width_user b (i32);

  initial begin
    #1;
    $display("a: %0d %0d %0d, i8.d=%h", a.bd, a.bs, a.bl, i8.d);
    $display("b: %0d %0d %0d, i32.d=%h", b.bd, b.bs, b.bl, i32.d);
  end
endmodule
