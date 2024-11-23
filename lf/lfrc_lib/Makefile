# "Namespace" for lf-language library commands.
# Note, lf-language allows ':' in identifiers.
NAMESPACE = LFRC::

BUILD_DIR = build
SRC_DIR = .
SRCS = $(wildcard $(SRC_DIR)/*.lf)
OBJS = $(patsubst $(SRC_DIR)/%.lf, $(BUILD_DIR)/%.lfo, $(SRCS))
LIB = $(BUILD_DIR)/lfrc_lib.lfso

# "Compile" a .lf file to a .lfo file.
$(BUILD_DIR)/%.lfo: $(SRC_DIR)/%.lf
	@printf "Compiling %s\n" $@
	@cp $< $@
	@# Namespace declared commands.
	@sed -r -i 's/^cmd ([^\s]+)/cmd '"$(NAMESPACE)"'\1/' $@

# Create the .lfso library.
$(LIB): $(OBJS)
	@printf "Building %s\n" $@
	@>$@
	@echo "# NOTE: This file is auto-generated. Do not edit." >> $@
	@for lfo in $^ ; do \
	    printf 'source %s\n' "$$(realpath $$lfo)" >> $@ ; \
	done

clean:
	rm -rf $(wildcard $(BUILD_DIR)/*)

default: $(LIB)

.PHONY: default clean
