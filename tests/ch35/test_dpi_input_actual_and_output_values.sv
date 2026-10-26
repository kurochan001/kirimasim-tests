/*
:name: test_dpi_input_actual_and_output_values
:description: a foreign function that writes through the pointers of its input formals does not change the actual arguments of the imported function, while the values it writes to an output argument reach SystemVerilog (IEEE 1800-2023 Sections 35.5.1.2 and 35.6.1)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.1.2 35.6.1 35.2.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_input_actual_and_output_values.c
:expected_stdout: @test_dpi_input_actual_and_output_values.expected
*/
// IEEE 1800-2023 §35.5.1.2: foreign code is not to modify the input formals of
// an imported function, and even if it changes them internally the actual
// arguments outside the call shall remain unchanged. §35.6.1: an output
// argument carries the value the foreign code writes back.
//
// The C function overwrites the int formal, the bytes of the packed bit vector
// and the value and x/z bits of the packed logic vector, and writes 99 to the
// output. The test prints the actual arguments after the call: the int and the
// two vectors still have the values they had before (11, 5a and 1001), and the
// output has 99.

module test_dpi_input_actual_and_output_values;
  import "DPI-C" function void change_inputs(input int i, input bit [7:0] v,
      input logic [3:0] l, output int o);

  initial begin
    int iv = 11;
    bit [7:0] bv = 8'h5A;
    logic [3:0] lv = 4'b1001;
    int ov;
    change_inputs(iv, bv, lv, ov);
    $display("inputs i=%0d v=%h l=%b output=%0d", iv, bv, lv, ov);
  end
endmodule
