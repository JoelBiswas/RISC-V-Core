.PHONY = clean setdefault archive restore purge flow syn apr lean

ARCHIVE_ROOT 				:= archives
FLOW_DEFAULT_FILES 	:= archives envsetup .git .gitignore .gitmodules inputs Makefile README.md resources scripts tapeouts TODOs outputs

.ONESHELL:

help:
	@echo "# Makefile Targets:"
	# 										# use spaces instead of tabs here to prevent weird spacing stuff
	@printf '%b\n' "clean:      removes non-default flow files."
	@printf '%b\n' "setdefault: sets the files currently in the directory as flow default"
	@printf '%b\n' "nondefault: previews nondefault flow files. useful to preview what 'clean' will remove."
	@printf ''
	@printf '%b\n' "archive:    moves flow output files to an archive folder."
	@printf '%b\n' "restore:    restores an archive to the working directory."
	@printf '%b\n' "purge:      purges the archives folder."

clean:
	@echo "Cleaning up non-default files..."
	@find . -maxdepth 1 ! -path . \
		$(foreach item,$(FLOW_DEFAULT_FILES),! -name "$(item)")	-exec rm -rf {} +
	
	## whatever survived is an NFS silly-rename (.nfsXXXX)
	## we need to kill the processes holding them open, then delete again
	@find . -maxdepth 1 ! -path . \
		$(foreach item,$(FLOW_DEFAULT_FILES),! -name "$(item)") \
		-exec fuser -k -KILL {} + 2>/dev/null || true
	@find . -maxdepth 1 ! -path . \
		$(foreach item,$(FLOW_DEFAULT_FILES),! -name "$(item)") -exec rm -rf {} +

	@echo "Cleanup complete."

setdefault:
	sed -i '4s|^FLOW_DEFAULT_FILES[[:space:]]*:=.*|FLOW_DEFAULT_FILES \t:= $(shell ls -A)|' Makefile

tidy:
	@find . -maxdepth 1 ! -path . \
		$(foreach item,$(FLOW_DEFAULT_FILES),! -name "$(item)") -exec echo {} +

# archives nondefault files
archive:
	@if [ -z "$(NAME)" ]; then 
		echo "Error: You must provide a name for this archive's folder." 
		echo " " 
		echo "Usage: make archive NAME=archive_name" 
	elif [ -d "$(ARCHIVE_ROOT)/$(NAME)" ]; then 
		echo "Error: $(ARCHIVE_ROOT)/$(NAME)/ already exists. Try again with a different NAME." 
	else 
		echo "=> Creating directory $(ARCHIVE_ROOT)/$(NAME)/ ..." 
		mkdir -p $(ARCHIVE_ROOT)/$(NAME)/ 
		echo "=> Copying flow outputs to $(ARCHIVE_ROOT)/$(NAME)/ ..." 
		rsync -av $(foreach x,$(FLOW_DEFAULT_FILES),--exclude='$(x)') . $(ARCHIVE_ROOT)/$(NAME)/ 
		echo "=> Archive complete." 
	fi

# restores an archive to the working directory. great for running from a specific flowstep!
restore: clean
	@if [ -z "$(NAME)" ]; then
		echo "Error: You must specify an archive to pull from." 
		echo " " 
		echo "Usage: make archive NAME=archive_name" 
	elif [ ! [-d "$(ARCHIVE_ROOT)/$(NAME)"] ]; then 
		echo "Error: Couldn't find $(ARCHIVE_ROOT)/$(NAME)/. Are you sure that's the right name?" 
	else 
		echo "=> Copying flow outputs from $(ARCHIVE_ROOT)/$(NAME)/ into the working directory..." 
		rsync -av $(ARCHIVE_ROOT)/$(NAME)/ .
		echo "=> Restore complete." 
	fi

# delete all archives
purge:
	-@ rm -rf archives
