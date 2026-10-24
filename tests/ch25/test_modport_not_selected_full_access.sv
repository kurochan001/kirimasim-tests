/*
:name: test_modport_not_selected_full_access
:description: an interface with modports can be connected without selecting one, and the module then has inout access to its nets and ref access to its variables (IEEE 1800-2023 Section 25.5)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_modport_not_selected_full_access.expected
*/
// IEEE 1800-2023 §25.5: declaring modports in an interface does not oblige
// any user to select one. When neither the module header nor the port
// connection names a modport, all nets of the interface are accessible as
// inout and all variables as ref.
// Interface mo_if declares the modports rd, which makes n and v inputs,
// and wr. Module mo_user takes an mo_if port without a modport: it drives
// the net n with a continuous assignment and reads it back, and writes and
// reads the variable v, which rd alone would not allow. The top module
// sees the same values through the instance.

interface mo_if;
  wire [7:0] n;
  logic [7:0] v;
  modport rd (input n, input v);
  modport wr (output n, output v);
endinterface

module mo_user (mo_if p);
  assign p.n = 8'h3c;
  initial begin
    #1 p.v = 8'h5a;
    #1 $display("module: n=%h v=%h", p.n, p.v);
  end
endmodule

module test_modport_not_selected_full_access;
  mo_if bus ();
  mo_user u (.p(bus));
  initial #3 $display("instance: n=%h v=%h", bus.n, bus.v);
endmodule
