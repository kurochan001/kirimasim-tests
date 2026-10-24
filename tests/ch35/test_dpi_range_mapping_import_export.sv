/*
:name: test_dpi_range_mapping_import_export
:description: An ascending packed range is normalized with its left bit as the most significant bit, two packed dimensions are linearized into one, and unpacked elements are laid out from the lowest index up, in the same way for an imported function called from SystemVerilog and an exported function called from C (IEEE 1800-2023 Section 35.5.6, H.7.6)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6 H.7.6 H.7.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_range_mapping_import_export.c
:expected_stdout: @test_dpi_range_mapping_import_export.expected
*/
// IEEE 1800-2023 §35.5.6: packed and unpacked arrays of bit and int may be
// formal arguments. H.7.6: for C, a packed range [L:R] becomes [abs(L-R):0],
// with the bit at L as bit abs(L-R) and the bit at R as bit 0, so p[3:10] is
// bit 7 (p[3]) down to bit 0 (p[10]); several packed dimensions are first
// made into one, so in q[1:0][3:0] the element q[1] is bits 7 to 4. An
// unpacked range [L:R] is laid out with the element of index min(L,R) at C
// index 0 and that of max(L,R) at C index abs(L-R), so u[4:1] has u[1] first
// and o[2:5] has o[2] first. H.7.6 applies these rules to calls in both
// directions. H.7.7: the packed values arrive as svBitVecVal chunks.
//
// The design calls the import c_import, which prints what C sees and fills
// o; the design prints o. Then c_call_export calls the export sv_export with
// C values; sv_export prints what SystemVerilog sees and fills its output o,
// which C prints.

module test_dpi_range_mapping_import_export;
  import "DPI-C" function void c_import(input bit [3:10] p, input bit [1:0][3:0] q,
                                        input int u [4:1], output int o [2:5]);
  import "DPI-C" context function void c_call_export();
  export "DPI-C" function sv_export;

  function void sv_export(input bit [3:10] p, input bit [1:0][3:0] q, input int u [4:1],
                          output int o [2:5]);
    $display("sv_export: p[3] %b p[4] %b p[9] %b p[10] %b, q[1] %h q[0] %h", p[3], p[4], p[9],
             p[10], q[1], q[0]);
    $display("sv_export: u[1] %0d u[2] %0d u[3] %0d u[4] %0d", u[1], u[2], u[3], u[4]);
    o[2] = 7;
    o[3] = 8;
    o[4] = 9;
    o[5] = 6;
  endfunction

  bit [3:10] p;
  bit [1:0][3:0] q;
  int u [4:1];
  int o [2:5];

  initial begin
    p = 8'b1000_0011;
    q[1] = 4'ha;
    q[0] = 4'h5;
    u[4] = 40;
    u[3] = 30;
    u[2] = 20;
    u[1] = 10;
    c_import(p, q, u, o);
    $display("c_import: o[2] %0d o[3] %0d o[4] %0d o[5] %0d", o[2], o[3], o[4], o[5]);
    c_call_export();
  end
endmodule
