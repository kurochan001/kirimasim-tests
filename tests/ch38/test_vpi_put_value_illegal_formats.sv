/*
:name: test_vpi_put_value_illegal_formats
:description: vpi_put_value rejects a string value for a real variable and for a real system function call and a strength value for a vector, while the real and vector formats that the clause allows set the values (IEEE 1800-2023 Section 38.34)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.34 38.2 38.15
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_put_value_illegal_formats.c
:expected_stdout: @test_vpi_put_value_illegal_formats.expected
*/
// IEEE 1800-2023 §38.34: it is illegal to put a value in the vpiStringVal
// format to a real variable or to a system function call of type vpiRealFunc,
// and in the vpiStrengthVal format to a vector object. An illegal call is an
// error, which vpi_chk_error (38.2) reports directly after it, and the call
// sets no value. The same routine puts a real value to the real variable r, a
// vector value to v, and the return value of a real system function; those
// puts work and the values are printed. $vt_realfn(1) puts the real 3.25 on
// its call; $vt_realfn(0) puts a string there instead, so it returns the
// default 0, and the test prints the value it observed from C afterwards.

module test_vpi_put_value_illegal_formats;
  real r;
  logic [7:0] v;

  initial begin
    #1;
    $vt_values;
    $display("real variable after a real value: %0.2f", r);
    $display("vector after a vector value: %b", v);
    $display("real function with a legal real value: %0.2f", $vt_realfn(1));
    $display("real function with an illegal string value: %0.2f", $vt_realfn(0));
    $vt_illegal;
  end
endmodule
