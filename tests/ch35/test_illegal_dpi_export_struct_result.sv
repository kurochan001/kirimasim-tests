/*
:name: test_illegal_dpi_export_struct_result
:description: An exported function follows the result type rules of imported functions, so exporting a function whose result is an unpacked struct is an error (IEEE 1800-2023 Section 35.7)
:tags: ch35
:type: elaboration
:lrm: 1800-2023 35.7 35.5.5 35.2.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an exported function returns an unpacked struct, which is not a permitted DPI result type
:expected_stderr_regex: test_illegal_dpi_export_struct_result\.sv:(39|45):
*/
// IEEE 1800-2023 §35.7: an exported function has to meet the restrictions
// on argument and result types that apply to imported functions, and
// exporting one that does not is an error. §35.5.5 and §35.2.2: the result
// of a DPI function is restricted to small values (void, byte, shortint,
// int, longint, real, shortreal, chandle, string and scalar bit and logic),
// for exported functions as for imported ones.
//
// sv_sum returns an int and is exported legally. sv_pair returns the
// unpacked struct pair_t, so its export declaration is an error. A tool can
// report it at the export declaration or at the header of the function, so
// both lines are accepted. Without that export declaration the design is
// legal: sv_pair stays an ordinary SystemVerilog function.
//
// Icarus Verilog 13.0 has no DPI and no unpacked structs, and it rejects
// both export declarations as syntax errors, so its error does not count.
// The 5.054 release of Verilator reports the struct result of sv_pair as a
// result type that a DPI function may not have.

module test_illegal_dpi_export_struct_result;
  typedef struct {
    int lo;
    int hi;
  } pair_t;

  export "DPI-C" function sv_sum;
  export "DPI-C" function sv_pair;

  function int sv_sum(input int a, input int b);
    return a + b;
  endfunction

  function pair_t sv_pair(input int v);
    pair_t p;
    p.lo = v;
    p.hi = v + 1;
    return p;
  endfunction

  initial begin
    pair_t p;
    p = sv_pair(1);
    $display("%0d %0d %0d", p.lo, p.hi, sv_sum(2, 3));
  end
endmodule
