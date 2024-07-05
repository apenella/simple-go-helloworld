package main

import (
	"errors"
	"fmt"
	"html/template"
	"net/http"
	"os"

	"github.com/apenella/simple-go-helloworld/release"
)

type Context struct {
	Version, Commit, Hostname string
}

func helloworld(w http.ResponseWriter, r *http.Request) {
	var hostname string
	var err error

	hostname, err = os.Hostname()
	if err != nil {
		hostname = "unknown"
	}

	context := Context{
		Version:  release.Version,
		Commit:   release.Commit,
		Hostname: hostname,
	}

	page := `
		<html>
			<head>
				<title>Simple Go Helloworld</title>
			</head>

			<style>
				.data{
					font-family: Arial;
					margin: 0 auto;
					width: 500px;
				}
				.data h1 {
					padding: 5px;
					background-color: #ff6347;
					color: white;
					text-align: center;
				}
				.data h2 {
					color: #808080;
					text-align: center;
				}
				.release {
					text-align: right;	
				}
			</style>

			<body>
				<div class="data">
					<h1>Simple Go Helloworld</h1>
					<h2>I'm {{.Hostname}}</h2>
					<div class="release">Version: {{.Version}}</div>
					<div class="release">Commit: {{.Commit}}</div>
				</div>
			</body>
		</html>
	`

	t := template.New("Simple Go Helloworld")
	t, _ = t.Parse(page)
	t.Execute(w, context)
}

func main() {

	http.HandleFunc("/", helloworld)
	err := http.ListenAndServe(":80", nil)

	if errors.Is(err, http.ErrServerClosed) {
		fmt.Printf("server closed\n")
	} else if err != nil {
		fmt.Printf("error starting server: %s\n", err)
		os.Exit(1)
	}
}
