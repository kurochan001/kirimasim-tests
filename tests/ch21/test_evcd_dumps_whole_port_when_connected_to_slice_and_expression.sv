/*
:name: test_evcd_dumps_whole_port_when_connected_to_slice_and_expression
:description: Extended VCD retains complete ports when connections are slices and expressions
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.4.1 21.7.4.2 21.7.3.6.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_evcd_dumps_whole_port_when_connected_to_slice_and_expression.expected
*/
`timescale 1ns/1ns
module full_port_probe(input wire [7:4] from_slice,
                       input wire [2:5] from_expression,
                       output wire [7:4] result);
  assign result = from_slice ^ from_expression;
endmodule

module test_evcd_dumps_whole_port_when_connected_to_slice_and_expression;
  logic [7:0] source = 8'ha5;
  logic [3:0] mask = 4'h3;
  wire [3:0] result;

  full_port_probe probe(source[6:3], source[3:0] + mask, result);

  task automatic report_declarations;
    int fd, matches_slice, matches_expression, matches_result, extra_ports;
    string command, token, size, name;
    fd = $fopen("whole_ports.evcd", "r");
    if (!fd) begin
      $display("no extended VCD");
      return;
    end
    {matches_slice, matches_expression, matches_result, extra_ports} = '0;
    while ($fscanf(fd, "%s", command) == 1 && command != "$enddefinitions") begin
      string parts[$];
      while ($fscanf(fd, "%s", token) == 1 && token != "$end")
        parts.push_back(token);

      if (command == "$var") begin
        int left_index, right_index;
        size = "";
        for (int i = 1; i < parts.size() && parts[i][0] != "<"; i++)
          size = {size, parts[i]};
        name = parts.size() > 0 ? parts[parts.size()-1] : "";
        if (parts.size() >= 4 && parts[0] == "port" &&
            $sscanf(size, "[%d:%d]", left_index, right_index) == 2) begin
          if (name == "from_slice" && left_index == 7 && right_index == 4)
            matches_slice++;
          else if (name == "from_expression" && left_index == 2 && right_index == 5)
            matches_expression++;
          else if (name == "result" && left_index == 7 && right_index == 4)
            matches_result++;
          else
            extra_ports++;
        end else begin
          extra_ports++;
        end
      end
    end
    $fclose(fd);
    $display("whole slice=%0d expression port=%0d result=%0d other=%0d",
             matches_slice, matches_expression, matches_result, extra_ports);
  endtask

  initial begin
    $dumpports(probe, "whole_ports.evcd");
    #2 source = 8'h62;
    #2 mask = 4'h7;
    #2 $dumpportsflush("whole_ports.evcd");
    report_declarations();
    #11 $display("design end=%0d", $time);
  end
endmodule
