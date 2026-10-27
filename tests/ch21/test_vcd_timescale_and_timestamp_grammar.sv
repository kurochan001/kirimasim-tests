/*
:name: test_vcd_timescale_and_timestamp_grammar
:description: A four-state VCD file declares its timescale with one of the numbers 1, 10 or 100 and one of the units s, ms, us, ns, ps or fs, and writes every simulation time as # followed by a decimal number; a design with a 100us time unit and precision records 100us and the times 0, 2 and 5 (IEEE 1800-2023 Section 21.7.2.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.2.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vcd_timescale_and_timestamp_grammar.expected
*/
// IEEE 1800-2023 §21.7.2.1: the $timescale declaration holds a time_number
// that is 1, 10 or 100 and a time_unit that is s, ms, us, ns, ps or fs, and
// a simulation timestamp is # followed by a decimal_number. §21.7.2.3: the
// $timescale keyword specifies the timescale used for the simulation.
//
// The design sets a time unit and precision of 100us, dumps one scalar and
// changes it at 200us and 500us. The reader takes the number and the unit of
// the $timescale section, tests the number against the three allowed values
// and the unit against the six allowed names, checks that the declared
// timescale is the 100us of the design, and checks that every timestamp is #
// with only decimal digits and that the dumped times are 0, 2 and 5. A tool
// that wrote, for example, "1.0us", "2 ns" or "#1.5" would fail one of these
// checks. The order of the other sections and the white space do not matter.

`timescale 100us/100us

module test_vcd_timescale_and_timestamp_grammar;
  logic a = 1'b0;
  int times[$];

  function automatic bit decimal(string digits);
    if (digits.len() == 0) return 0;
    for (int i = 0; i < digits.len(); i++)
      if (digits[i] < "0" || digits[i] > "9") return 0;
    return 1;
  endfunction

  task automatic read_dump();
    int fd, i = 0;
    string token, text = "", number, unit, digits;
    bit one_section = 0, number_ok = 0, unit_ok = 0, us_ok = 0;
    bit times_ok = 1, order_ok = 0;

    fd = $fopen("times.vcd", "r");
    if (fd == 0) $fatal(1, "the dump file is missing");
    while ($fscanf(fd, "%s", token) == 1) begin
      if (token == "$timescale") begin
        one_section = one_section == 0;
        text = "";
        do begin
          void'($fscanf(fd, "%s", token));
          if (token != "$end") text = {text, token};
        end while (token != "$end");
      end else if (token == "$date" || token == "$version" ||
                   token == "$comment" || token == "$scope" ||
                   token == "$upscope" || token == "$var" ||
                   token == "$enddefinitions" || token == "$dumpvars" ||
                   token == "$dumpall" || token == "$dumpoff" ||
                   token == "$dumpon" || token == "$end") begin
        do void'($fscanf(fd, "%s", token)); while (token != "$end");
      end else if (token[0] == "#") begin
        digits = token.substr(1, token.len() - 1);
        if (!decimal(digits)) times_ok = 0;
        else times.push_back(digits.atoi());
      end
    end
    $fclose(fd);
    while (i < text.len() && text[i] >= "0" && text[i] <= "9") i++;
    number = text.substr(0, i - 1);
    unit = text.substr(i, text.len() - 1);
    number_ok = number == "1" || number == "10" || number == "100";
    unit_ok = unit == "s" || unit == "ms" || unit == "us" ||
              unit == "ns" || unit == "ps" || unit == "fs";
    us_ok = number == "100" && unit == "us";
    order_ok = times.size() >= 3 && times[0] == 0 &&
               times[1] == 2 && times[2] == 5;
    $display("the file has one timescale section: %0d", one_section);
    $display("the timescale number is 1, 10 or 100: %0d", number_ok);
    $display("the timescale unit is s, ms, us, ns, ps or fs: %0d", unit_ok);
    $display("the timescale is the 100us of the design: %0d", us_ok);
    $display("every timestamp is # and a decimal number: %0d", times_ok);
    $display("the changes are at the times 0, 2 and 5: %0d", order_ok);
  endtask

  initial begin
    $dumpfile("times.vcd");
    $dumpvars(0, test_vcd_timescale_and_timestamp_grammar);
    #2 a = 1'b1;
    #3 a = 1'b0;
    #1 $dumpflush;
    read_dump();
  end
endmodule
