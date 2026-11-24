/*
:name: test_uwire_padded_port_connection_warns
:description: A port with an unresolved net warns when its width conversion prevents the nets from merging
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.2 23.3.3.1 23.3.3.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_uwire_padded_port_connection_warns.expected
:expected_stderr_regex: (?im)^[^\n]*(?:\bwarn(?:ing)?\b[^\n]*\b(?:port_n|padded_child|uwire|unresolved|unidriver)\b|\b(?:port_n|padded_child|uwire|unresolved|unidriver)\b[^\n]*\bwarn(?:ing)?\b)
*/
module uwire_padded_input(input uwire [1:0] port_n, output wire [1:0] observed);
  assign observed = port_n;
endmodule

module test_uwire_padded_port_connection_warns;
  uwire source;
  wire [1:0] padded, matching;
  wire [1:0] same_width;

  assign source = 1'b1;
  assign same_width = 2'b10;
  // The upper input bit is supplied by zero extension, so the connection
  // cannot merge these two whole nets into one.
  uwire_padded_input padded_child(source, padded);
  uwire_padded_input matching_child(same_width, matching);
  initial begin
    #1;
    $display("padded=%b matching=%b", padded, matching);
  end
endmodule
