###############
## VARIABLES ##
###############
DEBUG 				?= 1
ENABLE_WARNINGS			?= 0

BUILD_DIR 			= build
SOURCE_DIR 			= src
INCLUDE_DIR 			= include
OBJECT_DIR			= $(BUILD_DIR)/objects
DEBUG_DIR			= $(BUILD_DIR)/debug
RELEASE_DIR			= $(BUILD_DIR)/release

ifeq ($(ENABLE_WARNINGS), 1)
	CXX_WARNINGS = pedantic-errors -Wall -Wextra -Werror
else
	CXX_WARNINGS = 
endif

# CC: Program for compiling C programs; default cc
# CXX: Program for compiling C++ programs; default g++
# CFLAGS: Extra flags to give to the C compiler
# CXXFLAGS: Extra flags to give to the C++ compiler
# CPPFLAGS: Extra flags to give to the C preprocessor
# LDFLAGS: Extra flags to give to the linker
CXX 				= g++
CXX_STANDAR 			= c++20 -pthread
CXXFLAGS 			= $(CXX_WARNINGS) --std=$(CXX_STANDAR)
CPPFLAGS 			= -I $(INCLUDE_DIR)
LDFLAGS 			= 

EXECUTABLE_NAME = nectarine

ifeq ($(DEBUG), 1)
	CXXFLAGS += -g -O0
else
	CXXFLAGS += -O3
endif

CXX_COMPILER_CALL = $(CXX) $(CXXFLAGS) $(CPPFLAGS)

CXX_SOURCES 		= $(wildcard $(SOURCE_DIR)/*.cc)
CXX_OBJECTS 		= $(patsubst $(SOURCE_DIR)/%.cc, $(OBJECT_DIR)/%.o, $(CXX_SOURCES))
CXX_DEPENDENCIES	= $(CXX_OBJECTS:.o = .d)

##############
## TARGETS  ##
##############

all: build $(BUILD_DIR)/$(EXECUTABLE_NAME)

build:
	@mkdir -p $(OBJECT_DIR)
ifeq ($(DEBUG), 1)
	@mkdir -p $(DEBUG_DIR)
else
	@mkdir -p $(RELEASE_DIR)
endif

$(BUILD_DIR)/$(EXECUTABLE_NAME): $(CXX_OBJECTS)
ifeq ($(DEBUG), 1)
	$(CXX_COMPILER_CALL) $(CXX_OBJECTS) $(LDFLAGS) -o $(DEBUG_DIR)/$(EXECUTABLE_NAME)
else
	$(CXX_COMPILER_CALL) $(CXX_OBJECTS) $(LDFLAGS) -o $(RELEASE_DIR)/$(EXECUTABLE_NAME)
endif

run:
ifeq ($(DEBUG), 1)
	@(./$(DEBUG_DIR)/$(EXECUTABLE_NAME))
else
	@(./$(RELEASE_DIR)/$(EXECUTABLE_NAME))
endif

##############
## PATTERNS ##
##############
# $@: the file name of the target
# $<: the name of the first ependency
# $^: the names of all prerequisites
$(OBJECT_DIR)/%.o: $(SOURCE_DIR)/%.cc
	$(CXX_COMPILER_CALL) -c $< -o $@

###########
## PHONY ##
###########
.PHONY: all build clean info run

clean:
	-@rm -rvf $(OBJECT_DIR)/*
	-@rm -rvf $(BUILD_DIR)/*

info:
ifeq ($(DEBUG), 1)
	@echo "[*] Application dir: ${DEBUG_DIR}	"
else
	@echo "[*] Application dir: ${RELEASE_DIR}	"
endif
	@echo "[*] Object dir: 		${OBJECT_DIR}	"
	@echo "[*] Sources dir: 	${CXX_SOURCES}	"
	@echo "[*] Objects dir: 	${CXX_OBJECTS}	"
	@echo "[*] Dependencies:    ${CXX_DEPENDENCIES}"
