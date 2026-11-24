/*
:name: test_vcd_alias_group_tracks_shared_net_and_independent_port
:description: Two ports connected to the same net have the same waveform and an independent port keeps its own changes
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.2.3 21.7.2.2 21.7.1.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vcd_alias_group_tracks_shared_net_and_independent_port.expected
*/
`timescale 1ns/1ns
module vcd_alias_leaf(input wire watched);
endmodule

module test_vcd_alias_group_tracks_shared_net_and_independent_port;
  bit shared_drive, independent_drive;
  wire common_line = shared_drive, independent_line = independent_drive;
  vcd_alias_leaf alias_a(common_line);
  vcd_alias_leaf alias_b(common_line);
  vcd_alias_leaf separate(independent_line);

  function automatic string append_transition(input string history, token, code,
                                                input int timestamp);
    if (token == {"0", code})
      return {history, $sformatf("%0d=0 ", timestamp)};
    if (token == {"1", code})
      return {history, $sformatf("%0d=1 ", timestamp)};
    return history;
  endfunction

  task automatic inspect_dump;
    integer fd, timestamp, parsed_time;
    string item, scope_type, scope_name, data_type, symbol, reference_name;
    string first_id, second_id, separate_id, first_trace, second_trace, separate_trace;
    int width;
    bit recording;

    fd = $fopen("shared_ports.vcd", "r");
    if (!fd) $fatal(1, "cannot read VCD fixture");
    timestamp = 0;
    while ($fscanf(fd, "%s", item) == 1) begin
      if (item == "$scope") begin
        void'($fscanf(fd, "%s %s", scope_type, scope_name));
      end else if (item == "$upscope") begin
        scope_name = "";
      end else if (item == "$var") begin
        if ($fscanf(fd, "%s %d %s %s", data_type, width, symbol, reference_name) == 4 &&
            width == 1 && reference_name == "watched") begin
          if (scope_name == "alias_a") first_id = symbol;
          else if (scope_name == "alias_b") second_id = symbol;
          else if (scope_name == "separate") separate_id = symbol;
        end
      end else if (item == "$enddefinitions") begin
        recording = 1;
      end else if (recording && $sscanf(item, "#%d", parsed_time) == 1) begin
        timestamp = parsed_time;
      end else if (recording) begin
        first_trace = append_transition(first_trace, item, first_id, timestamp);
        second_trace = append_transition(second_trace, item, second_id, timestamp);
        separate_trace = append_transition(separate_trace, item, separate_id, timestamp);
      end
    end
    $fclose(fd);
    $display("declared=%b/%b/%b distinct control=%b",
             first_id != "", second_id != "", separate_id != "",
             separate_id != first_id && separate_id != second_id);
    $display("first [%s] second [%s] independent [%s]", first_trace, second_trace, separate_trace);
  endtask

  initial begin
    $dumpfile("shared_ports.vcd");
    $dumpvars(0, alias_a.watched, alias_b.watched, separate.watched);
    #5 shared_drive = 1;
    #4 independent_drive = 1;
    #3 shared_drive = 0;
    #3;
    $dumpflush;
    inspect_dump();
    $finish(0);
  end
endmodule
