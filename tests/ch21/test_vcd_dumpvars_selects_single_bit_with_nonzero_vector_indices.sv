/*
:name: test_vcd_dumpvars_selects_single_bit_with_nonzero_vector_indices
:description: An individually dumped vector bit appears as a scalar and ignores changes to neighboring bits
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.2.3 21.7.1.2
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_vcd_dumpvars_selects_single_bit_with_nonzero_vector_indices.expected
*/
`timescale 1ns/1ns
module test_vcd_dumpvars_selects_single_bit_with_nonzero_vector_indices;
  logic [5:2] value;
  wire [5:2] bus = value;

  initial begin
    int fd, width, declarations, narrow, changes_high, changes_low;
    string word, kind, id_code, signal_name, selected_code, vector_code;
    value = '0;
    $dumpfile("one_bit.vcd");
    $dumpvars(0, bus[4]);
    #2 value[5] = 1;
    #2 value[4] = 1;
    #2 value[3] = 1;
    #2 value[4] = 0;
    #2 $dumpflush;
    fd = $fopen("one_bit.vcd", "r");
    if (fd == 0)
      $fatal(1, "could not open selected-bit waveform");

    while ($fscanf(fd, "%s", word) == 1 && word != "$enddefinitions") begin
      if (word == "$var" &&
          $fscanf(fd, "%s %d %s %s", kind, width, id_code, signal_name) == 4) begin
        declarations++;
        if (width == 1) begin
          narrow++;
          selected_code = id_code;
        end
      end
    end

    while ($fscanf(fd, "%s", word) == 1) begin
      if (word == {"1", selected_code})
        changes_high++;
      else if (word == {"0", selected_code})
        changes_low++;
      else if ((word == "b0" || word == "b1") && $fscanf(fd, "%s", vector_code) == 1) begin
        if (vector_code == selected_code) begin
          changes_high += word == "b1";
          changes_low += word == "b0";
        end
      end
    end
    $fclose(fd);
    $display("declarations=%0d scalar=%0d high=%0d low=%0d",
             declarations, narrow, changes_high, changes_low);
  end
endmodule
