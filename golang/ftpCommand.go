package main

import (

)

type FtpCommand interface {
	handle(session FtpSession, args []string)
}