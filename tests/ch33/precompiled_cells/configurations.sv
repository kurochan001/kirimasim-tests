config precompiled_crossed;
  design work.test_config_precompiled_cells;
  instance test_config_precompiled_cells.west use cellsLib.phase_worker;
  instance test_config_precompiled_cells.east use cellsLib.phase_worker;
  instance test_config_precompiled_cells.west.implementation use eastLib.phase_leaf;
  instance test_config_precompiled_cells.east.implementation use westLib.phase_leaf;
endconfig

config precompiled_local;
  design work.test_config_precompiled_cells;
  instance test_config_precompiled_cells.west use cellsLib.phase_worker;
  instance test_config_precompiled_cells.east use cellsLib.phase_worker;
  instance test_config_precompiled_cells.west.implementation use westLib.phase_leaf;
  instance test_config_precompiled_cells.east.implementation use eastLib.phase_leaf;
endconfig
