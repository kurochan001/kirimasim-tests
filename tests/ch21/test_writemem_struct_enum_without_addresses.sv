/*
:name: test_writemem_struct_enum_without_addresses
:description: Memory output preserves packed struct bits and enum numerical values without address tokens for fixed arrays (IEEE 1800-2023 Section 21.5.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.5.1 21.5.2 21.5.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_writemem_struct_enum_without_addresses.expected
*/
// IEEE 1800-2023 21.5.1 21.5.2 21.5.3: Readback validates packed field order
// and enum values; scanning the output independently rejects address words that
// fixed arrays must not contain.

module test_writemem_struct_enum_without_addresses;
  typedef struct packed { bit [3:0] high; bit [3:0] low; } octet_t;
  typedef enum bit [7:0] { FIRST = 8'h11, LAST = 8'h1e } state_t;
  octet_t source_words[2];
  state_t enum_words[2];
  bit [7:0] read_words[2];
  int fd, c, at_count;
  initial begin
    source_words[0] = 8'h5a; source_words[1] = 8'hc3;
    enum_words[0] = FIRST; enum_words[1] = LAST;
    $writememh("words.hex", source_words);
    $readmemh("words.hex", read_words);
    $display("packed=%h,%h", read_words[0], read_words[1]);
    $writememh("enums.hex", enum_words);
    $readmemh("enums.hex", read_words);
    fd = $fopen("enums.hex", "r");
    if (fd == 0) $fatal(1, "open failed");
    c = $fgetc(fd);
    while (c != -1) begin
      if (c == 8'h40) at_count++;
      c = $fgetc(fd);
    end
    $fclose(fd);
    $display("enum=%h,%h address_words=%0d", read_words[0], read_words[1], at_count);
  end
endmodule
