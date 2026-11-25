  wire [7:0] primary_value, supplemental_value;
  primary_cell selected(primary_value);
  supplemental_cell supplemental(supplemental_value);
  initial #1 $display("selected=%0d supplemental=%0d", primary_value, supplemental_value);
