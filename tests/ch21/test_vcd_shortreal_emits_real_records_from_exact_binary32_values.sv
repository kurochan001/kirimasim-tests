/*
:name: test_vcd_shortreal_emits_real_records_from_exact_binary32_values
:description: A shortreal variable emits real-format VCD records for exact binary32 values
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.5 21.7.2.1 20.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vcd_shortreal_emits_real_records_from_exact_binary32_values.expected
*/
`timescale 1ns/1ns
module test_vcd_shortreal_emits_real_records_from_exact_binary32_values;
  localparam string FILE = "single_precision.vcd";
  shortreal sample = 0.0;

  task automatic verify_trace();
    int fd, tick = 0;
    bit definitions_done = 0;
    string word, kind, width_text, id, name, sample_id;
    fd = $fopen(FILE, "r");
    if (fd == 0) begin
      $display("missing VCD");
      return;
    end

    while ($fscanf(fd, "%s", word) == 1) begin
      if (word == "$enddefinitions") definitions_done = 1;
      else if (word == "$var" && !definitions_done) begin
        if ($fscanf(fd, "%s %s %s %s", kind, width_text, id, name) != 4) break;
        if (name == "sample") begin
          sample_id = id;
          $display("shortreal type=%s", kind);
        end
      end else if (definitions_done && word[0] == "#") begin
        void'($sscanf(word, "#%d", tick));
      end else if (definitions_done && word[0] == "r") begin
        if ($fscanf(fd, "%s", id) != 1) break;
        if (sample_id != "" && id == sample_id)
          $display("at %0d value=%s", tick, word.substr(1, word.len()-1));
      end
    end
    $fclose(fd);
  endtask

  initial begin
    $dumpfile(FILE);
    $dumpvars(0, sample);
    #2 sample = $bitstoshortreal(32'h3f9e0652);
    #3 sample = $bitstoshortreal(32'hb5800001);
    #5 sample = $bitstoshortreal(32'hc0400001);
    #3 $dumpflush;
    verify_trace();
    $finish(0);
  end
endmodule
