package main

import (
	"flag"
	"log"
	"net"
	"os"
	"bufio"
)

var addr = flag.String("addr", ":2121", "The addr to listen (':2121')")

var commands = map[string]FtpCommand {
	
}

func main() {
	log.SetFlags(log.LstdFlags | log.Lshortfile)

	ln, err := net.Listen("tcp", *addr)
	if err != nil {
		log.Fatal(err)
		return
	}

	wd, _ := os.Getwd()
	log.Println("working dir: ", wd)
	
	exit := make(chan bool) 

	go startAccept(ln, exit, wd)
	
	reader := bufio.NewReader(os.Stdin)
	
	for {
		data, _, _ := reader.ReadLine()
        command := string(data)
        if command == "stop" {
			exit <- true
			ln.Close()
            break;
        }
	}
	
	<-exit
	log.Println("The listener is stopped")
}

func startAccept(ln net.Listener, exit chan(bool), root string) {
	for {
		ret, ok := <-exit
		if ok && !ret  {
			conn, err := ln.Accept()
			if err != nil {
				log.Fatal(err)
			}
			
			var session = FtpSession { Conn: conn, Root: root }			
			go session.Process(commands)			
		} else {
			break
		}
	}
	
	exit <- false
}
