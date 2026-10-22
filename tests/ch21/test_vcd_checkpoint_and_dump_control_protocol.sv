/*
:name: test_vcd_checkpoint_and_dump_control_protocol
:description: VCD declarations checkpoints and dump controls preserve typed values and suppress disabled changes (IEEE 1800-2023 Section 21.7.1.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.1.1 21.7.1.3 21.7.1.4 21.7.1.6 21.7.2.1 21.7.2.2 21.7.2.3 21.7.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_vcd_checkpoint_and_dump_control_protocol.expected
*/
// IEEE 1800-2023 21.7.1.1 21.7.1.3 21.7.1.4 21.7.1.6 21.7.2.1 21.7.2.2 21.7.2.3
// 21.7.5: A small reader resolves generated identifier codes and timescale
// units rather than assuming either. It checks logic and int declarations,
// binary values, off/on checkpoints, dumpall, and absence of disabled changes
// or deeper scope variables.
// Oracle checks: The 5.052 release is a two-state engine and is not used as the
// oracle here.

`timescale 1ns/1ns
module depth_dump_child;
  logic hidden = 0;
endmodule
module depth_dump_payload;
  logic [3:0] vector_value = 0;
  int count_value = 2;
  logic [1:0] memory_value[2];
  depth_dump_child child();
endmodule
module test_vcd_checkpoint_and_dump_control_protocol;
  depth_dump_payload payload();
  function automatic real unit_ns(string text_value);
    if (text_value == "s") return 1e9;
    if (text_value == "ms") return 1e6;
    if (text_value == "us") return 1e3;
    if (text_value == "ns") return 1.0;
    if (text_value == "ps") return 1e-3;
    if (text_value == "fs") return 1e-6;
    return 0.0;
  endfunction
  task automatic read_dump();
    int fd, rc, width_value, declarations = 0, multiplier;
    longint current_time = 0;
    real step = 0.0;
    string token, kind, identifier, reference_name, vector_id, count_id;
    string section = "", scale_text = "", time_digits;
    logic [31:0] value;
    bit vector_header, count_header, initial_vector, initial_count;
    bit changed, off_vector, off_count, resumed, checkpoint;
    bit no_disabled_changes = 1;
    fd = $fopen("protocol.vcd", "r");
    if (fd == 0) $fatal(1, "dump file missing");
    while ($fscanf(fd, "%s", token) == 1) begin
      if (token == "$var") begin
        rc = $fscanf(fd, "%s %d %s %s", kind, width_value, identifier, reference_name);
        if (rc != 4) $fatal(1, "malformed variable declaration");
        declarations++;
        if (reference_name == "vector_value") begin
          vector_id = identifier; vector_header = kind == "reg" && width_value == 4;
        end
        if (reference_name == "count_value") begin
          count_id = identifier; count_header = kind == "integer" && width_value == 32;
        end
        do rc = $fscanf(fd, "%s", token); while (rc == 1 && token != "$end");
      end else if (token == "$timescale") begin
        do begin
          rc = $fscanf(fd, "%s", token);
          if (rc == 1 && token != "$end") scale_text = {scale_text, token};
        end while (rc == 1 && token != "$end");
        multiplier = scale_text.atoi();
        step = multiplier * unit_ns(scale_text.substr(multiplier >= 100 ? 3 :
                                  multiplier >= 10 ? 2 : 1, scale_text.len()-1));
      end else if (token == "$date" || token == "$version" || token == "$scope" ||
                   token == "$upscope" || token == "$comment" || token == "$enddefinitions") begin
        do rc = $fscanf(fd, "%s", token); while (rc == 1 && token != "$end");
      end else if (token == "$dumpvars" || token == "$dumpoff" ||
                   token == "$dumpon" || token == "$dumpall") section = token;
      else if (token == "$end") section = "";
      else if (token[0] == 8'h23) begin
        time_digits = token.substr(1, token.len()-1);
        current_time = longint'(time_digits.atoi() * step);
      end else if (token[0] == "b" || token[0] == "B") begin
        rc = $fscanf(fd, "%s", identifier);
        if (rc != 1) $fatal(1, "missing value identifier");
        rc = $sscanf(token.substr(1, token.len()-1), "%b", value);
        if (rc != 1) $fatal(1, "malformed binary value");
        if (current_time == 3) no_disabled_changes = 0;
        if (identifier == vector_id) begin
          if (current_time == 0 && section == "$dumpvars") initial_vector = value[3:0] === 0;
          if (current_time == 1 && section == "") changed = value[3:0] === 4'd3;
          if (current_time == 2 && section == "$dumpoff") off_vector = $isunknown(value[3:0]);
          if (current_time == 4 && section == "$dumpon") resumed = value[3:0] === 4'd9;
          if (current_time == 5 && section == "$dumpall") checkpoint = value[3:0] === 4'd9;
        end
        if (identifier == count_id) begin
          if (current_time == 0 && section == "$dumpvars") initial_count = value === 32'd2;
          if (current_time == 2 && section == "$dumpoff") off_count = $isunknown(value);
        end
      end
    end
    $fclose(fd);
    $display("declarations=%0d", declarations == 2 && vector_header && count_header);
    $display("initial=%0d change=%0d", initial_vector && initial_count, changed);
    $display("off=%0d on=%0d checkpoint=%0d", off_vector && off_count, resumed, checkpoint);
    $display("disabled_changes_suppressed=%0d", no_disabled_changes);
  endtask
  initial begin
    $dumpfile("protocol.vcd"); $dumpvars(1, payload);
    #1 payload.vector_value = 3;
    #1 $dumpoff;
    #1 payload.vector_value = 9;
    #1 $dumpon;
    #1 $dumpall;
    #1 $dumpflush;
    read_dump();
  end
endmodule
