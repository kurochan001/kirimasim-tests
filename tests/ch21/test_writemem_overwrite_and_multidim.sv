/*
:name: test_writemem_overwrite_and_multidim
:description: $writememh replaces a file that exists instead of appending to it, and $writememh and $writememb write a multidimensional unpacked array in row-major order so that $readmemh and $readmemb read it back into a one-dimensional and a multidimensional array (IEEE 1800-2023 Sections 21.5 and 21.4.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.5 21.4.3 21.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_writemem_overwrite_and_multidim.expected
*/
// IEEE 1800-2023 §21.5: if the file exists when $writememh or $writememb is
// called, it is overwritten; there is no append mode. The file first holds six
// words 01 to 06; after $writememh of a 2-word memory, reading it into six
// words set to ee gives the two new words and leaves four ee, where an
// appended or partly overwritten file would give more words. §21.4.3: the
// $readmem and $writemem tasks work with multidimensional unpacked arrays, the
// file in row-major order with the rightmost dimension varying fastest, so
// m[0:1][0:2] reads back into a 6-word array in the order m[0][0], m[0][1],
// m[0][2], m[1][0], and so on, and into a second [0:1][0:2] array unchanged;
// the same holds for $writememb and $readmemb. The files are created in the
// current directory.

module test_writemem_overwrite_and_multidim;
  logic [7:0] two [0:1];
  logic [7:0] six [0:5];
  logic [7:0] m [0:1][0:2], m_back [0:1][0:2];
  logic [3:0] b [0:1][0:1], b_back [0:1][0:1];
  int fd;

  task automatic show_six(string what);
    $display("%s: %h %h %h %h %h %h", what, six[0], six[1], six[2], six[3], six[4], six[5]);
    foreach (six[i]) six[i] = 8'hee;
  endtask

  initial begin
    fd = $fopen("test_writemem_overwrite.mem", "w");
    $fdisplay(fd, "01 02 03 04 05 06");
    $fclose(fd);
    two = '{8'haa, 8'hbb};
    $writememh("test_writemem_overwrite.mem", two);
    foreach (six[i]) six[i] = 8'hee;
    $readmemh("test_writemem_overwrite.mem", six);
    show_six("after overwrite");

    m = '{'{8'h10, 8'h11, 8'h12}, '{8'h20, 8'h21, 8'h22}};
    $writememh("test_writemem_multidim_h.mem", m);
    $readmemh("test_writemem_multidim_h.mem", six);
    show_six("2-D written, read 1-D");
    $readmemh("test_writemem_multidim_h.mem", m_back);
    $display("2-D read back: %h %h %h / %h %h %h", m_back[0][0], m_back[0][1], m_back[0][2],
             m_back[1][0], m_back[1][1], m_back[1][2]);

    b = '{'{4'b0001, 4'b0010}, '{4'b0100, 4'b1000}};
    $writememb("test_writemem_multidim_b.mem", b);
    $readmemb("test_writemem_multidim_b.mem", b_back);
    $display("2-D binary read back: %b %b / %b %b", b_back[0][0], b_back[0][1], b_back[1][0],
             b_back[1][1]);
  end
endmodule
