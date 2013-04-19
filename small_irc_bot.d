private import std.bind;
private import std.c.time;
private import std.conv;
private import std.cstream;
private import std.regexp;
private import std.socket;
private import std.socketstream;
private import std.stdio;
private import std.string;
private import std.thread;
private import std.utf;

import bot_base;

/*extern	char[][char[]] regexp_pseudo;
extern	char[][char[]] regexp_ident;
extern	char[][char[]] regexp_host; //*/

class small_irc_bot {

	private { // proprietes
		char[] host;
		ushort port;
		char[] pseudo,pseudo2;
		char[] response,response2,response3;
		char[] masterchan= "#sebbu";
		char[] temp= "";
		int pseudo_number=0;
		int buffer_size=10;
		
		debug {
			int test=0;
		}
		
		InternetHost ih;
		InternetAddress ia;
		TcpSocket sock;
		SocketStream stream;
		
		//Thread th=new Thread( bindAlias!(bot_base.really_do_nothing)(' ').ptr);
		Thread th;
		char[] regex;
		RegExp myRegExp;
		
		private {
			char[] line;
			version(buffer) {
				char[][int] lignes;
				char[][int] lignes2;
				int lignes_s=0;
				int lignes_c=0;
			}
		}
		
		public {
			bool connected=false;
		}
	}
	
	public { // constructeurs
		~this() {
			//writefln("~small_irc_bot");
			/*try {
				th.pause();
			}
			catch(ThreadError) {}*/
			//writefln("~small_irc_bot");
			writefln("test fin");
		}
		
		this() {
			writefln("vous devez specifier au moins l'adresse");
			init();
			delete this;
		}
		
		this(char[] _host,ushort _port=6667,char[] _pseudo= "sebbu-test") {
			host=_host;
			port=_port;
			pseudo=_pseudo;
			pseudo2=_pseudo;
			writefln("%s %d %s",host,port,pseudo);
			init();
		}
		
		this(char[] _host,char[] _port,char[] _pseudo= "sebbu-test") {
			host=_host;
			try {
				port=toUshort(_port);
			}
			catch(ConvError) {
				port=6667;
			}
			catch(ConvOverflowError) {
				port=6667;
			}
			pseudo=_pseudo;
			pseudo2=_pseudo;
			writefln("%s %d %s",host,port,pseudo);
			init();
		}
		
		void init() {
			version(buffer) {
				lignes.length = buffer_size*10;
			}
			//th=new Thread( bindAlias!(bot_base.really_do_nothing)(' ').ptr);
		}
	}
	
	static if(true) { //debut connection
		
		//debut send
		void send(char[] string,bool display=true,bool send=true) {
			if(send) {
				stream.writeString(string~"\n");
			}
			if(display) {
				display_s(string);
			}
		}
		//fin send
		
		//debut display_s
		void display_s(char[] line) {
			try {
				assert(line);
				validate(line);
				writefln("-> %s",line);
			}
			catch(Object o) {
				printf("-> %s\n",toStringz(line));
			}
		}
		//fin display_s
		
		//debut display_r
		void display_r(char[] line) {
			try {
				assert(line);
				validate(line);
				writefln("<- %s",line);
			}
			catch(Object o) {
				printf("<- %s\n",toStringz(line));
			}
		}
		//fin display_r
		
		//debut read
		char[] read() {
			line=stream.readLine();
			try {
				assert(line);
				validate(line);
				line=std.utf.toUTF8(line);
			}
			catch(UtfException e) {
				line=latin1_to_unicode(line);
			}
			version(buffer) {
				if(lignes.length<lignes_c) lignes.length=buffer_size*3+lignes.length;
				writefln(lignes.length);
			}
			version(buffer) {
				lignes[lignes_c][]=line;
				lignes_c++;
			}
			//writefln(line);
			return line;
		}
		//fin read
		
		//debut connect
		void connect() {
			connected=true;
			ih = new InternetHost;
			ih.getHostByName(host);
			if(ih.addrList.length<=0) {
				writefln("host not responding");
				delete this;
			}
			writefln("%d ip adress found for %s",ih.addrList.length,host);
			int cpt=0;
			bool success=false;
			while(!success&&cpt<ih.addrList.length) {
				writefln("trying to connect to %s",long2ip(cast(long)ih.addrList[cpt]));
				ia = new InternetAddress(ih.addrList[cpt], port);
				sock = new TcpSocket();
				try {
					sock.connect(ia);
					success= true;
				}
				catch(SocketException e) {
					writefln("%s isn't responding, switching to next server ( if any )",long2ip(cast(long)ih.addrList[cpt]));
					cpt++;
				}
			}
			stream = new SocketStream(sock);
			/*th=new Thread( bindAlias!(bot_base.do_nothing)(' ').ptr );
			th.setPriority(std.thread.Thread.PRIORITY.IDLE);
			th.start();
			th.wait(2000);*/
			send("PASS blabla",false,true);
			send("PASS ***",true,false);
			send("USER test test test :test");
			send("NICK "~pseudo);
			usleep(2000000);
			writefln("[SLEEP 2]");
			bool loop=true;
			while(loop) {
				
				debug { test=0; }
				read();
				//display_r(line);
				debug { writefln(++test); }
				regex=r"^:([^ ]+) 433 \S "~pseudo2~" :Nickname is already in use.$";
				myRegExp=std.regexp.search(line,regex);
				//writefln(regex);
				debug { writefln(++test); }
				if(myRegExp) {
					writefln("433");
					pseudo_number++;
					pseudo2=pseudo~(std.string.toString(pseudo_number));
					//temp=std.string.toString(pseudo_number);
					//pseudo2=pseudo~temp;
					send("NICK "~pseudo2,true,true);
				}
				debug { writefln(++test); }
				myRegExp=std.regexp.search(line,r"^:([^ ]+) 432 \S "~pseudo2~" :Erroneous Nickname: Illegal characters$");
				debug { writefln(++test); }
				if(myRegExp) {
					pseudo_number++;
					pseudo2=pseudo~std.string.toString(pseudo_number);
					//fwritef(cast(_iobuf *)pseudo2.ptr, "%s%i",pseudo,pseudo_number);
					send("NICK "~pseudo2,true,true);
				}
				debug { writefln(++test); }
				myRegExp=std.regexp.search(line, "^:([^ ]+) 451 (.+)$");
				debug { writefln(++test); }
				if(myRegExp) {
					send("USER test test test :test");
				}
				debug { writefln(++test); }
				myRegExp=std.regexp.search(line, "^:([^ ]+) NOTICE AUTH (.+)$");
				debug { writefln(++test); }
				if(myRegExp) {
					//do nothing
				}
				debug { writefln(++test); }
				myRegExp=std.regexp.search(line, "^:([^ ]+) NOTICE "~pseudo2~" :(.+)$");
				debug { writefln(++test); }
				if(myRegExp) {
					//do nothing
				}
				debug { writefln(++test); }
				myRegExp=std.regexp.search(line, "^PING :([a-zA-Z0-9_.-]+)$");
				debug { writefln(++test); }
				if(myRegExp) {
					response2=myRegExp.match(1);
					send("PONG :" ~ response2 ~ "\n");
					loop=false;
				}
				debug { writefln(++test); }
				myRegExp=std.regexp.search(line, "^ERROR :Closing Link(.*)$");
				debug { writefln(++test); }
				if(myRegExp) {
					loop=false;
					connected=false;
					return false;
				}
				debug { writefln(++test); }
				display_r(line);
			}
			after_connect();
		}
		//fin connect
		
		//debut after_connect
		void after_connect() {
			bool loop=true;
			writefln("\n\n\nafter connect starting\n\n\n");
			while(loop) {
				debug { test=0; }
				read();
				display_r(line);
				debug { writefln(++test); }
				myRegExp=std.regexp.search(line, "^PING :([a-zA-Z0-9_.-]+)$");
				debug { writefln(++test); }
				if(myRegExp) {
					response2=myRegExp.match(1);
					send("PONG :" ~ response2 ~ "\n");
					loop=false;
				}
				debug { writefln(++test); }
				myRegExp=std.regexp.search(line, "^:([^ ]+) 376 "~pseudo2~" :(.+)$");
				debug { writefln(++test); }
				if(myRegExp) {
					writefln("376");
					response= "JOIN "~masterchan~"\n";
					send(response,true,true);
				}
				debug { writefln(++test); }
				if(parse_raw(line)) {
					writefln("raw parsed");
				}
				debug { writefln(++test); }
				myRegExp=std.regexp.search(line, "^:([^ ]+) JOIN :"~masterchan~"(.*)$");
				debug { writefln(++test); }
				if(myRegExp) {
					response= "PRIVMSG "~masterchan~" :connection successfully\n";
					send(response,true,true);
				}
				debug { writefln(++test); }
				myRegExp=std.regexp.search(line, "^:([^ ]+) 366 "~pseudo2~" "~masterchan~" (.+)$");
				debug { writefln(++test); }
				if(myRegExp) {
					loop=false;
				}
				debug { writefln(++test); }
			}
			writefln("after connect ending");
		}
		//fin after_connect
		
	} //fin connection
	
	static if(true) { //parse
		
		//debut eval
		bool eval(char[] ligne) {
			bool result=parse(ligne);
			return result;
			return false;
		}
		//fin eval
		
		//debut parse
		bool parse(char[] ligne) {
			debug { test=0; }
			debug { writefln(++test); }
			if(parse_ping(ligne)) {
				writefln("ping parsed");
				version(buffer) lignes_s++;
				return true;
			}
			debug { writefln(++test); }
			if(std.regexp.search(ligne, "^ERROR :Closing Link (.*)$")) {
				connected=false;
				return false;
			}
			debug { writefln(++test); }
			if(parse_raw(ligne)) {
				writefln("raw parsed");
				version(buffer) lignes_s++;
				return true;
			}
			debug { writefln(++test); }
			if(parse_privmsg(ligne)) {
				writefln("privmsg parsed");
				version(buffer) lignes_s++;
				return true;
			}
			debug { writefln(++test); }
			if(parse_commands(ligne)) {
				writefln("command parsed");
				version(buffer) lignes_s++;
				return true;
			}
			debug { writefln(++test); }
			return false;
		}
		//fin parse
		
		//debut parse_raw
		bool parse_raw(char[] ligne) {
			debug { test=0; }
			debug { writefln(++test); }
			myRegExp=std.regexp.search(ligne,r"^:([^!]+)\!([^@]+)@([^ ]+) JOIN :?([&#][^ ]+)$");
			debug { writefln(++test); }
			if(myRegExp) {
				char[] salon=myRegExp.match(4);
				bool good=true;
				debug { writefln("%s%d", "parsing !quit : ",test+1); }
				if( std.regexp.search(myRegExp.match(1),regexp_pseudo["sebbu-test"]) && std.regexp.search(myRegExp.match(2),regexp_ident["sebbu-test"]) && std.regexp.search(myRegExp.match(3),regexp_host["sebbu-test"]) ) {
					writef("good mask\n");
				}
				else good=false;
				if( RegExp(regexp_pseudo["sebbu-test"]).test(myRegExp.match(1))!=0 ) writefln("good nick"); else good=false;
				if( RegExp(regexp_ident["sebbu-test"]).test(myRegExp.match(2))!=0 ) writefln("good ident"); else good=false;
				if( RegExp(regexp_host["sebbu-test"]).test(myRegExp.match(3))!=0 ) writefln("good host"); else good=false; //*/
				if(good) {
					// je vient de joindre un salon, je charge les commandes & access
					load_access(host,salon);
					load_command(host,salon);
				}
				else {
					// c'est qqun d'autre
				}
				return true;
			}
			return false;
		}
		//fin parse_raw
		
		//debut parse_ping
		bool parse_ping(char[] ligne) {
			debug { test=0; }
			writefln("parse_ping 1");
			debug { writefln(++test); }
			myRegExp=std.regexp.search(ligne, "^PING :([a-zA-Z0-9_.-]+)$");
			debug { writefln(++test); }
			if(myRegExp) {
				writefln("parse_ping 2");
				response2=myRegExp.match(1);
				send("PONG :" ~ response2 ~ "\n");
				return true;
			}
			debug { writefln(++test); }
			return false;
		}
		//fin parse_ping
		
		//debut parse_privmsg
		bool parse_privmsg(char[] ligne) {
			
			debug { test=0; }
			
			debug { writefln(++test); }
			myRegExp=std.regexp.search(line,r"^:([^!]+)!([^@]+)@([^ ]+) PRIVMSG ([#&][^ ]+) :\?quit$");
			debug { writefln(++test); }
			// je le quitte manuellement
			if(myRegExp) {
				writefln("!quit parsed");
				bool good=true;
				debug { writefln("%s%d", "parsing !quit : ",test+1); }
				if( std.regexp.search(myRegExp.match(1),regexp_pseudo["sebbu"]) && std.regexp.search(myRegExp.match(2),regexp_ident["sebbu"]) && std.regexp.search(myRegExp.match(3),regexp_host["sebbu"]) ) {
					writef("good mask\n");
				}
				else good=false;
				debug { writefln("%s%d", "parsing !quit : ",test+2); }
				if(good) {
					response= "QUIT :bye\n";
					send(response);
				}
				else {
					response2=myRegExp.match(4);
					response= "PRIVMSG " ~ response2 ~ " :nice try !\n";
					send(response);
				}
				debug { writefln("%s%d", "parsing !quit : ",test+3); }
				return true;
			}
			debug { writefln(++test); }
			myRegExp=std.regexp.search(line,r"^:([^!]+)!([^@]+)@([^ ]+) PRIVMSG ([#&][^ ]+) :\?quit (.+)$");
			debug { writefln(++test); }
			// je le quitte manuellement avec une raison
			if(myRegExp) {
				writefln("!quit parsed");
				bool good=true;
				debug { writefln("%s%d", "parsing !quit : ",test+1); }
				if( std.regexp.search(myRegExp.match(1),regexp_pseudo["sebbu"]) && std.regexp.search(myRegExp.match(2),regexp_ident["sebbu"]) && std.regexp.search(myRegExp.match(3),regexp_host["sebbu"]) ) {
					writef("good mask\n");
				}
				else good=false;
				debug { writefln("%s%d", "parsing !quit : ",test+2); }
				if(good) {
					response= "QUIT :"~myRegExp.match(5)~"\n";
					send(response);
				}
				else {
					response2=myRegExp.match(4);
					response= "PRIVMSG " ~ response2 ~ " :nice try !\n";
					send(response);
				}
				debug { writefln("%s%d", "parsing !quit : ",test+3); }
				return true;
			}
			debug { writefln(++test); }
			myRegExp=std.regexp.search(line,r"^:([^!]+)!([^@]+)@([^ ]+) PRIVMSG ([#&][^ ]+) :\?say (.+)$");
			debug { writefln(++test); }
			// je le fait parler
			if(myRegExp) {
				bool good=true;
				if( RegExp(regexp_pseudo["sebbu"]).test(myRegExp.match(1))!=0 && RegExp(regexp_ident["sebbu"]).test(myRegExp.match(2))!=0 && RegExp(regexp_host["sebbu"]).test(myRegExp.match(3))!=0 ) {
					writef("good mask\n");
				}
				else good=false; //*/
				if(good) {
					response2=myRegExp.match(4);
					response3=myRegExp.match(5);
					response= "PRIVMSG " ~ response2 ~ " :" ~ response3 ~ "\n";
					send(response);
				}
				else {
					response2=myRegExp.match(4);
					response= "PRIVMSG " ~ response2 ~ " :nice try !\n";
					send(response);
				}
				return true;
			}
			debug { writefln(++test); }
			myRegExp=std.regexp.search(line,r"^:([^!]+)!([^@]+)@([^ ]+) PRIVMSG ([#&][^ ]+) :\?act (.+)$");
			debug { writefln(++test); }
			// je le fait agir
			if(myRegExp) {
				bool good=true;
				if( RegExp(regexp_pseudo["sebbu"]).test(myRegExp.match(1))!=0 && RegExp(regexp_ident["sebbu"]).test(myRegExp.match(2))!=0 && RegExp(regexp_host["sebbu"]).test(myRegExp.match(3))!=0 ) {
					writef("good mask\n");
				}
				else good=false; //*/
				if(good) {
					response2=myRegExp.match(4);
					response3=myRegExp.match(5);
					response= "PRIVMSG " ~ response2 ~ " :\1ACTION " ~ response3 ~ "\1\n";
					send(response);
				}
				else {
					response2=myRegExp.match(4);
					response= "PRIVMSG " ~ response2 ~ " :nice try !\n";
					send(response);
				}
				return true;
			}
			debug { writefln(++test); }
			myRegExp=std.regexp.search(line,r"^:([^!]+)!([^@]+)@([^ ]+) PRIVMSG ([#&][^ ]+) :\?raw (.+)$");
			debug { writefln(++test); }
			// je le fait agir
			if(myRegExp) {
				bool good=true;
				if( RegExp(regexp_pseudo["sebbu"]).test(myRegExp.match(1))!=0 && RegExp(regexp_ident["sebbu"]).test(myRegExp.match(2))!=0 && RegExp(regexp_host["sebbu"]).test(myRegExp.match(3))!=0 ) {
					writef("good mask\n");
				}
				else good=false; //*/
				if(good) {
					response2=myRegExp.match(4);
					response3=myRegExp.match(5);
					//response= "PRIVMSG " ~ response2 ~ " :\1ACTION " ~ response3 ~ "\1\n";
					response=response3~"\r\n";
					send(response);
				}
				else {
					response2=myRegExp.match(4);
					response= "PRIVMSG " ~ response2 ~ " :nice try !\n";
					send(response);
				}
				return true;
			}
			debug { writefln(++test); }
			myRegExp=std.regexp.search(line,r"^:([^!]+)!([^@]+)@([^ ]+) INVITE ([^ ]+) :([#&][^ ]+)$");
			debug { writefln(++test); }
			// je le fait rejoindre un salon
			if(myRegExp) {
				bool good=true;
				if( RegExp(regexp_pseudo["sebbu"]).test(myRegExp.match(1))!=0 && RegExp(regexp_ident["sebbu"]).test(myRegExp.match(2))!=0 && RegExp(regexp_host["sebbu"]).test(myRegExp.match(3))!=0 ) {
					writef("good mask\n");
				}
				else good=false;
				if(good) {
					response2=myRegExp.match(5);
					response= "JOIN " ~ response2 ~ "\n";
					send(response);
				}
				else {
					response2=myRegExp.match(4);
					response= "PRIVMSG " ~ response2 ~ " :nice try !\n";
					send(response);
				}
				return true;
			}
			/*debug { writefln(++test); }
			myRegExp=std.regexp.search(line,r"^:([^!]+)!([^@]+)@([^ ]+) PRIVMSG ([&#][^ ]+) :\?yield$");
			debug { writefln(++test); }
			// yield ( inutile )
			if(myRegExp) {
				bool good=true;
				if( RegExp(regexp_pseudo["sebbu"]).test(myRegExp.match(1))!=0 && RegExp(regexp_ident["sebbu"]).test(myRegExp.match(2))!=0 && RegExp(regexp_host["sebbu"]).test(myRegExp.match(3))!=0 ) {
					writef("good mask\n");
				}
				else good=false;
				if(good) {
					Thread.yield();
					response2=myRegExp.match(4);
					response= "PRIVMSG " ~ response2 ~ " :yield completed !\n";
					send(response);
				}
				else {
					response2=myRegExp.match(4);
					response= "PRIVMSG " ~ response2 ~ " :nice try !\n";
					send(response);
				}
				return true;
			}
			debug { writefln(++test); }*/
			debug { writefln(++test); }
			myRegExp=std.regexp.search(line,r"^:([^!]+)!([^@]+)@([^ ]+) PRIVMSG ([&#][^ ]+) :\?init$");
			debug { writefln(++test); }
			// yield ( inutile )
			if(myRegExp) {
				bool good=true;
				if( RegExp(regexp_pseudo["sebbu"]).test(myRegExp.match(1))!=0 && RegExp(regexp_ident["sebbu"]).test(myRegExp.match(2))!=0 && RegExp(regexp_host["sebbu"]).test(myRegExp.match(3))!=0 ) {
					writef("good mask\n");
				}
				else good=false;
				if(good) {
					//Thread.yield();
					response2=myRegExp.match(4);
					replace_access ( host, response2, "admin", response2);
					writefln("added %s as password for %s on %s@%s",response2, "admin", response2, host);
					response= "PRIVMSG " ~ response2 ~ " :init completed !\n";
					send(response);
				}
				else {
					response2=myRegExp.match(4);
					response= "PRIVMSG " ~ response2 ~ " :nice try !\n";
					send(response);
				}
				return true;
			}
			debug { writefln(++test); }
			myRegExp=std.regexp.search(line,r"^:([^!]+)!([^@]+)@([^ ]+) PRIVMSG ([&#][^ ]+) :\?ip$");
			debug { writefln(++test); }
			// yield ( inutile )
			if(myRegExp) {
				bool good=true;
				if( RegExp(regexp_pseudo["sebbu"]).test(myRegExp.match(1))!=0 && RegExp(regexp_ident["sebbu"]).test(myRegExp.match(2))!=0 && RegExp(regexp_host["sebbu"]).test(myRegExp.match(3))!=0 ) {
					writef("good mask\n");
				}
				else good=false;
				if(good) {
					response2=myRegExp.match(4);
					response3=get_ip();
					response= "PRIVMSG " ~ response2 ~ " :"~response3~ "\n";
					send(response);
					return true;
				}
				else {
					response2=myRegExp.match(4);
					response= "PRIVMSG " ~ response2 ~ " :nice try !\n";
					send(response);
				}
				return true;
			}
			debug { writefln(++test); }
			myRegExp=std.regexp.search(line,r"^:([^!]+)!([^@]+)@([^ ]+) PRIVMSG ([^ ]+) ?:(.+)DCC CHAT( \w+) (\d+) (\d+)(.+)$");
			debug { writefln(++test); }
			// je le dcc chat
			if(myRegExp) {
				if( (cast(ushort)myRegExp.match(5)[0]) == (cast(ushort)myRegExp.match(9)[0]) && (cast(ushort)myRegExp.match(5)[0]) == 1 ) {
					writefln("dcc chat parsed");
				}
				else {
					writefln("bad dcc chat founded");
					return false;
				}
				char[] ip=long2ip(std.conv.toLong(myRegExp.match(7)));
				ushort port=std.conv.toUshort(myRegExp.match(8));
				writefln("%s %d",ip,port);
				//if(dcc_chats[host][myRegExp.match(1)].getState()==Thread.TS.INITIAL) {
				if( (host in dcc_chats)==null || (myRegExp.match(1) in dcc_chats[host])==null || dcc_chats[host][myRegExp.match(1)].getState()==Thread.TS.TERMINATED ) {
					if((host in dcc_chats)==null) dcc_chats[host]=null;
					dcc_chats[host][myRegExp.match(1)]=new Thread( bindAlias!(dcc_chat.dcc_chat)(host,ip,port).ptr );
					dcc_chats[host][myRegExp.match(1)].start();
				}
				else {
					response=r""~ "NOTICE "~myRegExp.match(1)~ " :Vous avez deja un DCC chat en cours.\r\n";
					send(response);
				}
				return true;
			}
			debug { writefln(++test); }
			myRegExp=std.regexp.search(line,r"^:([^!]+)!([^@]+)@([^ ]+) PRIVMSG ([&#][^ ]+) ?:\?dcc$");
			debug { writefln(++test); }
			// je lui demande un dcc chat
			if(myRegExp) {
				/*bool good=true;
				if( RegExp(regexp_pseudo["sebbu"]).test(myRegExp.match(1))!=0 && RegExp(regexp_ident["sebbu"]).test(myRegExp.match(2))!=0 && RegExp(regexp_host["sebbu"]).test(myRegExp.match(3))!=0 ) {
					writef("good mask\n");
				}
				else {
					writef("bad mask\n");
					good=false;
				}
				if(!good) return false;*/
				if( (host in dcc_chats)==null || (myRegExp.match(1) in dcc_chats[host])==null || dcc_chats[host][myRegExp.match(1)].getState()==Thread.TS.TERMINATED ) {
					int dcc_port=11000;
					int _test=-2; //-2
					char[] _host= "127.0.0.1";
					//char[] _host=InternetAddress.ADDR_ANY;
					InternetHost _ih;
					InternetAddress _ia;
					Socket _sock,_sock2;
					SocketStream _stream;
					_sock=new Socket (AddressFamily.INET, SocketType.STREAM, ProtocolType.IP);
					writefln(++_test); //-1
					_sock.blocking(true);
					writefln(++_test); //0
					_sock.setOption (std.socket.SocketOptionLevel.SOCKET, SocketOption.REUSEADDR,false);
					writefln(++_test); //1
					/*_ih = new InternetHost;
					writefln(++_test); //2
					_ih.getHostByName(_host);
					writefln(++_test); //3
					//_ia = new InternetAddress(_ih.addrList[0], InternetAddress.PORT_ANY);
					_ia = new InternetAddress(_ih.addrList[0], dcc_port);*/
					_ia = new InternetAddress ( InternetAddress.ADDR_ANY, dcc_port );
					writefln(++_test); //4
					bool succeeded= false;
					while(!succeeded) {
						try {
							_sock.bind(_ia);
							succeeded= true;
						}
						catch (SocketException)  {
							_ia=null;dcc_port++;
							_ia = new InternetAddress( InternetAddress.ADDR_ANY, dcc_port);
							if(dcc_port>12000) {
								response=r""~ "PRIVMSG "~myRegExp.match(4)~ " :error\r\n";
								send(response);
								return true;
							}
							//return false;
						}
					}
					writefln(++_test); //5
					_sock.listen(10);
					writefln(++_test); //6
					writefln("test");
					//response=r""~ "PRIVMSG "~myRegExp.match(1)~ " :\1DCC CHAT chat "~ std.string.toString(ip2long(_host))~ " "~std.string.toString(dcc_port)~ "\1\r\n";
					_sock.blocking(false);
					//_sock2=_sock.accept();
					response=r""~ "PRIVMSG "~myRegExp.match(1)~ " :\1DCC CHAT chat "~ std.string.toString(ip2long(ip))~ " "~std.string.toString(dcc_port)~ "\1\r\n";
					send(response);
					usleep(500000);
					long time2=std.date.getUTCtime();
					show(time2);
					//_sock2=_sock.accept();
					long time=std.date.getUTCtime()+20*1000;
					succeeded= false;
					while(!succeeded&&time>time2) {
						try { //*/
							_sock2=_sock.accept();
							succeeded= true;
						}
						catch(SocketAcceptException e) {
							time2=std.date.getUTCtime();
							/*show(time2);
							writefln("small_irc_bot : "~ std.string.toString(__LINE__));*/
							usleep(500000);
						}
					}
					if(time<std.date.getUTCtime()) {
						writefln("small_irc_bot : "~ std.string.toString(__LINE__)~ " : dcc chat non accepté ");
						return true;
					} //*/
					_sock2.blocking(true);
					//_sock.blocking(false);
					/*while(!success&&(std.date.getUTCtime()<time)) {
						try {
							success=true;
							_sock2=_sock.accept();
						}
						catch(SocketAcceptException e) {
							success=false;
						}
					}*/
					//_sock.blocking(true);
					writefln(++_test); //7
					_stream=new SocketStream(_sock2);
					//char[] ip=long2ip(std.conv.toLong(myRegExp.match(7)));
					char[] ip=host;
					char[] salon=myRegExp.match(4);
					char[] nick=myRegExp.match(1);
					ushort port=dcc_port;
					writefln("%s %d",ip,port);
					//if(dcc_chats[host]!=null&&dcc_chats[host][myRegExp.match(1)]==null) {
					//if( (host in dcc_chats)==null || (myRegExp.match(1) in dcc_chats[host])==null ) {
					if((host in dcc_chats)==null) dcc_chats[host]=null;
					dcc_chats[host][myRegExp.match(1)]=new Thread( bindAlias!(dcc_chat.dcc_chat3)(host,salon,nick,_sock,_stream,ip,port).ptr );
					dcc_chats[host][myRegExp.match(1)].start();
				} //*/
				else {
					response=r""~ "PRIVMSG "~myRegExp.match(4)~ " :Vous avez deja un DCC chat en cours.\r\n";
					send(response);
				}
				return true;
			}
			debug { writefln(++test); }
				/*if( RegExp(regexp_pseudo["sebbu"]).test(myRegExp.match(1))!=0 ) writefln("good nick"); else good=false;
				if( RegExp(regexp_ident["sebbu"]).test(myRegExp.match(2))!=0 ) writefln("good ident"); else good=false;
				if( RegExp(regexp_host["sebbu"]).test(myRegExp.match(3))!=0 ) writefln("good host"); else good=false; //*/
			return false;
		}
		//fin parse_privmsg
		
		//debut parse_commands
		bool parse_commands(char[] ligne) {
			debug { test=0; }
			debug { writefln(++test); }
			myRegExp=std.regexp.search(ligne,r"^:([^!]+)\!([^@]+)@([^ ]+) PRIVMSG ([&#][^ ]+) :\!(\S+ ?)( \S+.*)?$");
			debug { writefln(++test); }
			if(myRegExp) {
				char[] salon=myRegExp.match(4);
				char[] commande=myRegExp.match(5);
				if(commande[length-1..$]== " ") commande=commande[0..length-1];
				writefln(__LINE__);
				try {
					assert(commande);
					writefln(__LINE__);
					validate(commande);
					writefln(__LINE__);
					commande=std.utf.toUTF8(commande);
					writefln(__LINE__);
				}
				catch(UtfException e) {
					line=latin1_to_unicode(line);
				}
				writefln(__LINE__);
				writefln(commande);
				writefln(__LINE__);
				writefln("'%s' '%s'",myRegExp.match(4),myRegExp.match(5));
				writefln("debut commandes %d",__LINE__);
				if( (host in commandes)!=null && (salon in commandes[host])!=null && (commande in commandes[host][salon])!=null ) {
					Tuple!(char[], int,char[])[int] commande_list=*(commande in commandes[host][salon]);
					int count=0;
					foreach( Tuple!(char[], int, char[]) test_; commande_list) {
						count++;
						char[] commande_1=test_.value[0];
						int args=test_.value[1];
						char[] arg;
						writefln(args);
						writefln("length : %d %d",myRegExp.match(6).length,test_.value[2].length);
						if( args==0 && myRegExp.match(6).length>1 ) {
							writefln(__LINE__);
							//arg=myRegExp.match(6)[1..length];
							arg=std.string.join(std.string.split(commande_1)[1..length], " ");
						}
						else if( args==1 && ( myRegExp.match(6).length==0 || myRegExp.match(6)== " " ) ) {
							writefln(__LINE__);
							arg=std.string.join(std.string.split(commande_1)[1..length], " ");
						}
						else if( args==1 && ( myRegExp.match(6).length>1 && test_.value[2].length>0 ) ) {
							writefln(__LINE__);
							commande_1=test_.value[2];
							arg=std.string.join(std.string.split(commande_1)[1..length], " ");
						}
						else if( args==2 && ( myRegExp.match(6).length==0 || myRegExp.match(6)== " " ) ) {
							arg=std.string.join(std.string.split(commande_1)[1..length], " ");
						}
						else {
							writefln("argument expected or bad mode for command on line "~ std.string.toString(__LINE__)~ " from small_irc_bot.");
							return true;
						}
						
						arg=replace(arg, "{NICK}",myRegExp.match(1));
						arg=replace(arg, "{CHAN}",myRegExp.match(4));
						if(myRegExp.match(6).length>=1) arg=replace(arg, "{ARGS}",myRegExp.match(6)[1..length]);
						else arg=replace(arg, "{ARGS}", "");
						if(myRegExp.match(6).length>=1) arg=replace(arg, " {_ARGS_} ",myRegExp.match(6)[1..length]);
						else arg=replace(arg, " {_ARGS_} ", "");
						if(myRegExp.match(6).length>=1) arg=replace(arg, " {_ARGS}",myRegExp.match(6)[1..length]);
						else arg=replace(arg, " {_ARGS}", "" );
						if(myRegExp.match(6).length>=1) arg=replace(arg, "{ARGS_} ",myRegExp.match(6)[1..length]);
						else arg=replace(arg, "{ARGS_} ", "");
						writefln(__LINE__);
						if( arg.length == 0 || arg == " " ) {
							writefln("argument expected or bad mode for command on line "~ std.string.toString(__LINE__)~ " from small_irc_bot.");
							return true;
						}
						if(std.string.split(commande_1)[0]== "act") {
							writefln(__LINE__);
							send("PRIVMSG "~salon~ " :\1ACTION "~arg~ "\1\r\n");
						}
						else if(std.string.split(commande_1)[0]== "notice") {
							writefln(__LINE__);
							send("NOTICE "~salon~ " :"~arg~ "\r\n");
						}
						else if(std.string.split(commande_1)[0]== "say") {
							writefln(__LINE__);
							send("PRIVMSG "~salon~ " :"~arg~ "\r\n");
						}
						else if(std.string.split(commande_1)[0]== "ctcp") {
							writefln(__LINE__);
							send("PRIVMSG "~salon~ " :\1"~arg~ "\1\r\n");
						}
						else if(std.string.split(commande_1)[0]== "raw") {
							writefln(__LINE__);
							send(arg~ "\r\n");
						}
						writefln(__LINE__);
						//send("PRIVMSG "~salon~ " :commande "~std.string.toString(count)~ " traitee"~ "\r\n");
					}
					writefln(__LINE__);
					return true;
				}
				else {
					// la commande n'a pas ete trouvee
					writefln(__LINE__);
				}
				writefln(__LINE__);
				return true;
			}
			writefln("parse_commands finished without found any matches.");
			return false;
		}
		//fin parse_commands
		
	}
	
}
