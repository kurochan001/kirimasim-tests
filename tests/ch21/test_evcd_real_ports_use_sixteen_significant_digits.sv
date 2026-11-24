/*
:name: test_evcd_real_ports_use_sixteen_significant_digits
:description: Extended VCD stores real input and output changes with sixteen significant digits as in the ordinary VCD control
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.4.1 21.7.2.1 21.7.3.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_evcd_real_ports_use_sixteen_significant_digits.expected
*/
`timescale 1ns/1ns

module evcd_real_port_sample(input var real input_value, output var real output_value,
                             output bit digital);
  always @(input_value) output_value = -input_value;
  initial #8 digital = 1;
endmodule

module test_evcd_real_ports_use_sixteen_significant_digits;
  real source = 1.234567890123456;
  real result;
  wire digital;
  evcd_real_port_sample dut(source, result, digital);

  task automatic read_reals(input string filename);
    int fd, index;
    int tick = 0, count = 0;
    string line, word, kind, width_text, id, reference_name, value_text;
    string input_id, output_id;
    int ticks[3] = '{0, 5, 10};
    string input_value[3], output_value[3];

    fd = $fopen(filename, "r");
    if (fd == 0) begin
      $display("%s missing", filename);
      return;
    end

    while ($fgets(line, fd) > 0) begin
      if ($sscanf(line, "%s", word) != 1) continue;
      if (word == "$var") begin
        if ($sscanf(line, "%s %s %s %s %s", word, kind, width_text, id, reference_name) != 5)
          continue;
        if (reference_name == "input_value") input_id = id;
        if (reference_name == "output_value") output_id = id;
      end else if (word[0] == "#") begin
        if ($sscanf(word, "#%d", tick) != 1) continue;
      end else if (word[0] == "r" && $sscanf(line, "%s %s", value_text, id) == 2) begin
        if (input_id == "" || output_id == "") continue;
        for (index = 0; index < 3; index++)
          if (tick == ticks[index]) begin
            if (id == input_id) input_value[index] = value_text.substr(1, value_text.len()-1);
            if (id == output_id) output_value[index] = value_text.substr(1, value_text.len()-1);
          end
        if (id == input_id || id == output_id) count++;
      end
    end
    $fclose(fd);

    foreach (ticks[i])
      $display("%s t=%0d in=%s out=%s", filename, ticks[i], input_value[i], output_value[i]);
    $display("%s real changes=%0d", filename, count);
  endtask

  initial begin
    $dumpfile("control.vcd");
    $dumpvars(1, dut);
    $dumpports(dut, "ports.evcd");
    #5 source = 9.876543210987654e-19;
    #5 source = 0.1000000000000006;
    #3;
    $dumpflush;
    $dumpportsflush("ports.evcd");
    read_reals("control.vcd");
    read_reals("ports.evcd");
    $finish(0);
  end
endmodule
