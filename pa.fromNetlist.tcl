
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name InspirationalPong -dir "C:/Users/djtran/InspirationalPong/planAhead_run_1" -part xc6slx16csg324-3
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "C:/Users/djtran/InspirationalPong/vga_display.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/Users/djtran/InspirationalPong} }
set_property target_constrs_file "vga_display.ucf" [current_fileset -constrset]
add_files [list {vga_display.ucf}] -fileset [get_property constrset [current_run]]
link_design
