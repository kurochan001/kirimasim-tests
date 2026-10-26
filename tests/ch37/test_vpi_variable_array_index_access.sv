/*
:name: test_vpi_variable_array_index_access
:description: A two-dimensional unpacked array variable is indexed with vpi_handle_by_multi_index, its elements are read with vpi_get_value and written with vpi_put_value, and a bit of a packed vector variable is indexed and written the same way (IEEE 1800-2023 Section 37.17)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.17 38.19 38.20 38.15 38.34
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_variable_array_index_access.c
:expected_stdout: @test_vpi_variable_array_index_access.expected
*/
// IEEE 1800-2023 §37.17: variables support access by index and by multiple
// indices, and vpi_get_value and vpi_put_value where the kind-specific value
// property is defined (37.17 diagram); an unpacked array element and a bit of
// a packed vector are such objects. §38.20: vpi_handle_by_multi_index takes
// the leftmost index first, so {1,2} is m[1][2] and {0,0} is m[0][0].
// §38.15 and §38.34: vpi_get_value with vpiIntVal reads the element and
// vpi_put_value with vpiNoDelay writes it at once. The design prints the
// values it wrote, so a write through VPI and a read through the variable are
// compared.

`timescale 1ns/1ns

module test_vpi_variable_array_index_access;
  int m [0:1][0:2];
  logic [3:0] pk = 4'b1010;

  initial begin
    m[0][0] = 10; m[0][1] = 11; m[0][2] = 12;
    m[1][0] = 20; m[1][1] = 21; m[1][2] = 22;
    $vt_idx;
    #1 $display("m[0][2]=%0d m[1][2]=%0d pk=%b", m[0][2], m[1][2], pk);
  end
endmodule
