all: results/merged.gds
drc: reports/klayout_drc.rpt

results/synth.v:
	mkdir -p ./logs ./results ./reports
	yosys -c ./scripts/synth.tcl -l ./logs/yosys.log

results/global_route.def: results/synth.v
	openroad -no_init -exit ./scripts/apr.tcl | tee ./logs/apr.log

results/detail_route.def: results/global_route.def
	./utils/mergeLef.py --inputLef $(wildcard ./tech/*.lef) $(wildcard ./src/*.lef) --outputLef ./results/merged.lef
	./utils/modifyLefSpacing.py -i ./results/merged.lef -o ./results/merged.lef
	TritonRoute ./scripts/TritonRoute.param 2>&1 | tee ./logs/TritonRoute.log

results/final.def: results/detail_route.def
	openroad -no_init -exit ./scripts/finish.tcl | tee ./logs/finish.log

results/merged.gds: results/final.def
	sed -i 's,<lef-files>.*</lef-files>,$(foreach file, $(wildcard ./tech/*.lef) $(wildcard ./src/*.lef),<lef-files>$(abspath $(file))</lef-files>),g' ./tech/klayout/FreePDK45.lyt
	klayout -zz -rd design_name="RocketTile" \
	        -rd in_def=./results/final.def \
	        -rd in_gds="$(wildcard ./tech/*.gds)" \
	        -rd out_gds="./results/merged.gds" \
	        -rd tech_file=./tech/klayout/FreePDK45.lyt \
	        -rm ./utils/def2gds.py 2>&1 | tee ./logs/merge.log

reports/klayout_drc.rpt: results/merged.gds
	klayout -zz -rd in_gds="./results/merged.gds" \
	        -rd report_file="./reports/klayout_drc.rpt" \
	        -r ./tech/klayout/FreePDK45.lydrc 2>&1 | tee ./logs/drc.log

inspect:
	klayout -nn ./tech/klayout/FreePDK45.lyt ./results/merged.gds

clean:
	rm -rf ./logs ./results ./reports