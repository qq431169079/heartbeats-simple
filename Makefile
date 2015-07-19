CXX = /usr/bin/gcc
CXXFLAGS = -fPIC -Wall -Wno-unknown-pragmas -Iinc -O6
DBG = -g
LDFLAGS = -shared

BINDIR = ./bin
LIBDIR = ./lib
INCDIR = ./inc
SRCDIR = ./src
EXADIR = ./example
ROOTS = hb-pow-example
BINS = $(ROOTS:%=$(BINDIR)/%)
OBJS = $(ROOTS:%=$(BINDIR)/%.o)

all: $(BINDIR) $(LIBDIR) $(LIBDIR)/libhbs.so $(LIBDIR)/libhbs-acc.so $(LIBDIR)/libhbs-pow.so $(LIBDIR)/libhbs-acc-pow.so $(BINS)

$(BINDIR):
	-mkdir -p $(BINDIR)

$(LIBDIR):
	-mkdir -p $(LIBDIR)

$(BINDIR)/%.o : $(EXADIR)/%.c
	$(CXX) -c $(CXXFLAGS) $(DBG) -o $@ $<

$(BINS) : $(OBJS)

$(BINS) : % : %.o
	$(CXX) $(CXXFLAGS) -o $@ $< -Llib -lhbs-pow

$(LIBDIR)/libhbs.so: $(SRCDIR)/hb.c $(SRCDIR)/hb-util.c $(SRCDIR)/hb-pow-util.c
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -Wl,-soname,$(@F) -o $@ $^

$(LIBDIR)/libhbs-acc.so: $(SRCDIR)/hb.c $(SRCDIR)/hb-util.c $(SRCDIR)/hb-acc-util.c
	$(CXX) $(CXXFLAGS) -DHEARTBEAT_MODE_ACC -DHEARTBEAT_USE_ACC $(LDFLAGS) -Wl,-soname,$(@F) -o $@ $^

$(LIBDIR)/libhbs-pow.so: $(SRCDIR)/hb.c $(SRCDIR)/hb-util.c $(SRCDIR)/hb-pow-util.c
	$(CXX) $(CXXFLAGS) -DHEARTBEAT_MODE_POW -DHEARTBEAT_USE_POW $(LDFLAGS) -Wl,-soname,$(@F) -o $@ $^

$(LIBDIR)/libhbs-acc-pow.so: $(SRCDIR)/hb.c $(SRCDIR)/hb-util.c $(SRCDIR)/hb-acc-util.c $(SRCDIR)/hb-pow-util.c
	$(CXX) $(CXXFLAGS) -DHEARTBEAT_MODE_ACC_POW -DHEARTBEAT_USE_ACC -DHEARTBEAT_USE_POW $(LDFLAGS) -Wl,-soname,$(@F) -o $@ $^

# Installation
install: all
	install -m 0644 $(LIBDIR)/*.so /usr/local/lib/
	mkdir -p /usr/local/include/heartbeats-simple
	install -m 0644 $(INCDIR)/* /usr/local/include/heartbeats-simple/

uninstall:
	rm -f /usr/local/lib/libhbs-*.so
	rm -rf /usr/local/include/heartbeats-simple/

## cleaning
clean:
	-rm -rf $(LIBDIR) $(BINDIR) *.log *~
