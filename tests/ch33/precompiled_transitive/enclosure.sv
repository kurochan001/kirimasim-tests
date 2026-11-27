module phase_enclosure(output wire [7:0] west_value, east_value);
  phase_worker west(.value(west_value));
  phase_worker east(.value(east_value));
endmodule
