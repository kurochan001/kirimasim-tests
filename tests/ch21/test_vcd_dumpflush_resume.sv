/*
:name: test_vcd_dumpflush_resume
:description: $dumpflush empties the file so a later read sees the changes made so far, and dumping then continues without losing a value change (IEEE 1800-2023 Section 21.7.1.6)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.1.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vcd_dumpflush_resume.expected
*/
// IEEE 1800-2023 §21.7.1.6: $dumpflush empties the operating-system buffer
// of the VCD file so that the data can be read during the simulation, and
// then dumping continues as before, so no value change is lost. The test
// changes first at time 10, flushes, and reads the file; then it changes
// second at time 20, flushes again and reads the whole file again. The
// second read must still hold the change at time 10 and add the one at
// time 20.

`timescale 1ns/1ns

module test_vcd_dumpflush_resume;
  logic [3:0] first = 4'h1;
  logic [3:0] second = 4'h2;

  task automatic scan(int phase);
    int fd, at = -1, value;
    string token, kind, size, code, reference, digits, id;
    string first_code = "", second_code = "";
    bit first_change = 0, second_change = 0;

    fd = $fopen("flush.vcd", "r");
    if (fd == 0) $fatal(1, "the file is not readable after the flush");
    while ($fscanf(fd, "%s", token) == 1) begin
      if (token == "$var") begin
        void'($fscanf(fd, "%s %s %s %s", kind, size, code, reference));
        if (reference == "first") first_code = code;
        if (reference == "second") second_code = code;
        do void'($fscanf(fd, "%s", token)); while (token != "$end");
      end else if (token == "$date" || token == "$version" || token == "$timescale" ||
                   token == "$scope" || token == "$upscope" || token == "$comment" ||
                   token == "$enddefinitions") begin
        do void'($fscanf(fd, "%s", token)); while (token != "$end");
      end else if (token.substr(0, 0) == "#") begin
        digits = token.substr(1, token.len() - 1);
        at = digits.atoi();
      end else if (token.substr(0, 0) == "b" || token.substr(0, 0) == "B") begin
        void'($fscanf(fd, "%s", id));
        digits = token.substr(1, token.len() - 1);
        void'($sscanf(digits, "%b", value));
        if (id == first_code && at == 10) first_change = (value === 4'h3);
        if (id == second_code && at == 30) second_change = (value === 4'h4);
      end
    end
    $fclose(fd);
    if (phase == 1) begin
      $display("the change before the first flush is in the file: %0d", first_change);
      $display("the later change is not yet in the file: %0d", !second_change);
    end else begin
      $display("the earlier change survives the second flush: %0d", first_change);
      $display("dumping continues and the new change is in the file: %0d",
               second_change);
    end
  endtask

  initial begin
    $dumpfile("flush.vcd");
    $dumpvars(0, test_vcd_dumpflush_resume);
    #10 first = 4'h3;
    #10 $dumpflush;
    scan(1);
    #10 second = 4'h4;
    #10 $dumpflush;
    scan(2);
  end
endmodule
