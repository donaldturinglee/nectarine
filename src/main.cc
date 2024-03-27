#include "nectarine.h"

using namespace nectarine;

int main(int argc, char* argv[]) {

	Server server(6379);
	server.start();

	return 0;
}
