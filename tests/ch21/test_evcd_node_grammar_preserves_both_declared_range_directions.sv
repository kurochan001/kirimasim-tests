/*
:name: test_evcd_node_grammar_preserves_both_declared_range_directions
:description: Extended VCD node declarations identify scalar and vector ports in declaration order
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_evcd_node_grammar_preserves_both_declared_range_directions.expected
*/
`timescale 1ns/1ns
module evcd_range_node (
  input wire scalar_pin,
  input wire [2:5] ascending,
  output wire [7:4] descending
);
  assign descending = ascending ^ {4{scalar_pin}};
endmodule

module test_evcd_node_grammar_preserves_both_declared_range_directions;
  localparam string FILE_NAME = "node_ranges.evcd";
  logic scalar_pin = 0;
  logic [2:5] ascending = 4'b1010;
  wire [7:4] descending;
  evcd_range_node dut(scalar_pin, ascending, descending);

  initial begin
    int fd, count, bad, size, first_index, last_index, identifier, fields;
    string keyword, node_type, node_name, end_marker;

    $dumpports(dut, FILE_NAME);
    #1 $dumpportsflush(FILE_NAME);
    fd = $fopen(FILE_NAME, "r");
    if (fd == 0)
      $fatal(1, "could not open the extended VCD");

    count = 0;
    bad = 0;
    while ($fscanf(fd, "%s", keyword) == 1 && keyword != "$enddefinitions") begin
      if (keyword == "$var") begin
        fields = $fscanf(fd, "%s", node_type);
        bad += fields != 1 || node_type != "port";
        if (count == 0) begin
          fields = $fscanf(fd, "%d <%d %s %s", size, identifier, node_name, end_marker);
          bad += fields != 4 || size != 1 || node_name != "scalar_pin";
        end else begin
          fields = $fscanf(fd, " [%d : %d ] <%d %s %s",
                           first_index, last_index, identifier, node_name, end_marker);
          bad += fields != 5;
          case (count)
            1: bad += first_index != 2 || last_index != 5 || node_name != "ascending";
            2: bad += first_index != 7 || last_index != 4 || node_name != "descending";
            default: bad++;
          endcase
        end
        bad += (identifier != count || end_marker != "$end");
        count++;
      end
    end
    bad += keyword != "$enddefinitions";
    $fclose(fd);
    $display("ports=%0d format errors=%0d", count, bad);
  end
endmodule
