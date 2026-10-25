/*
:name: test_sscanf_v_strength_values
:description: $sscanf %v reads a three-character strength, a mnemonic or two digits followed by the value, and stores its logic value 0, 1, x or z in an integral variable (IEEE 1800-2023 Section 21.3.4.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3 21.2.1.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_sscanf_v_strength_values.expected
*/
// IEEE 1800-2023 §21.3.4.3, Table 21-7: %v matches a net strength of three
// characters as written by %v (21.2.1.4): a two-letter strength mnemonic or
// two strength digits, then the value 0, 1, X or Z. Read into an integral
// variable, it is converted to its 4-state value. St1, We0, HiZ and StX give
// 1, 0, z and x; the digit forms 520 and 65X give 0 and x; and two strengths
// separated by white space are two fields. Icarus Verilog 13.0 and the 5.052
// release of Verilator do not support %v in $sscanf.

module test_sscanf_v_strength_values;
  logic v, w;
  int n;

  initial begin
    n = $sscanf("St1", "%v", v); $display("St1: n=%0d %b", n, v);
    n = $sscanf("We0", "%v", v); $display("We0: n=%0d %b", n, v);
    n = $sscanf("HiZ", "%v", v); $display("HiZ: n=%0d %b", n, v);
    n = $sscanf("StX", "%v", v); $display("StX: n=%0d %b", n, v);
    n = $sscanf("520", "%v", v); $display("520: n=%0d %b", n, v);
    n = $sscanf("65X", "%v", v); $display("65X: n=%0d %b", n, v);
    n = $sscanf("Pu1 Sm0", "%v %v", v, w);
    $display("Pu1 Sm0: n=%0d %b %b", n, v, w);
  end
endmodule
