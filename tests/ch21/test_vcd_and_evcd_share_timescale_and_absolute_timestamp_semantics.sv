/*
:name: test_vcd_and_evcd_share_timescale_and_absolute_timestamp_semantics
:description: Four-state and extended VCD record the same absolute change times with the shared timescale and timestamp syntax
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.3 21.7.4.1 21.7.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vcd_and_evcd_share_timescale_and_absolute_timestamp_semantics.expected
*/
`timescale 1ns/10ps

module common_dump_ports(input wire a, output wire y);
  assign y = !a;
endmodule

module test_vcd_and_evcd_share_timescale_and_absolute_timestamp_semantics;
  bit a = 0;
  wire y;
  common_dump_ports dut(a, y);

  function automatic int time_scale_fs(string text);
    int number;
    string units;
    if ($sscanf(text, "%d%s", number, units) != 2) return 0;
    if (number != 1 && number != 10 && number != 100) return 0;
    case (units)
      "fs": return number;
      "ps": return number * 1000;
      "ns": return number * 1000000;
      default: return 0;
    endcase
  endfunction

  function automatic bit decimal_digits(string token);
    if (token.len() < 2) return 0;
    for (int i = 1; i < token.len(); ++i)
      if (token[i] < "0" || token[i] > "9") return 0;
    return 1;
  endfunction

  task automatic inspect(string filename, string label_text);
    int fd = $fopen(filename, "r");
    int sections = 0, scale = 0;
    longint stamp_fs;
    string line_text, token, rest, scale_text = "";
    bit clean = 1, first = 0, second = 0;
    if (fd == 0) $fatal(1, "missing dump file %s", filename);
    while ($fscanf(fd, "%s", token) == 1) begin
      if (token == "$timescale") begin
        sections++;
        while ($fscanf(fd, "%s", token) == 1 && token != "$end")
          scale_text = {scale_text, token};
      end else if (token == "$enddefinitions") begin
        break;
      end
    end
    scale = time_scale_fs(scale_text);
    while ($fgets(line_text, fd) > 0) begin
      if ($sscanf(line_text, "%s%s", token, rest) != 1 || token[0] != "#") continue;
      if (!decimal_digits(token) || $sscanf(token, "#%d", stamp_fs) != 1) begin
        clean = 0;
        continue;
      end
      stamp_fs *= scale;
      if (stamp_fs == 70000) first = 1;
      if (stamp_fs == 180000) second = 1;
    end
    $fclose(fd);
    $display("%s scale=%b decimal=%b t70ps=%b t180ps=%b",
             label_text, sections == 1 && scale > 0, clean, first, second);
  endtask

  initial begin
    $dumpfile("four_state.vcd");
    $dumpvars(1, dut);
    $dumpports(dut, "ports.vcd");
    #0.07 a = 1;
    #0.11 a = 0;
    #0.10;
    $dumpflush;
    $dumpportsflush("ports.vcd");
    inspect("four_state.vcd", "VCD");
    inspect("ports.vcd", "EVCD");
  end
endmodule
