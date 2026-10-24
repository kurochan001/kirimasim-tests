/*
:name: test_dpi_formal_integer_logic_time
:description: Formal arguments of type logic, integer and time pass between SystemVerilog and C in both directions, as inputs and outputs of imported functions and as inputs of an exported function, with their x and z bits (IEEE 1800-2023 Section 35.5.6)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6 H.7.3 H.7.7 H.8.7 H.8.8 H.10.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:dpi_c: @test_dpi_formal_integer_logic_time.c
:expected_stdout: @test_dpi_formal_integer_logic_time.expected
*/
// IEEE 1800-2023 §35.5.6: time, integer and scalar logic are among the
// permitted types of formal arguments of imported and exported subroutines.
// H.10.1: a scalar logic is an svLogic, sv_0 to sv_x being 0 to 3. H.7.3,
// H.7.7: integer and time are 4-state packed values in the canonical form,
// svLogicVecVal words with an aval and a bval word, 1 word for integer and 2
// for time, low bits first; in each bit, 0 is (0,0), 1 is (1,0), z is (0,1)
// and x is (1,1). They are passed by reference (H.8.7, H.8.8). The C code
// returns the codes of four logic inputs, sets a logic output to z, returns
// the two planes of the integer 'b10zx, sets an integer output to -128,
// returns the two words of a time input and sets a time output to 2**32 + 9.
// dpi_call_export, a context import, calls the exported sv_combine with the
// integer 30, the time 12 and the logic z, for which it returns 30 + 12 +
// 1000. Icarus Verilog 13.0 has no DPI, and Verilator 5.052 does not build
// the design, as it does not support z in an argument of a DPI call.

module test_dpi_formal_integer_logic_time;
  import "DPI-C" function int dpi_logic_code(input logic l);
  import "DPI-C" function void dpi_make_logic(output logic l);
  import "DPI-C" function void dpi_integer_planes(input integer i, output int a, output int b);
  import "DPI-C" function void dpi_make_integer(output integer i);
  import "DPI-C" function void dpi_time_words(input time t, output int lo, output int hi);
  import "DPI-C" function void dpi_make_time(output time t);
  import "DPI-C" context function int dpi_call_export();
  export "DPI-C" function sv_combine;

  function int sv_combine(input integer i, input time t, input logic l);
    return i + int'(t) + (l === 1'bz ? 1000 : 0);
  endfunction

  initial begin
    logic l;
    integer i;
    time t;
    int a, b, lo, hi;
    $display("logic inputs: %0d %0d %0d %0d", dpi_logic_code(1'b0), dpi_logic_code(1'b1),
             dpi_logic_code(1'bz), dpi_logic_code(1'bx));
    dpi_make_logic(l);
    $display("logic output: %b", l);
    i = 'b10zx;
    dpi_integer_planes(i, a, b);
    $display("integer input 'b10zx: aval %h, bval %h", a, b);
    dpi_make_integer(i);
    $display("integer output: %0d", i);
    t = 64'h0000_0005_0000_0007;
    dpi_time_words(t, lo, hi);
    $display("time input: low word %0d, high word %0d", lo, hi);
    dpi_make_time(t);
    $display("time output: %0d", t);
    $display("exported function: %0d", dpi_call_export());
  end
endmodule
