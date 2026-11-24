/*
:name: test_vpi_udp_table_entries_allow_only_string_and_ascii_vector
:description: Combinational and sequential UDP table rows support text and ASCII vectors and reject other value formats
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.36 38.15
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_udp_table_entries_allow_only_string_and_ascii_vector.expected
:vpi_c: @test_vpi_udp_table_entries_allow_only_string_and_ascii_vector.c
*/
primitive comb_formats (q, a, b, c);
  output q;
  input a, b, c;
  table
    1 ? 0 : 1;
  endtable
endprimitive

primitive seq_formats (q, a, b);
  output q;
  reg q;
  input a, b;
  table
    0 (01) : ? : -;
  endtable
endprimitive

module test_vpi_udp_table_entries_allow_only_string_and_ascii_vector;
  logic a = 0, b = 0, c = 0;
  wire x, y;
  comb_formats combinational(x, a, b, c);
  seq_formats sequential(y, a, b);

  initial #1 $vt_row_formats;
endmodule
