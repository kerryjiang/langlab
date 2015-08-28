package main

import (
	"net"
	"log"
	"fmt"
	"strings"
	"bufio"
)

type FtpSession struct {
	Conn net.Conn
	Root string
}

func (s FtpSession) Process(commands map[string]FtpCommand) {
	
	s.Reply("220 Welcome to the FTP server written by Golang");
	
	reader := bufio.NewReader(s.Conn)
	
	for {
		line, err := reader.ReadString('\n')
		if err != nil {
			log.Print(err)
			s.Close()
			return
		}
		
		log.Print("CMD: ", line)
		
		var lineArray = strings.Split(strings.Trim(line, "\r\n "), " ")
		
		
		cmd := strings.ToLower(lineArray[1])
		msgs := lineArray[1:]
		
		command := commands[cmd]
		
		if command == nil {
			log.Print("Cannot find command: ", cmd)
			break
		}
		
		command.handle(s, msgs)
	}

}

func (s FtpSession) Close() {
	s.Conn.Close()
}

func (s FtpSession) Reply(msg string) {
	fmt.Fprintf(s.Conn, msg + "\r\n")
}