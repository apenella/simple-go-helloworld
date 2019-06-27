package command

import (
	"fmt"
	"html/template"
	"net/http"
	"os"

	"github.com/apenella/simple-go-helloworld/release"
	"github.com/apenella/simple-go-helloworld/webserver"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

type Context struct {
	Version, Commit, Hostname string
}

var serveCmd = &cobra.Command{
	Use:   "serve",
	Short: "start web server",
	Long:  "start web server",
	RunE:  serve,
}

func init() {
	rootCmd.AddCommand(serveCmd)
}

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hi there, I love %s!", r.URL.Path[1:])
}
func handler2(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hi there, I love %s!", r.URL.Path[1:])
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

func serve(cmd *cobra.Command, args []string) error {
	fmt.Println(viper.Get("port"))

	w := webserver.NewWebserver(":8080")
	w.AddHandler("/", helloworld)
	w.AddHandler("/2", handler2)
	w.Start()

	return nil
}
