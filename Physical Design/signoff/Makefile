.PHONY = clean 

DEFAULT_FILES 	:= .gitignore .git Makefile README.md cds.lib 

.ONESHELL:

help:
	@echo "> Makefile Targets:"
	# 										# use spaces instead of tabs here to prevent weird spacing stuff
	@printf '%b\n' "clean:     removes non-default files."
	@printf '%b\n' "virtuoso:  launches virtuoso with the library file specified."

clean:
	@echo "Cleaning up non-default files..."
	@find . -maxdepth 1 ! -path . \
		$(foreach item,$(DEFAULT_FILES),! -name "$(item)")	-exec rm -rf {} +
	@echo "Cleanup complete."

virtuoso:
	@if [ -z $(ENV_SETUP) ]; then
		@echo "ERROR: Please enter the SJapr shell using the envsetup file in SJapr."
		@exit
	@fi
	echo "Launching Virtuoso. This will take ~30 seconds."
	tcsh -c "virtuoso -cdslib cds.lib -nocdsinit" &> /dev/null &
