/*
:name: test_class_stream_cycle_observation
:description: Stream a class with a null link and observe the same expression after making the link cyclic
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_stream_cycle_observation.expected
*/
class stream_cycle_node;
  bit [7:0] payload;
  stream_cycle_node link;
endclass

module test_class_stream_cycle_observation;
  stream_cycle_node node;
  bit [7:0] value;

  initial begin
    node = new;
    node.payload = 8'h35;
    node.link = null;
    for (int trial = 0; trial < 2; trial++) begin
      if (trial == 1) begin
        if (!$test$plusargs("observe_cycle"))
          break;
        node.link = node;
        $display("before cyclic stream self=%0d", node.link == node);
        $fflush();
      end

      // The acyclic control checks the payload. The cyclic result is undefined.
      value = {>>{node}};
      if (trial == 0)
        $display("acyclic value=%h", value);
      else
        $display("after cyclic stream value=%h", value);
    end
    $finish(0);
  end
endmodule
