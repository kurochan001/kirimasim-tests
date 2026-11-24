/*
:name: test_vcd_selection_can_cross_processes_in_the_same_nonzero_time_slot
:description: Two processes add signals to one VCD selection at the same nonzero time
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.1.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vcd_selection_can_cross_processes_in_the_same_nonzero_time_slot.expected
*/
`timescale 1ns/1ns
module test_vcd_selection_can_cross_processes_in_the_same_nonzero_time_slot;
  bit first_pin, second_pin, unrelated_pin, selected_first;

  initial begin
    $dumpfile("same_time.vcd");
    #3 $dumpvars(0, first_pin);
    selected_first = 1;
  end

  initial begin
    int fd, size;
    bit first_found, second_found, unrelated_found;
    string word, kind, code, signal_name;
    wait (selected_first);
    $dumpvars(0, second_pin);
    #1;
    first_pin = 1;
    second_pin = 1;
    unrelated_pin = 1;
    #1 $dumpflush;
    fd = $fopen("same_time.vcd", "r");
    if (fd == 0)
      $fatal(1, "waveform file could not be read");
    while ($fscanf(fd, "%s", word) == 1 && word != "$enddefinitions") begin
      if (word == "$var" && $fscanf(fd, "%s %d %s %s", kind, size, code, signal_name) == 4) begin
        first_found |= signal_name == "first_pin";
        second_found |= signal_name == "second_pin";
        unrelated_found |= signal_name == "unrelated_pin";
      end
    end
    $fclose(fd);
    $display("first=%0d second=%0d unrelated=%0d",
             first_found, second_found, unrelated_found);
  end
endmodule
