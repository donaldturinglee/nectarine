#ifndef SERVER_H
#define SERVER_H

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>
#include <iostream>
#include <string>

#define ISVALIDSOCKET(s) ((s) >= 0)
#define SOCKET int

namespace nectarine {

class Server {
public:
	Server(SOCKET port) : port_(port) {}
	~Server() {
		close(socket_server_);
	}
	void start() {
		create_socket();
		bind_socket();
		listen_for_connections();
		accept_connections();
	}
private:
	int port_;
	SOCKET socket_server_;
	
	void create_socket() {
		socket_server_ = socket(AF_INET, SOCK_STREAM, 0);
		if(!ISVALIDSOCKET(socket_server_)) {
			std::cerr << "socket() failed.\n";
			return;
		}
	}
	
	void bind_socket() {
		struct sockaddr_in server_addr;
		server_addr.sin_family = AF_INET;
		server_addr.sin_addr.s_addr = INADDR_ANY;
		server_addr.sin_port = htons(port_);
		if(bind(socket_server_, (struct sockaddr*) &server_addr,      
     sizeof(server_addr))) {
			std::cerr << "bind() failed.\n";
			return;
		}
	}

	void listen_for_connections() {
		if(listen(socket_server_, SOMAXCONN) < 0) {
			std::cerr << "listen() failed.\n";
			return;
		}
	}

	void accept_connections() {
		struct sockaddr_storage client_addr;
		socklen_t client_len = sizeof(client_addr);
		std::cout << "Waiting for a client to connect...\n";
		while(true) {
			SOCKET socket_client = accept(socket_server_, (struct sockaddr*) &client_addr, &client_len);
			if(socket_client < 0) {
				std::cerr << "accept() failed.\n";
				break;
			}
			handle_connection(socket_client);
		}
	}

	void handle_connection(int socket_client) {
		char buffer[1024];
		int bytes_received = recv(socket_client, buffer, 1024, 0);
		if(bytes_received <= 0) {
			return;
		}
		std::string response;
		send(socket_client, response.c_str(), response.size(), 0);
		close(socket_client);
	}
};

} // namespace nectarine

#endif // SERVER_H
