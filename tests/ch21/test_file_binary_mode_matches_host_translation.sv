/*
:name: test_file_binary_mode_matches_host_translation
:description: Binary mode preserves file bytes and text mode follows the host
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.1 21.3.4.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_file_binary_mode_matches_host_translation.expected
:expected_exit: 0
:dpi_c: @test_file_binary_mode_matches_host_translation.c
*/
module test_file_binary_mode_matches_host_translation;
  localparam string PATH = "host-modes.bin";
  import "DPI-C" function int matches_host_mode(input string path, input string mode,
                                                input int count, input longint unsigned bytes);

  function automatic longint unsigned read_bytes(input string mode, output int count);
    longint unsigned bytes = 0;
    int fd = $fopen(PATH, mode);
    int value;
    if (fd == 0) $fatal(1, "cannot open the file in mode %s", mode);
    count = 0;
    forever begin
      value = $fgetc(fd);
      if (value < 0) break;
      count++;
      if (count > 8) break;
      bytes = (bytes << 8) | longint'(value);
    end
    $fclose(fd);
    return bytes;
  endfunction

  initial begin
    int writer, binary_count, text_count;
    longint unsigned binary_bytes, text_bytes;
    writer = $fopen(PATH, "wb");
    if (writer == 0) $fatal(1, "cannot create the binary fixture");
    $fwrite(writer, "%c%c%c%c%c%c%c%c", 65, 13, 10, 0, 26, 255, 66, 10);
    $fclose(writer);

    binary_bytes = read_bytes("rb", binary_count);
    text_bytes = read_bytes("r", text_count);
    $display("binary exact=%0d binary matches host=%0d text matches host=%0d",
             binary_count == 8 && binary_bytes == 64'h410d0a001aff420a,
             matches_host_mode(PATH, "rb", binary_count, binary_bytes),
             matches_host_mode(PATH, "r", text_count, text_bytes));
  end
endmodule
