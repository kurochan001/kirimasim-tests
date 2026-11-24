/*
:name: test_legacy_dpi_open_array_copies_multichunk_elements
:description: Legacy DPI copies both chunks of selected open-array elements through caller storage
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6.1 I.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_legacy_dpi_open_array_copies_multichunk_elements.expected
:dpi_c: @test_legacy_dpi_open_array_copies_multichunk_elements.c
*/
module test_legacy_dpi_open_array_copies_multichunk_elements;
  import "DPI" function void legacy_open_array_transfer(
    inout bit [44:0] flags[][], inout logic [44:0] atoms[][]
  );

  bit [44:0] flags[4:5][-3:-1];
  logic [44:0] atoms[5:4][-1:-3];

  initial begin
    flags[5][-2] = 45'h1234_89ab_cdef;
    flags[4][-1] = 45'h0567_0123_4567;
    atoms[5][-2] = 45'h1x0z_89ab_cdef;
    atoms[4][-1] = 45'h0567_abxz_4567;
    legacy_open_array_transfer(flags, atoms);

    $display("first writes bit=%012h logic=%012h", flags[4][-3], atoms[4][-3]);
    $display("other writes bit=%012h logic=%012h", flags[5][-1], atoms[5][-1]);
    $display("untouched bit=%012h logic=%012h", flags[5][-2], atoms[5][-2]);
  end
endmodule
