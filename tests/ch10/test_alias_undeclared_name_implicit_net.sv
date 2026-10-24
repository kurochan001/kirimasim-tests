/*
:name: test_alias_undeclared_name_implicit_net
:description: an identifier that is not declared when it appears in an alias statement becomes an implicit scalar net, joined to the other names of the alias (IEEE 1800-2023 Section 10.11)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.11 6.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_alias_undeclared_name_implicit_net.expected
*/
// IEEE 1800-2023 §10.11: an identifier in an alias statement that has not
// been declared gets an implicit net, by the same rules as a name connected
// to a port of a module instance (§6.10): a scalar net of the default net
// type, here wire.
// imp_r first appears in an alias with the declared scalar k_r, and reads the
// 1 that k_r is driven with. imp_d first appears in an alias with k_d, is then
// the target of a continuous assignment of 0, and k_d reads that 0. $bits
// shows that both implicit nets have one bit.
// Icarus Verilog 13.0 does not parse alias statements, and Verilator 5.052
// reports imp_r as undefined, so the expected output follows the clause alone.

module test_alias_undeclared_name_implicit_net;
  wire k_r, k_d;

  alias imp_r = k_r;
  assign k_r = 1'b1;

  alias imp_d = k_d;
  assign imp_d = 1'b0;

  initial begin
    #1;
    $display("imp_r=%b k_d=%b", imp_r, k_d);
    $display("bits: imp_r=%0d imp_d=%0d", $bits(imp_r), $bits(imp_d));
  end
endmodule
