/*
:name: test_string_ato_method_result_types
:description: atoi(), atohex(), atooct() and atobin() take no arguments and return a signed 32-bit integer, and atoreal() takes no arguments and returns real (IEEE 1800-2023 Sections 6.16.9 and 6.16.10)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.9 6.16.10 20.6.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_ato_method_result_types.expected
*/
// IEEE 1800-2023 §6.16.9: atoi(), atohex(), atooct() and atobin() have no
// arguments and return integer, a signed 32-bit type: the 32 one bits written
// in hexadecimal, octal or binary read back as -1, and a result below zero
// compares as negative. §6.16.10: atoreal() has no arguments and returns real,
// so the fraction of 2.5 is kept. $typename and $bits (§20.6.1) show the type
// of each call without evaluating it. Icarus Verilog 13.0 does not know
// atooct() and has no $typename (unsupported constructs).

module test_string_ato_method_result_types;
  string d = "123", h = "7f", o = "17", b = "101", r = "2.5";
  string hx = "ffffffff", oc = "37777777777", bn = "11111111111111111111111111111111";

  initial begin
    $display("types: %s %s %s %s %s", $typename(d.atoi()), $typename(h.atohex()),
             $typename(o.atooct()), $typename(b.atobin()), $typename(r.atoreal()));
    $display("bits: %0d %0d %0d %0d", $bits(d.atoi()), $bits(h.atohex()),
             $bits(o.atooct()), $bits(b.atobin()));
    $display("values: %0d %0d %0d %0d", d.atoi(), h.atohex(), o.atooct(), b.atobin());
    $display("all ones: %0d %0d %0d", hx.atohex(), oc.atooct(), bn.atobin());
    $display("negative: %0d %0d %0d", hx.atohex() < 0, oc.atooct() < 0, bn.atobin() < 0);
    $display("real: %0.2f doubled=%0.2f", r.atoreal(), r.atoreal() * 2);
  end
endmodule
