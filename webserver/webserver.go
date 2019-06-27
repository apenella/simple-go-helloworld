package webserver

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

type Handler func(w http.ResponseWriter, r *http.Request)

type Webserver struct {
	server   *http.Server
	Handlers map[string]Handler
}

func NewWebserver(l string) *Webserver {
	router := http.NewServeMux()
	router.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	})

	server := &http.Server{
		Addr:         l,
		Handler:      router,
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  15 * time.Second,
	}

	return &Webserver{
		server:   server,
		Handlers: map[string]Handler{},
	}
}

func (w *Webserver) AddHandler(uri string, handler Handler) {
	if w.Handlers == nil {
		w.Handlers = map[string]Handler{}
	}

	w.Handlers[uri] = handler
}

func (w *Webserver) LoadHandlers() {
	for uri, handler := range w.Handlers {
		http.HandleFunc(uri, handler)
	}
}

func (w *Webserver) Start() {

	ch := make(chan os.Signal, 1)
	signal.Notify(ch, os.Interrupt, os.Kill, syscall.SIGTERM)

	go func() {
		signalType := <-ch
		signal.Stop(ch)
		fmt.Println("Exit command received. Exiting...")

		fmt.Println("Received signal type : ", signalType)

		os.Exit(0)

	}()

	w.LoadHandlers()
	log.Fatal(http.ListenAndServe(":8080", nil))
}
