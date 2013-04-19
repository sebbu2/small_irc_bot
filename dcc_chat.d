private import std.bind;
private import std.conv;
private import std.c.stdlib;
private import std.cstream;
private import std.regexp;
private import std.socket;
private import std.socketstream;
private import std.stdio;
private import std.string;
private import std.thread;
private import std.utf;

import bot_base;

int thread2 (int test) {
	
	writefln("1: Start");
	return 0;
}

int dcc_chat(char[] serv, char[] ip, ushort port) {
	/* declarations */
	int result=0;
	InternetHost ih;
	InternetAddress ia;
	TcpSocket sock;
	SocketStream stream;
	/* code */
	ih = new InternetHost;
	ih.getHostByName(ip);
	if(ih.addrList.length<=0) {
		writefln("host not responding");
		return 1;
	}
	ia = new InternetAddress(ih.addrList[0], port);
	sock = new TcpSocket();
	sock.connect(ia);
	stream = new SocketStream(sock);
	stream.writeString("DCC CHAT accepte ( !quit pour le quitter )\r\n");
	writefln("DCC CHAT accepte");
	//Thread.yield();
	int count=5;
	char[] salon,login,password;
	bool succeeded=false;
	while(--count>=0&&sock.isAlive()) {
		stream.writeString("salon :\r\n");
		salon=stream.readLine();
		if(!sock.isAlive()) return 1;
		if( (serv in access)!=null && (salon in access[serv])!=null) {
			stream.writeString("login :\r\n");
			login=stream.readLine();
			if( (login in access[serv][salon])!=null) {
				stream.writeString("password :\r\n");
				password=stream.readLine();
				if(access[serv][salon][login]==password) {
					succeeded=true;count=0;
				}
				else {
					stream.writeString("mauvais mot de passe, plus que "~std.string.toString(count)~ " essais\r\n");
				}
			}
			else {
				stream.writeString("Vous n'avez pas d'access a ce salon, veuillez demander a un admin pour en avoir un ( "~std.string.toString(count)~ " essais restant(s) ).\r\n");
			}
		}
		else {
			stream.writeString("Ce salon n'a pas encore d'access de defini, veuillez demander a un admin pour en avoir un ( "~std.string.toString(count)~ " essais restant(s) ).\r\n");
		}
		Thread.yield();
	}
	if(succeeded) {
		stream.writeString("tentative de login reussie...\r\n");
		result=dcc_chat_final(serv,salon,login,sock,stream,ip,port);
	}
	else {
		result=1;
		stream.writeString("tentative de login echouee...\r\n");
	}
	stream.close();
	sock.close();
	return result;
}

int dcc_chat2(char[] serv, char[] salon, char[] login, char[] ip, ushort port) {
	/* declarations */
	int result=0;
	InternetHost ih;
	InternetAddress ia;
	TcpSocket sock;
	SocketStream stream;
	/* code */
	ih = new InternetHost;
	ih.getHostByName(ip);
	if(ih.addrList.length<=0) {
		writefln("host not responding");
		return 1;
	}
	ia = new InternetAddress(ih.addrList[0], port);
	sock = new TcpSocket();
	sock.connect(ia);
	stream = new SocketStream(sock);
	stream.writeString("DCC CHAT accepte ( !quit pour le quitter )\r\n");
	writefln("DCC CHAT accepte");
	//Thread.yield();
	int count=5;
	char[] password;
	bool succeeded=false;
	while(--count>=0&&sock.isAlive()) {
		stream.writeString("login :\r\n");
		login=stream.readLine();
		if( (serv in access)!=null && (salon in access[serv])!=null && (login in access[serv][salon])!=null ) {
			stream.writeString("password :\r\n");
			password=stream.readLine();
			writefln("testing %s as password for %s on %s@%s",password,login,salon,serv);
			if( access[serv][salon][login]==password) {
				succeeded=true;count=0;
			}
			else {
				stream.writeString("mauvais mot de passe, plus que "~std.string.toString(count)~ " essais\r\n");
			}
		}
		else {
			stream.writeString("mauvais login, plus que "~std.string.toString(count)~ " essais\r\n");
		}
		Thread.yield();
	}
	if(succeeded) {
		stream.writeString("tentative de login reussie...\r\n");
		result=dcc_chat_final(serv,salon,login,sock,stream,ip,port);
	}
	else {
		result=1;
		stream.writeString("tentative de login echouee...\r\n");
	}
	stream.close();
	sock.close();
	return result;
}

int dcc_chat3(char[] serv, char[] salon, char[] login, Socket sock, SocketStream stream, char[] ip, ushort port) {
	/* declarations */
	int result=0;
	stream.writeString("DCC CHAT accepte ( !quit pour le quitter )\r\n");
	writefln("DCC CHAT accepte");
	//Thread.yield();
	int count=5;
	char[] password;
	bool succeeded=false;
	while(--count>=0&&sock.isAlive()) {
		stream.writeString("login :\r\n");
		login=stream.readLine();
		if( (serv in access)!=null && (salon in access[serv])!=null && (login in access[serv][salon])!=null ) {
			stream.writeString("password :\r\n");
			password=stream.readLine();
			writefln("testing %s as password for %s on %s@%s",password,login,salon,serv);
			if( access[serv][salon][login]==password) {
				succeeded=true;count=0;
			}
			else {
				stream.writeString("mauvais mot de passe, plus que "~std.string.toString(count)~ " essais\r\n");
			}
		}
		else {
			stream.writeString("mauvais login, plus que "~std.string.toString(count)~ " essais\r\n");
		}
		Thread.yield();
	}
	if(succeeded) {
		stream.writeString("tentative de login reussie...\r\n");
		result=dcc_chat_final(serv,salon,login,sock,stream,ip,port);
	}
	else {
		result=1;
		stream.writeString("tentative de login echouee...\r\n");
	}
	stream.close();
	sock.close();
	return result;
}

/*
$ctcp=$me=chr(1);$bold=chr(2);$color=chr(3);$fin=chr(15);$reverse=chr(22);$underline=chr(31);
*/

/*
blabla
*/

int dcc_chat_final(char[] serv, char[] chan, char[] nick, Socket sock, SocketStream stream, char[] ip, ushort port) {
	char[] line="";
	stream.writeString("bienvenue sur l'administration du salon "~chan~"\r\n");
	stream.writeString("tapez !help pour l'aide\r\n");
	while(sock.isAlive()&&line!="!quit") {
		line=stream.readLine();
		try {
			assert(line);
			validate(line);
			line=std.utf.toUTF8(line);
		}
		catch(UtfException e) {
			line=latin1_to_unicode(line);
		}
    catch(Exception e) {
      writefln(e.toString());
    }
		if( line == "!help" ) {
			stream.writeString("Les commandes sont :\r\n");
			stream.writeString("!addaccess nick password ==> ajoute un access\r\n");
			stream.writeString("!addcommand commande index : cmd : arg : cmd2 ==> ajoute une commande ( arg : 0=> obligatoire 1=> arg facultatif 2=> interdit)\r\n");
			stream.writeString("!addcommand commande index : cmd : arg ==> ajoute une commande ( arg : 0=> obligatoire 1=> arg facultatif 2=> interdit)\r\n");
			stream.writeString("!delcommand commande index ==> supprime une commande\r\n");
			stream.writeString("!delcommand commande ==> supprime une commande\r\n");
			stream.writeString("!delcommand ==> supprime toutes les commandes\r\n");
			stream.writeString("!listcommand [full] ==> liste toutes les commandes\r\n");
			stream.writeString("!addaccess pseudo password ==> ajoute un access\r\n");
			stream.writeString("!listaccess ==> liste tous les access\r\n");
			stream.writeString("!delaccess pseudo ==> supprime un access\r\n");
			stream.writeString("!delaccess ==> supprime tout les access\r\n");
			stream.writeString("!saveaccess ==> sauvegarde les access\r\n");
			stream.writeString("!loadaccess ==> charge les access\r\n");
			stream.writeString("!savecommand ==> sauvegarde les commandes\r\n");
			stream.writeString("!loadcommand ==> charge les commandes\r\n");
			stream.writeString("!help ==> vous êtes \2déjà\2 ici\r\n");
			stream.writeString("!helpurl ==> aide online\r\n");
			stream.writeString("!quit ==> ferme le dcc chat\r\n");
		}
		else if( line == "!helpurl" ) {
			stream.writeString("http://ayumifr.free.fr/D/small_irc_bot/aide%20Triggers.htm\r\n");
		}
		else if( line.length>= 12 && line[0..12]== "!savecommand" ) {
			if( (serv in commandes) == null ) commandes[serv]= null;
			if( (chan in commandes[serv]) == null ) commandes[serv][chan]= null;
			bool result=save_command(serv,chan);
			if(result) stream.writeString("Commandes sauvegardées avec succès.\r\n");
			else stream.writeString("Echec de la sauvegarde des commandes.\r\n");
		}
		else if( line.length>= 12 && line[0..12]== "!loadcommand" ) {
			bool result=load_command(serv,chan);
			if(result) stream.writeString("Commandes chargées avec succès.\r\n");
			else stream.writeString("Echec du chargement des commandes.\r\n");
		}
		else if( line.length>= 11 && line[0..11]== "!saveaccess" ) {
			if( (serv in access) == null ) access[serv]= null;
			if( (chan in access[serv]) == null ) access[serv][chan]= null;
			bool result=save_access(serv,chan);
			if(result) stream.writeString("Access sauvegardés avec succès.\r\n");
			else stream.writeString("Echec de la sauvegarde des access.\r\n");
		}
		else if( line.length>= 11 && line[0..11]== "!loadaccess" ) {
			bool result=load_access(serv,chan);
			if(result) stream.writeString("Access chargés avec succès.\r\n");
			else stream.writeString("Echec du chargement des access.\r\n");
		}
		else if( line.length >= 10 && line[0..10] == "!addaccess" ) {
			auto myRegExp=std.regexp.search(line,r"^!addaccess (\S+) (\S+)$");
			if(myRegExp) {
				bool result=add_access(serv,chan,myRegExp.match(1),myRegExp.match(2));
				if(result) {
					stream.writeString("Access ajouté avec succès.\r\n");
					save_access(serv,chan);
				}
				else stream.writeString("Echec de l'ajout de l'access.\r\n");
			}
			else {
				stream.writeString("Syntaxe incorrecte.\r\n");
			}
		}
		else if( line.length == 11 && line[0..11]== "!delcommand" ) {
			bool result=del_command(serv,chan);
			if(result) {
				stream.writeString("Commandes supprimées avec succès.\r\n");
				save_command(serv,chan);
			}
			else stream.writeString("Echec de la suppresion des commandes.\r\n");
		}
		else if( line.length == 10 && line[0..10]== "!delaccess" ) {
			bool result=del_access(serv,chan);
			if(result) {
				stream.writeString("Access supprimé avec succès.\r\n");
				save_access(serv,chan);
			}
			else stream.writeString("Echec de la suppresion de l'access.\r\n");
		}
		else if( line.length >= 10 && line[0..10] == "!delaccess" ) {
			bool syntax=false;
			auto myRegExp=std.regexp.search(line,r"^!delaccess (\S+)$");
			if(myRegExp) {
				bool result=del_access(serv,chan,myRegExp.match(1));
				if(result) {
					stream.writeString("Access supprimé avec succès.\r\n");
					save_access(serv,chan);
				}
				else stream.writeString("Echec de la suppresion de l'access.\r\n");
				syntax=true;
			}
			if(!syntax) {
				stream.writeString("Syntaxe incorrecte.\r\n");
			}
		}
        else if( line.length >= 11 && line[0..11] == "!listaccess" ) {
			bool syntax=false;
			auto myRegExp=std.regexp.search(line,r"^!listaccess ?(full)?$");
			if(myRegExp) {
				syntax= true;
				if( (serv in access)==null || (chan in access[serv])==null || access[serv][chan].length==0  ) {
                    stream.writeString("aucun access pour l'instant\r\n");
                    continue;
                }
				bool full=(myRegExp.match(1)=="full");
				full= false;
                foreach(char[] str;list_access(serv, chan, full)) {
                    stream.writeString(str~ "\r\n");
                }
				syntax=true;
			}
			if(!syntax) {
				stream.writeString("Syntaxe incorrecte.\r\n");
			}
		}
		else if( line.length >= 12 && line[0..12] == "!listcommand" ) {
			bool syntax=false;
			auto myRegExp=std.regexp.search(line,r"^!listcommand ?(full)?$");
			if(myRegExp) {
				syntax= true;
				if( (serv in commandes)==null || (chan in commandes[serv])==null || commandes[serv][chan].length==0 ) {
                    stream.writeString("aucune commandes pour l'instant\r\n");
                    continue;
                }
				bool full=(myRegExp.match(1)=="full");
                foreach(char[] str;list_command(serv, chan, full)) {
                    stream.writeString(str~ "\r\n");
                }
				syntax=true;
			}
			if(!syntax) {
				stream.writeString("Syntaxe incorrecte.\r\n");
			}
		}
		else if( line.length >= 11 && line[0..11] == "!addcommand" ) {
			auto myRegExp=std.regexp.search(line,r"^!addcommand (\S+) ([0-9]+) : (.+) : ([0-2]) : (.+)$");
			if(myRegExp) {
				bool result=add_command(serv,chan,myRegExp.match(1),std.conv.toInt(myRegExp.match(2)),myRegExp.match(3),std.conv.toInt(myRegExp.match(4)),myRegExp.match(5));
				if(result) {
					stream.writeString("Commande ajouté avec succès.\r\n");
					save_command(serv,chan);
				}
				else stream.writeString("Echec de l'ajout de la commande.\r\n");
			}
			else {
				myRegExp=std.regexp.search(line,r"^!addcommand (\S+) ([0-9]+) : (.+) : ([0-2])$");
				if(myRegExp) {
					bool result=add_command(serv,chan,myRegExp.match(1),std.conv.toInt(myRegExp.match(2)),myRegExp.match(3),std.conv.toInt(myRegExp.match(4)), "");
					if(result) {
						stream.writeString("Commande ajouté avec succès.\r\n");
						save_command(serv,chan);
					}
					else stream.writeString("Echec de l'ajout de la commande.\r\n");
				}
				else stream.writeString("Syntaxe incorrecte.\r\n");
			}
		}
		else if( line.length >= 11 && line[0..11] == "!delcommand" ) {
			auto myRegExp=std.regexp.search(line,r"^!delcommand (\S+) ([0-9]+)$");
			if(myRegExp) {
				bool result=del_command(serv,chan,myRegExp.match(1),std.conv.toInt(myRegExp.match(2)));
				if(result) {
					stream.writeString("Commande supprimée avec succès.\r\n");
					save_command(serv,chan);
				}
				else stream.writeString("Echec de la suppression de la commande.\r\n");
			}
			else {
				myRegExp=std.regexp.search(line,r"^!delcommand (\S+)$");
				if(myRegExp) {
					bool result=del_command(serv,chan,myRegExp.match(1));
					if(result) {
						stream.writeString("Commande supprimée avec succès.\r\n");
						save_command(serv,chan);
					}
					else stream.writeString("Echec de la suppression de la commande.\r\n");
				}
				else {
					stream.writeString("Syntaxe incorrecte.\r\n");
				}
			}
		}
		else if( line == "!quit") {
			stream.writeString("Au revoir.\r\n");
		}
		else if( line.length >= 1 && line[0] != '!' ) {
			stream.writeString("respond to "~line~ "\r\n");
		}
		else {
			writefln("test\r\n");
			writefln("taille : '%d'",line.length);
			stream.writeString("commande "~line~" inconnue\r\n");
		}
	}
	stream.close();
	sock.close();
	return 0;
}
